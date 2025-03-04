@isTest
public with sharing class CC_WS_Disponibilidad_Cita_Test {
    @testSetup 
    static void setup() { 
        Id profileCC = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];       
        UserRole rolCC = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
        
        List<User> userList = new List<User>();
        User admin = new User();
        admin.ProfileId = profileAdmin;
        admin.FirstName = 'Usuario Admin Prueba';
        admin.LastName = 'last211';
        admin.Email = 'aalsdna@kfsb.com';
        admin.Username = 'tuser0001@amamama.com' + System.currentTimeMillis();
        admin.CompanyName = 'MST';
        admin.Title = 'title';
        admin.Alias = 'alias';
        admin.TimeZoneSidKey = 'Europe/Paris';
        admin.EmailEncodingKey = 'UTF-8';
        admin.LanguageLocaleKey = 'es';
        admin.LocaleSidKey = 'es_ES';
        userList.add(admin);

        User agente = new User();
        agente.profileId = profileCC;
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
        userList.add(agente);
        insert userList;

        insert new PermissionSetAssignment(AssigneeId = agente.Id, PermissionSetId = ps.Id);

        List <CC_Settings__c> settingsList = new List <CC_Settings__c>();

        CC_Settings__c reservationType = new CC_Settings__c(
            Name = 'CC_Configuracion_Cita_Rapida',
            CC_Activa__c = true,
            CC_Configuracion_1__c = 'true',
            CC_Configuracion_2__c = 'TELEMATIC',
            CC_Configuracion_4__c = '4'
        );
        settingsList.add(reservationType);

        CBK_IntegrationSetting__c customSetting = new CBK_IntegrationSetting__c();
        customSetting.Name = 'CC_Disponibilidad_Citas';
        customSetting.NamedCredential__c = 'callout:API_GWT_TST_CC/customerManagement/customerRelationshipManagement/sales/xpe/branches/{branchId}/slots';
        customSetting.RegistroTrazaIntegracion__c = true;
       
        System.runAs(admin) {
            insert settingsList;
            insert customSetting;
        }
    }

    @isTest
    static void consultarDisponibilidadOK() {
        User usuario = [SELECT Id FROM User WHERE LastName = 'CC_Usuario_CaixaBank'];
        System.runAs(usuario) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
            List<String> resultado = CC_WS_Disponibilidad_Cita.obtenerFechasDisponiblidadGestorPool('1345', '2024-12-19');
            Test.stopTest();
            System.assertEquals(false, resultado.size() == 0);
        }
    }

    @isTest
    static void consultarDisponibilidadKO() {
        User usuario = [SELECT Id FROM User WHERE LastName = 'CC_Usuario_CaixaBank'];
        System.runAs(usuario) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseError());
            List<String> resultadoNumPerKO = CC_WS_Disponibilidad_Cita.obtenerFechasDisponiblidadGestorPool('', '2024-12-19');
            List<String> resultadoCatch = CC_WS_Disponibilidad_Cita.obtenerFechasDisponiblidadGestorPool('1345', '2024-12-19');
            Test.stopTest();
            System.assertEquals(true, resultadoNumPerKO.size() == 0);
            System.assertEquals(true, resultadoCatch.size() == 0);
        }
    }

    private class MockHttpResponseExito implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) { 
            String respuesta = '[{"Slots":[{"starTimeSlot":"09:00","endTimeSlot":"09:30","numberPlaces":2,"numberPlacesAvailable":2,"isAvailable":true}], "currentWaitTime": 0, "slotDate": "2024-12-19"}]';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(respuesta);
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    private class MockHttpResponseError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) { 
            String respuesta = '[{"Slots":[{"starTimeSlot":"09:00","endTimeSlot":"09:30","numberPlaces":2,"numberPlacesAvailable":2,"isAvailable":true}]}]';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(respuesta);
            res.setStatusCode(400);
            res.setStatus('KO');
            return res;
        }
    }
}