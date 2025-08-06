/**********************************************************************************************************************
Name:	  CIBE_OppFromGroupsController_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_OpportunitiesFromGroupsController"
-----------------------------------------------------------------------------------------------------------------------
Historial
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Test Class		Mikel Lezama		28/09/2022		Init version
1.1         Test Class      Gonzalo Ávila       26/09/2024      Modify RunAs user and StartTest position to avoid too many queries

-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/
@isTest
public with sharing class CIBE_OppFromGroupsController_Test {
    
    @TestSetup
	static void setup() {
        CIBE_TestInitialSetup.setupInitialDataEMP();
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c ='U0000000'];
        Test.startTest();
        System.runAs(usrTest) {
            User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
            Account acc = CIBE_TestHelper.createCustomer(u);

            Opportunity opp = CIBE_TestHelper.createOpportunity(acc);
            opp.StageName = 'En curso';
            opp.ownerId = u.Id;
            update opp;
        }
        Test.stopTest();
    }
    
	@isTest
	public static void getDataTest() {
        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        System.runAs(u) {
            Test.startTest();
            Map<Id, Account> clients = new Map<Id, Account>([SELECT Id FROM Account WHERE Recordtype.DeveloperName = 'CC_Cliente']);
            List<CIBE_OpportunitiesFromGroupsController.OpportunityWrapper> result = CIBE_OpportunitiesFromGroupsController.getRecords(0, new List<Id>(clients.keySet()));
            Test.stopTest();
            System.assert(!result.isEmpty());
        }
        
    }

}