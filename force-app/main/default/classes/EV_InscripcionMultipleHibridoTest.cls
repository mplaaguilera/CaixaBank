/*********************************************************************************************************************
 Name:  EV_InscripcionMultipleHibridoTest
 Copyright © 2024  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test para Web service EV_InscripcionMultipleHibridoTest de Portal
---------------------------------------------------------------------------------------------------------------------- 
 * VERSION        USER_STORY         AUTHOR              DATE         Description
 * 1.0            US622078           Carolina Lopez      07/06/2024   Init Version
***********************************************************************************************************************/
@isTest
public class EV_InscripcionMultipleHibridoTest {
    // Request variables
    static final String WS_PATH = '/services/apexrest/EV_InscripcionMultiple/';
    static final String HTTP_METHOD = 'POST';

    @isTest
    //Se testea la inscripción de un no cliente (LEAD) New Architecturre
	public static void testInscripcionNoClienteNewArchitecture() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<EV_NoClienteWrapperHibrido.LstEventFormat> idEvento = new List<EV_NoClienteWrapperHibrido.LstEventFormat>();
		System.runAs(newUser){
            Campaign camp = EV_TestHelper.createParentCampaignTechSummitHibrido();
            EV_NoClienteWrapperHibrido.LstEventFormat eventCopy = new EV_NoClienteWrapperHibrido.LstEventFormat();
            eventCopy.idEvento = camp.EV_ExternalID__c;
            eventCopy.formatoDeAsistencia = '001';
            idEvento.add(eventCopy);
            EV_NoClienteWrapperHibrido.RequestInscripcionBodyMultipleHibrido wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleHibrido(idEvento);
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
          EV_WS_InscripcionMultipleHibrido.inscripcionPortal();
          System.assertEquals(200, RestContext.response.statusCode, 'Correcto');
        }
        Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un lead erroneo;
	public static void testInscripcionErrorLead() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<EV_NoClienteWrapperHibrido.LstEventFormat> idEvento = new List<EV_NoClienteWrapperHibrido.LstEventFormat>();
		System.runAs(newUser){
            EV_CampaignMemberC__c campaignMemberInscrito = EV_TestHelper.createCampaignMemberCustomLeadTechSummit(false,true);
            campaignMemberInscrito.EV_Empresa__c = true;
            update campaignMemberInscrito;
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c, EV_TechSummit__c from Campaign Limit 2];
            EV_NoClienteWrapperHibrido.LstEventFormat eventCopy = new EV_NoClienteWrapperHibrido.LstEventFormat();
            for(Campaign cm : lstEventoVirtual){
                eventCopy.idEvento = cm.EV_ExternalId__c;
                eventCopy.formatoDeAsistencia = '001';
                cm.EV_NewArchitecture__c = true;
                cm.EV_TechSummit__c = true;
                idEvento.add(eventCopy);
            }
            update lstEventoVirtual;
            EV_NoClienteWrapperHibrido.RequestInscripcionBodyMultipleHibrido wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleHibrido(idEvento);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));
            RestContext.request = req;
            RestContext.response = res;
            res.statusCode = 404;
            EV_WS_InscripcionMultipleHibrido.inscripcionPortal();

            EV_NoClienteWrapperHibrido.RequestInscripcionBodyMultipleHibrido wrapperJSON2 = EV_TestHelper.createWrapperJSONInscripcionMultipleHibrido(idEvento);
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
            EV_WS_InscripcionMultipleHibrido.inscripcionPortal();
          	System.assertEquals(null, RestContext.response.statusCode, 'No encontrado.');
        }
        Test.stopTest();
    }
    @isTest
	public static void testInscripcionNoClienteNewArchitectureNullForm() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<EV_NoClienteWrapperHibrido.LstEventFormat> idEvento = new List<EV_NoClienteWrapperHibrido.LstEventFormat>();
		System.runAs(newUser){
            Campaign camp = EV_TestHelper.createParentCampaignTechSummitHibrido();
            EV_NoClienteWrapperHibrido.LstEventFormat eventCopy = new EV_NoClienteWrapperHibrido.LstEventFormat();
            eventCopy.idEvento = camp.EV_ExternalID__c;
            eventCopy.formatoDeAsistencia = '001';
            idEvento.add(eventCopy);
            EV_NoClienteWrapperHibrido.RequestInscripcionBodyMultipleHibrido wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleHibridoNullForm(idEvento);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI =WS_PATH; 
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
          EV_WS_InscripcionMultipleHibrido.inscripcionPortal();
          System.assertEquals(400, RestContext.response.statusCode, 'El formulario esta vacio');
        }
        Test.stopTest();
    }
    @isTest
    //Se testea la inscripción de un no cliente (LEAD) interlocutor
	public static void testInscripcionNoClienteNewArchitectureInterlocutor() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<EV_NoClienteWrapperHibrido.LstEventFormat> idEvento = new List<EV_NoClienteWrapperHibrido.LstEventFormat>();
		System.runAs(newUser){
            Campaign camp = EV_TestHelper.createParentCampaignTechSummitHibrido();
            EV_NoClienteWrapperHibrido.LstEventFormat eventCopy = new EV_NoClienteWrapperHibrido.LstEventFormat();
            eventCopy.idEvento = camp.EV_ExternalID__c;
            eventCopy.formatoDeAsistencia = '001';
            idEvento.add(eventCopy);
            EV_NoClienteWrapperHibrido.RequestInscripcionBodyMultipleHibrido wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleHibrido(idEvento);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI =WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));   
            RestContext.request = req;
            res.statusCode = 202;
            RestContext.response = res;
            Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
            EV_WS_InscripcionMultipleHibrido.inscripcionPortal();

        }    
        Test.startTest();
        System.runAs(newUser){ 
          EV_WS_InscripcionMultipleHibrido.inscripcionPortal();
          System.assertEquals(202, RestContext.response.statusCode, 'Correcto');
        }
        Test.stopTest();
    }

    @isTest
    //Se testea la inscripción de un no cliente (LEAD) Duplicado
	public static void testInscripcionNoClienteNewArchitectureDuplicado() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<EV_NoClienteWrapperHibrido.LstEventFormat> idEvento = new List<EV_NoClienteWrapperHibrido.LstEventFormat>();
        Campaign camp = new Campaign();
		System.runAs(newUser){
            camp = EV_TestHelper.createParentCampaignTechSummitHibrido();
        }  
        System.runAs(newUser){
            EV_TestHelper.createCampaignMemberCustomLeadTechSummitHibrido(camp.Id);
            EV_NoClienteWrapperHibrido.LstEventFormat eventCopy = new EV_NoClienteWrapperHibrido.LstEventFormat();
            eventCopy.idEvento = camp.EV_ExternalID__c;
            eventCopy.formatoDeAsistencia = '001';
            idEvento.add(eventCopy);
            EV_NoClienteWrapperHibrido.RequestInscripcionBodyMultipleHibrido wrapperJSON = EV_TestHelper.createWrapperJSONInscripcionMultipleHibrido(idEvento);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI =WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapperJSON));   
            RestContext.request = req;
            res.statusCode = 202;
            RestContext.response = res;
            Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
        }
        Test.startTest();
        System.runAs(newUser){ 
          EV_WS_InscripcionMultipleHibrido.inscripcionPortal();
          System.assertEquals(202, RestContext.response.statusCode, 'Correcto');
        }
        Test.stopTest();
    }
}