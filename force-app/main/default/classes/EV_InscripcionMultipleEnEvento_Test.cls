/**********************************************************************************************************************
 Name:	  EV_InscripcionMultipleEnEvento_Test
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test para WS inscripcion multiple de Talks
----------------------------------------------------------------------------------------------------------------------
Historial
----------------------------------------------------------------------------------------------------------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		    US297853    	    Daniel Rodriguez	29/03/2023			Init version
	1.1			US586996			Mamen Arias			16/05/2023			Add methods testInscripcionNoClienteNewArchitecture, testInscripcionClienteNewArchitecture, testInscripcionClienteYaInscritoNewArchitecture,
																			testInscripcionNoClienteYaInscritoNewArchitecture, testInscripcionInterlocutorConEmpresaNewArchitecture, testInscripcionInterlocutorSinEmpresaNewArchitecture,
																			testInscripcionInterlocutorConVariasEmpresasNewArchitecture, testInscripcionInterlocutorExistenteNewArchitecture, testInscripcionMasDeUnInterlocutorNewArchitecture
***********************************************************************************************************************/
@isTest
public class EV_InscripcionMultipleEnEvento_Test {

    // Request variables
    static final String WS_PATH = '/services/apexrest/EV_InscripcionMultipleEnEvento/';
    static final String HTTP_METHOD = 'POST';
    static final Integer HTTP_STATUS_200 = 200;
    static final Integer HTTP_STATUS_202 = 202;
    static final Integer HTTP_STATUS_203 = 203;
    static final Integer HTTP_STATUS_205 = 205;
    static final Integer HTTP_STATUS_400 = 400;
    
    @TestSetup
    static void makeData(){
        EV_TestHelper.createChildCampaignFisica();
        User user = EV_TestHelper.createUser('EV_Eventos');
		Campaign eventoFisico = [SELECT Id, EV_Acompanante__c, EV_ExternalId__c FROM Campaign LIMIT 1];
        eventoFisico.EV_Acompanante__c = true;
        update eventoFisico;
    }

    @isTest
    //Se testea la inscripción de un no cliente (LEAD)
    public static void testInscripcionNoCliente() {
        User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1]; 
		Campaign eventoFisico = [SELECT Id, EV_Acompanante__c, EV_ExternalId__c FROM Campaign LIMIT 1];
		
		EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = new EV_NoClienteMultipleWrapper.RequestInscripcionBody();
		wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleEvento(eventoFisico.EV_ExternalId__c, null, false);
		
		Test.startTest();
		System.runAs(user){
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
            EV_WS_InscripcionMultipleEnEvento.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
	}

	@isTest
	//Se testea la inscripción de un no cliente (LEAD)
	public static void testInscripcionNoClienteNewArchitecture() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');

