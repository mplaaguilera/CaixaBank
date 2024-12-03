/**********************************************************************************************************************
 Name:	  AV_RegularizeHeaderCustomActivity_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de Test para AV_RegularizeHeaderCustomActivity
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR					DATE				Description
	1.0			App FSC			Carolina Alonso	   		02/09/2020			Init version
	1.1			App FSC			Carolina Alonso	   		09/03/2020			Modify RT in Task creation

***********************************************************************************************************************/
@isTest
public class AV_RegularizeHeaderCustomActivity_Test {
	
	/**
	 * Create Task and update it without AV_Task__c filled.
	 */
	@TestSetup
	static void setup() {
		AV_TestHelper.activateLogger();
		User usuario = AV_TestHelper.createUser('System Administrator');
        //Tarea sin null en AV_Task__c
		RecordType rt = AV_AppUtilities.getRecordType('Task', 'AV_Otros');
		Task tarea2  = new Task();
		tarea2.Subject = 'Llamada Saliente 2';
		tarea2.OwnerId = usuario.Id;
		tarea2.Status = 'Open';
		tarea2.Priority = 'Normal';
		tarea2.AV_ExternalID__c = '01928373';
		tarea2.RecordTypeId = rt.Id;
		insert tarea2;
		Test.startTest();
        //Tareas con null en AV_Task__c y con cabecera
		Task tarea  = AV_TestHelper.createTarea(usuario);
		tarea.AV_Task__c = null;
		upsert tarea;
        //Tareas con null en AV_Task__c y sin cabecera
		Task tareaWithoutExtId  = AV_TestHelper.createTareaExternalId(usuario, null);
		tareaWithoutExtId.AV_Task__c = null;
		tareaWithoutExtId.AV_ExternalID__c = '9999999999';
		upsert tareaWithoutExtId;
        //Tareas con null en AV_Task__c, sin cabecera y sin asunto
        Task tareaWithoutExtId2  = AV_TestHelper.createTareaExternalId(usuario, null);
        tareaWithoutExtId2.AV_Task__c = null;
        tareaWithoutExtId2.Subject = null;
        tareaWithoutExtId2.AV_ExternalID__c = '99999999999';
		upsert tareaWithoutExtId2;
		Test.stopTest();
	}

	/**
	 * Execute the Batch class (AV_RegularizeHeaderCustomActivity) and check if the Task has been updated with the AV_HeaderCustomActivity__c.
	 */
	@isTest
	static void executeBatchRegularize() {
		Test.startTest();

		String nameBatch = 'AV_RegularizeHeaderCustomActivity';
		AV_SchedulerBatches.activate(nameBatch);
		System.assertEquals(1, [select count() from CronTrigger WHERE CronJobDetail.Name = :nameBatch]);
		CronTrigger ct = [SELECT State FROM CronTrigger WHERE CronJobDetail.Name = :nameBatch ];
		System.assertEquals('WAITING', ct.State);
		AV_LogDebug.printLogDebug('executeBatchDeleteRecord', 'CT: ' + ct);

		Test.stopTest();
	}
}