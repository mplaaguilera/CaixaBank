/*********************************************************************************************************************
 Name:  EV_InscripcionMultiple_Test
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test para Web service EV_InscripcionMultiple_Test de Portal
---------------------------------------------------------------------------------------------------------------------- 
 * VERSION        USER_STORY         AUTHOR              DATE         Description
 * 1.0            US622078           Carolina Lopez      01/06/2023   Init Version
 * 1.1            US661500           Carolina Lopez      31/07/2023   Add Mock call TestSetup and methods testInscripcionClienteNewArchitectureNoEncontrado, testInscripcionClienteSinFormularioNewArchitecture, 
 *                                                                      testInscripcionClienteErrorIdInvitacion to improve coverage
 * 1.2			  US680535			 Daniel Rodriguez 	 17/08/2023   Modify all assert test method
 * 1.3			  US680535			 Carolina Lopez 	 18/08/2023   Modify error code of duplicate elements 204 by 202
 * 1.4            FIX                Carolina Lopez      01/02/2024   Modify testInscripcionNoClienteYaInscritoNewArchitecture with seeAllData > ConnectApi Error and remove TestSetup.
 * 1.5            TechSummit         Carolina Lopez      14/05/2024   Modify all methods to include with record types techsummit.
***********************************************************************************************************************/
@isTest
public class EV_InscripcionMultiple_Test {
    // Request variables
    static final String WS_PATH = '/services/apexrest/EV_InscripcionMultiple/';
    static final String HTTP_METHOD = 'POST';

