/**********************************************************************************************************************
Name:	  AV_SetFieldsAPIOpp_SyncOpportunityTest
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_SetFieldsAPIOpp_SyncOpportunity"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY	   AUTHOR		   		DATE			Description
    1.0			Test Class	   Eric Vázquez	   	   26/10/2020		Init version
	1.1			Test Class	   David Rufo	   	   11/05/2021		Improve coverage and reuse code
	1.2		    AV_Query IT	   Daniel Rodríguez	   07/02/2022	    Change AV_Query to SOQL for User and Account

***********************************************************************************************************************/
@isTest
public with sharing class AV_SetFieldsAPIOpp_SyncOpportunityTest {

    private static Account accTest;
    private static Account cenTest;
    private static Contact conTest;
    
    @TestSetup
	static void setup(){
		AV_TestHelper.activateLogger();
        AV_TestHelper.createPricebook2();
	}
    
    private static void prepareData(){
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_ALTAOPP','OK'));
        User usrTest = AV_TestHelper.createUser(null);
        accTest = AV_TestHelper.createCustomer();
        cenTest = AV_TestHelper.createCaixaCenter();
        conTest = AV_TestHelper.createEmployee(cenTest, usrTest);
    }
    
    @isTest
	private static void testSyncOppDataNew() {
        prepareData();
        
        Test.startTest();
		Opportunity oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);
        Test.stopTest();
    }
    
    @isTest
	private static void testSyncOppDataUpdate() {
        prepareData();        
        Opportunity oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);
        
        Test.startTest();
        oppTest.AV_ExternalID__c = '00000001';
        oppTest.AV_OrigenApp__c = 'AV_SalesforceReport';
        oppTest.StageName = 'Vencido';
        update oppTest;
		Test.stopTest();
    }
    
    @isTest
	private static void testSyncOppDataUpdate2() {
        prepareData();        
        Opportunity oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);
        
        Test.startTest();
        oppTest.AV_ExternalID__c = '00000001';
        oppTest.AV_OrigenApp__c = 'AV_SalesforceReport';
        oppTest.StageName = 'No apto';
        update oppTest;
		Test.stopTest();
    }
    
    @isTest
	private static void testSyncOppDataUpdate3() {
        prepareData();        
        Opportunity oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);
        
        Test.startTest();
        oppTest.AV_ExternalID__c = '00000001';
        oppTest.AV_OrigenApp__c = 'AV_SalesforceReport';
        oppTest.StageName = 'Cerrado positivo';
        update oppTest;
		Test.stopTest();
    }
    
    @isTest
	private static void testSyncOppDataUpdate4() {
        prepareData();        
        Opportunity oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);
        
        Test.startTest();
        oppTest.AV_ExternalID__c = '00000001';
        oppTest.AV_OrigenApp__c = 'AV_SalesforceReport';
        oppTest.StageName = 'No interesado';
        update oppTest;
		Test.stopTest();
    }
    
    @isTest
	private static void testSyncOppDataUpdate5() {
        prepareData();        
        Opportunity oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);
        
        Test.startTest();
        oppTest.AV_ExternalID__c = '00000001';
        oppTest.AV_OrigenApp__c = 'AV_SalesforceReport';
        oppTest.StageName = 'Con venta';
        update oppTest;
		Test.stopTest();
    }
    
    @isTest
	private static void sendNewGCFTest() {
        prepareData();        
        Opportunity oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);
        AV_SetFieldsAPIOpp_SyncOpportunity.DataRequest data = new AV_SetFieldsAPIOpp_SyncOpportunity.DataRequest();
        User u = [Select id from User limit 1];
        //data.oppGCF = oppTest;
        data.oppSF = oppTest;
        data.user = u;
        
        Test.startTest();
        AV_SetFieldsAPIOpp_SyncOpportunity.sendNewGCF(data);

		Test.stopTest();
    }
    
     @isTest
	private static void sendUpdateGCFTest() {
        prepareData();        
        Opportunity oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);
        AV_SetFieldsAPIOpp_SyncOpportunity.DataRequest data = new AV_SetFieldsAPIOpp_SyncOpportunity.DataRequest();
        User u = [Select id from User limit 1];
        //data.oppGCF = oppTest;
        data.oppSF = oppTest;
        data.user = u;
        
        Test.startTest();
        AV_SetFieldsAPIOpp_SyncOpportunity.sendUpdateGCF(data);

		Test.stopTest();
    }
    
     @isTest
	private static void insertIntegrationResponsesTest() {
        prepareData();      
        Opportunity oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);
        AV_SetFieldsAPIOpp_SyncOpportunity.DataResponse datares = new AV_SetFieldsAPIOpp_SyncOpportunity.DataResponse();

        List<AV_SetFieldsAPIOpp_SyncOpportunity.DataResponse> listData = new List<AV_SetFieldsAPIOpp_SyncOpportunity.DataResponse>();
        /*User u = [Select id from User limit 1];
        oppTest.AV_ExternalID__c = '00000001';
        update oppTest;*/ 
        datares.idOpp = oppTest.Id;
        datares.externalIdOpp = '00000001';
        listdata.add(datares);
         
        Test.startTest();
        AV_SetFieldsAPIOpp_SyncOpportunity.insertIntegrationResponses(listdata);

		Test.stopTest();        
    }
    
    @isTest
	private static void fillDataTest() {
        prepareData();      
        Opportunity oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);

        /*User u = [Select id, AV_ExternalID__c from User limit 1];
        oppTest.AV_ExternalID__c = 'U0100001';
        update oppTest;*/  
        List<Opportunity> listopp = new List<Opportunity>();
		listopp.add(oppTest);
        String jsonString = json.serialize(listopp);
        
        Test.startTest();
        AV_SetFieldsAPIOpp_SyncOpportunity.fillData(jsonString);

		Test.stopTest();
        
    }
    
    
    

    
}