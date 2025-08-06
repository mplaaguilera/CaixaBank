/**********************************************************************************************************************
 Name:      AV_DeleteRecordsCarteraBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_DeleteRecordsCarteraBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            App FSC          Maria Telleria   23/04/2020          Init version
   1.1			  App FSC		   Sandra Gómez		04/11/2020			Refactor

***********************************************************************************************************************/
@isTest
private class AV_DeleteRecordsCarteraBatch_Test {

	/**
	 * Create 10 Books with the field  To Delete checked.
	 */
	@TestSetup
	static void setup() {
		AV_TestHelper.activateLogger();

		// Insert 10 Books 
		List<AV_Book__c> books = new List<AV_Book__c>();
		for (Integer i=0;i<100;i++) {
			books.add(new AV_Book__c(name='TestBorrado'+i, 
				AV_ToDelete__c=true));
		}
		
		insert books;
	}

	/**
	 * Execute the Batch class (AV_DeleteRecordsCarteraBatch) and check if the books created in te previous method are deleted.
	 */
	@isTest
	static void executeBatchDeleteRecord() {
		System.assertEquals(100, [select count() from AV_Book__c where AV_ToDelete__c = true]);
		Test.startTest();
		AV_DeleteRecordsCarteraBatch obj = new AV_DeleteRecordsCarteraBatch();
		DataBase.executeBatch(obj);
		Test.stopTest();
		// Check if the inserted Books are deleted correctly
		System.assertEquals(0, [select count() from AV_Book__c where AV_ToDelete__c = true]);
	}
	
}