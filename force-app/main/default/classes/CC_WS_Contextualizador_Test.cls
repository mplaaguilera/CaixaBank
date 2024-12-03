@isTest
public with sharing class CC_WS_Contextualizador_Test {
    @TestSetup
    static void setData() {

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        
        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = profileId;
        usuario1.FirstName = 'Usuario Admin Prueba';
        usuario1.LastName = 'last211';
        usuario1.Email = 'aalsdna@kfsb.com';
        usuario1.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';

        userList.add(usuario1);

		insert userList;        

        System.runAs(usuario1) {
        Account cuenta = new Account();
        Id recordTypeCuenta = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuenta.Name = 'Cuenta01';
        cuenta.CC_NumPerso__c = '12345569';
        insert cuenta;        
        Id accountId = cuenta.Id;
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        insert contacto;        
        Id cId = contacto.Id;

        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicio1();
        String jsonLlamadaEntrante = CC_Llamada_Test.obtenerJsonLlamada(s1.CC_Codigo__c, '', '', '12345678');
        Id idLlamada = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamadaEntrante);
        CC_Llamada__c llamada = CC_Llamada_Test.obtenerLlamada(idLlamada);
        llamada.CC_Cuenta__c = accountId;
        update llamada;
        
        Case oCaso = new Case();
        oCaso.Subject = 'Contextualizador';
        oCaso.Origin = 'Email';
        oCaso.Status = 'Activo';
        oCaso.ContactId = cId;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        insert oCaso;

        CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'CC_Contextualizador';
		wsc.NamedCredential__c = 'callout:MyIntegrationTest';
        wsc.RegistroTrazaIntegracion__c = true;
		insert wsc;
        
        }
    }

    @isTest
    public static void llamadaWSOkTestCase() {
        Case c = [SELECT CC_Info_Denegacion__c, Id FROM Case WHERE Subject = 'Contextualizador'];
        Account a = [SELECT CC_NumPerso__c FROM Account WHERE Name = 'Cuenta01'];
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Contextualizador(200));
        Map <String, Object> llamadaWs = new Map <String, Object>();
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            llamadaWs = CC_WS_Contextualizador.ccWSContextualizador(a.CC_NumPerso__c, c.Id, 'Case');
        }
        Test.stopTest();
        String valorEsperado = 'SUPERADO LIMITE: NO DISPONE DE EXCEDIDO POR FALTA DE SALDO CCC';
        system.assertEquals(valorEsperado, (String)llamadaWs.get('MotivoDenegacion'), 'No salio bien la llamada');
    }
    @isTest
    public static void sinLlamarAlWSTestCase() {
        Case c = [SELECT CC_Info_Denegacion__c, Id FROM Case WHERE Subject = 'Contextualizador'];
        Account a = [SELECT CC_NumPerso__c FROM Account WHERE Name = 'Cuenta01'];
        c.CC_Info_Denegacion__c = '{"MotivoDenegacion":"SUPERADO LIMITE: NO DISPONE DE EXCEDIDO POR FALTA DE SALDO CCC"}';
        update c;
        Map <String, Object> sinLlamadaWs = new Map <String, Object>();
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            sinLlamadaWs = CC_WS_Contextualizador.ccWSContextualizador(a.CC_NumPerso__c, c.Id, 'Case');
        }
        Test.stopTest();
        String valorEsperado = 'SUPERADO LIMITE: NO DISPONE DE EXCEDIDO POR FALTA DE SALDO CCC';
        system.assertEquals(valorEsperado, (String)sinLlamadaWs.get('MotivoDenegacion'), 'No respeto la información que habia en el campo');
    }
    @isTest
    public static void llamadaWSNOkTestCase() {
        Case c = [SELECT CC_Info_Denegacion__c, Id FROM Case WHERE Subject = 'Contextualizador'];
        Account a = [SELECT CC_NumPerso__c FROM Account WHERE Name = 'Cuenta01'];
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Contextualizador(404));
        Map <String, Object> llamadaWs = new Map <String, Object>();
            Test.startTest();
            System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
               llamadaWs = CC_WS_Contextualizador.ccWSContextualizador(a.CC_NumPerso__c, c.Id, 'Case');  
            }
            Test.stopTest();
        	Boolean error = llamadaWs.containsKey('Error');
            system.assertEquals(true, error, 'No ok el mock');
        
    }

    @isTest
    public static void llamadaWSOkTestLlamada() {
        // Case c = [SELECT CC_Info_Denegacion__c, Id FROM Case WHERE Subject = 'Contextualizador'];
        Account a = [SELECT Id FROM Account WHERE Name = 'Cuenta01'];
        CC_Llamada__c l = [SELECT CC_Info_Denegacion__c FROM CC_Llamada__c WHERE CC_Cuenta__c = :a.Id];
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Contextualizador(200));
        Map <String, Object> llamadaWs = new Map <String, Object>();
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            llamadaWs = CC_WS_Contextualizador.ccWSContextualizador(a.Id, l.Id, 'Llamada');
        }
        Test.stopTest();
        String valorEsperado = 'SUPERADO LIMITE: NO DISPONE DE EXCEDIDO POR FALTA DE SALDO CCC';
        system.assertEquals(valorEsperado, (String)llamadaWs.get('MotivoDenegacion'), 'No salio bien la llamada');
    }
    @isTest
    public static void sinLlamarAlWSTestLlamada() {

        Account a = [SELECT Id, CC_NumPerso__c FROM Account WHERE Name = 'Cuenta01'];
        CC_Llamada__c l = [SELECT CC_Info_Denegacion__c FROM CC_Llamada__c WHERE CC_Cuenta__c = :a.Id];
        l.CC_Info_Denegacion__c = '{"MotivoDenegacion":"SUPERADO LIMITE: NO DISPONE DE EXCEDIDO POR FALTA DE SALDO CCC"}';
        update l;
        Map <String, Object> sinLlamadaWs = new Map <String, Object>();
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            sinLlamadaWs = CC_WS_Contextualizador.ccWSContextualizador(a.Id, l.Id, 'Llamada');
        }
        Test.stopTest();
        String valorEsperado = 'SUPERADO LIMITE: NO DISPONE DE EXCEDIDO POR FALTA DE SALDO CCC';
        system.assertEquals(valorEsperado, (String)sinLlamadaWs.get('MotivoDenegacion'), 'No respeto la información que habia en el campo');
    }
    @isTest
    public static void llamadaWSNOkTestLlamada() {
        Account a = [SELECT Id, CC_NumPerso__c FROM Account WHERE Name = 'Cuenta01'];
        CC_Llamada__c l = [SELECT CC_Info_Denegacion__c FROM CC_Llamada__c WHERE CC_Cuenta__c = :a.Id];
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Contextualizador(404));
        Map <String, Object> llamadaWs = new Map <String, Object>();
            Test.startTest();
            System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
               llamadaWs = CC_WS_Contextualizador.ccWSContextualizador(a.Id, l.Id, 'Llamada');  
            }
            Test.stopTest();
        	Boolean error = llamadaWs.containsKey('Error');
            system.assertEquals(true, error, 'No ok el mock');
        
    }
    @isTest
    public static void llamadaSinNumPerso() {
        Account a = [SELECT Id, CC_NumPerso__c FROM Account WHERE Name = 'Cuenta01'];
        a.CC_NumPerso__c = null;
        update a;
        CC_Llamada__c l = [SELECT CC_Info_Denegacion__c FROM CC_Llamada__c WHERE CC_Cuenta__c = :a.Id];
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Contextualizador(200));
        Map <String, Object> llamadaWs = new Map <String, Object>();
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            llamadaWs = CC_WS_Contextualizador.ccWSContextualizador(a.Id, l.Id, 'Llamada');
        }
        Test.stopTest();
        String valorEsperado = null;
        system.assertEquals(valorEsperado, (String)llamadaWs.get('MotivoDenegacion'), 'Hay numperso en la cuenta');
    }
}