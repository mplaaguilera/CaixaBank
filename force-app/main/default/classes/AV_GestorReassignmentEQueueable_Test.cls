/**********************************************************************************************************************
Name:      AV_GestorReassignmentEQueueable_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase AV_GestorReassignmentEventsQueueable
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION        USER_STORY		AUTHOR              DATE                Description
	1.0            Init             Sandra Gómez        05/04/2022          Init version

***********************************************************************************************************************/
@isTest
public with sharing class AV_GestorReassignmentEQueueable_Test {
	@TestSetup
	static void setup() {
		AV_TestHelper.createUser('','U0181273981391');
		User us = AV_TestHelper.createUser('','U0181273981392');
		Account centroCaixa = AV_TestHelper.createCaixaCenter();
		Contact empleado  = AV_TestHelper.createEmployee(centroCaixa, us,us.AV_ExternalId__c);
		Account acc = AV_TestHelper.createCustomer();
		Datetime activityDate = Date.Today().addDays(-1);
		List<Event> listEventInsert = new List<Event>();
		for(Integer i=0;i<10;i++) {
			Event ev = AV_TestHelper.createEventExternalIdSinInsert(us,activityDate.addDays(i), 'E6543211234'+i, acc);
			listEventInsert.add(ev);
		}
		insert listEventInsert;
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
	}

	@isTest
	public static void validateEventQueueble() {
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_MOCNT','OK'));
		User us=[Select Id from User where AV_ExternalId__c='U0181273981391' limit 1];
		List<Event> listEvent= [Select Id, OwnerId from Event];
		for(Event e: listEvent) {
			e.OwnerId=us.Id;
		}
        AV_GestorReassignmentEventsQueueable.doChainJob = true;
		Test.startTest();
		System.enqueueJob(new AV_GestorReassignmentEventsQueueable(listEvent));
		Test.stopTest();
	}
    
    @isTest
	public static void validateEventQueuebleVacio() {
        AV_GestorReassignmentEventsQueueable.doChainJob = false;
		Test.startTest();
		System.enqueueJob(new AV_GestorReassignmentEventsQueueable(null));
		Test.stopTest();
	}
}