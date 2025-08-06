/**********************************************************************************************************************
 Name:	  EV_InscripcionEnEventoAccionista_Test
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test para Web service EV_WS_InscripcionEnEventoAccionista de Portal
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		  	US586996			Mamen Arias         12/05/2023          Modify version new Architecture with the new object EV_CampaignMemberC__c
	1.1			US586996			Mamen Arias			15/05/2023			Add methods testInscripcionNoClienteNewArchitecture, testInscripcionClienteNewArchitecture, testInscripcionClienteYaInscritoNewArchitecture, 
																			testInscripcionNoClienteYaInscritoNewArchitecture, testInscripcionInterlocutorConEmpresaNewArchitecture, testInscripcionInterlocutorSinEmpresaNewArchitecture,
																			testInscripcionInterlocutorConVariasEmpresasNewArchitecture, testInscripcionInterlocutorExistenteNewArchitecture, testInscripcionMasDeUnInterlocutorNewArchitecture
***********************************************************************************************************************/
@isTest
public class EV_InscripcionEnEventoAccionista_Test {

	// Request variables
	static final String WS_PATH = '/services/apexrest/EV_InscripcionEnEventoAccionista/';
	static final String HTTP_METHOD = 'POST';
	static final Integer HTTP_STATUS_200 = 200;
	static final Integer HTTP_STATUS_202 = 202;
	static final Integer HTTP_STATUS_203 = 203;
	static final Integer HTTP_STATUS_205 = 205;
	static final Integer HTTP_STATUS_400 = 400;
	
	@TestSetup
	static void makeData(){
		EV_TestHelper.createParentCampaignVirtual();
	}

	@isTest
	//Se testea la inscripción de un no cliente (LEAD)
	public static void testInscripcionNoCliente() {
		Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c FROM Campaign LIMIT 1];
		EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionAccionista(eventoVirtual.EV_ExternalId__c, null, false);

		Test.startTest();
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI =WS_PATH; 
		req.addHeader('Content-Type', 'application/json');
		req.httpMethod = HTTP_METHOD;
		req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
		
