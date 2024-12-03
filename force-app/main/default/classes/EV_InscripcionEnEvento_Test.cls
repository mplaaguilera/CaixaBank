/**********************************************************************************************************************
 Name:	  EV_InscripcionEnEvento_Test
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test para Web service EV_InscripcionEnEvento_Test de Portal
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		  	US586996			Daniel Rodriguez   08/05/2023			Modify version new Architecture with the new object EV_CampaignMemberC__c
	1.1			US586996			Daniel Rodriguez   12/05/2023			Add method testInscripcionNoClienteNewArchitecture, testInscripcionClienteNewArchitecture, testInscripcionClienteYaInscritoNewArchitecture, testInscripcionInterlocutorConEmpresaNewArchitecture
																			testInscripcionInterlocutorConEmpresaYnifNewArchitecture, testInscripcionInterlocutorNumper, testInscripcionInterlocutorNumperNewArchitecture
***********************************************************************************************************************/


@isTest
public class EV_InscripcionEnEvento_Test {

    // Request variables
    static final String WS_PATH = '/services/apexrest/EV_InscripcionEnEvento/';
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
        Campaign eventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 1];
        EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(eventoVirtual.EV_ExternalId__c, null, false);

        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI =WS_PATH; 
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = HTTP_METHOD;
        req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
        
        RestContext.request = req;
        RestContext.response = res;
        EV_WS_InscripcionEnEvento.inscripcionPortal();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
    }


    @isTest
    //Se testea la inscripción de un no cliente (LEAD) New Architecturre
	public static void testInscripcionNoClienteNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            Campaign eventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 1];
            eventoVirtual.EV_NewArchitecture__c = true;
            update eventoVirtual;
            EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(eventoVirtual.EV_ExternalId__c, null, false);
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
        	EV_WS_InscripcionEnEvento.inscripcionPortal();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    //Se testea la inscripción de un cliente (Contact);
	public static void testInscripcionCliente() {
        EV_TestHelper.createCampaignMemberContact(false,true);
        Campaign eventoVirtual = [Select id, EV_ExternalId__c from Campaign where EV_NewArchitecture__c= false Limit 1];
        CampaignMember campaignMemberInscrito = [Select id, EV_ExternalId__c from CampaignMember where campaign.EV_NewArchitecture__c = false Limit 1];
        EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(eventoVirtual.EV_ExternalId__c, campaignMemberInscrito.EV_ExternalId__c, false);

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
        EV_WS_InscripcionEnEvento.inscripcionPortal();

        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
    }
    
    @isTest
    //Se testea la inscripción de un cliente (Contact);
	public static void testInscripcionClienteNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            EV_TestHelper.createCampaignMemberCustomContact(false,true);
            Campaign eventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 1];
            eventoVirtual.EV_NewArchitecture__c = true;
            update eventoVirtual;
            EV_CampaignMemberC__c campaignMemberInscrito = [Select id, EV_ExternalId__c from EV_CampaignMemberC__c Limit 1];
            EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(eventoVirtual.EV_ExternalId__c, campaignMemberInscrito.EV_ExternalId__c, false);
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
        	EV_WS_InscripcionEnEvento.inscripcionPortal();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    //Se testea la inscripción de un cliente (Contact) ya inscrito;
	public static void testInscripcionClienteYaInscrito() {
        EV_TestHelper.createCampaignMemberContact(false,true);
        Campaign eventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 1];
        CampaignMember campaignMemberInscrito = [Select id, EV_ExternalId__c from CampaignMember Limit 1];
        campaignMemberInscrito.Status='Registro confirmado';
        update campaignMemberInscrito;
        EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(eventoVirtual.EV_ExternalId__c, campaignMemberInscrito.EV_ExternalId__c, false);

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
        EV_WS_InscripcionEnEvento.inscripcionPortal();
        
        System.assertEquals(HTTP_STATUS_202, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
    }
    
    @isTest
    //Se testea la inscripción de un cliente (Contact) ya inscrito;
	public static void testInscripcionClienteYaInscritoNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
        EV_TestHelper.createCampaignMemberCustomContact(false,true);
        Campaign eventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 1];
        eventoVirtual.EV_NewArchitecture__c = true;
        update eventoVirtual;
        EV_CampaignMemberC__c campaignMemberInscrito = [Select id, EV_ExternalId__c,EV_Status__c from EV_CampaignMemberC__c Limit 1];
        campaignMemberInscrito.EV_Status__c='Registro confirmado';
        update campaignMemberInscrito;
        EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(eventoVirtual.EV_ExternalId__c, campaignMemberInscrito.EV_ExternalId__c, false);
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
        	EV_WS_InscripcionEnEvento.inscripcionPortal();
        }
		Test.stopTest();
            
        System.assertEquals(HTTP_STATUS_202, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }

    @isTest
    //Se testea la inscripción de un no cliente (LEAD) ya inscrito
	public static void testInscripcionNoClienteYaInscrito() {
        EV_TestHelper.createCampaignMemberLead();

        Campaign eventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 1];
        CampaignMember campaignMemberInscrito = [Select id, EV_ExternalId__c from CampaignMember Limit 1];

        EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(eventoVirtual.EV_ExternalId__c, null, false);

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
        EV_WS_InscripcionEnEvento.inscripcionPortal();
        
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
    }
    
    
    @isTest
    //Se testea la inscripción de un no cliente (LEAD) ya inscrito
	public static void testInscripcionNoClienteYaInscritoNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            EV_TestHelper.createCampaignMemberCustomLead();
            Campaign eventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 1];
            eventoVirtual.EV_NewArchitecture__c = true;
            update eventoVirtual;
            EV_CampaignMemberC__c campaignMemberInscrito = [Select id, EV_ExternalId__c from EV_CampaignMemberC__c Limit 1];
            EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(eventoVirtual.EV_ExternalId__c, null, false);
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
            EV_WS_InscripcionEnEvento.inscripcionPortal();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
       
    }

    @isTest
    //Se testea la inscripción de un Interlocutor con empresa registrada en Salesforce
	public static void testInscripcionInterlocutorConEmpresa() {
        EV_TestHelper.createEmpresa();

        Campaign eventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 1];
        EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(eventoVirtual.EV_ExternalId__c, null, true);

        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI =WS_PATH; 
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = HTTP_METHOD;
        req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
        
        RestContext.request = req;
        RestContext.response = res;
        EV_WS_InscripcionEnEvento.inscripcionPortal();
        
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
    }
    
    @isTest
    //Se testea la inscripción de un Interlocutor con empresa registrada en Salesforce
	public static void testInscripcionInterlocutorConEmpresaNewArchitecture() {
        
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            EV_TestHelper.createEmpresa();
            Campaign eventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 1];
            eventoVirtual.EV_NewArchitecture__c = true;
            update eventoVirtual;
            EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(eventoVirtual.EV_ExternalId__c, null, true);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI =WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
            RestContext.request = req;
            RestContext.response = res;
        }
        Test.startTest();
        System.runAs(newUser){
            Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
        	Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
        	EV_WS_InscripcionEnEvento.inscripcionPortal();
        }
		Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
     @isTest
    //Se testea la inscripción de un Interlocutor con empresa registrada en Salesforce
	public static void testInscripcionInterlocutorConEmpresaYnifNewArchitecture() {
        
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            EV_TestHelper.createEmpresa();
            EV_TestHelper.createCampaignMemberCustomContact(false,true);
            Campaign eventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 1];
            EV_CampaignMemberC__c campaignMemberInscrito = [Select id, EV_ExternalId__c, EV_NumeroDocumento__c, EV_Empresa__c from EV_CampaignMemberC__c Limit 1];
            campaignMemberInscrito.EV_campaignid__c = eventoVirtual.id;
            campaignMemberInscrito.EV_Empresa__c = true;
            update campaignMemberInscrito;
            
            eventoVirtual.EV_NewArchitecture__c = true;
            update eventoVirtual;
            EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(eventoVirtual.EV_ExternalID__c, campaignMemberInscrito.EV_ExternalId__c, true);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI =WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
            RestContext.request = req;
            RestContext.response = res;
        }
        Test.startTest();
        System.runAs(newUser){
            Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
        	Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
        	EV_WS_InscripcionEnEvento.inscripcionPortal();
        }
		Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    //Se testea la inscripción de un Interlocutor con empresa registrada en Salesforce
	public static void testInscripcionInterlocutorNumperNewArchitecture() {
        
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            EV_TestHelper.createContactAux('Test');
            EV_TestHelper.createCampaignMemberCustomContact(false,true);
            Contact cont = [Select id,CC_NumPerso__c from Contact where LastName = 'Test'];
    		cont.CC_NumPerso__c = '123';
            update cont;
            Campaign eventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 1];
            EV_CampaignMemberC__c campaignMemberInscrito = [Select id, EV_ExternalId__c, EV_NumeroDocumento__c, EV_Empresa__c from EV_CampaignMemberC__c Limit 1];
            campaignMemberInscrito.EV_campaignid__c = eventoVirtual.id;
            campaignMemberInscrito.EV_Empresa__c = true;
            update campaignMemberInscrito;
            
            eventoVirtual.EV_NewArchitecture__c = true;
            update eventoVirtual;
            EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(eventoVirtual.EV_ExternalID__c, null, true);
            wrapperJSON.numper = cont.CC_NumPerso__c;
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI =WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
            RestContext.request = req;
            RestContext.response = res;
        }
        Test.startTest();
        System.runAs(newUser){
            Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
        	Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
        	EV_WS_InscripcionEnEvento.inscripcionPortal();
        }
		Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    //Se testea la inscripción de un Interlocutor con numper //Nuevo
	public static void testInscripcionInterlocutorNumper() {
        
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            EV_TestHelper.createContactAux('Test');
            EV_TestHelper.createCampaignMemberContact(false,true);
            Contact cont = [Select id,CC_NumPerso__c from Contact where LastName = 'Test'];
    		cont.CC_NumPerso__c = '123';
            update cont;
            Campaign eventoVirtual = [Select id, EV_ExternalId__c from Campaign Where Name = 'TestCampaign' Limit 1];
            EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(eventoVirtual.EV_ExternalID__c, null, true);
            wrapperJSON.numper = cont.CC_NumPerso__c;
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI =WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
            RestContext.request = req;
            RestContext.response = res;
        }
        Test.startTest();
        System.runAs(newUser){
            Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
        	Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
        	EV_WS_InscripcionEnEvento.inscripcionPortal();
        }
		Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }


    @isTest
    //Se testea la inscripción de un Interlocutor con empresa no registrada registrada en Salesforce
	public static void testInscripcionInterlocutorSinEmpresa() {

        Campaign eventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 1];
        EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(eventoVirtual.EV_ExternalId__c, null, true);

        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI =WS_PATH; 
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = HTTP_METHOD;
        req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
        
        RestContext.request = req;
        RestContext.response = res;
        EV_WS_InscripcionEnEvento.inscripcionPortal();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
    }
    
    @isTest
    //Se testea la inscripción de un Interlocutor con varias empresas registradas en Salesforce
	public static void testInscripcionInterlocutorConVariasEmpresas() {
        EV_TestHelper.createEmpresas();

        Campaign eventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 1];
        EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(eventoVirtual.EV_ExternalId__c, null, true);

        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI =WS_PATH; 
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = HTTP_METHOD;
        req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
        
        RestContext.request = req;
        RestContext.response = res;
        EV_WS_InscripcionEnEvento.inscripcionPortal();
        
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
    }

    @isTest
    //Se testea la inscripción de un Interlocutor ya existente
	public static void testInscripcionInterlocutorExistente() {

        EV_TestHelper.createContactInterlocutorEmpresa('TestEmpresa');

        Campaign eventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 1];
        EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(eventoVirtual.EV_ExternalId__c, null, true);

        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI =WS_PATH; 
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = HTTP_METHOD;
        req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
        
        RestContext.request = req;
        RestContext.response = res;
        EV_WS_InscripcionEnEvento.inscripcionPortal();

        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
    }

    @isTest
    //Se testea la inscripción de un Interlocutor cuando existen más de uno iguales.
	public static void testInscripcionMasDeUnInterlocutor() {

        EV_TestHelper.createContactInterlocutorEmpresa('TestEmpresa');
        EV_TestHelper.createContactInterlocutorEmpresa('Empresa');

        Campaign eventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 1];
        EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(eventoVirtual.EV_ExternalId__c, null, true);

        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI =WS_PATH; 
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = HTTP_METHOD;
        req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
        
        RestContext.request = req;
        RestContext.response = res;
        EV_WS_InscripcionEnEvento.inscripcionPortal();

        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
    }

    @isTest
    //Se testea la inscripción de un no cliente (LEAD)
	public static void testInscripcionSinEvento() {

        EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(null, null, true);

        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI =WS_PATH; 
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = HTTP_METHOD;
        req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
        
        RestContext.request = req;
        RestContext.response = res;
        EV_WS_InscripcionEnEvento.inscripcionPortal();

        System.assertEquals(HTTP_STATUS_205, RestContext.response.statusCode, 'La llamada no ha sido correcta');

		Test.stopTest();
    }

}