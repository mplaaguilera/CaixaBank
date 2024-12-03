/**********************************************************************************************************************
 Name:	  AV_DeleteRecordsContactBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_DeleteRecordsContactBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY		AUTHOR				DATE				Description
   1.0			App FSC			Maria Telleria		14/07/2020			Init version
   1.1			App FSC			Carolina Alonso		26/10/2020			Add RecordType in Test
   1.2			App FSC			Sandra Gómez		04/11/2020			Refactor

***********************************************************************************************************************/
@isTest
private class AV_DeleteRecordsContactBatch_Test {

	/**
	 * Create 10 Contacts with the field  To Delete checked.
	 */
	@TestSetup
	static void setup() {
		AV_TestHelper.activateLogger();
		RecordType rt = AV_AppUtilities.getRecordType('Contact', 'CC_Empleado');
		List<Contact> contacts = new List<Contact>();
	
		// Insertar 10 Contactos 
		for (Integer i=0;i<10;i++) {
			contacts.add(new Contact(LastName='TestBorrado'+i,
									 AV_ToDelete__c=true,
									 RecordTypeId = rt.Id));
		}
		insert contacts;
	}

	/**
	 * Execute the Batch class (AV_DeleteRecordsContactBatch) and check if the goals created in te previous method are deleted.
	 */
	@isTest
	static void executeBatchDeleteRecord() {
		System.assertEquals(10, [select count() from Contact where AV_ToDelete__c = true]);
		Test.startTest();
		AV_DeleteRecordsContactBatch obj = new AV_DeleteRecordsContactBatch();
		DataBase.executeBatch(obj);
		Test.stopTest();
		// Check if the inserted Contact are deleted correctly
		System.assertEquals(0, [select count() from Contact where AV_ToDelete__c = true]);
	}
	
}