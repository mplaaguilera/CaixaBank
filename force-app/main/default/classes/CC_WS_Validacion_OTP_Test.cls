@IsTest
public class CC_WS_Validacion_OTP_Test {

    @TestSetup
    static void creacionDatos() {
        Id profileIdAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;

        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = profileIdAdmin;
        usuario1.FirstName = 'Usuario Admin Prueba';
        usuario1.LastName = 'last211';
        usuario1.Email = 'aalsdna@kfsb.com';
        usuario1.Username = 'tuser0001@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';
        insert usuario1;

         // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        insert a;

        // Crear contacto.
        Contact b = new Contact();
       Id RecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
    b.RecordTypeId = RecordType;
        b.AccountId = a.Id;
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        b.CC_Matricula__c = 'U0144565';
        b.FirstName = 'Cliente prueba 1';
        insert b;

        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();

        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
         mcc.CC_Canal_Operativo__c = 'Sin canal';

        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
    //'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = prod.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;
    CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];

        Case c1 = new Case();
        c1.Subject = 'Prueba';
        //c1.CC_Idioma__c = 'es';
        //c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
    c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = motiv.Id;
    c1.CC_MCC_ProdServ__c = prod.Id;
        c1.CC_MCC_Tematica__c = tem.Id;
        c1.AccountId = a.Id;
        c1.ContactId = b.Id;
        insert c1;

        CC_Comunicaciones__c com = new CC_Comunicaciones__c();
        com.RecordTypeId = Schema.SObjectType.CC_Comunicaciones__c.getRecordTypeInfosByDeveloperName().get('CC_OTPSMS').getRecordTypeId();
        com.CC_Detalle__c = 'Comunicacion1';
        com.CC_Case__c = c1.Id;
        com.CC_Ticket__c = 'sagklj12312kj';
        insert com;

    }


     @isTest
    static void otpOK() {
        Set<ID> oSetCom = new Set<ID>();
        List<CC_Comunicaciones__c> oComunicaciones = [SELECT Name, CC_Case__r.CC_Status_Autorizacion__c, CC_Case__c, CC_Case__r.CC_NumPerso__c, CC_Case__r.CC_Idioma__c
                                                        FROM CC_Comunicaciones__c  WHERE CC_Detalle__c = :'Comunicacion1'];

        oSetCom.add(oComunicaciones.get(0).Id);
        String Codigo_OTPSMS = '12345';
        User user1 = [SELECT Id FROM User WHERE Email = 'aalsdna@kfsb.com' LIMIT 1];
        System.runAs(user1){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_OTP(200));

        //oSetCom.add(oComunicaciones.Id);
        CC_WS_Validacion_OTP.CC_WS_Validacion_OTP(oSetCom, Codigo_OTPSMS);
        //CC_WS_Envio_OTP.CC_WS_Envio_OTP(oSetCom);
            Test.stopTest();
        }
        String estado = [SELECT CC_Status_Autorizacion__c FROM Case WHERE Id = :oComunicaciones.get(0).CC_Case__c].CC_Status_Autorizacion__c;
        System.assertEquals('APPROVED', estado);
    }

    @isTest
    private static void otpNOK() {
        User user1 = [SELECT Id FROM User WHERE Email = 'aalsdna@kfsb.com' LIMIT 1];
        System.runAs(user1){
            CC_Comunicaciones__c comunicacion = [SELECT CC_Case__c FROM CC_Comunicaciones__c WHERE CC_Detalle__c = 'Comunicacion1'];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_OTP(404));
            CC_WS_Validacion_OTP.CC_WS_Validacion_OTP(new Set<Id>{comunicacion.Id}, '12345');
            Test.stopTest();

            String estado = [SELECT CC_Status_Autorizacion__c FROM Case WHERE Id = :comunicacion.CC_Case__c].CC_Status_Autorizacion__c;
            system.assertEquals('ERROR', estado);
        }
    }
}