		RestContext.request = req;
		RestContext.response = res;
		EV_WS_InscripcionEnEventoAccionista.inscripcionPortal();
		
		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
	}

	@isTest
	//Se testea la inscripción de un no cliente (LEAD)
	public static void testInscripcionNoClienteNewArchitecture() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');

		System.runAs(newUser){
			Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c, EV_NewArchitecture__c FROM Campaign LIMIT 1];
			eventoVirtual.EV_NewArchitecture__c = true;
			update eventoVirtual;
			EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionAccionista(eventoVirtual.EV_ExternalId__c, null, false);

			RestRequest req = new RestRequest(); 
			RestResponse res = new RestResponse();

			req.requestURI =WS_PATH; 
			req.addHeader('Content-Type', 'application/json');
			req.httpMethod = HTTP_METHOD;
			req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
			
			RestContext.request = req;
			RestContext.response = res;
			Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
			Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
		}
		
		Test.startTest();
		System.runAs(newUser){
			EV_WS_InscripcionEnEventoAccionista.inscripcionPortal();
		}
		Test.stopTest();
		
		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
	}
	
	@isTest
	//Se testea la inscripción de un cliente (Contact);
	public static void testInscripcionCliente() {
		EV_TestHelper.createCampaignMemberContact(false,true);
		Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c FROM Campaign LIMIT 1];
		CampaignMember campaignMemberInscrito = [SELECT Id, EV_ExternalId__c FROM CampaignMember LIMIT 1];
		EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionAccionista(eventoVirtual.EV_ExternalId__c, campaignMemberInscrito.EV_ExternalId__c, false);

		Test.startTest();
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = WS_PATH; 
		req.addHeader('Content-Type', 'application/json');
		req.httpMethod = HTTP_METHOD;
		req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
		
		RestContext.request = req;
		RestContext.response = res;
		Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
		Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
		EV_WS_InscripcionEnEventoAccionista.inscripcionPortal();
		
		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
	}

	@isTest
	//Se testea la inscripción de un cliente (Contact);
	public static void testInscripcionClienteNewArchitecture() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');

		System.runAs(newUser){
			EV_TestHelper.createCampaignMemberCustomContact(false,true);
			Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c, EV_NewArchitecture__c FROM Campaign LIMIT 1];
			eventoVirtual.EV_NewArchitecture__c = true;
			update eventoVirtual;
			EV_CampaignMemberC__c campaignMemberInscrito = [SELECT Id, EV_ExternalId__c FROM EV_CampaignMemberC__c LIMIT 1];
			EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionAccionista(eventoVirtual.EV_ExternalId__c, campaignMemberInscrito.EV_ExternalId__c, false);
			RestRequest req = new RestRequest(); 
			RestResponse res = new RestResponse();
	
			req.requestURI = WS_PATH; 
			req.addHeader('Content-Type', 'application/json');
			req.httpMethod = HTTP_METHOD;
			req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
			
			RestContext.request = req;
			RestContext.response = res;
			Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
			Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
		}
		
		Test.startTest();
		System.runAs(newUser){
			EV_WS_InscripcionEnEventoAccionista.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
	}
	
	@isTest
	//Se testea la inscripción de un cliente (Contact) ya inscrito;
	public static void testInscripcionClienteYaInscrito() {
		EV_TestHelper.createCampaignMemberContact(false,true);
		Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c FROM Campaign LIMIT 1];
		CampaignMember campaignMemberInscrito = [SELECT Id, EV_ExternalId__c FROM CampaignMember LIMIT 1];
		campaignMemberInscrito.Status='Registro confirmado';
		update campaignMemberInscrito;
		EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionAccionista(eventoVirtual.EV_ExternalId__c, campaignMemberInscrito.EV_ExternalId__c, false);

		Test.startTest();
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI = WS_PATH; 
		req.addHeader('Content-Type', 'application/json');
		req.httpMethod = HTTP_METHOD;
		req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
		
		RestContext.request = req;
		RestContext.response = res;
		Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
		Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
		EV_WS_InscripcionEnEventoAccionista.inscripcionPortal();
		
		System.assertEquals(HTTP_STATUS_202, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
	}

	@isTest
	//Se testea la inscripción de un cliente (Contact) ya inscrito;
	public static void testInscripcionClienteYaInscritoNewArchitecture() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');

		System.runAs(newUser){
			EV_TestHelper.createCampaignMemberCustomContact(false,true);
			Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c, EV_NewArchitecture__c FROM Campaign LIMIT 1];
			eventoVirtual.EV_NewArchitecture__c = true;
			update eventoVirtual;
			EV_CampaignMemberC__c campaignMemberInscrito = [SELECT Id, EV_ExternalId__c FROM EV_CampaignMemberC__c LIMIT 1];
			campaignMemberInscrito.EV_Status__c='Registro confirmado';
			update campaignMemberInscrito;
			EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionAccionista(eventoVirtual.EV_ExternalId__c, campaignMemberInscrito.EV_ExternalId__c, false);

			
			RestRequest req = new RestRequest(); 
			RestResponse res = new RestResponse();

			req.requestURI = WS_PATH; 
			req.addHeader('Content-Type', 'application/json');
			req.httpMethod = HTTP_METHOD;
			req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
			
			RestContext.request = req;
			RestContext.response = res;
			Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
			Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
		}

		Test.startTest();
		System.runAs(newUser){
			EV_WS_InscripcionEnEventoAccionista.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_202, RestContext.response.statusCode, 'La llamada no ha sido correcta');
	}

	@isTest
	//Se testea la inscripción de un no cliente (LEAD) ya inscrito
	public static void testInscripcionNoClienteYaInscrito() {
		EV_TestHelper.createCampaignMemberLead();

		Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c FROM Campaign LIMIT 1];
		CampaignMember campaignMemberInscrito = [SELECT Id, EV_ExternalId__c FROM CampaignMember LIMIT 1];

		EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionAccionista(eventoVirtual.EV_ExternalId__c, null, false);

		Test.startTest();
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI =WS_PATH; 
		req.addHeader('Content-Type', 'application/json');
		req.httpMethod = HTTP_METHOD;
		req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
		
		RestContext.request = req;
		RestContext.response = res;
		Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
		Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
		EV_WS_InscripcionEnEventoAccionista.inscripcionPortal();
		
		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
	}

	@isTest
	//Se testea la inscripción de un no cliente (LEAD) ya inscrito
	public static void testInscripcionNoClienteYaInscritoNewArchitecture() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');

		System.runAs(newUser){
			EV_TestHelper.createCampaignMemberCustomLead();

			Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c, EV_NewArchitecture__c FROM Campaign LIMIT 1];
			eventoVirtual.EV_NewArchitecture__c = true;
			update eventoVirtual;
			EV_CampaignMemberC__c campaignMemberInscrito = [SELECT Id, EV_ExternalId__c FROM EV_CampaignMemberC__c LIMIT 1];
	
			EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionAccionista(eventoVirtual.EV_ExternalId__c, null, false);
	
			RestRequest req = new RestRequest(); 
			RestResponse res = new RestResponse();
	
			req.requestURI =WS_PATH; 
			req.addHeader('Content-Type', 'application/json');
			req.httpMethod = HTTP_METHOD;
			req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
			
			RestContext.request = req;
			RestContext.response = res;
			Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
			Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
		}

		Test.startTest();
		System.runAs(newUser){
			EV_WS_InscripcionEnEventoAccionista.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
	}

	@isTest
	//Se testea la inscripción de un Interlocutor con empresa registrada en Salesforce
	public static void testInscripcionInterlocutorConEmpresa() {
		EV_TestHelper.createEmpresa();

		Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c FROM Campaign LIMIT 1];
		EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionAccionista(eventoVirtual.EV_ExternalId__c, null, true);

		Test.startTest();
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI =WS_PATH; 
		req.addHeader('Content-Type', 'application/json');
		req.httpMethod = HTTP_METHOD;
		req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
		
		RestContext.request = req;
		RestContext.response = res;
		EV_WS_InscripcionEnEventoAccionista.inscripcionPortal();
		
		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
	}

	@isTest
	//Se testea la inscripción de un Interlocutor con empresa registrada en Salesforce
	public static void testInscripcionInterlocutorConEmpresaNewArchitecture() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');

		System.runAs(newUser){
			EV_TestHelper.createEmpresa();

			Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c, EV_NewArchitecture__c FROM Campaign LIMIT 1];
			eventoVirtual.EV_NewArchitecture__c = true;
			update eventoVirtual;
			EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionAccionista(eventoVirtual.EV_ExternalId__c, null, true);
	
			RestRequest req = new RestRequest(); 
			RestResponse res = new RestResponse();
	
			req.requestURI =WS_PATH; 
			req.addHeader('Content-Type', 'application/json');
			req.httpMethod = HTTP_METHOD;
			req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
			
			RestContext.request = req;
			RestContext.response = res;
			Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
			Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
		}

		Test.startTest();
		System.runAs(newUser){
			EV_WS_InscripcionEnEventoAccionista.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
	}

	@isTest
	//Se testea la inscripción de un Interlocutor con empresa no registrada registrada en Salesforce
	public static void testInscripcionInterlocutorSinEmpresa() {

		Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c FROM Campaign LIMIT 1];
		EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionAccionista(eventoVirtual.EV_ExternalId__c, null, true);

		Test.startTest();
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI =WS_PATH; 
		req.addHeader('Content-Type', 'application/json');
		req.httpMethod = HTTP_METHOD;
		req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
		
		RestContext.request = req;
		RestContext.response = res;
		EV_WS_InscripcionEnEventoAccionista.inscripcionPortal();
		
		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
	}

	@isTest
	//Se testea la inscripción de un Interlocutor con empresa no registrada registrada en Salesforce
	public static void testInscripcionInterlocutorSinEmpresaNewArchitecture() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');

		System.runAs(newUser){
			Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c, EV_NewArchitecture__c FROM Campaign LIMIT 1];
			eventoVirtual.EV_NewArchitecture__c = true;
			update eventoVirtual;
			EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionAccionista(eventoVirtual.EV_ExternalId__c, null, true);

			RestRequest req = new RestRequest(); 
			RestResponse res = new RestResponse();

			req.requestURI =WS_PATH; 
			req.addHeader('Content-Type', 'application/json');
			req.httpMethod = HTTP_METHOD;
			req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
			
			RestContext.request = req;
			RestContext.response = res;
			Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
			Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
		}

		Test.startTest();
		System.runAs(newUser){
			EV_WS_InscripcionEnEventoAccionista.inscripcionPortal();
		}
		Test.stopTest();
		
		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
	}
	
	@isTest
	//Se testea la inscripción de un Interlocutor con varias empresas registradas en Salesforce
	public static void testInscripcionInterlocutorConVariasEmpresas() {
		EV_TestHelper.createEmpresas();

		Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c FROM Campaign LIMIT 1];
		EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionAccionista(eventoVirtual.EV_ExternalId__c, null, true);

		Test.startTest();
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI =WS_PATH; 
		req.addHeader('Content-Type', 'application/json');
		req.httpMethod = HTTP_METHOD;
		req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
		
		RestContext.request = req;
		RestContext.response = res;
		EV_WS_InscripcionEnEventoAccionista.inscripcionPortal();
		
		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
	}

	@isTest
	//Se testea la inscripción de un Interlocutor con varias empresas registradas en Salesforce
	public static void testInscripcionInterlocutorConVariasEmpresasNewArchitecture() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');

		System.runAs(newUser){
			EV_TestHelper.createEmpresas();

			Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c, EV_NewArchitecture__c FROM Campaign LIMIT 1];
			eventoVirtual.EV_NewArchitecture__c = true;
			update eventoVirtual;
			EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionAccionista(eventoVirtual.EV_ExternalId__c, null, true);
	
			
			RestRequest req = new RestRequest(); 
			RestResponse res = new RestResponse();
	
			req.requestURI =WS_PATH; 
			req.addHeader('Content-Type', 'application/json');
			req.httpMethod = HTTP_METHOD;
			req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
			
			RestContext.request = req;
			RestContext.response = res;
			Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
			Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
		}

		Test.startTest();
		System.runAs(newUser){
			EV_WS_InscripcionEnEventoAccionista.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
	}

	@isTest
	//Se testea la inscripción de un Interlocutor ya existente
	public static void testInscripcionInterlocutorExistente() {

		EV_TestHelper.createContactInterlocutorEmpresa('TestEmpresa');

		Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c FROM Campaign LIMIT 1];
		EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionAccionista(eventoVirtual.EV_ExternalId__c, null, true);

		Test.startTest();
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI =WS_PATH; 
		req.addHeader('Content-Type', 'application/json');
		req.httpMethod = HTTP_METHOD;
		req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
		
		RestContext.request = req;
		RestContext.response = res;
		EV_WS_InscripcionEnEventoAccionista.inscripcionPortal();
		
		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
	}

	@isTest
	//Se testea la inscripción de un Interlocutor ya existente
	public static void testInscripcionInterlocutorExistenteNewArchitecture() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');

		System.runAs(newUser){
			EV_TestHelper.createContactInterlocutorEmpresa('TestEmpresa');

			Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c, EV_NewArchitecture__c FROM Campaign LIMIT 1];
			eventoVirtual.EV_NewArchitecture__c = true;
			update eventoVirtual;
			EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionAccionista(eventoVirtual.EV_ExternalId__c, null, true);

			RestRequest req = new RestRequest(); 
			RestResponse res = new RestResponse();

			req.requestURI =WS_PATH; 
			req.addHeader('Content-Type', 'application/json');
			req.httpMethod = HTTP_METHOD;
			req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
			
			RestContext.request = req;
			RestContext.response = res;
			Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
			Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
		}
		
		Test.startTest();
		System.runAs(newUser){
			EV_WS_InscripcionEnEventoAccionista.inscripcionPortal();
		}
		Test.stopTest();
		
		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
	}

	@isTest
	//Se testea la inscripción de un Interlocutor cuando existen más de uno iguales.
	public static void testInscripcionMasDeUnInterlocutor() {

		EV_TestHelper.createContactInterlocutorEmpresa('TestEmpresa');
		EV_TestHelper.createContactInterlocutorEmpresa('Empresa');

		Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c FROM Campaign LIMIT 1];
		EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionAccionista(eventoVirtual.EV_ExternalId__c, null, true);

		Test.startTest();
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI =WS_PATH; 
		req.addHeader('Content-Type', 'application/json');
		req.httpMethod = HTTP_METHOD;
		req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
		
		RestContext.request = req;
		RestContext.response = res;
		EV_WS_InscripcionEnEventoAccionista.inscripcionPortal();
		
		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
	}

	@isTest
	//Se testea la inscripción de un Interlocutor cuando existen más de uno iguales.
	public static void testInscripcionMasDeUnInterlocutorNewArchitecture() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
			EV_TestHelper.createContactInterlocutorEmpresa('TestEmpresa');
			EV_TestHelper.createContactInterlocutorEmpresa('Empresa');

			Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c, EV_NewArchitecture__c FROM Campaign LIMIT 1];
			eventoVirtual.EV_NewArchitecture__c = true;
			update eventoVirtual;
			EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionAccionista(eventoVirtual.EV_ExternalId__c, null, true);

			RestRequest req = new RestRequest(); 
			RestResponse res = new RestResponse();

			req.requestURI =WS_PATH; 
			req.addHeader('Content-Type', 'application/json');
			req.httpMethod = HTTP_METHOD;
			req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
			
			RestContext.request = req;
			RestContext.response = res;
			Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
			Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
		}

		Test.startTest();
		System.runAs(newUser){
			EV_WS_InscripcionEnEventoAccionista.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
	}

	@isTest
	//Se testea la inscripción de un no cliente (LEAD)
	public static void testInscripcionSinEvento() {

		EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionAccionista(null, null, true);

		Test.startTest();
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestURI =WS_PATH; 
		req.addHeader('Content-Type', 'application/json');
		req.httpMethod = HTTP_METHOD;
		req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
		
		RestContext.request = req;
		RestContext.response = res;
		EV_WS_InscripcionEnEventoAccionista.inscripcionPortal();
		
		System.assertEquals(HTTP_STATUS_205, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
	}
}