		System.runAs(newUser){
			Campaign eventoFisico = [SELECT Id, EV_Acompanante__c, EV_ExternalId__c, EV_NewArchitecture__c FROM Campaign LIMIT 1];
			eventoFisico.EV_NewArchitecture__c = true;
			update eventoFisico;
			
			EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = new EV_NoClienteMultipleWrapper.RequestInscripcionBody();
			wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleEvento(eventoFisico.EV_ExternalId__c, null, false);
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
			EV_WS_InscripcionMultipleEnEvento.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    //Se testea la inscripción de un cliente (Contact);
    public static void testInscripcionCliente() {
        EV_TestHelper.createCampaignMemberContact(false,true);
        User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
		Campaign eventoFisico = [SELECT Id, EV_Acompanante__c, EV_ExternalId__c FROM Campaign LIMIT 1];
		eventoFisico.EV_Acompanante__c = true;
		update eventoFisico;
		CampaignMember campaignMemberInscrito = [SELECT Id, EV_ExternalId__c FROM CampaignMember LIMIT 1];
		EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = new EV_NoClienteMultipleWrapper.RequestInscripcionBody();
		wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleEvento(eventoFisico.EV_ExternalId__c, campaignMemberInscrito.EV_ExternalId__c, false);

		Test.startTest();
		System.runAs(user){
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
            EV_WS_InscripcionMultipleEnEvento.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
	}

	@isTest
	//Se testea la inscripción de un cliente (Contact);
	public static void testInscripcionClienteNewArchitecture() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		
		System.runAs(newUser){
			EV_TestHelper.createCampaignMemberCustomContact(false,true);
			Campaign eventoFisico = [SELECT Id, EV_Acompanante__c, EV_ExternalId__c, EV_NewArchitecture__c FROM Campaign LIMIT 1];
			eventoFisico.EV_Acompanante__c = true;
			eventoFisico.EV_NewArchitecture__c = true;
			update eventoFisico;
			EV_CampaignMemberC__c campaignMemberInscrito = [SELECT Id, EV_ExternalId__c FROM EV_CampaignMemberC__c LIMIT 1];
			EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = new EV_NoClienteMultipleWrapper.RequestInscripcionBody();
			wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleEvento(eventoFisico.EV_ExternalId__c, campaignMemberInscrito.EV_ExternalId__c, false);
			
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
			EV_WS_InscripcionMultipleEnEvento.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    //Se testea la inscripción de un cliente (Contact) ya inscrito;
    public static void testInscripcionClienteYaInscrito() {
        User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
        EV_TestHelper.createCampaignMemberContact(false,true);
		Campaign eventoFisico = [SELECT Id, EV_Acompanante__c, EV_ExternalId__c FROM Campaign LIMIT 1];
		eventoFisico.EV_Acompanante__c = true;
		update eventoFisico;
		CampaignMember campaignMemberInscrito = [SELECT Id, EV_ExternalId__c FROM CampaignMember LIMIT 1];
		campaignMemberInscrito.Status='Registro confirmado';
		update campaignMemberInscrito;
		EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleEvento(eventoFisico.EV_ExternalId__c, campaignMemberInscrito.EV_ExternalId__c, false);
		
		Test.startTest();
		System.runAs(user){
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
            EV_WS_InscripcionMultipleEnEvento.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_202, RestContext.response.statusCode, 'La llamada no ha sido correcta');
	}

	@isTest
	//Se testea la inscripción de un cliente (Contact) ya inscrito;
	public static void testInscripcionClienteYaInscritoNewArchitecture() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');

		System.runAs(newUser){
			EV_TestHelper.createCampaignMemberCustomContact(false,true);
			Campaign eventoFisico = [SELECT Id, EV_Acompanante__c, EV_ExternalId__c, EV_NewArchitecture__c FROM Campaign LIMIT 1];
			eventoFisico.EV_Acompanante__c = true;
			eventoFisico.EV_NewArchitecture__c = true;
			update eventoFisico;

			EV_CampaignMemberC__c campaignMemberInscrito = [SELECT Id, EV_ExternalId__c FROM EV_CampaignMemberC__c LIMIT 1];
			campaignMemberInscrito.EV_Status__c='Registro confirmado';
			update campaignMemberInscrito;
			EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleEvento(eventoFisico.EV_ExternalId__c, campaignMemberInscrito.EV_ExternalId__c, false);

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
			EV_WS_InscripcionMultipleEnEvento.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_202, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }

    @isTest
    //Se testea la inscripción de un no cliente (LEAD) ya inscrito
    public static void testInscripcionNoClienteYaInscrito() {
        User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
        EV_TestHelper.createCampaignMemberLead();

		Campaign eventoFisico = [SELECT Id, EV_ExternalId__c FROM Campaign LIMIT 1];
		CampaignMember campaignMemberInscrito = [SELECT Id, EV_ExternalId__c FROM CampaignMember LIMIT 1];

		EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleEvento(eventoFisico.EV_ExternalId__c, null, false);
		
		Test.startTest();
		System.runAs(user){
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
            EV_WS_InscripcionMultipleEnEvento.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
	}

	@isTest
	//Se testea la inscripción de un no cliente (LEAD) ya inscrito
	public static void testInscripcionNoClienteYaInscritoNewArchitecture() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');

		System.runAs(newUser){
			EV_TestHelper.createCampaignMemberCustomLead();

			Campaign eventoFisico = [SELECT Id, EV_ExternalId__c, EV_NewArchitecture__c FROM Campaign LIMIT 1];
			eventoFisico.EV_NewArchitecture__c = true;
			update eventoFisico;
			EV_CampaignMemberC__c campaignMemberInscrito = [SELECT Id, EV_ExternalId__c FROM EV_CampaignMemberC__c LIMIT 1];
	
			EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleEvento(eventoFisico.EV_ExternalId__c, null, false);
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
			EV_WS_InscripcionMultipleEnEvento.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }

    @isTest
    //Se testea la inscripción de un Interlocutor con empresa registrada en Salesforce
    public static void testInscripcionInterlocutorConEmpresa() {
        User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
        EV_TestHelper.createEmpresa();

		Campaign eventoFisico = [SELECT Id, EV_ExternalId__c FROM Campaign LIMIT 1];
		EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleEvento(eventoFisico.EV_ExternalId__c, null, true);
		
		Test.startTest();
		System.runAs(user){
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
            EV_WS_InscripcionMultipleEnEvento.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
	}

	@isTest
	//Se testea la inscripción de un Interlocutor con empresa registrada en Salesforce
	public static void testInscripcionInterlocutorConEmpresaNewArchitecture() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');

		System.runAs(newUser){
			EV_TestHelper.createEmpresa();

			Campaign eventoFisico = [SELECT Id, EV_ExternalId__c, EV_NewArchitecture__c FROM Campaign LIMIT 1];
			eventoFisico.EV_NewArchitecture__c = true;
			update eventoFisico;
			EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleEvento(eventoFisico.EV_ExternalId__c, null, true);

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
			EV_WS_InscripcionMultipleEnEvento.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }

    @isTest
    //Se testea la inscripción de un Interlocutor con empresa no registrada registrada en Salesforce
    public static void testInscripcionInterlocutorSinEmpresa() {
        User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
		Campaign eventoFisico = [SELECT Id, EV_ExternalId__c FROM Campaign LIMIT 1];
		EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleEvento(eventoFisico.EV_ExternalId__c, null, true);

		Test.startTest();
		System.runAs(user){
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
            EV_WS_InscripcionMultipleEnEvento.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
	}

	@isTest
	//Se testea la inscripción de un Interlocutor con empresa no registrada registrada en Salesforce
	public static void testInscripcionInterlocutorSinEmpresaNewArchitecture() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');

		System.runAs(newUser){
			Campaign eventoFisico = [SELECT Id, EV_ExternalId__c, EV_NewArchitecture__c FROM Campaign LIMIT 1];
			eventoFisico.EV_NewArchitecture__c = true;
			update eventoFisico;
			EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleEvento(eventoFisico.EV_ExternalId__c, null, true);

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
			EV_WS_InscripcionMultipleEnEvento.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    //Se testea la inscripción de un Interlocutor con varias empresas registradas en Salesforce
    public static void testInscripcionInterlocutorConVariasEmpresas() {
        User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
        EV_TestHelper.createEmpresas();

		Campaign eventoFisico = [SELECT Id, EV_ExternalId__c FROM Campaign LIMIT 1];
		EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleEvento(eventoFisico.EV_ExternalId__c, null, true);
		Test.startTest();
		System.runAs(user){
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
            EV_WS_InscripcionMultipleEnEvento.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
	}

	@isTest
	//Se testea la inscripción de un Interlocutor con varias empresas registradas en Salesforce
	public static void testInscripcionInterlocutorConVariasEmpresasNewArchitecture() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');

		System.runAs(newUser){
			EV_TestHelper.createEmpresas();
			Campaign eventoFisico = [SELECT Id, EV_ExternalId__c, EV_NewArchitecture__c FROM Campaign LIMIT 1];
			eventoFisico.EV_NewArchitecture__c = true;
			update eventoFisico;
			EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleEvento(eventoFisico.EV_ExternalId__c, null, true);

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
			EV_WS_InscripcionMultipleEnEvento.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }

    @isTest
    //Se testea la inscripción de un Interlocutor ya existente
    public static void testInscripcionInterlocutorExistente() {
        User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
        EV_TestHelper.createContactInterlocutorEmpresa('TestEmpresa');

		Campaign eventoFisico = [SELECT Id, EV_ExternalId__c FROM Campaign LIMIT 1];
		EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleEvento(eventoFisico.EV_ExternalId__c, null, true);

		Test.startTest();
		System.runAs(user){
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
            EV_WS_InscripcionMultipleEnEvento.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
	}

	@isTest
	//Se testea la inscripción de un Interlocutor ya existente
	public static void testInscripcionInterlocutorExistenteNewArchitecture() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');

		System.runAs(newUser){
			EV_TestHelper.createContactInterlocutorEmpresa('TestEmpresa');

			Campaign eventoFisico = [SELECT Id, EV_ExternalId__c, EV_NewArchitecture__c FROM Campaign LIMIT 1];
			eventoFisico.EV_NewArchitecture__c = true;
			update eventoFisico;
			EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleEvento(eventoFisico.EV_ExternalId__c, null, true);

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
			EV_WS_InscripcionMultipleEnEvento.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }

    @isTest
    //Se testea la inscripción de un Interlocutor cuando existen más de uno iguales.
    public static void testInscripcionMasDeUnInterlocutor() {
        User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
        EV_TestHelper.createContactInterlocutorEmpresa('TestEmpresa');
        EV_TestHelper.createContactInterlocutorEmpresa('Empresa');

		Campaign eventoFisico = [SELECT Id, EV_ExternalId__c FROM Campaign LIMIT 1];
		EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleEvento(eventoFisico.EV_ExternalId__c, null, true);
		
		Test.startTest();
		System.runAs(user){
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
            EV_WS_InscripcionMultipleEnEvento.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
	}

	@isTest
	//Se testea la inscripción de un Interlocutor cuando existen más de uno iguales.
	public static void testInscripcionMasDeUnInterlocutorNewArchitecture() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');

		System.runAs(newUser){
			EV_TestHelper.createContactInterlocutorEmpresa('TestEmpresa');
			EV_TestHelper.createContactInterlocutorEmpresa('Empresa');
	
			Campaign eventoFisico = [SELECT Id, EV_ExternalId__c, EV_NewArchitecture__c FROM Campaign LIMIT 1];
			eventoFisico.EV_NewArchitecture__c = true;
			update eventoFisico;
			EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleEvento(eventoFisico.EV_ExternalId__c, null, true);

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
			EV_WS_InscripcionMultipleEnEvento.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }

    @isTest
    //Se testea la inscripción de un no cliente (LEAD)
    public static void testInscripcionSinEvento() {
        User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
        EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleEvento(null, null, true);
		
		Test.startTest();
		System.runAs(user){
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
            EV_WS_InscripcionMultipleEnEvento.inscripcionPortal();
		}
		Test.stopTest();

		System.assertEquals(HTTP_STATUS_400, RestContext.response.statusCode, 'La llamada no ha sido correcta');
	}
}