/**********************************************************************************************************************
 Name:	  EV_GetEvents_Test
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test para el Web service de GCF
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		  	US587006			Mamen Arias         07/06/2023          Init Version
***********************************************************************************************************************/
@isTest
public class EV_GetEvents_Test {

    static final String WS_PATH = '/services/apexrest/EV_GetEvents/';
    static final String HTTP_METHOD = 'POST';
    static final Integer HTTP_STATUS_200 = 200;
    static final Integer HTTP_STATUS_400 = 400;
    
    @TestSetup
	static void makeData(){
		EV_TestHelper.createCampaignMemberCustomContact(true, false);
        EV_TestHelper.createCampaignMemberContact(false, true);
        EV_TestHelper.createCaixaCenter();
	}
    
    @isTest
    public static void noServiceTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            EV_CampaignMemberC__c cm = [SELECT Id, EV_ContactId__r.CC_Numperso__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_Numero_Documento__c = '48133877Y'];
            cm.EV_ContactId__r.CC_Numperso__c='123';
            update cm;
            List<String> idioma = new List<String>{'001', '002'};
            EV_WS_GetEvents.RequestServicesGCFBody wrapper = EV_TestHelper.createWrapperJSONServicesGCF('8', cm.EV_ContactId__r.CC_NumPerso__c, idioma, null, null, null, null);

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
        System.runAs(newUser){
        	EV_WS_GetEvents.getResults();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_400, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void listByClientTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            EV_CampaignMemberC__c cm = [SELECT Id, EV_ContactId__r.CC_Numperso__c, EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_Numero_Documento__c = '48133877Y'];
            cm.EV_ContactId__r.CC_Numperso__c='123';
            update cm;
            Campaign camp = [SELECT Id, EV_EventoVisibleNOW__c, Status FROM Campaign WHERE Id = :cm.EV_CampaignId__c];
            camp.EV_EventoVisibleNOW__c = true;
            camp.Status = '008';
            update camp;
            List<String> idioma = new List<String>{'001', '002'};
            EV_WS_GetEvents.RequestServicesGCFBody wrapper = EV_TestHelper.createWrapperJSONServicesGCF('list-by-client', cm.EV_ContactId__r.CC_NumPerso__c, idioma, null, null, null, null);

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
        System.runAs(newUser){
        	EV_WS_GetEvents.getResults();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void pastListByClientTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            EV_CampaignMemberC__c cm = [SELECT Id, EV_ContactId__r.CC_Numperso__c, EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_Numero_Documento__c = '48133877Y'];
            cm.EV_ContactId__r.CC_Numperso__c='123';
            update cm;
            Campaign camp = [SELECT Id, EV_EventoVisibleNOW__c, Status FROM Campaign WHERE Id = :cm.EV_CampaignId__c];
            camp.EV_EventoVisibleNOW__c = true;
            camp.Status = '005';
            update camp;
            List<String> idioma = new List<String>{'001', '002'};
            EV_WS_GetEvents.RequestServicesGCFBody wrapper = EV_TestHelper.createWrapperJSONServicesGCF('past-list-by-client', cm.EV_ContactId__r.CC_NumPerso__c, idioma, null, null, null, null);

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
        System.runAs(newUser){
        	EV_WS_GetEvents.getResults();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void futureRegisteredListByClientTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            EV_CampaignMemberC__c cm = [SELECT Id, EV_ContactId__r.CC_Numperso__c, EV_CampaignId__c, EV_Status__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_Numero_Documento__c = '48133877Y'];
            cm.EV_ContactId__r.CC_Numperso__c='123';
            update cm;
            Campaign camp = [SELECT Id, EV_EventoVisibleNOW__c, Status FROM Campaign WHERE Id = :cm.EV_CampaignId__c];
            camp.EV_EventoVisibleNOW__c = true;
            camp.Status = '003';
            update camp;
            List<String> idioma = new List<String>{'001', '002'};
            EV_WS_GetEvents.RequestServicesGCFBody wrapper = EV_TestHelper.createWrapperJSONServicesGCF('future-registered-list-by-client', cm.EV_ContactId__r.CC_NumPerso__c, idioma, null, null, null, null);

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
        System.runAs(newUser){
        	EV_WS_GetEvents.getResults();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void futureInterestedListByClientTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            EV_CampaignMemberC__c cm = [SELECT Id, EV_ContactId__r.CC_Numperso__c, EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_Numero_Documento__c = '48133877Y'];
            cm.EV_ContactId__r.CC_Numperso__c='123';
            update cm;
            Campaign camp = [SELECT Id, EV_EventoVisibleNOW__c, Status FROM Campaign WHERE Id = :cm.EV_CampaignId__c];
            camp.EV_EventoVisibleNOW__c = true;
            camp.Status = '003';
            update camp;
            List<String> idioma = new List<String>{'001', '002'};
            EV_WS_GetEvents.RequestServicesGCFBody wrapper = EV_TestHelper.createWrapperJSONServicesGCF('future-interested-list-by-client', cm.EV_ContactId__r.CC_NumPerso__c, idioma, null, null, null, null);

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
        System.runAs(newUser){
        	EV_WS_GetEvents.getResults();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void futureListByClientTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            EV_CampaignMemberC__c cm = [SELECT Id, EV_ContactId__r.CC_Numperso__c, EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_Numero_Documento__c = '48133877Y'];
            cm.EV_ContactId__r.CC_Numperso__c='123';
            update cm;
            Campaign camp = [SELECT Id, EV_EventoVisibleNOW__c, Status FROM Campaign WHERE Id = :cm.EV_CampaignId__c];
            camp.EV_EventoVisibleNOW__c = true;
            camp.Status = '003';
            update camp;
            List<String> idioma = new List<String>{'001', '002'};
            EV_WS_GetEvents.RequestServicesGCFBody wrapper = EV_TestHelper.createWrapperJSONServicesGCF('future-list-by-client', cm.EV_ContactId__r.CC_NumPerso__c, idioma, null, null, null, null);

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
        System.runAs(newUser){
        	EV_WS_GetEvents.getResults();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void passAndFutureListByClientTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            EV_CampaignMemberC__c cm = [SELECT Id, EV_ContactId__r.CC_Numperso__c, EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_Numero_Documento__c = '48133877Y'];
            cm.EV_ContactId__r.CC_Numperso__c='123';
            update cm;
            Campaign camp = [SELECT Id, EV_EventoVisibleNOW__c, Status FROM Campaign WHERE Id = :cm.EV_CampaignId__c];
            camp.EV_EventoVisibleNOW__c = true;
            camp.Status = '008';
            update camp;
            List<String> idioma = new List<String>{'001', '002'};
            EV_WS_GetEvents.RequestServicesGCFBody wrapper = EV_TestHelper.createWrapperJSONServicesGCF('pass-and-future-list-by-client', cm.EV_ContactId__r.CC_NumPerso__c, idioma, null, null, null, null);

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
        System.runAs(newUser){
        	EV_WS_GetEvents.getResults();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void listByOfficeTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            Account acc = [SELECT Id, CC_Numero_Oficina__c FROM Account WHERE CC_Numero_Oficina__c = '00615'];
            Campaign camp = EV_TestHelper.createChildCampaignVirtual(acc, null);
            List<String> idioma = new List<String>{'001', '002'};
            EV_WS_GetEvents.RequestServicesGCFBody wrapper = EV_TestHelper.createWrapperJSONServicesGCF('list-by-office', null, idioma, acc.CC_Numero_Oficina__c, null, null, null);

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
        System.runAs(newUser){
        	EV_WS_GetEvents.getResults();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void clientAndEventListByDateTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            EV_WS_GetEvents.RequestServicesGCFBody wrapper = EV_TestHelper.createWrapperJSONServicesGCF('client-and-event-list-by-date', null, null, null, null, null, Date.today());

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
        System.runAs(newUser){
        	EV_WS_GetEvents.getResults();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void detailListByExternalIdAndLanguageTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            EV_CampaignMemberC__c cm = [SELECT Id, EV_CampaignId__c, EV_CampaignId__r.EV_ExternalID__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_Numero_Documento__c = '48133877Y'];
            Campaign camp = [SELECT Id, EV_EventoVisibleNOW__c, Status FROM Campaign WHERE Id = :cm.EV_CampaignId__c];
            camp.EV_EventoVisibleNOW__c = true;
            camp.Status = '008';
            List<String> idioma = new List<String>{'001', '002'};
            EV_WS_GetEvents.RequestServicesGCFBody wrapper = EV_TestHelper.createWrapperJSONServicesGCF('detail-list-by-externalid-and-language', null, idioma, null, cm.EV_CampaignId__r.EV_ExternalID__c, null, null);

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
        System.runAs(newUser){
        	EV_WS_GetEvents.getResults();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void detailByExternalIdTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            EV_CampaignMemberC__c cm = [SELECT Id, EV_ExternalID__c, EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_Numero_Documento__c = '48133877Y'];
            Campaign camp = [SELECT Id, EV_EventoVisibleNOW__c, Status FROM Campaign WHERE Id = :cm.EV_CampaignId__c];
            camp.EV_EventoVisibleNOW__c = true;
            camp.Status = '008';
            List<String> idioma = new List<String>{'001', '002'};
            EV_WS_GetEvents.RequestServicesGCFBody wrapper = EV_TestHelper.createWrapperJSONServicesGCF('detail-by-externalid', null, idioma, null, null, cm.EV_ExternalID__c, null);

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
        System.runAs(newUser){
        	EV_WS_GetEvents.getResults();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void detailByExternalIdAndClient() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            EV_CampaignMemberC__c cm = [SELECT Id, EV_CampaignId__c, EV_CampaignId__r.EV_ExternalID__c, EV_ContactId__r.CC_Numperso__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_Numero_Documento__c = '48133877Y'];
            cm.EV_ContactId__r.CC_Numperso__c='123';
            update cm;
            Campaign camp = [SELECT Id, EV_EventoVisibleNOW__c, Status FROM Campaign WHERE Id = :cm.EV_CampaignId__c];
            camp.EV_EventoVisibleNOW__c = true;
            camp.Status = '003';
            List<String> idioma = new List<String>{'001', '002'};
            EV_WS_GetEvents.RequestServicesGCFBody wrapper = EV_TestHelper.createWrapperJSONServicesGCF('detail-by-externalid-and-client', cm.EV_ContactId__r.CC_Numperso__c, idioma, null, cm.EV_CampaignId__r.EV_ExternalID__c, null, null);

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
        System.runAs(newUser){
        	EV_WS_GetEvents.getResults();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void inprogressListByOfficeTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            Account acc = [SELECT Id, CC_Numero_Oficina__c FROM Account WHERE CC_Numero_Oficina__c = '00615'];
            EV_TestHelper.createChildCampaignVirtual(acc, null);
            Campaign camp = [SELECT Id, Status FROM Campaign WHERE EV_CentroOrganizador__c = :acc.Id];
            camp.Status = '004';
            update camp;
            List<String> idioma = new List<String>{'001', '002'};
            EV_WS_GetEvents.RequestServicesGCFBody wrapper = EV_TestHelper.createWrapperJSONServicesGCF('inprogress-list-by-office', null, idioma, acc.CC_Numero_Oficina__c, null, null, null);

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
        System.runAs(newUser){
        	EV_WS_GetEvents.getResults();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void registeredClientListByExternalIdTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            EV_CampaignMemberC__c cm = [SELECT Id, EV_CampaignId__c, EV_CampaignId__r.EV_ExternalID__c, EV_ContactId__r.CC_Numperso__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_Numero_Documento__c = '48133877Y'];
            Campaign camp = [SELECT Id, EV_EventoVisibleNOW__c, Status FROM Campaign WHERE Id = :cm.EV_CampaignId__c];
            camp.EV_EventoVisibleNOW__c = true;
            camp.Status = '003';
            List<String> idioma = new List<String>{'001', '002'};
            EV_WS_GetEvents.RequestServicesGCFBody wrapper = EV_TestHelper.createWrapperJSONServicesGCF('registered-client-list-by-externalid', null, null, null, cm.EV_CampaignId__r.EV_ExternalID__c, null, null);

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
        System.runAs(newUser){
        	EV_WS_GetEvents.getResults();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void clientByExternalid() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            EV_CampaignMemberC__c cm = [SELECT Id, EV_ExternalID__c, EV_ContactId__r.CC_Numperso__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_Numero_Documento__c = '48133877Y'];
            EV_WS_GetEvents.RequestServicesGCFBody wrapper = EV_TestHelper.createWrapperJSONServicesGCF('client-by-externalid', null, null, null, null, cm.EV_ExternalID__c, null);

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
        System.runAs(newUser){
        	EV_WS_GetEvents.getResults();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void clientUnsubscribedEventCustom() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            EV_CampaignMemberC__c cm = [SELECT Id, EV_ExternalID__c, EV_Status__c, EV_ContactId__r.CC_Numperso__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_Numero_Documento__c = '48133877Y'];
            EV_WS_GetEvents.RequestServicesGCFBody wrapper = EV_TestHelper.createWrapperJSONServicesGCF('client-unsubscribed-event', null, null, null, null, cm.EV_ExternalID__c, null);

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
        System.runAs(newUser){
        	EV_WS_GetEvents.getResults();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void clientUnsubscribedEvent() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            CampaignMember cm = [SELECT Id, EV_ExternalID__c, Status, Contact.CC_Numperso__c FROM CampaignMember WHERE Contact.CC_Numero_Documento__c = '48133877Y'];
            EV_WS_GetEvents.RequestServicesGCFBody wrapper = EV_TestHelper.createWrapperJSONServicesGCF('client-unsubscribed-event', null, null, null, null, cm.EV_ExternalID__c, null);

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
        System.runAs(newUser){
        	EV_WS_GetEvents.getResults();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_200, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void clientUnsubscribedEventEmptyList() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            EV_WS_GetEvents.RequestServicesGCFBody wrapper = EV_TestHelper.createWrapperJSONServicesGCF('client-unsubscribed-event', null, null, null, null, '1234567890', null);

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
        System.runAs(newUser){
        	EV_WS_GetEvents.getResults();
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_400, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
    
    @isTest
    public static void wrongParametersTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');     
        
        System.runAs(newUser){
            EV_CampaignMemberC__c cm = [SELECT Id, EV_ContactId__r.CC_Numperso__c, EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_Numero_Documento__c = '48133877Y'];
            Campaign camp = [SELECT Id, EV_EventoVisibleNOW__c, Status FROM Campaign WHERE Id = :cm.EV_CampaignId__c];
            camp.EV_EventoVisibleNOW__c = true;
            camp.Status = '008';
            update camp;
            List<String> idioma = new List<String>{'001', '002'};
            EV_WS_GetEvents.RequestServicesGCFBody wrapper = EV_TestHelper.createWrapperJSONServicesGCF('list-by-client', null, idioma, null, null, null, null);

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
        System.runAs(newUser){
        	EV_WS_GetEvents.getResults();
            system.debug('@@results ' + RestContext.response.responsebody);
        }
        Test.stopTest();
        System.assertEquals(HTTP_STATUS_400, RestContext.response.statusCode, 'La llamada no ha sido correcta');
    }
}