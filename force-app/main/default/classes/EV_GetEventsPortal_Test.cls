/**********************************************************************************************************************
 Name:	  EV_GetEventsPortal_Test
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test para el Web service de Portal
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		  	US602112			Mamen Arias         11/07/2023          Init Version
***********************************************************************************************************************/
@isTest
public class EV_GetEventsPortal_Test {

    static final String WS_PATH = '/services/apexrest/EV_GetEventsPortal/';
    static final String HTTP_METHOD = 'POST';
    static final Integer HTTP_STATUS_200 = 200;
    static final Integer HTTP_STATUS_400 = 400;
    
    @TestSetup
	static void makeData(){
        EV_TestHelper.createCampaignMemberCustomContact(true, false);
        EV_CampaignMemberC__c cm = [SELECT Id, EV_ContactId__r.CC_Numperso__c, EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_Numero_Documento__c = '48133877Y'];
        
        Campaign camp = [SELECT Id, EV_EventoVisibleNOW__c, Status FROM Campaign WHERE Id = :cm.EV_CampaignId__c];
        camp.EV_EventoVisibleNOW__c = true;
        camp.Status = '008';
        update camp;
        
        EV_TestHelper.createCampaignMemberContact(false, true);
        CampaignMember cm2 = [SELECT Id, Contact.CC_Numperso__c, CampaignId FROM CampaignMember WHERE Contact.CC_Numero_Documento__c = '48133877Y'];
        
        List<Contact> contactList = [SELECT Id, CC_Numperso__c FROM Contact LIMIT 2];
        contactList[0].CC_Numperso__c = '123';
        contactList[1].CC_Numperso__c = '1234';
        update contactList;
        
        Campaign camp2 = [SELECT Id, Status, EV_DiaHora_evento__c FROM Campaign WHERE Id = :cm2.CampaignId];
        camp2.Status = '008';
        update camp2;
            
        EV_TestHelper.createCaixaCenter();
        EV_LogDebug.printLogDebug('@@Limit queries makedata: ', String.valueOf(Limits.getQueries()));
	}
    
