/**********************************************************************************************************************
 Name:	  CIBE_FeedCommentTriggerHelper_test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_FeedCommentTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY			AUTHOR				DATE				Description
1.0			Data access		    Luis Martínez	        22/12/2022		    Init version
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_FeedCommentTriggerHelper_test {
    @TestSetup
    static void setup(){
        List<String> lstPSet = new list<String>{CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA};
        CIBE_TestInitialSetup.setupInitialData('','','', '','',lstPSet);
        User usrTest = [SELECT Id FROM User WHERE Profile.name =:CIBE_AppConstants.CIBE_GESTOR AND AV_ExternalID__c ='U0000001' ];

        system.runAs(usrTest){
            Account accTest = CIBE_TestHelper.createConfidencialCustomer();
            CIBE_TestHelper.createOpportunityTeam(accTest);
        }
    
    }

    @isTest
    private static void createNotificationNewChat_test() {
        User usrTest = [SELECT Id FROM User WHERE Profile.name =:CIBE_AppConstants.CIBE_GESTOR AND AV_ExternalID__c ='U0000001' ];
        List<FeedItem> lstFi = new List<FeedItem>();
        FeedItem fi = new FeedItem();
        system.runAs(usrTest){
            List<Opportunity> opps = [SELECT Id, OwnerId, AccountId FROM Opportunity];
            fi.parentId = opps[0].Id;
            fi.body = 'Prueba123';
            lstFi.add(fi);
            insert lstFi;
            List<FeedComment> lstFc = new List<FeedComment>();
            FeedComment fc = new FeedComment();
            fc.FeedItemId = fi.id;
            fc.CommentBody	 = 'Prueba123';
            lstFc.add(fc);
            insert lstFc;

            Test.startTest();
            if(!opps.isEmpty()){
                CIBE_FeedItemTriggerHelper.createNotificationNewChat(lstFi);
            }
            Test.stopTest();
        }
        List<FeedComment> lstFcFin =[SELECT Id FROM FeedComment WHERE FeedItemId = :fi.id];
        System.assert(lstFcFin.size()>0);
    }
}