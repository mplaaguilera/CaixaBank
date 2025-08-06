/**********************************************************************************************************************
Name:      CIBE_DeleteRelatedOppQueueable_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase CIBE_DeleteRelatedOppQueueable
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION        USER_STORY		AUTHOR              DATE                Description
	1.0            US482011         Luis Martinez     18/05/2023          ºInit version

***********************************************************************************************************************/
@isTest
public with sharing class CIBE_DeleteRelatedOppQueueable_Test {
    @TestSetup
	static void setup() {
        User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

        System.runAs(userCli) {
            Account customer = AV_TestHelper.createCustomer();
		}
        System.runAs(userGcf) {
            Account customer = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];
            Opportunity opportunity = AV_TestHelper.createOpportunity(customer);
            AV_CustomActivityOpportunity__c custActOpp = new AV_CustomActivityOpportunity__c();
            custActOpp.AV_Opportunity__c = opportunity.Id;
            insert custActOpp;
		}
	}

	@isTest
	public static void validateQueueble() {
        User userGcf = [SELECT Id, UserRole.Name FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        List<AV_CustomActivityOpportunity__c> custOppList = new List<AV_CustomActivityOpportunity__c>();
        
        System.runAs(userGcf) {
            Account customer = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];
            Opportunity opportunity = [SELECT Id FROM Opportunity WHERE AccountId = :customer.Id];
            custOppList = [SELECT Id FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c = :opportunity.Id];
            Test.startTest();
            System.enqueueJob(new CIBE_DeleteRelatedOppQueueable(custOppList));
            Test.stopTest();
            custOppList = [SELECT Id FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c = :opportunity.Id];
        }
        System.assertEquals(custOppList.isEmpty(), true);
	}
}