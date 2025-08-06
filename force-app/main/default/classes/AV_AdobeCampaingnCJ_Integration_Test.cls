/**********************************************************************************************************************
Name:	  AV_AdobeCampaingnCJ_Integration_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Unit test del servicio AV_AdobeCampaingnCJ_Integration_Test
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Jashanpreet Singh  	18/11/2020		Init version
1.1 		HotFix  	   Víctor Santiago  	22/09/2021		Added CustomSetting in setup
1.2         US609232       Oscar Moreno         13/06/2023      The class is commented out to avoid making the unnecessary calls to Adobe Campaign
***********************************************************************************************************************/
@isTest
public with sharing class AV_AdobeCampaingnCJ_Integration_Test {

    
    @TestSetup
    static void setup(){
        AV_TestHelper.createCustomer();
        AV_AzureTeamsToken__c cs = new AV_AzureTeamsToken__c();
        cs.Name = 'AdobeToken';
        cs.AV_ExpiresIn__c = 0; //Zero so cs.LastModifiedDate < now and syncCJ calls login method
        insert cs;
        
        
        
        
    }
    
    @isTest
    public static void testMethod1(){
	//Test.startTest();
	Map<String,String> test = AV_AdobeCampaingnCJ_Integration.login();
    Map<String,String> tokenTest = new Map<String,String>();
    system.assertEquals(tokenTest , test);
    //Test.stopTest();

	}

   	/*@isTest
    public static void testlookUpList() {
        
        Test.startTest();
        String numperson = [SELECT Id, AV_NumPerso__c FROM Account Limit 1].AV_NumPerso__c;
 		Map<String, HttpCalloutMock> header2TestResp =
                                   new Map<String,HttpCalloutMock>();
        header2TestResp.put('"xtk:session#Logon"',new AV_MockCallout_Test('CJ_Login','OK'));
        header2TestResp.put('"nms:recipient#lookUpCJ"',new AV_MockCallout_Test('CJ_LookUpList','OK'));
         header2TestResp.put('"nms:recipient#marketing360"',new AV_MockCallout_Test('CJ_Marketing360','OK'));
 
        HttpCalloutMock multiCalloutMock =
                                   new AV_MultiRequestMock_Test(header2TestResp);
 
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        String result = AV_AdobeCampaingnCJ_Integration.syncCJ(numPerson);
        Test.stopTest();
    }
    
    @isTest
    public static void testlookUp() {
        
        
        Test.startTest();
        String numperson = [SELECT Id, AV_NumPerso__c FROM Account Limit 1].AV_NumPerso__c;
         Map<String, HttpCalloutMock> header2TestResp =
                                   new Map<String,HttpCalloutMock>();
        header2TestResp.put('"xtk:session#Logon"',new AV_MockCallout_Test('CJ_Login','OK'));
        header2TestResp.put('"nms:recipient#lookUpCJ"',new AV_MockCallout_Test('CJ_LookUp','OK'));
         header2TestResp.put('"nms:recipient#marketing360"',new AV_MockCallout_Test('CJ_Marketing360','OK'));
 
        HttpCalloutMock multiCalloutMock =
                                   new AV_MultiRequestMock_Test(header2TestResp);
 
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        String result = AV_AdobeCampaingnCJ_Integration.syncCJ(numPerson);	
        Test.stopTest();
    }
    
    @isTest
    public static void testlookUpError() {
        Test.startTest();
        String numperson = [SELECT Id, AV_NumPerso__c FROM Account Limit 1].AV_NumPerso__c;
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CJ_Login','OK'));
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CJ_LookUpError','OK'));
        String result = AV_AdobeCampaingnCJ_Integration.syncCJ(numPerson);	
        Test.stopTest();
    }*/
    
}