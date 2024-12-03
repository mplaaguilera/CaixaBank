/**********************************************************************************************************************
Name:      CIBE_GestorReassignmentQueueable_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase CIBE_GestorReassignmentQueueable
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY	   	AUTHOR		   		DATE			Description
    1.0			Test Class	   	Mikel Lezama	   	10/11/2022		Init version

***********************************************************************************************************************/
@isTest
public class CIBE_GestorReassignmentQueueable_Test {
	@TestSetup
	static void setup() {
		CIBE_TestHelper.createUser(CIBE_AppConstants.CIBE_GESTOR,'U0181273981391');
		Account acc = CIBE_TestHelper.createCustomerWithNumperson('65432112341');
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;
		CIBE_TestHelper.createOpportunity(acc);
        
		User us = CIBE_TestHelper.createUser(CIBE_AppConstants.CIBE_GESTOR,'U0181273981392');
        CIBE_TestHelper.createTareaExternalId(us,'6543211234');

	}

	@isTest
	public static void validateOppQueueble() {
		User us=[Select Id from User where AV_ExternalId__c='U0181273981391' limit 1];
		List<Opportunity> listOpp= [Select Id, OwnerId from Opportunity];
		for(Opportunity opp: listOpp) {
			opp.OwnerId=us.Id;
		}
        CIBE_GestorReassignmentQueueable.doChainJob = false;
		Test.startTest();
		System.enqueueJob(new CIBE_GestorReassignmentQueueable(listOpp,null,null));
		Test.stopTest();
	}
    
    @isTest
	public static void validateOppQueuebleElse() {
        User us=[Select Id from User where AV_ExternalId__c='U0181273981391' limit 1];
		List<Task> listTask= [Select Id, OwnerId from Task];
		for(Task ta: listTask) {
			ta.OwnerId=us.Id;
		}
        CIBE_GestorReassignmentQueueable.doChainJob = false;
		Test.startTest();
		System.enqueueJob(new CIBE_GestorReassignmentQueueable(null,listTask,null));
		Test.stopTest();
	}
}