    @isTest
    public static void noServiceTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            String idioma = '002';
            EV_WS_GetEventsPortal.RequestServicesPortalBody wrapper = EV_TestHelper.createWrapperJSONServicesPortal('8', '123', idioma);

            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapper));  
            RestContext.request = req;
            RestContext.response = res;
        }
        EV_LogDebug.printLogDebug('@@Limit queries noServiceInitial: ', String.valueOf(Limits.getQueries()));
        
        Test.startTest();
        EV_LogDebug.printLogDebug('@@Limit queries noServiceStart: ', String.valueOf(Limits.getQueries()));
        System.runAs(newUser){
        	EV_WS_GetEventsPortal.getResultsEvents();
        }
        EV_LogDebug.printLogDebug('@@Limit queries noServiceStop: ', String.valueOf(Limits.getQueries()));
        Test.stopTest();
        
        EV_LogDebug.printLogDebug('@@limit queries noServiceEnd: ', String.valueOf(Limits.getQueries()));
        System.assertEquals(HTTP_STATUS_400, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void sliderHomeByClient() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            String idioma = '002';
            EV_WS_GetEventsPortal.RequestServicesPortalBody wrapper = EV_TestHelper.createWrapperJSONServicesPortal('slider-home-events-by-client', '123', idioma);

            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapper));  
            RestContext.request = req;
            RestContext.response = res;
        }
        EV_LogDebug.printLogDebug('@@Limit queries sliderInitial: ', String.valueOf(Limits.getQueries()));
        
        Test.startTest();
        EV_LogDebug.printLogDebug('@@Limit queries sliderStart: ', String.valueOf(Limits.getQueries()));
        System.runAs(newUser){
        	EV_WS_GetEventsPortal.getResultsEvents();
        }
        EV_LogDebug.printLogDebug('@@Limit queries sliderStop: ', String.valueOf(Limits.getQueries()));
        Test.stopTest();
        
        EV_LogDebug.printLogDebug('@@Limit queries sliderEnd: ', String.valueOf(Limits.getQueries()));
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void futureEventsByClient() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
 
        EV_LogDebug.printLogDebug('@@Limit queries futureInitial: ', String.valueOf(Limits.getQueries()));
        
        Test.startTest();
        EV_LogDebug.printLogDebug('@@Limit queries futureStart: ', String.valueOf(Limits.getQueries()));
        System.runAs(newUser){
            EV_CampaignMemberC__c cm = [SELECT Id, EV_ContactId__r.CC_Numperso__c, EV_CampaignId__c FROM EV_CampaignMemberC__c LIMIT 1];
            Campaign camp = [SELECT Id, Status, EV_DiaHora_evento__c FROM Campaign WHERE Id = :cm.EV_CampaignId__c];
			CampaignMember cm2 = [SELECT Id, Contact.CC_Numperso__c, CampaignId FROM CampaignMember LIMIT 1];
        	Campaign camp2 = [SELECT Id, Status, EV_DiaHora_evento__c FROM Campaign WHERE Id = :cm2.CampaignId];
            List<EV_CampaignWrapperDate> orderList = new List<EV_CampaignWrapperDate>();
            orderList.add(new EV_CampaignWrapperDate(camp));
            orderList.add(new EV_CampaignWrapperDate(camp2));
            orderList.sort();
            
            String idioma = '002';
            EV_WS_GetEventsPortal.RequestServicesPortalBody wrapper = EV_TestHelper.createWrapperJSONServicesPortal('future-events-by-client', '123', idioma);

            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapper));  
            RestContext.request = req;
            RestContext.response = res;
        	EV_WS_GetEventsPortal.getResultsEvents();
        }
        EV_LogDebug.printLogDebug('@@Limit queries futureStop: ', String.valueOf(Limits.getQueries()));
        Test.stopTest();
        
        EV_LogDebug.printLogDebug('@@Limit queries futureEnd: ', String.valueOf(Limits.getQueries()));
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void pastEventsByClient() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos'); 
        EV_LogDebug.printLogDebug('@@Limit queries pastInitial: ', String.valueOf(Limits.getQueries()));
 
        Test.startTest();
        EV_LogDebug.printLogDebug('@@Limit queries pastStart: ', String.valueOf(Limits.getQueries()));
        System.runAs(newUser){
            List<Campaign> campList = [SELECT Id, Status, EV_DiaHora_evento__c FROM Campaign LIMIT 2];
            campList[0].Status = '005';
            campList[1].Status = '005';
			update campList;
            
            List<EV_CampaignWrapperDateDesc> orderList = new List<EV_CampaignWrapperDateDesc>();
            orderList.add(new EV_CampaignWrapperDateDesc(campList[0]));
            orderList.add(new EV_CampaignWrapperDateDesc(campList[1]));
            orderList.sort();
            
            String idioma = '002';
            EV_WS_GetEventsPortal.RequestServicesPortalBody wrapper = EV_TestHelper.createWrapperJSONServicesPortal('past-events-by-client', '123', idioma);

            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapper));  
            RestContext.request = req;
            RestContext.response = res;
        	EV_WS_GetEventsPortal.getResultsEvents();
        }
        EV_LogDebug.printLogDebug('@@Limit queries pastStop: ', String.valueOf(Limits.getQueries()));
        Test.stopTest();
        
        EV_LogDebug.printLogDebug('@@Limit queries pastEnd: ', String.valueOf(Limits.getQueries()));
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void mostViewedEventsByClient() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');   
        EV_LogDebug.printLogDebug('@@Limit queries mostViewedInitial: ', String.valueOf(Limits.getQueries()));
    
        Test.startTest();
        EV_LogDebug.printLogDebug('@@Limit queries mostViewedStart: ', String.valueOf(Limits.getQueries()));
        System.runAs(newUser){
            List<Campaign> campList = [SELECT Id, Status, EV_DiaHora_evento__c, EV_TotalAsistentes__c, EV_TotalAsistentesC__c FROM Campaign LIMIT 2];
            campList[0].Status = '005';
            campList[1].Status = '005';
			update campList;
            
            List<EV_CampaignWrapperTotalAsis> orderList = new List<EV_CampaignWrapperTotalAsis>();
            orderList.add(new EV_CampaignWrapperTotalAsis(campList[0]));
            orderList.add(new EV_CampaignWrapperTotalAsis(campList[1]));
            orderList.sort();
            
            String idioma = '002';
            EV_WS_GetEventsPortal.RequestServicesPortalBody wrapper = EV_TestHelper.createWrapperJSONServicesPortal('most-viewed-events-by-client', '123', idioma);

            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapper));  
            RestContext.request = req;
            RestContext.response = res;
        	EV_WS_GetEventsPortal.getResultsEvents();
        }
        EV_LogDebug.printLogDebug('@@Limit queries mostViewedStop: ', String.valueOf(Limits.getQueries()));
        Test.stopTest();
        
        EV_LogDebug.printLogDebug('@@Limit queries mostViewedEnd: ', String.valueOf(Limits.getQueries()));
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
        @isTest
    public static void wrongParametersTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');  
        EV_LogDebug.printLogDebug('@@Limit queries wrongParametersInitial: ', String.valueOf(Limits.getQueries()));
        
        System.runAs(newUser){
            String idioma = '002';
            EV_WS_GetEventsPortal.RequestServicesPortalBody wrapper = EV_TestHelper.createWrapperJSONServicesPortal('slider-home-events-by-client', null, idioma);

            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = WS_PATH; 
            req.addHeader('Content-Type', 'application/json');
            req.httpMethod = HTTP_METHOD;
            req.requestBody = Blob.valueof(JSON.serialize(wrapper));  
            RestContext.request = req;
            RestContext.response = res;
        }    
        Test.startTest();
        EV_LogDebug.printLogDebug('@@Limit queries wrongParametersStart: ', String.valueOf(Limits.getQueries()));
        System.runAs(newUser){
        	EV_WS_GetEventsPortal.getResultsEvents();
        }
        EV_LogDebug.printLogDebug('@@Limit queries wrongParametersStop: ', String.valueOf(Limits.getQueries()));
        Test.stopTest();
        
        EV_LogDebug.printLogDebug('@@Limit queries wrongParametersEnd: ', String.valueOf(Limits.getQueries()));
        System.assertEquals(HTTP_STATUS_400, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void nullCampaignDate(){
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        try {
            System.runAs(newUser){
            	EV_CampaignWrapperDate wrapper = new EV_CampaignWrapperDate(null);
            }
            System.assert(false, 'Se esperaba una excepción NullPointerException');
        } catch (NullPointerException ex) {
            System.assertEquals('Campaña no encontrada', ex.getMessage());
        }
    }
    
    @isTest
    public static void nullCampaignDateDesc(){
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        try {
            System.runAs(newUser){
            	EV_CampaignWrapperDateDesc wrapper = new EV_CampaignWrapperDateDesc(null);
            }
            System.assert(false, 'Se esperaba una excepción NullPointerException');
        } catch (NullPointerException ex) {
            System.assertEquals('Campaña no encontrada', ex.getMessage());
        }
    }
    
    @isTest
    public static void nullCampaignTotalAsis(){
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        try {
            System.runAs(newUser){
            	EV_CampaignWrapperTotalAsis wrapper = new EV_CampaignWrapperTotalAsis(null);
            }
            System.assert(false, 'Se esperaba una excepción NullPointerException');
        } catch (NullPointerException ex) {
            System.assertEquals('Campaña no encontrada', ex.getMessage());
        }
    }
}