    @isTest
    //Se testea la inscripción de un nocliente (LEAD)
	public static void testInscripcionNoCliente() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
        System.runAs(newUser){
            Campaign camp = EV_TestHelper.createParentCampaignTechSummit();
            idEvento.add(camp.EV_ExternalID__c);
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, null, false);
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
          EV_WS_InscripcionMultiple.inscripcionPortal();
          System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
        Test.stopTest();
    }

    @isTest
    //Se testea la inscripción de un no cliente (LEAD) New Architecturre
	public static void testInscripcionNoClienteNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
		System.runAs(newUser){
            Campaign camp = EV_TestHelper.createParentCampaignTechSummit();
            camp.EV_NewArchitecture__c = true;
            camp.EV_TechSummit__c = true;
            update camp;
            idEvento.add(camp.EV_ExternalID__c);
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, null, false);
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
          EV_WS_InscripcionMultiple.inscripcionPortal();
          System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
        Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un cliente (Contact);
	public static void testInscripcionClienteNewArchitectureNoEncontrado() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
		System.runAs(newUser){
            EV_TestHelper.createCampaignMemberCustomLeadTechSummit(false,true);
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, EV_TechSummit__c from Campaign Limit 1];
            for(Campaign cm : lstEventoVirtual){
                idEvento.add(cm.EV_ExternalId__c);
                cm.EV_NewArchitecture__c = true;
                cm.EV_TechSummit__c = true;
            }
            update lstEventoVirtual;
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento,'AW77', false);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
            RestContext.request = req;
            res.statusCode = 404;
            RestContext.response = res;
            Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
        }
        Test.startTest();
        System.runAs(newUser){
          EV_WS_InscripcionMultiple.inscripcionPortal();
          System.assertEquals(404, RestContext.response.statusCode, 'Registro no encontrado');
        }
        Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un cliente (Contact);
	public static void testInscripcionClienteNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
		System.runAs(newUser){
            EV_CampaignMemberC__c campaignMemberInscrito = EV_TestHelper.createCampaignMemberCustomLeadTechSummit(false,true);
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c from Campaign Limit 2];
            for(Campaign cm : lstEventoVirtual){
                idEvento.add(cm.EV_ExternalId__c);
                cm.EV_NewArchitecture__c = true;
                cm.EV_TechSummit__c = true;
            }
            update lstEventoVirtual;
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, campaignMemberInscrito.EV_ExternalId__c, false);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = WS_PATH; 
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
            EV_WS_InscripcionMultiple.inscripcionPortal();
          System.assertEquals(200, RestContext.response.statusCode, 'Registro no encontrado');
        }
        Test.stopTest();
    }

    @isTest
    //Se testea la inscripción de un cliente (Contact) IdInvitación erroneo;
	public static void testInscripcionClienteErrorIdInvitacion() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
		System.runAs(newUser){
            EV_CampaignMemberC__c campaignMemberInscrito = EV_TestHelper.createCampaignMemberCustomLeadTechSummit(false,true);
            campaignMemberInscrito.EV_Empresa__c = true;
            update campaignMemberInscrito;
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, EV_TechSummit__c from Campaign Limit 2];
            for(Campaign cm : lstEventoVirtual){
                idEvento.add(cm.EV_ExternalId__c);
                cm.EV_NewArchitecture__c = true;
                cm.EV_TechSummit__c = true;
            }
            update lstEventoVirtual;
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, campaignMemberInscrito.EV_ExternalId__c, true);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
            RestContext.request = req;
            RestContext.response = res;
            res.statusCode = 404;
            EV_WS_InscripcionMultiple.inscripcionPortal();

            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON2 = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, campaignMemberInscrito.EV_ExternalId__c, false);
            RestRequest req1 = new RestRequest(); 
            RestResponse res1 = new RestResponse();
            req1.requestURI = WS_PATH; 
            req1.addHeader('Content-Type', 'application/json');
            req1.httpMethod = HTTP_METHOD;
            req1.requestBody = Blob.valueof(JSON.serialize(wrapperJSON2));
            RestContext.request = req1;
            res.statusCode = 404;
            RestContext.response = res1;
            Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
        }
        Test.startTest();
        System.runAs(newUser){
            EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(null, RestContext.response.statusCode, 'idInvitacion no encontrado');
        }
        Test.stopTest();
    }

    @isTest
    //Se testea la inscripción de un cliente (Contact) sin datos;
	public static void testInscripcionClienteSinDatosNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
		System.runAs(newUser){
        EV_TestHelper.createCampaignMemberCustomLeadTechSummit(false,true);
        List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, EV_TechSummit__c from Campaign Limit 2];
        for(Campaign cm : lstEventoVirtual){
            idEvento.add(cm.EV_ExternalId__c);
            cm.EV_NewArchitecture__c = true;
            cm.EV_TechSummit__c = true;
        }
        update lstEventoVirtual;
        EV_CampaignMemberC__c campaignMemberInscrito = [Select id, EV_ExternalId__c,EV_Status__c from EV_CampaignMemberC__c Limit 1];
        campaignMemberInscrito.EV_Status__c='Registro confirmado';
        update campaignMemberInscrito;
        EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, '65759jn4bv347k473473', false);
        wrapperJSON.datosFormulario = null;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = WS_PATH; 
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = HTTP_METHOD;
        req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
        RestContext.request = req;
        res.statusCode = 404;
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
        }
        Test.startTest();
		System.runAs(newUser){
        	EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(404, RestContext.response.statusCode, 'Registro no encontrado');
        }
		Test.stopTest();
    }

     @isTest
    //Se testea la inscripción de un cliente (Contact) sin datos;
	public static void testInscripcionClienteSinFormularioNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
		System.runAs(newUser){
        EV_TestHelper.createCampaignMemberCustomLeadTechSummit(false,true);
        List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, EV_TechSummit__c from Campaign Limit 2];
        for(Campaign cm : lstEventoVirtual){
            idEvento.add(cm.EV_ExternalId__c);
            cm.EV_NewArchitecture__c = true;
            cm.EV_TechSummit__c = true;
        }
        update lstEventoVirtual;
        EV_CampaignMemberC__c campaignMemberInscrito = [Select id, EV_ExternalId__c,EV_Status__c from EV_CampaignMemberC__c Limit 1];
        campaignMemberInscrito.EV_Status__c='Registro confirmado';
        update campaignMemberInscrito;
        EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, '65759jn4bv347k473473', false);
        wrapperJSON.datosFormulario = null;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = WS_PATH; 
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = HTTP_METHOD;
        req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
        RestContext.request = req;
        res.statusCode = 400;
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
        }
        Test.startTest();
		System.runAs(newUser){
        	EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(400, RestContext.response.statusCode, 'Sin datos');
        }
        Test.stopTest();
    }

    @isTest
    //Se testea la inscripción de un cliente (Contact) ya inscrito;
	public static void testInscripcionClienteYaInscritoNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
		System.runAs(newUser){
        EV_CampaignMemberC__c campaignMemberInscrito = EV_TestHelper.createCampaignMemberCustomLeadTechSummit(false,true);
        List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, EV_TechSummit__c from Campaign Limit 1];
        for(Campaign cm : lstEventoVirtual){
            idEvento.add(cm.EV_ExternalId__c);
            cm.EV_NewArchitecture__c = true;
            cm.EV_TechSummit__c = true;
        }
        update lstEventoVirtual;
        campaignMemberInscrito.EV_Status__c='Registro confirmado';
        update campaignMemberInscrito;
        EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, campaignMemberInscrito.EV_ExternalId__c, false);
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
        	EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(202, RestContext.response.statusCode, 'Ya inscrito');
        }
		Test.stopTest();
    }

    @isTest
    //Se testea la inscripción de un cliente (Contact) ya inscrito;
	public static void testInscripcionClientePendienteNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
		System.runAs(newUser){
        EV_CampaignMemberC__c campaignMemberInscrito = EV_TestHelper.createCampaignMemberCustomLeadTechSummit(false,true);
        List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, EV_TechSummit__c from Campaign Limit 1]; 
        for(Campaign cm : lstEventoVirtual){
            idEvento.add(cm.EV_ExternalId__c);
            cm.EV_NewArchitecture__c = true;
            cm.EV_TechSummit__c = true;
            campaignMemberInscrito.EV_campaignid__c = cm.id;
        }
        update lstEventoVirtual;
        campaignMemberInscrito.EV_Empresa__c = false;
        update campaignMemberInscrito;
        EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, campaignMemberInscrito.EV_ExternalId__c, false);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = WS_PATH; 
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = HTTP_METHOD;
        req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
        RestContext.request = req;
        res.statusCode = 200;
        RestContext.response = res;
        }
        Test.startTest();
		System.runAs(newUser){
        	EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Ya inscrito');
        }
		Test.stopTest();
    }

    @isTest(SeeAllData=true)
    //Se testea la inscripción de un no cliente (LEAD) ya inscrito sin IdInvitación
	public static void testInscripcionNoClienteYaInscritoNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
		System.runAs(newUser){
            EV_CampaignMemberC__c campaignMemberInscrito = EV_TestHelper.createCampaignMemberCustomLeadTechSummit(true, false);
            Campaign lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, EV_TechSummit__c from Campaign where id =:campaignMemberInscrito.EV_campaignId__c Limit 1];
            idEvento.add(lstEventoVirtual.EV_ExternalId__c);
            lstEventoVirtual.EV_NewArchitecture__c = true;
            lstEventoVirtual.EV_TechSummit__c = true;
            update lstEventoVirtual;
            campaignMemberInscrito.EV_Status__c='Registro confirmado';
            update campaignMemberInscrito;
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, null, false);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI =WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
			res.statusCode = 202;
            RestContext.request = req;
            RestContext.response = res;
            Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
        }
        Test.startTest();
		System.runAs(newUser){
            EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(202, RestContext.response.statusCode, 'Ya inscrito');
        }
        Test.stopTest();  
    }

    @isTest
    //Se testea la inscripción de un Interlocutor con empresa registrada en Salesforce
	public static void testInscripcionInterlocutorConEmpresa() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
        System.runAs(newUser){
            EV_TestHelper.createEmpresa();
            Campaign camp = EV_TestHelper.createParentCampaignTechSummit();
            idEvento.add(camp.EV_ExternalID__c);
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, null, true);
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
            EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
        Test.stopTest();
    }

    @isTest
    //Se testea la inscripción de un Interlocutor con empresa registrada en Salesforce
	public static void testInscripcionInterlocutorConEmpresaNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
		System.runAs(newUser){
            EV_TestHelper.createEmpresa();
            Campaign camp = EV_TestHelper.createParentCampaignTechSummit();
            camp.EV_NewArchitecture__c = true;
            camp.EV_TechSummit__c = true;
            update camp;
            idEvento.add(camp.EV_ExternalID__c);
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, null, true);
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
        	EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
		Test.stopTest();
    }

    @isTest
    //Se testea la inscripción de un Interlocutor con empresa registrada en Salesforce
	public static void testInscripcionInterlocutorConEmpresaYnifNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
		System.runAs(newUser){
            EV_TestHelper.createEmpresa();
            EV_CampaignMemberC__c cmcustom = EV_TestHelper.createCampaignMemberCustomLeadTechSummit(false,true);
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, EV_TechSummit__c from Campaign Limit 2];
            for(Campaign cm : lstEventoVirtual){
                idEvento.add(cm.EV_ExternalId__c);
                cm.EV_NewArchitecture__c = true;
                cm.EV_TechSummit__c = true;
                cmcustom.EV_campaignid__c = cm.id;
            }
            cmcustom.EV_Empresa__c = true;
            update cmcustom;
            update lstEventoVirtual;
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, cmcustom.EV_ExternalId__c, true);
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
        	EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
		Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un Interlocutor con empresa registrada en Salesforce
	public static void testInscripcionInterlocutorNumperNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
		System.runAs(newUser){
            EV_TestHelper.createContactAux('Test');
            EV_CampaignMemberC__c cmcustom = EV_TestHelper.createCampaignMemberCustomLeadTechSummit(false,true);
            Contact cont = [Select id,CC_NumPerso__c from Contact where LastName = 'Test'];
    		cont.CC_NumPerso__c = '123';
            update cont;
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, EV_TechSummit__c from Campaign Limit 2];
            for(Campaign cm : lstEventoVirtual){
                idEvento.add(cm.EV_ExternalId__c);
                cm.EV_NewArchitecture__c = true;
                cm.EV_TechSummit__c = true;
                cmcustom.EV_campaignid__c = cm.id;
            }
            cmcustom.EV_Empresa__c = true;
            update cmcustom;
            update lstEventoVirtual;
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, null, true);
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
        	EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
		Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un Interlocutor
	public static void testInscripcionInterlocutorNumper() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
		System.runAs(newUser){
            EV_TestHelper.createCampaignMemberCustomLeadTechSummit(false, true);
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c from Campaign Where Name = 'TestCampaign' Limit 2];
            for(Campaign cm : lstEventoVirtual){
                idEvento.add(cm.EV_ExternalId__c);
                cm.EV_NewArchitecture__c = true;
                cm.EV_TechSummit__c = true;
            }
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, null, true);
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
            EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
		Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un Interlocutor con empresa no registrada registrada en Salesforce Custom
	public static void testInscripcionInterlocutorCustomSinEmpresa() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
        System.runAs(newUser){
            Campaign eventoVirtual = EV_TestHelper.createParentCampaignTechSummit();
            idEvento.add(eventoVirtual.EV_ExternalId__c);
            eventoVirtual.EV_NewArchitecture__c = true;
            eventoVirtual.EV_TechSummit__c = true;
            update eventoVirtual;
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, null, true);
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
            EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
		Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un Interlocutor con empresa no registrada registrada en Salesforce
	public static void testInscripcionInterlocutorSinEmpresa() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
        System.runAs(newUser){
            Campaign eventoVirtual = EV_TestHelper.createParentCampaignTechSummit();
            idEvento.add(eventoVirtual.EV_ExternalId__c);
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, null, true);
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
            EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
		Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un Interlocutor con varias empresas registradas en Salesforce
	public static void testInscripcionInterlocutorConVariasEmpresas() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
        System.runAs(newUser){
            EV_TestHelper.createEmpresas();
            Campaign eventoVirtual = EV_TestHelper.createParentCampaignTechSummit();
            idEvento.add(eventoVirtual.EV_ExternalId__c);
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, null, true);
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
            EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
		Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un Interlocutor ya existente
	public static void testInscripcionInterlocutorExistente() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
        System.runAs(newUser){
            EV_TestHelper.createContactInterlocutorEmpresa('TestEmpresa');
            Campaign eventoVirtual = EV_TestHelper.createParentCampaignTechSummit();
            idEvento.add(eventoVirtual.EV_ExternalId__c);
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, null, true);
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
            EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
		Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un Interlocutor cuando existen más de uno iguales.
	public static void testInscripcionMasDeUnInterlocutor() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
        System.runAs(newUser){
            EV_TestHelper.createContactInterlocutorEmpresa('TestEmpresa');
            EV_TestHelper.createContactInterlocutorEmpresa('Empresa');
            Campaign eventoVirtual = EV_TestHelper.createParentCampaignTechSummit();
            idEvento.add(eventoVirtual.EV_ExternalId__c);
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, null, true);
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
            EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
		Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un no cliente (LEAD)
	public static void testInscripcionSinEvento() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> idEvento = new List<String>();
        System.runAs(newUser){
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(idEvento, null, true);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI =WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
            RestContext.request = req;
            res.statusCode = 404;
            RestContext.response = res;
            Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
        }
        Test.startTest();
        System.runAs(newUser){
            EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(404, RestContext.response.statusCode, 'No existe');  
        }
		Test.stopTest();
    }
}