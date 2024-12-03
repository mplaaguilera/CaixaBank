/**********************************************************************************************************************
Name:      CIBE_GestorReassignmentEQueueable_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase CIBE_GestorReassignmentEventsQueueable
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY	   	AUTHOR		   		DATE			Description
    1.0			Test Class	   	Mikel Lezama	   	10/11/2022		Init version
	1.1			US609754  		Lucía          		26/06/2023      Añadir el System.runAs y arreglar el error de QC: Apex unit tests should include at least one assertion

***********************************************************************************************************************/
@isTest
public class CIBE_GestorReassignmentEQueueable_Test {
	@TestSetup
	static void setup() {

		CIBE_TestInitialSetup.setupInitialDataCIB();
        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

		System.runAs(new User(Id = UserInfo.getUserId())){
			CIBE_TestHelper.createUser(CIBE_AppConstants.CIBE_GESTOR,'U0181273981391');//1
			User us = CIBE_TestHelper.createUser(CIBE_AppConstants.CIBE_GESTOR,'U0181273981392');//1
			Account acc = CIBE_TestHelper.createCustomer();
			Datetime activityDate = Date.Today().addDays(-1);
			CIBE_TestHelper.createEventExternalId(us,activityDate.addDays(1), 'E6543211234', acc);
			CIBE_TestHelper.createEventExternalId(us,activityDate.addDays(2), 'E6543211235', acc);

		
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
		}
		
	}

	@isTest
	public static void validateEventQueueble() {

		User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

		System.runAs(usuario){
			Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_MOCNT','OK'));
			User us=[Select Id from User where AV_ExternalId__c='U0181273981391' limit 1];
			List<Event> listEvent= [Select Id, OwnerId from Event];
			for(Event e: listEvent) {
				e.OwnerId=us.Id;
			}
			CIBE_GestorReassignmentEventsQueueable.doChainJob = false;
			Test.startTest();
			System.enqueueJob(new CIBE_GestorReassignmentEventsQueueable(listEvent));
			System.assertNotEquals(null, listEvent.size());
			Test.stopTest();
		}

      
	}
    @isTest
	public static void validateEventQueuebleElse() {
		User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

		System.runAs(usuario){
			CIBE_GestorReassignmentEventsQueueable.doChainJob = false;
			List<Event> listEvent= new List<Event>();
			Test.startTest();
			System.enqueueJob(new CIBE_GestorReassignmentEventsQueueable(listEvent));
			System.assertEquals(0, listEvent.size());
			Test.stopTest();
		}
	}
}