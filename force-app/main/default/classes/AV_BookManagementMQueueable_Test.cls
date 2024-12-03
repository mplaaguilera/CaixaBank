/**********************************************************************************************************************
Name:      AV_BookManagementMQueueable_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase AV_BookManagementMemberQueueable
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION        USER_STORY		AUTHOR              DATE                Description
	1.0            Init             Sandra Gómez        04/04/2022          Init version
	1.1            Fix              Patricia Solano     12/01/2023          Modify setup to reduce querys and added runAs
***********************************************************************************************************************/
@isTest
public with sharing class AV_BookManagementMQueueable_Test {
	
    @TestSetup
	static void setup() {
        User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true limit 1];
        AV_TestHelper.createUser(null);
        System.runAs(userCli) {
			for(Integer i=0;i<5;i++) {
				AV_TestHelper.createCustomerWithNumperson('6543211234'+i);
			}
        }
	}

	@isTest
	public static void validateAccountQueueble() {
		User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true limit 1];
        
		List<Account> listAcc = [SELECT Id, AV_EAPGestor__c FROM Account WHERE Recordtype.DeveloperName = 'CC_ClientePA'];
		List<Account> listAll = new List<Account>(listAcc);
		Map<Id, Account> mapOld = new Map<Id, Account>(listAcc);
		Set<Id> listContactEAP = new Set<Id>();
		Set<Id> listContactEAPOld = new Set<Id>();
		List<Opportunity> listOppo = new List<Opportunity>();

		for (Account acc : listAcc) {
			listContactEAP.add(acc.AV_EAPGestor__c);
			listContactEAPOld.add(acc.AV_EAPGestor__c);
		}

		for (Integer i = 1; i <= 1; i++) {
            Opportunity opp = AV_TestHelper.createOpportunity(listAcc.get(0));
            listOppo.add(opp);
        }

        System.runAs(userCli){
            Test.startTest();
            AV_BookManagementMemberQueueable a = new AV_BookManagementMemberQueueable(null, null);
            
            System.enqueueJob(a);
			Test.stopTest();
            System.assertNotEquals(a, null);
        }
	}
    
}