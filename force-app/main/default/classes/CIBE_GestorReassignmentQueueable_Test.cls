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

		List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP, CIBE_AppConstants.USER_AV_AVOIDBULKAPI};
        CIBE_TestInitialSetup.setupInitialData(null, null, null, null, null, ps);
        User usuarioSA = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        User usuarioG = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];

		System.runAs(usuarioSA){
		//CIBE_TestHelper.createUser(CIBE_AppConstants.CIBE_GESTOR,'U0181273981391');
		Account acc = CIBE_TestHelper.createCustomerWithNumperson('65432112341');
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;
		CIBE_TestHelper.createOpportunity(acc);
        
		//User us = CIBE_TestHelper.createUser(CIBE_AppConstants.CIBE_GESTOR,'U0181273981392');
        CIBE_TestHelper.createTareaExternalId(usuarioG,'6543211234');

		}
		

	}

	@isTest
	public static void validateOppQueueble() {
		User us=[SELECT Id FROM User WHERE AV_ExternalId__c='U0000001' LIMIT 1];
		List<Opportunity> listOpp= [SELECT Id, OwnerId FROM Opportunity WHERE Name = 'Alerta Comercial' LIMIT 1];
		for(Opportunity opp: listOpp) {
			opp.OwnerId=us.Id;
		}
		User usAdmin=[SELECT Id FROM User WHERE AV_ExternalId__c='U0000000' LIMIT 1];

		System.runAs(usAdmin){
			CIBE_GestorReassignmentQueueable.doChainJob = false;
			Test.startTest();
			System.enqueueJob(new CIBE_GestorReassignmentQueueable(listOpp,null,null));
			System.assert(!listOpp.isEmpty());
			Test.stopTest();
		}
	}
    
    @isTest
	public static void validateOppQueuebleElse() {
        User us=[SELECT Id FROM User WHERE AV_ExternalId__c='U0000001' LIMIT 1];
		List<Task> listTask= [SELECT Id, OwnerId FROM Task WHERE AV_ExternalId__c ='6543211234' LIMIT 1];
		for(Task ta: listTask) {
			ta.OwnerId=us.Id;
		}
		User usAdmin=[SELECT Id FROM User WHERE AV_ExternalId__c='U0000000' LIMIT 1];

		System.runAs(usAdmin){
			CIBE_GestorReassignmentQueueable.doChainJob = false;
			Test.startTest();
			System.enqueueJob(new CIBE_GestorReassignmentQueueable(null,listTask,null));
			System.assert(!listTask.isEmpty());
			Test.stopTest();
		}
	}
}