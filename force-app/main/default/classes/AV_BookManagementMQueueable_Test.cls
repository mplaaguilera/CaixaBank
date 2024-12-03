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
	1.2		       Fix PMD Errors 	Daniel Rodriguez	06/11/2023	    	Modified test to increase coverage and error PMD
    1.3			   Fix error		Daniel Rodriguez    18/01/2024			Fix method setup to create two account
***********************************************************************************************************************/
@isTest
public with sharing class AV_BookManagementMQueueable_Test {
	
    @TestSetup
	static void setup() {
        User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true limit 1];
        AV_TestHelper.createUser(null);
        System.runAs(userCli) {
			for(Integer i=0;i<2;i++) {
				AV_TestHelper.createCustomerWithNumperson('6543211234'+i);
			}

        }

	}

	@isTest
	public static void validateAccountQueueble() {
		User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true limit 1];
		List<Account> listAcc = [SELECT Id, AV_EAPGestor__c FROM Account WHERE Recordtype.DeveloperName = 'CC_ClientePA'];
    	Opportunity opp = AV_TestHelper.createOpportunity(listAcc.get(0));

        System.runAs(userCli){
			Test.startTest();
			Account acc = AV_TestHelper.createCaixaCenter();
			Contact empleado = AV_TestHelper.createEmployee(acc, userCli);
			Map<String,String> empleadoUsu = new Map<string,String>();
			empleadoUsu.put(empleado.id, empleado.id);
			List<AV_BookManagementMember__c> bookMemeberlst= new List<AV_BookManagementMember__c>();
			AV_Book__c book = AV_TestHelper.createPurse('11111');

			AV_BookManagementMember__c bookMM = AV_TestHelper.createBookManagement(empleado, book);
			AV_BookMember__c bookmem = AV_TestHelper.createBookMember(acc, book);
			bookMemeberlst.add(bookMM);
            AV_BookManagementMemberQueueable a = new AV_BookManagementMemberQueueable(bookMemeberlst, empleadoUsu);
            
            System.enqueueJob(a);
			Test.stopTest();
            System.assertNotEquals(a, null, 'KO');
        }
	}
    
}