@isTest
public with sharing class CC_WS_Recuperar_Tarjetas_Test {

    @testSetup static void setup()
    { 
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];       
        UserRole rolCC = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
        //Id profileIdAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        
        //List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
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

        User agente = new User();        
        agente.profileId = profileAdmin;
        agente.UserRoleId = rolCC.Id;
        agente.FirstName = '';
        agente.LastName = 'CC_Usuario_CaixaBank';
        agente.Email = 'tuser000@amamama.com';
        agente.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        agente.CompanyName = 'MST';
        agente.Title = 'title';
        agente.Alias = 'alias';
        agente.TimeZoneSidKey = 'Europe/Paris';
        agente.EmailEncodingKey = 'UTF-8';
        agente.LanguageLocaleKey = 'es';
        agente.LocaleSidKey = 'es_ES';
        insert agente;

        insert new PermissionSetAssignment(AssigneeId = agente.Id, PermissionSetId = ps.Id);

        Account cuenta = new Account(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA'),
            FirstName = 'Cuenta',
            LastName = 'Test',
            CC_Email__c = 'cuenta@test.com',
            PersonMobilePhone = '+34 123456789',
            PersonBirthdate = Date.newInstance(2000, 05, 22),
            CC_NumPerso__c = '1608138'
        );

        List <CC_Settings__c> settingsList = new List <CC_Settings__c>();
        CC_Settings__c recuperarTarjetasDatos = new CC_Settings__c(
            Name = 'CC_Recuperar_Tarjetas_Datos',
            CC_Activa__c = true,
            CC_Configuracion_1__c = 'CARD_MASKEDPAN',
            CC_Configuracion_2__c = 'CARD_STATUSMAINCARD'
        );
        settingsList.add(recuperarTarjetasDatos);

        CC_Settings__c recuperarTarjetasFiltro = new CC_Settings__c(
            Name = 'CC_Recuperar_Tarjetas_Filtro',
            CC_Activa__c = true,
            CC_Configuracion_1__c = 'ACTIVE_CARD'
        );
        settingsList.add(recuperarTarjetasFiltro);

        CBK_IntegrationSetting__c customSetting = new CBK_IntegrationSetting__c();
        customSetting.Name = 'CC_Recuperar_Tarjetas';
        customSetting.NamedCredential__c = 'callout:API_GWT_TST_CCSF/cards/creditCard/bis/cards/customers/id/request';
        customSetting.RegistroTrazaIntegracion__c = true;
       
        System.runAs (usuario1) {
            insert cuenta;
            insert settingsList;
            insert customSetting;
        }
    }

    private class MockHttpResponseExito implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) { 
            String bodyClienteDigital = '{"totalCards":1,"hasExcluded":false,"CardList":[{"maskedPan":"403051******9035","statusMainCard":"ACTIVE_CARD"}]}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(bodyClienteDigital);
            res.setStatusCode(200);
            return res;
        }
    }

    private class MockHttpResponseError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) { 
            String bodyClienteDigital = '{"totalCards":1,"hasExcluded":false,"CardList":[{"maskedPan":"403051******9035","statusMainCard":"ACTIVE_CARD"}]}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(bodyClienteDigital);
            res.setStatusCode(400);
            return res;
        }
    }
    
    @isTest
    static void recuperarTarjetasPorClienteTestOK(){
        User user1 = [SELECT Id FROM User WHERE  LastName = 'CC_Usuario_CaixaBank'];
        Account acc = [SELECT Id, CC_NumPerso__c FROM Account WHERE FirstName = 'Cuenta' AND LastName = 'Test'];
        System.runAs(user1){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
            List<String> resultado = CC_WS_Recuperar_Tarjetas.recuperarTarjetasPorCliente(acc.CC_NumPerso__c);
            Test.stopTest();
            System.assertEquals(false, resultado.size() == 0);
            System.assertEquals(true, resultado[0] == '403051******9035');
        }
    }

    @isTest
    static void recuperarTarjetasPorClienteTestKO(){
        User user1 = [SELECT Id FROM User WHERE  LastName = 'CC_Usuario_CaixaBank'];
        Account acc = [SELECT Id, CC_NumPerso__c FROM Account WHERE FirstName = 'Cuenta' AND LastName = 'Test'];
        System.runAs(user1){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseError());
            List<String> resultado = CC_WS_Recuperar_Tarjetas.recuperarTarjetasPorCliente(acc.CC_NumPerso__c);
            Test.stopTest();
            System.assertEquals(true, resultado.size() == 0);
        }
    }
}