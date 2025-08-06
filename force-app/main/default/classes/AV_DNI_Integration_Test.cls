/**********************************************************************************************************************
Name:	  AV_DNI_Integration_Test
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: AV_DNI_Integration test covertry
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY	   		AUTHOR		   			DATE				Description
    1.0			US820938	   		Luis Fernández	   	   	19/06/2024			Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_DNI_Integration_Test {

    @TestSetup
    public static void setup(){


        User userGCF = [SELECT Id FROM User WHERE Alias = 'AV-TF9'];
        User userCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];

        User gest = AV_TestHelper.createUser(AV_AppConstants.AV_PROFILE,'fakeExternalId');
        AV_TestHelper.insertNeededPermissions(gest);
        System.runAs(userCli){
            Account acc = AV_TestHelper.createCustomerSinInsert();
            acc.AV_Numperso__c = '00000000';
            acc.OwnerId = gest.Id;
            insert acc;
            insert new List<CBK_IntegrationSetting__c>{new CBK_IntegrationSetting__c(
                Name = 'AV_DNI',
                NamedCredential__c = 'callout:API_GWT_PRO/partyReferenceDataDirectory/basic/tickets?imagesType={typeofdni}',
                CBK_Method__c = 'GET'
            ), new CBK_IntegrationSetting__c(
                Name = 'AV_DNI_IMG',
                NamedCredential__c = 'callout:API_GWT_PRO/partyReferenceDataDirectory/basic/tickets/binaries/request',
                CBK_Method__c = 'POST'
            )};
        }


    }

    @isTest 
    public static void validateApiCallMethod(){

        User gest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'fakeExternalId'];
        Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
        header2TestResp.put('callout:API_GWT_PRO/partyReferenceDataDirectory/basic/tickets?imagesType=DOCUMENT', new AV_MockCallout_Test('API_DNI_FIRST_CALL','OK'));
        header2TestResp.put('callout:API_GWT_PRO/partyReferenceDataDirectory/basic/tickets/binaries/request',new AV_MockCallout_Test('API_DNI_SECOND_CALL','OK'));
        HttpCalloutMock multiCalloutMock = new AV_MultiRequestMock_Test(header2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Account customer = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = '9446386T' AND AV_Numperso__c = '00000000'];
        Test.startTest();
        System.runAs(gest){
            Map<String,String> tstResponse = AV_DNI_Integration.callDNIApi(customer.Id);
            System.assert(tstResponse.get('anvers').equals('TestingDNI'),'NOK');
        }
        
        Test.stopTest();


    }

    @isTest 
    public static void testingFailSecondCall(){
        User gest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'fakeExternalId'];
        Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
        header2TestResp.put('callout:API_GWT_PRO/partyReferenceDataDirectory/basic/tickets?imagesType=DOCUMENT', new AV_MockCallout_Test('API_DNI_FIRST_CALL','OK'));
        HttpCalloutMock multiCalloutMock = new AV_MultiRequestMock_Test(header2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Account customer = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = '9446386T' AND AV_Numperso__c = '00000000'];
        Test.startTest();
        System.runAs(gest){
            Map<String,String> tstResponse = AV_DNI_Integration.callDNIApi(customer.Id);
            System.assert(tstResponse.get('errorMessage') != null);
        }
        
        Test.stopTest();
    }
    @isTest 
    public static void testingFailsFirstCall(){
        User gest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'fakeExternalId'];
        Account customer = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = '9446386T' AND AV_Numperso__c = '00000000'];
        Test.startTest();
        System.runAs(gest){
            Map<String,String> tstResponse = AV_DNI_Integration.callDNIApi(customer.Id);
            System.assert(tstResponse.get('errorMessage') != null);
        }
        
        Test.stopTest();
    }
    @isTest 
    public static void testingFailsNoClient(){
        User gest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'fakeExternalId'];
        Account customer = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = '9446386T' AND AV_Numperso__c = '00000000'];
        customer.AV_Numperso__c = null;
        customer.OwnerId = gest.Id;
        update customer;
        Test.startTest();
        System.runAs(gest){
            Map<String,String> tstResponse = AV_DNI_Integration.callDNIApi(customer.Id);
            System.assert(tstResponse.get('errorMessage') != null);
        }
        
        Test.stopTest();
    }
}