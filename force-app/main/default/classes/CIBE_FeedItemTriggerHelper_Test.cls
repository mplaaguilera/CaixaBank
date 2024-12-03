/**********************************************************************************************************************
Name:	  CIBE_FeedItemTriggerHelper_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_FeedItemTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY			AUTHOR				DATE				Description
1.0			Data access		    Luis Martínez	    22/12/2022		    Init version
1.1			FIX  	            Luis Martínez	    27/11/2023		    Cambio por fallo subida FIX

***********************************************************************************************************************/
@isTest
public with sharing class CIBE_FeedItemTriggerHelper_Test {
    @TestSetup
    static void setup(){
        List<String> lstPSet = new list<String>{CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA};
        CIBE_TestInitialSetup.setupInitialData('','','', '','',lstPSet);
        User usrTest = [SELECT Id FROM User WHERE Profile.name =:CIBE_AppConstants.CIBE_GESTOR AND AV_ExternalID__c ='U0000001'];
        system.runAs(usrTest){
            Account accTest = CIBE_TestHelper.createConfidencialCustomer();
            CIBE_TestHelper.createOpportunityTeam(accTest);
        }
    }

    @isTest
    private static void createNotificationNewChat_test() {
        User usrTest = [SELECT Id FROM User WHERE Profile.name =:CIBE_AppConstants.CIBE_GESTOR AND AV_ExternalID__c ='U0000001'];
        system.runAs(usrTest){
            List<Opportunity> opps = [SELECT Id, OwnerId, AccountId FROM Opportunity 
            WHERE Recordtype.DeveloperName =:CIBE_AppConstants.OPP_INICIATIVACIB_RT AND OwnerId = :usrTest.Id];

            List<FeedItem> lstFI = new List<FeedItem>();
            FeedItem fi = new FeedItem();
            fi.parentId = opps[0].Id;
            fi.body = 'Prueba123';
            lstFI.add(fi);

            Test.startTest();
                insert lstFI;
                if(!opps.isEmpty()){
                    CIBE_FeedItemTriggerHelper.createNotificationNewChat(lstFI);
                    List<FeedItem> lstFI2 = [SELECT Id FROM FeedItem WHERE parentId = :opps.get(0).Id AND Id =: lstFI[0].Id];
                    System.assert(lstFI2.size()>0);
                }
            Test.stopTest();
        }
    }
}