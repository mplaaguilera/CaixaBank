@isTest
public with sharing class CBK_SCH_CSBD_ActivarGestor_Test {
    @TestSetup
    private static void altaDatosPrueba() {
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

        Pricebook2 listaPrecios = new Pricebook2(Name = 'CSBD Price Book', Description = 'CSBD Price Book', IsActive = true );
        insert listaPrecios;
    }

    private static Account crearCuentaContacto(String nif) {
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = nif;
        cuenta.Phone = '666666666';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.Phone = '666666666';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        contacto.CSBD_Limite_Prestamos_Oficinas__c = 20000;
        insert contacto;

        return cuenta;
    }

    @isTest
    private static void CBK_SCH_CSBD_ActivarGestorOportunidad_Test() {
        Account cuenta = crearCuentaContacto('53456777P');
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('Name', 'oportunidad de prueba');
        campos.put('CSBD_Estado__c', 'Activa');
        campos.put('StageName', 'Solicitud');
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        campos.put('CSBD_Horario_Contacto__c', 'Mañana');
        campos.put('CSBD_Idioma_Solicitud__c', 'Castellano');
        campos.put('CSBD_Familia_Producto__c', 'Cuentas');
        campos.put('CSBD_Empresa_Proveedora__c', 'CaixaBank'); 
        campos.put('CSBD_Importe_Producto_Principal__c', 200);
        
        Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
        CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{oportunidad}, 'Fuera horario contacto');
        List<CSBD_Gestor_Oportunidad__c> gestorOportunidad = [SELECT Id, OwnerId, CSBD_Estado__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c =: oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];
        List<CBK_SCH_PendingProcess__c> pendingProcess = [SELECT Id, RecordId__c FROM CBK_SCH_PendingProcess__c WHERE RecordId__c = :gestorOportunidad[0].Id];
        
        Test.startTest();
        CBK_SCH_CSBD_ActivarGestorOportunidad implClass = new CBK_SCH_CSBD_ActivarGestorOportunidad();
        implClass.lstInfoProcess = pendingProcess;
        System.enqueueJob(implClass);
        Test.stopTest();

        gestorOportunidad = [SELECT Id, OwnerId, CSBD_Estado__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c =: oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];

        System.assertEquals('Pendiente de asignar', gestorOportunidad[0].CSBD_Estado__c);
    }
}