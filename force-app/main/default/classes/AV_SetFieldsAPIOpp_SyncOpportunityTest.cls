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
    1.3 		US649249	   Gonzalo Ávila	   27/11/2023		Include system.asserts in all methods


***********************************************************************************************************************/
@isTest
public with sharing class AV_SetFieldsAPIOpp_SyncOpportunityTest {

    private static Account accTest;
    private static Account cenTest;
    private static Contact conTest;
    
    @TestSetup
	static void setup(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		AV_TestHelper.activateLogger();
        AV_TestHelper.createPricebook2();
	}
    
    private static void prepareData(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_ALTAOPP','OK'));
        System.runAs(userGcf){
        User usrTest = AV_TestHelper.createUser(null);
        accTest = AV_TestHelper.createCustomer();
        cenTest = AV_TestHelper.createCaixaCenter();
        conTest = AV_TestHelper.createEmployee(cenTest, usrTest);
        }
    }
    
    @isTest
	private static void testSyncOppDataNew() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Opportunity oppTest;
        prepareData();
        System.runAs(userGcf){
        Test.startTest();
		oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);
        Test.stopTest();
        }
        System.assert(oppTest != null, 'Opportunity is Empty');
    }
    
    @isTest
	private static void testSyncOppDataUpdate() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        prepareData();        
        Opportunity oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);
        System.runAs(userGcf){
        Test.startTest();
        oppTest.AV_ExternalID__c = '00000001';
        oppTest.AV_OrigenApp__c = 'AV_SalesforceReport';
        update oppTest;
       
		Test.stopTest();
        }
        System.assertEquals('00000001', oppTest.AV_ExternalID__c, 'El campo AV_ExternalID__c no se actualizó correctamente.');
        System.assertEquals('AV_SalesforceReport', oppTest.AV_OrigenApp__c, 'El campo AV_OrigenApp__c no se actualizó correctamente.');
    }
    
    @isTest
	private static void testSyncOppDataUpdate2() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        prepareData();        
        Opportunity oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);
        System.runAs(userGcf){
        Test.startTest();
        oppTest.AV_ExternalID__c = '00000001';
        oppTest.AV_OrigenApp__c = 'AV_SalesforceReport';
        oppTest.StageName = 'No apto';
        update oppTest;
        }
        
		Test.stopTest();
        System.assertEquals('00000001', oppTest.AV_ExternalID__c, 'El campo AV_ExternalID__c no se actualizó correctamente.');
        System.assertEquals('AV_SalesforceReport', oppTest.AV_OrigenApp__c, 'El campo AV_OrigenApp__c no se actualizó correctamente.');
        System.assertEquals('No apto', oppTest.StageName, 'El campo StageName no se actualizó correctamente.');
    }
    
    @isTest
	private static void testSyncOppDataUpdate3() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        prepareData();        
        Opportunity oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);
        System.runAs(userGcf){
        Test.startTest();
        oppTest.AV_ExternalID__c = '00000001';
        oppTest.AV_OrigenApp__c = 'AV_SalesforceReport';
        oppTest.StageName = 'Cerrado positivo';
        update oppTest;
		Test.stopTest();
        }
        System.assertEquals('00000001', oppTest.AV_ExternalID__c, 'El campo AV_ExternalID__c no se actualizó correctamente.');
        System.assertEquals('AV_SalesforceReport', oppTest.AV_OrigenApp__c, 'El campo AV_OrigenApp__c no se actualizó correctamente.');
        System.assertEquals('Cerrado positivo', oppTest.StageName, 'El campo StageName no se actualizó correctamente.');
    }
    
    @isTest
	private static void testSyncOppDataUpdate4() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        prepareData();        
        Opportunity oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);
        System.runAs(userGcf){
        Test.startTest();
        oppTest.AV_ExternalID__c = '00000001';
        oppTest.AV_OrigenApp__c = 'AV_SalesforceReport';
        oppTest.StageName = 'No interesado';
        update oppTest;
        
		Test.stopTest();
        }
        System.assertEquals('00000001', oppTest.AV_ExternalID__c, 'El campo AV_ExternalID__c no se actualizó correctamente.');
        System.assertEquals('AV_SalesforceReport', oppTest.AV_OrigenApp__c, 'El campo AV_OrigenApp__c no se actualizó correctamente.');
        System.assertEquals('No interesado', oppTest.StageName, 'El campo StageName no se actualizó correctamente.');
    }
    
    @isTest
	private static void testSyncOppDataUpdate5() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        prepareData();        
        Opportunity oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);
        System.runAs(userGcf){
        Test.startTest();
        oppTest.AV_ExternalID__c = '00000001';
        oppTest.AV_OrigenApp__c = 'AV_SalesforceReport';
        update oppTest;
        
		Test.stopTest();
        }
        System.assertEquals('00000001', oppTest.AV_ExternalID__c, 'El campo AV_ExternalID__c no se actualizó correctamente.');
        System.assertEquals('AV_SalesforceReport', oppTest.AV_OrigenApp__c, 'El campo AV_OrigenApp__c no se actualizó correctamente.');
    }
    
    @isTest
	private static void sendNewGCFTest() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        prepareData();        
        Opportunity oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);
        AV_SetFieldsAPIOpp_SyncOpportunity.DataRequest data = new AV_SetFieldsAPIOpp_SyncOpportunity.DataRequest();
        User u = [Select id from User limit 1];
        data.oppSF = oppTest;
        data.user = u;
        System.runAs(userGcf){
        Test.startTest();
        AV_SetFieldsAPIOpp_SyncOpportunity.DataResponse dataResp= AV_SetFieldsAPIOpp_SyncOpportunity.sendNewGCF(data);
        System.assert(dataResp != null, 'The DataResponse is Empty');

        
		Test.stopTest();
        }
        
    }
    
     @isTest
	private static void sendUpdateGCFTest() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        prepareData();        
        Opportunity oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);
        AV_SetFieldsAPIOpp_SyncOpportunity.DataRequest data = new AV_SetFieldsAPIOpp_SyncOpportunity.DataRequest();
        User u = [Select id from User limit 1];
        data.oppSF = oppTest;
        data.user = u;
        List<AV_SetFieldsAPIOpp_SyncOpportunity.DataResponse> listDtresponse = new List<AV_SetFieldsAPIOpp_SyncOpportunity.DataResponse>();
        System.runAs(userGcf){
        Test.startTest();
        listDtresponse.add(AV_SetFieldsAPIOpp_SyncOpportunity.sendUpdateGCF(data)); 
        System.assert(!listDtresponse.isEmpty(), 'The DataResponse is Empty');

		Test.stopTest();
        }
    }
    
     @isTest
	private static void insertIntegrationResponsesTest() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        prepareData();      
        Opportunity oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);
        AV_SetFieldsAPIOpp_SyncOpportunity.DataResponse datares = new AV_SetFieldsAPIOpp_SyncOpportunity.DataResponse();

        List<AV_SetFieldsAPIOpp_SyncOpportunity.DataResponse> listData = new List<AV_SetFieldsAPIOpp_SyncOpportunity.DataResponse>();
        datares.idOpp = oppTest.Id;
        datares.externalIdOpp = '00000001';
        listdata.add(datares);
        
        System.runAs(userGcf){
        Test.startTest();
        System.assert(!listdata.isEmpty(), 'ListData is empty before insert');
        AV_SetFieldsAPIOpp_SyncOpportunity.insertIntegrationResponses(listdata);
        

		Test.stopTest();    
        }    
    }
    
    @isTest
	private static void fillDataTest() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        prepareData();      
        Opportunity oppTest = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(accTest, conTest);

        List<Opportunity> listopp = new List<Opportunity>();
		listopp.add(oppTest);
        String jsonString = json.serialize(listopp);
        List<AV_SetFieldsAPIOpp_SyncOpportunity.DataRequest> listDtrequest = new List<AV_SetFieldsAPIOpp_SyncOpportunity.DataRequest>();
        System.runAs(userGcf){
        Test.startTest();
        listDtrequest = AV_SetFieldsAPIOpp_SyncOpportunity.fillData(jsonString);
        System.assert(!listDtrequest.isEmpty(), 'ListDtrequest is empty after calling fillData method');
		Test.stopTest();   
        }
    }
}