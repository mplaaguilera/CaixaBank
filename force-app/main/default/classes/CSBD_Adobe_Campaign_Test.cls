@isTest
public with sharing class CSBD_Adobe_Campaign_Test {

	@TestSetup
	private static void testSetup() {
		User admin = new User();
        admin.profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        admin.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'CSBD_Generico'].Id;
        admin.FirstName = 'Admin';
        admin.LastName = 'Admin';
        admin.Email = 'tuser000@amamama.com';
		admin.UserName = 'admintest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
        admin.Alias = 'alias';
        admin.TimeZoneSidKey = 'Europe/Paris';
        admin.EmailEncodingKey = 'UTF-8';
        admin.LanguageLocaleKey = 'es';
        admin.LocaleSidKey = 'es_ES';
		insert admin;

		System.runAs(admin) {
			User gestor = new User();
			gestor.FirstName = 'GestorCSBD';
			gestor.LastName = 'GestorCSBD';
			gestor.IsActive = true;
			gestor.Alias = 'Gestor';
			gestor.Email = 'usuario_test@test.com';
			gestor.EmailEncodingKey = 'ISO-8859-1';
			gestor.LanguageLocaleKey = 'es';
			gestor.LocaleSidKey = 'es_ES';
			gestor.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'CSBD Genérico'].Id;
			gestor.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CSBD Gestor'].Id;
			gestor.TimeZoneSidKey = 'Europe/Madrid';
			gestor.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
			insert gestor;

			PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'CSBD_PS_Gestor' LIMIT 1];
			if (permissionSet != null) {
				PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
				nuevoPermiso.PermissionSetId = permissionSet.Id;
				nuevoPermiso.AssigneeId = gestor.Id;
				insert nuevoPermiso;
			}

			System.runAs(admin) {
				CBK_IntegrationSetting__c integrationSetting = new CBK_IntegrationSetting__c();
				integrationSetting.Name = 'CSBD_WS_Adobe';
				integrationSetting.NamedCredential__c = 'callout:CSBD_WS_CredentialAdobe/{PARAMS_1}/{PARAMS_2}/{PARAMS_3}/{PARAMS_4}';
				insert integrationSetting;
			}
		}
	}

	@isTest
    public static void testEnviar() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		User usuarioGestor = [SELECT Id FROM User WHERE LastName = 'GestorCSBD' LIMIT 1];
		System.runAs(usuarioGestor) {
			Test.startTest();
			Map<String, Object> campos = new Map<String, Object>{
				'CSBD_CampaignId__c' => 'Journey49',
				'CSBD_DeliveryInternalName__c' => 'CXB_Channel_Slfc_NIS',
				'CSBD_JourneyActionId__c' => '3d93f49d-11ba-4364-8e0d-54601c3922eb',
				'CSBD_MessageProfileId__c' => '3d93f49d11ba43648e0d54601c3922eb_87B612_1709131806244',
				'CSBD_Now_NUMPERSO__c' => '1234'
			};
			Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_PROAutomatica', campos);
			Test.stopTest();

			oportunidad = [SELECT CSBD_MessageProfileId__c FROM Opportunity WHERE Id = :oportunidad.Id];
			List <Task> tareas = [SELECT Id FROM Task WHERE WhatId =: oportunidad.Id];
			System.assertEquals(1, tareas.size());
			System.assert(String.isNotBlank(oportunidad.CSBD_MessageProfileId__c), 'CSBD_MessageProfileId__c debería tener valor');
		}
    }
    
    @isTest
    public static void testPerdida() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		User usuarioGestor = [SELECT Id FROM User WHERE LastName = 'GestorCSBD' LIMIT 1];
		System.runAs(usuarioGestor) {
			Test.startTest();
			Map<String, Object> campos = new Map<String, Object>{
				'CSBD_CampaignId__c' => 'Journey49',
				'CSBD_DeliveryInternalName__c' => 'CXB_Channel_Slfc_NIS',
				'CSBD_JourneyActionId__c' => '3d93f49d-11ba-4364-8e0d-54601c3922eb',
				'CSBD_MessageProfileId__c' => '3d93f49d11ba43648e0d54601c3922eb_87B612_1709131806244',
				'CSBD_Now_NUMPERSO__c' => '1234'
			};
			Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_PROAutomatica', campos);
            CSBD_Opportunity.cerrarOportunidad(oportunidad.Id, 'Perdida', 'Test');
			Test.stopTest();

			oportunidad = [SELECT CSBD_MessageProfileId__c FROM Opportunity WHERE Id = :oportunidad.Id];
			List <Task> tareas = [SELECT Id FROM Task WHERE WhatId =: oportunidad.Id];
			System.assertEquals(3, tareas.size());
			System.assert(String.isNotBlank(oportunidad.CSBD_MessageProfileId__c), 'CSBD_MessageProfileId__c debería tener valor');
		}
    }
    
      @isTest
    public static void testPerdidaNoLocalizado() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		User usuarioGestor = [SELECT Id FROM User WHERE LastName = 'GestorCSBD' LIMIT 1];
		System.runAs(usuarioGestor) {
			Test.startTest();
			Map<String, Object> campos = new Map<String, Object>{
				'CSBD_CampaignId__c' => 'Journey49',
				'CSBD_DeliveryInternalName__c' => 'CXB_Channel_Slfc_NIS',
				'CSBD_JourneyActionId__c' => '3d93f49d-11ba-4364-8e0d-54601c3922eb',
				'CSBD_MessageProfileId__c' => '3d93f49d11ba43648e0d54601c3922eb_87B612_1709131806244'
			};
			Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_PROAutomatica', campos);
            CSBD_Opportunity.cerrarOportunidad(oportunidad.Id, 'Perdida', 'Cliente no localizado');
			Test.stopTest();

			oportunidad = [SELECT CSBD_MessageProfileId__c FROM Opportunity WHERE Id = :oportunidad.Id];
			System.assert(String.isNotBlank(oportunidad.CSBD_MessageProfileId__c), 'CSBD_MessageProfileId__c debería tener valor');
		}
    }
    
      @isTest
    public static void testFormalizada() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		User usuarioGestor = [SELECT Id FROM User WHERE LastName = 'GestorCSBD' LIMIT 1];
		System.runAs(usuarioGestor) {
			Test.startTest();
			Map<String, Object> campos = new Map<String, Object>{
				'CSBD_CampaignId__c' => 'Journey49',
				'CSBD_DeliveryInternalName__c' => 'CXB_Channel_Slfc_NIS',
				'CSBD_JourneyActionId__c' => '3d93f49d-11ba-4364-8e0d-54601c3922eb',
				'CSBD_MessageProfileId__c' => '3d93f49d11ba43648e0d54601c3922eb_87B612_1709131806244',
				'CSBD_Now_NUMPERSO__c' => '1234'
			};
			Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_PROAutomatica', campos);
            CSBD_Opportunity.cerrarOportunidad(oportunidad.Id, 'Formalizada', 'Test');
			Test.stopTest();

			oportunidad = [SELECT CSBD_MessageProfileId__c FROM Opportunity WHERE Id = :oportunidad.Id];
			List <Task> tareas = [SELECT Id FROM Task WHERE WhatId =: oportunidad.Id];
			System.assertEquals(3, tareas.size());
			System.assert(String.isNotBlank(oportunidad.CSBD_MessageProfileId__c), 'CSBD_MessageProfileId__c debería tener valor');
		}
    }

	private class MockHttpResponseGenerator implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			HttpResponse res = new HttpResponse();
			res.setStatus('OK');
			res.setStatusCode(200);

			String body = '{"receivedTimeMs" : 1710769031513,';
			body += '"flowId" : "d7b6ce5d-5a92-4bf8-a066-08ac9a4d1bfb",';
			body += '"xactionId" : "681381fd-ceea-4809-bf2b-e1c7e8caa20d",';
			body += '"inletId" : "970ddfea277bc1b1f534b79d5b8fa8bcdf73be80a2a20471df0360d565894e1e"}';
			res.setBody(body);
			return res;
		}
	}
}