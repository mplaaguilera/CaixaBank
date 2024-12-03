/**********************************************************************************************************************
 Name:      AV_DeleteRecordsAccountBatch_test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_DeleteRecordsAccountBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            App FSC          Maria Telleria   23/04/2020          Init version
   1.1			  App FSC		   Sandra Gómez		04/11/2020			Refactor

***********************************************************************************************************************/
@isTest
private class AV_DeleteRecordsAccountBatch_Test {

	/**
	 * Create 10 Accounts with the field  To Delete checked.
	 */
	@TestSetup
	static void setup() {
		AV_TestHelper.activateLogger();

		List<Account> accounts = new List<Account>();
	
		// Insertar 10 Cuentas 
		for (Integer i=0;i<10;i++) {
			accounts.add(new Account(name='TestBorrado'+i,
									 AV_ToDelete__c=true));
		}
		insert accounts;
	}

	/**
	 * Execute the Batch class (AV_DeleteRecordsAccountBatch) and check if the accounts created in te previous method are deleted.
	 */
	@isTest
	static void executeBatchDeleteRecord() {
		System.assertEquals(10, [select count() from Account where AV_ToDelete__c = true]);
		Test.startTest();
		AV_DeleteRecordsAccountBatch obj = new AV_DeleteRecordsAccountBatch();
		DataBase.executeBatch(obj);
		Test.stopTest();

		// Comprobar que las cuentas insertadas se han borrado correctamente
		System.assertEquals(0, [select count() from Account where AV_ToDelete__c = true]);
	}
	
}