/**********************************************************************************************************************
 Name:	  CIBE_FeedItemTriggerHelper_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_FeedItemTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY			AUTHOR				DATE				Description
1.0			Data access		    Luis Martínez	        22/12/2022		    Init version

***********************************************************************************************************************/
@isTest
public with sharing class CIBE_FeedItemTriggerHelper_Test {
    @TestSetup
    static void setup(){
        User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
        Account accTest = CIBE_TestHelper.createConfidencialCustomer();
        Account cenTest = CIBE_TestHelper.createCaixaCenter();
        Contact conTest = CIBE_TestHelper.createEmployee(cenTest, usrTest);
        CIBE_TestHelper.createOpportunityTeam(accTest);
    
    }

    @isTest
    private static void createNotificationNewChat_test() {
        List<Opportunity> opps = [SELECT Id, OwnerId, AccountId FROM Opportunity];
        List<FeedItem> lstFI = new List<FeedItem>();
        FeedItem fi = new FeedItem();
        fi.parentId = opps[0].Id;
        fi.body = 'Prueba123';
        lstFI.add(fi);
        insert lstFI;


        Test.startTest();
        if(!opps.isEmpty()){
            CIBE_FeedItemTriggerHelper.createNotificationNewChat(lstFI);
            List<FeedItem> lstFI2 =[SELECT Id FROM FeedItem WHERE parentId = :opps.get(0).Id];
            System.assert(lstFI2.size()>0);
        }
        Test.stopTest();
    }
}