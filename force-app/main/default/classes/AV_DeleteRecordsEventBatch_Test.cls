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
   1.3			FIX01080926		Ángel Medina		03/09/2024		Add AV_CodigoGestorAsignado__c in executeBatchDeleteRecord method
***********************************************************************************************************************/
@isTest
private class AV_DeleteRecordsEventBatch_Test {

	/**
	 * Create 10 Activities with the field  To Delete checked.
	 */
	 @TestSetup
    static void setup(){
		User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true LIMIT 1];
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		User userGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
		AV_TestHelper.insertNeededPermissions(userGestor);
	
		System.runAs(userCli){
			Account acc = AV_TestHelper.createCaixaCenter();	
			Account customer = AV_TestHelper.createCustomerSinInsert();
			customer.CC_Numero_Documento__c = 'DNI1';
            customer.OwnerId = userGestor.Id;
            customer.AV_NumPerso__c = '1357';
			insert customer;
		}
		
    }

	/**
	 * Execute the Batch class (AV_DeleteRecordsEventBatch) and check if the event created in the previous method are deleted.
	 */
	@isTest
	static void executeBatchDeleteRecord() {
		DateTime activityDate = Datetime.newInstance(2020, 5, 4);
        Account acc = [SELECT Id, AV_NumPerso__c FROM Account WHERE AV_NumPerso__c = '1357' Limit 1];
		User userGestor = [SELECT Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true  AND AV_ExternalID__c = 'U01545454'];
	
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_MOCNT','OK'));
		String externalId = '99999912';
		Event evento = AV_TestHelper.createEventExternalIdSinInsert(userGestor, activityDate, externalId, acc);
		evento.AV_CodigoGestorAsignado__c = 'U0999999';
		evento.AV_ToDelete__c = true;
		insert evento;

		System.runAs(userGestor){
			AV_DeleteRecordsEventBatch obj = new AV_DeleteRecordsEventBatch();
			DataBase.executeBatch(obj);
		}
		System.enqueueJob(new AV_DeleteRecordsEventBatchQueueable());  //mio
		Test.stopTest();
		// Check if the inserted Event are deleted correctly
		System.assertEquals(0, [select count() from Event where AV_ToDelete__c = true]);
	}
	
}