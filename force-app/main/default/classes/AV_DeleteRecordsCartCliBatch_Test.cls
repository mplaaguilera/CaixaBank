/**********************************************************************************************************************
 Name:      AV_DeleteRecordsCartCliBatch_test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_DeleteRecordsCartCliBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            App FSC          Maria Telleria   23/04/2020          Init version
   1.1			  App FSC		   Sandra Gómez		04/11/2020			Refactor
   1.3		    FIX11070844	    Oscar Moreno		22/07/2024	        Insert System.enqueueJob(new AV_DeleteRecordsCartCliBatchQueueable()); 


***********************************************************************************************************************/
@isTest
private class AV_DeleteRecordsCartCliBatch_Test {

	/**
	 * Create 10 BookManagement Members with the field  To Delete checked.
	 */
	@TestSetup
	static void setup() {
		AV_TestHelper.activateLogger();

		AV_Book__c book=new AV_Book__c(name='Test');
		insert book;
		Account cliente=new Account(name='Test');
		insert cliente;
		// Insert 10 Book Members
		List<AV_BookMember__c> bookmemb = new List<AV_BookMember__c>();
		for (Integer i=0;i<10;i++) {
			bookmemb.add(new AV_BookMember__c(name='TestBorrado'+i, AV_ToDelete__c = true, AV_Cartera__c = book.id, AV_Cliente__c = cliente.id));
		}
		insert bookmemb;
	}

	/**
	 * Execute the Batch class (AV_DeleteRecordsCartCliBatch) and check if the book members created in te previous method are deleted.
	 */
	@isTest
	static void executeBatchDeleteRecord() {
		System.assertEquals(10, [select count() from AV_BookMember__c where AV_ToDelete__c = true]);
		Test.startTest();
		AV_DeleteRecordsCartCliBatch obj = new AV_DeleteRecordsCartCliBatch();
		DataBase.executeBatch(obj);
		System.enqueueJob(new AV_DeleteRecordsCartCliBatchQueueable()); 
		Test.stopTest();
		// Check if the inserted Book members are deleted correctly
		System.assertEquals(0, [select count() from AV_BookMember__c where AV_ToDelete__c = true]);
	}
	
}