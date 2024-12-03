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
    1.2         US737264            Carolina Lopez     09/01/2024           Modify all methods, add coverage and RunAs.                                                                        
***********************************************************************************************************************/
@isTest
public class EV_InscripcionEnEvento_Test {
    // Request variables
    static final String WS_PATH = '/services/apexrest/EV_InscripcionEnEvento/';
    static final String HTTP_METHOD = 'POST';

    @isTest
    //Se testea la inscripción de un cliente (Contact);
	public static void testInscripcionCliente() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        System.runAs(newUser){
            CampaignMember campaignMemberNew = EV_TestHelper.createCampaignMemberContactEmpresa(false,true);
            CampaignMember campaignMemberInscrito = [Select id, EV_ExternalId__c, Campaign.EV_ExternalID__c from CampaignMember where Id =: campaignMemberNew.Id Limit 1];
            EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(campaignMemberInscrito.Campaign.EV_ExternalID__c, campaignMemberInscrito.EV_ExternalId__c, false);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI =WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON)); 
            RestContext.request = req;
            res.statusCode = 200;
            RestContext.response = res; 
        }
        Test.startTest();
        System.runAs(newUser){ 
            Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
            EV_WS_InscripcionEnEvento.inscripcionPortal();
          System.assertEquals(200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
        }
        Test.stopTest();
    }

    //Se testea la inscripción de un cliente (Contact);
    @isTest(SeeAllData=true)
	public static void testInscripcionClienteNewArchitecturePendiente() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            EV_CampaignMemberC__c campaignMemberNew = EV_TestHelper.createCampaignMemberCustomContact(false,true);
            EV_CampaignMemberC__c campaignMemberInscrito = [SELECT Id, EV_ExternalId__c, EV_Status__c, Name, EV_CampaignId__r.EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id =: campaignMemberNew.Id LIMIT 1];
            campaignMemberInscrito.EV_Status__c = 'Pendiente';
            update campaignMemberInscrito;
            EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(campaignMemberInscrito.EV_CampaignId__r.EV_ExternalId__c, campaignMemberInscrito.EV_ExternalId__c, false);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
            RestContext.request = req;
            RestContext.response = res;
            Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
        }
        Test.startTest();
        System.runAs(newUser){
            EV_WS_InscripcionEnEvento.inscripcionPortal();
            System.assertEquals(200, RestContext.response.statusCode, 'Registro OK');
        }
        Test.stopTest();
    }

    @isTest
    //Se testea la inscripción de un cliente (Contact) ya inscrito;
	public static void testInscripcionClienteYaInscrito() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        System.runAs(newUser){
            CampaignMember campaignMemberNew = EV_TestHelper.createCampaignMemberContactEmpresa(false,true);
            CampaignMember campaignMemberInscrito = [SELECT Id, EV_ExternalId__c, Status, Campaign.EV_ExternalId__c FROM CampaignMember WHERE Id =: campaignMemberNew.Id LIMIT 1];
            campaignMemberInscrito.Status='Registro confirmado';
            update campaignMemberInscrito;
            EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(campaignMemberInscrito.Campaign.EV_ExternalId__c, campaignMemberInscrito.EV_ExternalId__c, false);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI =WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON)); 
            RestContext.request = req;
            res.statusCode = 200;
            RestContext.response = res; 
            Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
            Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
        }
        Test.startTest();
        System.runAs(newUser){ 
            EV_WS_InscripcionEnEvento.inscripcionPortal();
            System.assertEquals(200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
        }
        Test.stopTest();
    }
  
    @isTest(SeeAllData=true)
    //Se testea la inscripción de un cliente (Contact) ya inscrito;
	public static void testInscripcionClienteYaInscritoNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
        EV_CampaignMemberC__c campaignMemberNew = EV_TestHelper.createCampaignMemberCustomContact(false,true);
        EV_CampaignMemberC__c campaignMemberInscrito = [SELECT Id, EV_ExternalId__c, EV_Status__c, EV_CampaignId__r.EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id =: campaignMemberNew.Id LIMIT 1];
        campaignMemberInscrito.EV_Status__c='Registro confirmado';
        update campaignMemberInscrito;
        EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(campaignMemberInscrito.EV_CampaignId__r.EV_ExternalId__c, campaignMemberInscrito.EV_ExternalId__c, false);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = WS_PATH; 
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = HTTP_METHOD;
        req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
        RestContext.request = req;
        res.statusCode = 202;
        RestContext.response = res;
        }

        Test.startTest();
		System.runAs(newUser){
            Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
        	EV_WS_InscripcionEnEvento.inscripcionPortal();
          	System.assertEquals(202, RestContext.response.statusCode, 'La llamada no ha sido correcta');
        }
		Test.stopTest();
    }

    @isTest
    //Se testea la inscripción de un cliente (Contact);
	public static void testInscripcionClienteNewArchitectureNoEncontrado() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            EV_CampaignMemberC__c campaignMemberNew = EV_TestHelper.createCampaignMemberCustomContact(false,true);
            EV_CampaignMemberC__c campaignMemberInscrito = [SELECT Id, EV_CampaignId__r.EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id =: campaignMemberNew.Id LIMIT 1];
            EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(campaignMemberInscrito.EV_CampaignId__r.EV_ExternalId__c,'AW77', false);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
            RestContext.request = req;
            res.statusCode = 404;
            RestContext.response = res;
        }
        Test.startTest();
        System.runAs(newUser){
            EV_WS_InscripcionEnEvento.inscripcionPortal();
          System.assertEquals(404, RestContext.response.statusCode, 'Registro no encontrado');
        }
        Test.stopTest();
    }

      @isTest(SeeAllData=true)
    //Se testea la inscripción de un no cliente (LEAD) ya inscrito
	public static void testInscripcionNoClienteYaInscritoNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest();
		System.runAs(newUser){
            EV_CampaignMemberC__c campaignMemberNew = EV_TestHelper.createCampaignMemberCustomLead();
            EV_CampaignMemberC__c campaignMemberInscrito = [Select id, EV_ExternalId__c, EV_NumeroDocumento__c, EV_Status__c, EV_LeadId__r.EV_NumeroDocumento__c, EV_CampaignId__r.EV_ExternalId__c from EV_CampaignMemberC__c where EV_LeadId__r.EV_NumeroDocumento__c != null and Id =:campaignMemberNew.Id Limit 1];
            campaignMemberInscrito.EV_Status__c = 'Registro confirmado';
            update campaignMemberInscrito;
            EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(campaignMemberInscrito.EV_CampaignId__r.EV_ExternalId__c, null, false);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI =WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
            RestContext.request = req;
            RestContext.response = res;
            Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
            EV_WS_InscripcionEnEvento.inscripcionPortal();            
        }
        Test.stopTest();
        System.assertEquals(202,RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }

    //Se testea la inscripción de un Interlocutor con empresa registrada en Salesforce
    @isTest(SeeAllData=true)
	public static void testInscripcionEmpresaNumeroDocumento() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            CampaignMember campaignMemberNew = EV_TestHelper.createCampaignMemberContactEmpresa(false, true);
            CampaignMember campaignMemberInscrito = [SELECT Id, EV_ExternalId__c, EV_NumeroDocumento__c, EV_Empresa__c, Contact.CC_Numero_Documento__c, Campaign.EV_ExternalId__c FROM CampaignMember WHERE Id =: campaignMemberNew.Id/*Contact.CC_Numero_Documento__c != null*/ LIMIT 1];
            campaignMemberInscrito.EV_Empresa__c = true;
            update campaignMemberInscrito;
            EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(campaignMemberInscrito.Campaign.EV_ExternalId__c, campaignMemberInscrito.EV_ExternalId__c, true);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI =WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
            RestContext.request = req; 
            res.statusCode = 200;
            RestContext.response = res;
            Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
        }
        Test.startTest();
        System.runAs(newUser){
        	EV_WS_InscripcionEnEvento.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'La llamada ha sido correcta');
        }
		Test.stopTest();
    }

    //Se testea la inscripción de un Interlocutor con empresa registrada en Salesforce
    @isTest(SeeAllData=true)
	public static void testInscripcionEmpresaNumeroDocumentoCustom() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            EV_CampaignMemberC__c cmCus = EV_TestHelper.createCampaignMemberCustomContact(false, true);
            EV_CampaignMemberC__c campaignMemberInscrito = [Select id, EV_ExternalId__c, EV_NumeroDocumento__c, EV_Empresa__c, EV_ContactId__r.CC_Numero_Documento__c, EV_CampaignId__r.EV_ExternalId__c  from EV_CampaignMemberC__c where id =:cmCus.Id Limit 1];
            campaignMemberInscrito.EV_Empresa__c = true;
            update campaignMemberInscrito;
            EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(campaignMemberInscrito.EV_CampaignId__r.EV_ExternalId__c, campaignMemberInscrito.EV_ExternalId__c , true);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI =WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
            RestContext.request = req; 
            res.statusCode = 200;
            RestContext.response = res;
            Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
        }
        Test.startTest();
        System.runAs(newUser){
        	EV_WS_InscripcionEnEvento.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'La llamada ha sido correcta');
        }
		Test.stopTest();
    }

    @isTest
    //Se testea la inscripción de un Interlocutor con empresa registrada en Salesforce
	public static void testInscripcionInterlocutorNumperNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            EV_CampaignMemberC__c campMemberNew = EV_TestHelper.createCampaignMemberCustomContact(false,true);
            Contact cont = [SELECT Id, CC_NumPerso__c FROM Contact WHERE Id =: campMemberNew.EV_ContactId__c];
    		cont.CC_NumPerso__c = '123';
            update cont;
            EV_CampaignMemberC__c campaignMemberInscrito = [SELECT Id, EV_ExternalId__c, EV_NumeroDocumento__c, EV_Empresa__c, EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE Id =: campMemberNew.Id LIMIT 1];
            Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c, EV_TechSummit__c FROM Campaign WHERE Id =: campaignMemberInscrito.EV_CampaignId__c LIMIT 1];
            eventoVirtual.EV_TechSummit__c = true;
            update eventoVirtual;
            campaignMemberInscrito.EV_CampaignId__c = eventoVirtual.Id;
            campaignMemberInscrito.EV_Empresa__c = true;
            update campaignMemberInscrito;
            EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(eventoVirtual.EV_ExternalId__c, null, true);
            wrapperJSON.numper = '123';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI =WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
            RestContext.request = req;
            res.statusCode = 500;
            RestContext.response = res;
        }
        Test.startTest();
        System.runAs(newUser){
        	EV_WS_InscripcionEnEvento.inscripcionPortal();
          	System.assertEquals(500, RestContext.response.statusCode, 'La llamada no ha sido correcta');
        }
		Test.stopTest();
    }

    @isTest
    //Se testea la inscripción de un Interlocutor con empresa registrada en Salesforce
	public static void testInscripcionInterNewArchitectureCorrecto() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            EV_CampaignMemberC__c campMemberNew = EV_TestHelper.createCampaignMemberCustomContact(false,true);
            Contact cont = [SELECT Id, CC_NumPerso__c FROM Contact WHERE Id =: campMemberNew.EV_ContactId__c LIMIT 1];
    		cont.CC_NumPerso__c = '123';
            update cont;
            EV_CampaignMemberC__c campaignMemberInscrito = [SELECT Id, EV_ExternalId__c, EV_NumeroDocumento__c, EV_Empresa__c, EV_CampaignId__r.EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id =: campMemberNew.Id LIMIT 1];
            campaignMemberInscrito.EV_Empresa__c = true;
            update campaignMemberInscrito;
            EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(campaignMemberInscrito.EV_CampaignId__r.EV_ExternalId__c, null, true);
            wrapperJSON.numper = '123';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI =WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
            RestContext.request = req;
            res.statusCode = 200;
            RestContext.response = res;
        }
        Test.startTest();
        System.runAs(newUser){
        	EV_WS_InscripcionEnEvento.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
        }
		Test.stopTest();
    }

    @isTest
    //Se testea la inscripción de un Interlocutor
	public static void testInscripcionNumper() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            EV_TestHelper.createContactAux('Test');
            EV_TestHelper.createCampaignMemberContactEmpresa(false,true);
            Contact cont = [SELECT Id, CC_NumPerso__c FROM Contact WHERE LastName = 'Test'];
    		cont.CC_NumPerso__c = '123';
            update cont;
            Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c FROM Campaign LIMIT 1];
            EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(eventoVirtual.EV_ExternalId__c, null, false);
            wrapperJSON.numper = '123';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI =WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
            RestContext.request = req;
            res.statusCode = 200;
            RestContext.response = res;
        }
        Test.startTest();
        System.runAs(newUser){
            EV_WS_InscripcionEnEvento.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
        }
		Test.stopTest();
    }
    
    @isTest
    //Se testea la inscripción de un no cliente (LEAD)
	public static void testInscripcionSinEvento() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        System.runAs(newUser){
            EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = EV_TestHelper.createWrapperJSONInscripcion(null, null, true);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI =WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
            RestContext.request = req;
            res.statusCode = 404;
            RestContext.response = res;
        }
        Test.startTest();
        System.runAs(newUser){
            EV_WS_InscripcionEnEvento.inscripcionPortal();
          	System.assertEquals(404, RestContext.response.statusCode, 'La llamada no ha sido correcta');  
        }
		Test.stopTest();
    }
}