/**********************************************************************************************************************
 Name:	  AV_DeleteRecordsEventBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para el batch AV_DeleteRecordsEventBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY	  	AUTHOR				DATE			Description
   1.0			App FSC			Carolina Alonso		05/04/2020		Test version
   1.1			App FSC			Carolina Alonso		02/09/2020		Add coverage for new method getCabeceraTareaAsociada
   1.2			App FSC			Sandra Gómez		04/11/2020		Refactor
***********************************************************************************************************************/
@isTest
private class AV_DeleteRecordsEventBatch_Test {

	/**
	 * Create 10 Activities with the field  To Delete checked.
	 */
	 @TestSetup
    static void setup(){
        Account acc = AV_TestHelper.createCaixaCenter();
        Account customer= AV_TestHelper.createCustomer();
		String labelProfile = 'Standard User';
		User usuario = AV_TestHelper.createUser(labelProfile);
    }

	/**
	 * Execute the Batch class (AV_DeleteRecordsEventBatch) and check if the event created in the previous method are deleted.
	 */
	@isTest
	static void executeBatchDeleteRecord() {
		DateTime activityDate = Datetime.newInstance(2020, 5, 4);
        Account acc = [SELECT Id FROM Account where AV_NumPerso__c = '123' Limit 1];
        User u = [SELECT Id,AV_ExternalID__c,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U0009003' Limit 1]; 
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_MOCNT','OK'));
		String externalId = '99999912';
		Event evento = AV_TestHelper.createEventExternalId(u, activityDate, externalId, acc);
        evento.AV_ToDelete__c = true;
        update evento;
		AV_DeleteRecordsEventBatch obj = new AV_DeleteRecordsEventBatch();
		DataBase.executeBatch(obj);
		Test.stopTest();
		// Check if the inserted Event are deleted correctly
		System.assertEquals(0, [select count() from Event where AV_ToDelete__c = true]);
	}
	
}