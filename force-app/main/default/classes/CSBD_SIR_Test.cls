@isTest
public with sharing class CSBD_SIR_Test {

    @TestSetup
    private static void altaDatosPrueba() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = '46979396X';
        cuenta.Phone = '666666666';
        insert cuenta;

        Contact contacto1 = new Contact();
        contacto1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto1.AccountId = cuenta.Id;
        contacto1.CC_NumPerso__c = '21444982';
        contacto1.FirstName = 'Nombre';
        contacto1.LastName = 'Apellido';
        contacto1.Email = 'test@test.com';
        contacto1.Phone = '666666666';
        Contact contacto2 = new Contact();
        contacto2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto2.AccountId = cuenta.Id;
        contacto2.CC_NumPerso__c = '21444983';
        contacto2.FirstName = 'Nombre2';
        contacto2.LastName = 'Apellido2';
        contacto2.Email = 'test2@test.com';
        contacto2.Phone = '666666666';
        insert new List<Contact>{contacto1, contacto2};

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor.CC_Lista__c = listaValores.Id;
        valor.Name = 'Préstamo';
        valor.CC_Valor__c = '1';
        listaValores.CC_Activa__c = true;
        insert valor;

        Pricebook2 listaPrecios = new Pricebook2();
        listaPrecios.Name = 'CSBD Price Book';
        listaPrecios.Description = 'CSBD Price Book';
        listaPrecios.IsActive = true;
        insert listaPrecios;
    }

    @isTest
    public static void actualizarDatosRiesgoClientesOportunidades() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '46979396X'];
        Contact contacto1 = [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id AND CC_NumPerso__c = '21444982'];
        Contact contacto2 = [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id AND CC_NumPerso__c = '21444983'];

        Map<String, Object> campos = new Map<String, Object>();
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', contacto1.Id);
        campos.put('CSBD_Contact_2__c', contacto2.Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
        prestamo.OwnerId = usuarioGestor.Id;
        update prestamo;

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        System.runAs ( usuarioGestor ) {
            Test.startTest();
            CSBD_SIR.actualizarDatosRiesgoClientesOportunidades(new List<Id>{prestamo.Id}, true);
            Test.stopTest();

            Opportunity oportunidadCreada = [SELECT CSBD_Limite_Prestamos_Oficinas__c, CSBD_Limite_Prestamos_Canales__c, CSBD_Limite_Tarjetas_Oficinas__c, CSBD_Limite_Tarjetas_Canales__c, CSBD_Limite_Compra_Estrella__c FROM Opportunity WHERE Id = :prestamo.Id];
            Contact contactoCreado = [SELECT CSBD_Actualizacion_Datos_Riesgo__c, Id FROM Contact WHERE Id = :prestamo.CSBD_Contact__c];
            System.assertEquals(false, contactoCreado.CSBD_Actualizacion_Datos_Riesgo__c);

            System.assertNotEquals(null, oportunidadCreada.CSBD_Limite_Prestamos_Oficinas__c);
            System.assertNotEquals(null, oportunidadCreada.CSBD_Limite_Prestamos_Canales__c);
            System.assertNotEquals(null, oportunidadCreada.CSBD_Limite_Tarjetas_Oficinas__c);
            System.assertNotEquals(null, oportunidadCreada.CSBD_Limite_Tarjetas_Canales__c);
            System.assertNotEquals(null, oportunidadCreada.CSBD_Limite_Compra_Estrella__c);
        }
    }

    private static CC_InterfaceSettings__mdt obtenerParametrosIntegracion(String interfazDevName) {
        List<CC_InterfaceSettings__mdt> parametrosInterfaz = [SELECT DeveloperName, CC_Certificado__c, CC_Endpoint__c, CC_TipoPeticion__c, CC_ContentType__c
                                                                FROM CC_InterfaceSettings__mdt WHERE DeveloperName = :interfazDevName AND CC_Activa__c = true LIMIT 1];
        if (!parametrosInterfaz.isEmpty()) {
            return parametrosInterfaz[0];
        } else {
            return null;
        }
    }
}