/**********************************************************************************************************************
 Name:	  AV_RegularizeHCActivityEvents_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de Test para AV_RegularizeHeaderCustomActivityEvents
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR					DATE				Description
	1.0			App FSC			Carolina Alonso	   		02/09/2020			Init version

***********************************************************************************************************************/
@isTest
public class AV_RegularizeHCActivityEvents_Test {
	
	/**
	 * Create Event and update it without AV_Task__c filled.
	 */
	@TestSetup
	static void setup() {
		AV_TestHelper.activateLogger();
		Account acc = AV_TestHelper.createCustomer();
	}

	/**
	 * Execute the Batch class (AV_RegularizeHeaderCustomActivityEvents) and check if the Event has been updated with the AV_HeaderCustomActivity__c.
	 */
	@isTest
	static void executeBatchRegularizeEvents() {
        DateTime activityDate = Datetime.newInstance(2020, 5, 4);
        Account acc = [SELECT Id FROM Account Limit 1];
		Test.startTest();
        User us= AV_TestHelper.createUser(null);
		Contact cnt = AV_TestHelper.createEmployee(
		AV_TestHelper.createCaixaCenter(),	
		us);
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
		String externalId = '99999912';
		Event evento = AV_TestHelper.createEventExternalId(us, activityDate, externalId,acc);
		evento.AV_Task__c = null;
		upsert evento;
		AV_RegularizeHeaderCustomActivityEvents batch = new AV_RegularizeHeaderCustomActivityEvents();
        Database.executeBatch(batch);
		Test.stopTest();
	}
}