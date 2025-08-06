/**********************************************************************************************************************
 Name:      AV_DeleteRecordsCarteraGestorBatch_test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_DeleteRecordsCarteraGestorBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            App FSC          Maria Telleria   23/04/2020          Init version
   1.1			  App FSC		   Sandra Gómez		04/11/2020			Refactor

***********************************************************************************************************************/
@isTest
private class AV_DeleteRecordsCarteraGestorBatch_Test {

	/**
	 * Create 10 BookManagement Members with the field  To Delete checked.
	 */
	@TestSetup
	static void setup() {
		AV_TestHelper.activateLogger();

		AV_Book__c book=new AV_Book__c(name='Test');
		insert book;

		// Insert 10 BookManagement Members
		List<AV_BookManagementMember__c> bookmemb = new List<AV_BookManagementMember__c>();
		for (Integer i=0;i<10;i++) {
			bookmemb.add(new AV_BookManagementMember__c(name='TestBorrado'+i,AV_ToDelete__c=true,AV_Cartera__c=book.id));

		}
		insert bookmemb;
	}

	/**
	 * Execute the Batch class (AV_DeleteRecordsCarteraGestorBatch) and check if the bookmanagement members created in te previous method are deleted.
	 */
	@isTest
	static void executeBatchDeleteRecord() {
		System.assertEquals(10, [select count() from AV_BookManagementMember__c where AV_ToDelete__c = true]);
		Test.startTest();
		AV_DeleteRecordsCarteraGestorBatch obj = new AV_DeleteRecordsCarteraGestorBatch();
		DataBase.executeBatch(obj);
		Test.stopTest();
		// Check if the inserted Book management members are deleted correctly
		System.assertEquals(0, [select count() from AV_BookManagementMember__c where AV_ToDelete__c = true]);
	}
	
}