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
***********************************************************************************************************************/
@isTest
public class EV_InscripcionMultiple_Test {
    // Request variables
    static final String WS_PATH = '/services/apexrest/EV_InscripcionMultiple/';
    static final String HTTP_METHOD = 'POST';
    
    @TestSetup
    static void makeData(){
        EV_TestHelper.createParentCampaignTechSummit();

        Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
        header2TestResp.put('https://qrpass-qrpass.tst.icp-1.internet.cloud.lacaixa.es/qrpass/NEMzNzU4MTg1QjM2MzcxQTAxMzYwQ0MzQTYxMjU5QzM3N0Y2OTMzMjZFREExQUYwQ0IyQzE0Q0M3ODMwNUVBOQ==',new EV_ConexionQR_Mock(200));

        if (DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) {
            header2TestResp.put('callout:API_GWT_PRO/servicing/registers',new EV_ConexionQR_Mock(200));
            header2TestResp.put('callout:EV_PROAdobeCampaign',new EV_AdobeCampaignInscripcion_Mock());
        } else {
            header2TestResp.put('callout:API_GWT_PRE/servicing/registers',new EV_ConexionQR_Mock(200));
            header2TestResp.put('callout:EV_PREAdobeCampaign',new EV_AdobeCampaignInscripcion_Mock());
        }
        
        HttpCalloutMock multiCalloutMock = new EV_multipleRequestConexionMock_Test(header2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
	}

    @isTest
    //Se testea la inscripción de un nocliente (LEAD)
	public static void testInscripcionNoCliente() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        System.runAs(newUser){
            List<String> lstEvt = new List<String> ();
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, Name from Campaign Limit 2];
            for(Campaign cm : lstEventoVirtual){
                lstEvt.add(cm.EV_ExternalID__c);
            }
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, null, false);
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
            EV_WS_InscripcionMultiple.inscripcionPortal();
          System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
        Test.stopTest();

}

    @isTest
    //Se testea la inscripción de un no cliente (LEAD) New Architecturre
	public static void testInscripcionNoClienteNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            List<String> lstEvt = new List<String> ();
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c,EV_TechSummit__c,  Name from Campaign Limit 2];
            for(Campaign cm : lstEventoVirtual){
                lstEvt.add(cm.EV_ExternalID__c);
                cm.EV_NewArchitecture__c = true;
                cm.EV_TechSummit__c = true;
            }
            update lstEventoVirtual;
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, null, false);
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
            EV_WS_InscripcionMultiple.inscripcionPortal();
          System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
        Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un cliente (Contact);
	public static void testInscripcionClienteNewArchitectureNoEncontrado() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            EV_TestHelper.createCampaignMemberCustomContact(false,true);
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, EV_TechSummit__c from Campaign Limit 2];
            List<String> lstEvt = new List<String>();
            for(Campaign cm : lstEventoVirtual){
                lstEvt.add(cm.EV_ExternalId__c);
                cm.EV_NewArchitecture__c = true;
                cm.EV_TechSummit__c = true;
            }
            update lstEventoVirtual;
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt,'AW77', false);
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
          EV_WS_InscripcionMultiple.inscripcionPortal();
          System.assertEquals(404, RestContext.response.statusCode, 'Registro no encontrado');
        }
        Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un cliente (Contact);
	public static void testInscripcionClienteNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            EV_TestHelper.createCampaignMemberCustomContact(false,true);
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c from Campaign Limit 2];
            List<String> lstEvt = new List<String>();
            for(Campaign cm : lstEventoVirtual){
                lstEvt.add(cm.EV_ExternalId__c);
                cm.EV_NewArchitecture__c = true;
                cm.EV_TechSummit__c = true;
            }
            update lstEventoVirtual;
            EV_CampaignMemberC__c campaignMemberInscrito = [Select id, EV_ExternalId__c, Name from EV_CampaignMemberC__c Limit 1];
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, campaignMemberInscrito.EV_ExternalId__c, false);
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
          System.assertEquals(200, RestContext.response.statusCode, 'Registro no encontrado');
        }
        Test.stopTest();
    }

    @isTest
    //Se testea la inscripción de un cliente (Contact) IdInvitación erroneo;
	public static void testInscripcionClienteErrorIdInvitacion() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            EV_TestHelper.createCampaignMemberCustomContact(false,true);
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, EV_TechSummit__c from Campaign Limit 2];
            List<String> lstEvt = new List<String>();
            for(Campaign cm : lstEventoVirtual){
                lstEvt.add(cm.EV_ExternalId__c);
                cm.EV_NewArchitecture__c = true;
                cm.EV_TechSummit__c = true;
            }
            update lstEventoVirtual;
            EV_CampaignMemberC__c campaignMemberInscrito = [Select id, EV_ExternalId__c, Name, EV_Empresa__c, EV_NumeroDocumento__c from EV_CampaignMemberC__c Limit 1];
            campaignMemberInscrito.EV_Empresa__c = true;
            update campaignMemberInscrito;
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, campaignMemberInscrito.EV_ExternalId__c, true);
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

            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON2 = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, campaignMemberInscrito.EV_ExternalId__c, false);
            RestRequest req1 = new RestRequest(); 
            RestResponse res1 = new RestResponse();
            req1.requestURI = WS_PATH; 
            req1.addHeader('Content-Type', 'application/json');
            req1.httpMethod = HTTP_METHOD;
            req1.requestBody = Blob.valueof(JSON.serialize(wrapperJSON2));
            RestContext.request = req1;
            res.statusCode = 404;
            RestContext.response = res1;
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
		System.runAs(newUser){
        EV_TestHelper.createCampaignMemberCustomContact(false,true);
        List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, EV_TechSummit__c from Campaign Limit 2];
        List<String> lstEvt = new List<String>();
        for(Campaign cm : lstEventoVirtual){
            lstEvt.add(cm.EV_ExternalId__c);
            cm.EV_NewArchitecture__c = true;
            cm.EV_TechSummit__c = true;
        }
        update lstEventoVirtual;
        EV_CampaignMemberC__c campaignMemberInscrito = [Select id, EV_ExternalId__c,EV_Status__c from EV_CampaignMemberC__c Limit 1];
        campaignMemberInscrito.EV_Status__c='Registro confirmado';
        update campaignMemberInscrito;
        EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, '65759jn4bv347k473473', false);
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
		System.runAs(newUser){
        EV_TestHelper.createCampaignMemberCustomContact(false,true);
        List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, EV_TechSummit__c from Campaign Limit 2];
        List<String> lstEvt = new List<String>();
        for(Campaign cm : lstEventoVirtual){
            lstEvt.add(cm.EV_ExternalId__c);
            cm.EV_NewArchitecture__c = true;
            cm.EV_TechSummit__c = true;
        }
        update lstEventoVirtual;
        EV_CampaignMemberC__c campaignMemberInscrito = [Select id, EV_ExternalId__c,EV_Status__c from EV_CampaignMemberC__c Limit 1];
        campaignMemberInscrito.EV_Status__c='Registro confirmado';
        update campaignMemberInscrito;
        EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, '65759jn4bv347k473473', false);
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
		System.runAs(newUser){
        EV_TestHelper.createCampaignMemberCustomContact(false,true);
        List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, EV_TechSummit__c from Campaign Limit 2];
        List<String> lstEvt = new List<String>();
        for(Campaign cm : lstEventoVirtual){
            lstEvt.add(cm.EV_ExternalId__c);
            cm.EV_NewArchitecture__c = true;
            cm.EV_TechSummit__c = true;
        }
        update lstEventoVirtual;
        EV_CampaignMemberC__c campaignMemberInscrito = [Select id, EV_ExternalId__c,EV_Status__c from EV_CampaignMemberC__c Limit 1];
        campaignMemberInscrito.EV_Status__c='Registro confirmado';
        update campaignMemberInscrito;
        EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, campaignMemberInscrito.EV_ExternalId__c, false);
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
    //Se testea la inscripción de un no cliente (LEAD) ya inscrito sin IdInvitación
	public static void testInscripcionNoClienteYaInscritoNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            EV_TestHelper.createCampaignMemberCustomLead();
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, EV_TechSummit__c from Campaign Limit 1];
            List<String> lstEvt = new List<String>();
            for(Campaign cm : lstEventoVirtual){
                lstEvt.add(cm.EV_ExternalId__c);
                cm.EV_NewArchitecture__c = true;
                cm.EV_TechSummit__c = true;
            }
            update lstEventoVirtual;
            EV_CampaignMemberC__c campaignMemberInscrito = [Select id, EV_ExternalId__c,EV_Status__c from EV_CampaignMemberC__c Limit 1];
            campaignMemberInscrito.EV_Status__c='Registro confirmado';
            update campaignMemberInscrito;
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, null, false);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI =WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
			res.statusCode = 202;
            RestContext.request = req;
            RestContext.response = res;
        }
        Test.startTest();
		System.runAs(newUser){
            Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
            EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(202, RestContext.response.statusCode, 'Ya inscrito');
        }
        Test.stopTest();  
    }

    @isTest
    //Se testea la inscripción de un Interlocutor con empresa registrada en Salesforce
	public static void testInscripcionInterlocutorConEmpresa() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        System.runAs(newUser){
            EV_TestHelper.createEmpresa();
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 2];
            List<String> lstEvt = new List<String>();
                for(Campaign cm : lstEventoVirtual){
                    lstEvt.add(cm.EV_ExternalId__c);
                }
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, null, true);
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
            EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
        Test.stopTest();
    }

    @isTest
    //Se testea la inscripción de un Interlocutor con empresa registrada en Salesforce
	public static void testInscripcionInterlocutorConEmpresaNewArchitecture() {
        
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            EV_TestHelper.createEmpresa();
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, EV_TechSummit__c from Campaign Limit 2];
            List<String> lstEvt = new List<String>();
            for(Campaign cm : lstEventoVirtual){
                lstEvt.add(cm.EV_ExternalId__c);
                cm.EV_NewArchitecture__c = true;
                cm.EV_TechSummit__c = true;
            } 
            update lstEventoVirtual;
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, null, true);
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
        	EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
		Test.stopTest();
    }

       @isTest
    //Se testea la inscripción de un Interlocutor con empresa registrada en Salesforce
	public static void testInscripcionInterlocutorConEmpresaYnifNewArchitecture() {
        
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            EV_TestHelper.createEmpresa();
            EV_TestHelper.createCampaignMemberCustomContact(false,true);
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, EV_TechSummit__c from Campaign Limit 2];
            List<String> lstEvt = new List<String>();
            List<EV_CampaignMemberC__c> lstCampaignMemberInscrito = [Select id, EV_ExternalId__c, EV_NumeroDocumento__c, EV_Empresa__c from EV_CampaignMemberC__c Limit 2];

            for(Campaign cm : lstEventoVirtual){
                lstEvt.add(cm.EV_ExternalId__c);
                cm.EV_NewArchitecture__c = true;
                cm.EV_TechSummit__c = true;
                lstCampaignMemberInscrito.get(0).EV_campaignid__c = cm.id;
            }
            lstCampaignMemberInscrito.get(0).EV_Empresa__c = true;
            update lstCampaignMemberInscrito;
            update lstEventoVirtual;
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, lstCampaignMemberInscrito.get(0).EV_ExternalId__c, true);
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
        	EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
		Test.stopTest();
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
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, EV_TechSummit__c from Campaign Limit 2];
            List<String> lstEvt = new List<String>();
            List<EV_CampaignMemberC__c> lstCampaignMemberInscrito = [Select id, EV_ExternalId__c, EV_NumeroDocumento__c, EV_Empresa__c from EV_CampaignMemberC__c Limit 2];
            for(Campaign cm : lstEventoVirtual){
                lstEvt.add(cm.EV_ExternalId__c);
                cm.EV_NewArchitecture__c = true;
                cm.EV_TechSummit__c = true;
                lstCampaignMemberInscrito.get(0).EV_campaignid__c = cm.id;
            }
            lstCampaignMemberInscrito.get(0).EV_Empresa__c = true;
            update lstCampaignMemberInscrito;
            update lstEventoVirtual;
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, null, true);
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
        	EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
		Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un Interlocutor //Nuevo
	public static void testInscripcionInterlocutorNumper() {
        
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
            EV_TestHelper.createContactAux('Test');
            EV_TestHelper.createCampaignMemberContact(false,true);
            Contact cont = [Select id,CC_NumPerso__c from Contact where LastName = 'Test'];
    		cont.CC_NumPerso__c = '123';
            update cont;
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c from Campaign Where Name = 'TestCampaign' Limit 2];
            List<String> lstEvt = new List<String>();
            for(Campaign cm : lstEventoVirtual){
                lstEvt.add(cm.EV_ExternalId__c);
            }
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, null, true);
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
            EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
		Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un Interlocutor con empresa no registrada registrada en Salesforce Custom
	public static void testInscripcionInterlocutorCustomSinEmpresa() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        System.runAs(newUser){
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_TechSummit__c, EV_NewArchitecture__c from Campaign Limit 2];
            List<String> lstEvt = new List<String>();
            for(Campaign cm : lstEventoVirtual){
                lstEvt.add(cm.EV_ExternalId__c);
                cm.EV_NewArchitecture__c = true;
                cm.EV_TechSummit__c = true;
            }
            update lstEventoVirtual;
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, null, true);
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
            EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
		Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un Interlocutor con empresa no registrada registrada en Salesforce
	public static void testInscripcionInterlocutorSinEmpresa() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        System.runAs(newUser){
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 2];
            List<String> lstEvt = new List<String>();
            for(Campaign cm : lstEventoVirtual){
                lstEvt.add(cm.EV_ExternalId__c);
            }
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, null, true);
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
            EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
		Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un Interlocutor con varias empresas registradas en Salesforce
	public static void testInscripcionInterlocutorConVariasEmpresas() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        System.runAs(newUser){
            EV_TestHelper.createEmpresas();

            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 2];
            List<String> lstEvt = new List<String>();
            for(Campaign cm : lstEventoVirtual){
                lstEvt.add(cm.EV_ExternalId__c);
            }
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, null, true);
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
            EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
		Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un Interlocutor ya existente
	public static void testInscripcionInterlocutorExistente() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        System.runAs(newUser){
            EV_TestHelper.createContactInterlocutorEmpresa('TestEmpresa');
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 2];
            List<String> lstEvt = new List<String>();
            for(Campaign cm : lstEventoVirtual){
                lstEvt.add(cm.EV_ExternalId__c);
            }
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, null, true);
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
            EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
		Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un Interlocutor cuando existen más de uno iguales.
	public static void testInscripcionMasDeUnInterlocutor() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        System.runAs(newUser){
            EV_TestHelper.createContactInterlocutorEmpresa('TestEmpresa');
            EV_TestHelper.createContactInterlocutorEmpresa('Empresa');
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c from Campaign Limit 2];
            List<String> lstEvt = new List<String>();
            for(Campaign cm : lstEventoVirtual){
                lstEvt.add(cm.EV_ExternalId__c);
            }
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, null, true);
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
            EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
		Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un no cliente (LEAD)
	public static void testInscripcionSinEvento() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        System.runAs(newUser){
            List<String> lstEvt = new List<String>();
            EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultiple(lstEvt, null, true);
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
            EV_WS_InscripcionMultiple.inscripcionPortal();
          	System.assertEquals(404, RestContext.response.statusCode, 'No existe');  
        }
		Test.stopTest();
    }
}