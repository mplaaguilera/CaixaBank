@isTest
public with sharing class CSBD_Datos_Formulario_Controller_Test {

    @TestSetup
    private static void altaDatosPrueba() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

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

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = '46979396X';
        cuenta.Phone = '666666666';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.AccountId = cuenta.Id;
        contacto.CC_NumPerso__c = '21444982';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.Email = 'test@test.com';
        contacto.Phone = '666666666';
        insert contacto;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;
    }

    @isTest
    public static void getSolicitud() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '46979396X'];
        Contact contacto = [SELECT Id, Name, CC_Numero_Documento__c FROM Contact WHERE AccountId = :cuenta.Id];

        Map<String, Object> campos = new Map<String, Object>();
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', contacto.Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
        prestamo.OwnerId = usuarioGestor.Id;
        update prestamo;

        String jsonPrestamo = [SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_Prestamo_JSON' LIMIT 1].Body.toString();
        Task actividad = CSBD_Activity.crearActividad(prestamo.Id, 'Solicitud recibida', 'Completed', 'Solicitud recibida', jsonPrestamo);
        actividad.OwnerId = usuarioGestor.Id;
        update actividad;

        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_Datos_Formulario_Controller.Retorno respuesta = CSBD_Datos_Formulario_Controller.getSolicitud(prestamo.Id);
            Test.stopTest();
    
            System.assertNotEquals(null,respuesta.datosFormulario);
        }
    }
}