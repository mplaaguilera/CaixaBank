/**********************************************************************************************************************
 Name:      AV_DeletePermissionBatchTest
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_DeletePermissionBatchTest
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            US448873         ivonne suntasig   3/07/2023          Test the Class AV_DeletePermissionBatchTest

***********************************************************************************************************************/
@isTest
public class AV_DeletePermissionBatch_Test {
	/**
	 * Create Permission with the field  AV_FinalPermiso checked.
	 */
	@TestSetup
	static void setup() {
		AV_TestHelper.activateLogger();
		 // Insert  Permission 
		List<AV_OfficePermission__c> ps = new List<AV_OfficePermission__c>();
			ps.add(new AV_OfficePermission__c(name='TestBorrado', 
				AV_FinalPermiso__c =System.today()));
		
		insert ps;
	}
	/**
	 * Execute the Batch class (AV_DeletePermissionBatch) and check if the Permission created in te previous method are deleted.
	 */
	@isTest
	static void executeBatchDeleteRecord() {
		Test.startTest();
		AV_DeletePermissionBatch obj = new AV_DeletePermissionBatch();
		DataBase.executeBatch(obj);
		String cronExp = '0 0 '+(System.now().hour()+1)+' * * ? *';
		System.schedule('jobTest', cronExp, obj);
		Test.stopTest();
		// Check if the inserted Permission are deleted correctly
		System.assertEquals(0, [select count() from AV_OfficePermission__c where AV_FinalPermiso__c <=TODAY]);
	}
	
}