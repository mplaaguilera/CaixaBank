/**********************************************************************************************************************
Name:      CIBE_GestorReassignmentTQueueable_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase CIBE_GestorReassignmentTaskQueueable
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY	   	AUTHOR		   		DATE			Description
    1.0			Test Class	   	Mikel Lezama	   	10/11/2022		Init version
   	1.1         US609754  		Lucía          		26/06/2023      Añadir el System.runAs y arreglar el error de QC: Apex unit tests should include at least one assertion

***********************************************************************************************************************/
@isTest
public class CIBE_GestorReassignmentTQueueable_Test {
	@TestSetup
	static void setup() {

		CIBE_TestInitialSetup.setupInitialDataCIB();
		User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

		System.runAs(new User(Id = UserInfo.getUserId())){
			CIBE_TestHelper.createUser(CIBE_AppConstants.CIBE_GESTOR,'U0181273981391');
			// User us = CIBE_TestHelper.createUser(CIBE_AppConstants.CIBE_GESTOR,'U0181273981392');
			CIBE_TestHelper.createTareaExternalId(usuario,'6543211234');
			CIBE_TestHelper.createTareaExternalId(usuario,'6543211235');
			//CIBE_TestHelper.createTareaExternalId(us,'6543211236');
			
			Account acc = CIBE_TestHelper.createCustomer();
			Datetime activityDate = Date.Today().addDays(-1);
			CIBE_TestHelper.createEventExternalId(usuario,activityDate.addDays(1), 'E6543211234', acc);
		}
		
	}

	@isTest
	public static void validateTaskQueueble() {

		User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		System.runAs(usuario){
			User us=[Select Id from User where AV_ExternalId__c='U0181273981391' limit 1];
			List<Task> listTask= [Select Id, OwnerId from Task];
			for(Task ta: listTask) {
				ta.OwnerId=us.Id;
			}
			CIBE_GestorReassignmentTaskQueueable.doChainJob = false;
			Test.startTest();
			System.enqueueJob(new CIBE_GestorReassignmentTaskQueueable(listTask,null));
			System.assertNotEquals(0, listTask.size());
			Test.stopTest();
		}
		
	
	}
    @isTest
	public static void validateTaskQueuebleElse() {

		User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		System.runAs(usuario){
			CIBE_GestorReassignmentTaskQueueable.doChainJob = false;
			List<Event> listEvent= [Select Id, OwnerId from Event];
			Test.startTest();
			System.enqueueJob(new CIBE_GestorReassignmentTaskQueueable(null,listEvent));
			System.assertNotEquals(0, listEvent.size());
			Test.stopTest();
		}
		
	}
}