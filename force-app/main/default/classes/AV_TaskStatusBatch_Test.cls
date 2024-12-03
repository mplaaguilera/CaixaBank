/**********************************************************************************************************************
 Name:	  AV_TaskStatusBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para actualizar Tareas.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Carolina Alonso		26/08/2020			Test version
	1.1			App FSC			Sandra Gómez		08/03/2020			Modify Test classes
	1.2			FIX				David Rufo			18/05/2021			Fix problem with the expire Iniciativa task after 3 days
	1.3			US384943		Víctor Santiago		30/05/2022			Test adapted to framework batch

***********************************************************************************************************************/
@isTest
public class AV_TaskStatusBatch_Test {
	
	/**
	 * Create Task with due date and status pendiente and Pendiente No Localizado.
	 */
	@TestSetup
	static void setup() {
        AV_TestHelper.activateLogger();
        Account acc = AV_TestHelper.createCustomer();
		User usuario = AV_TestHelper.createUser('Standard User');
		//Tarea INICIATIVA con estado Pendiente No Localizado
		Task tareaPendienteNoLocalizado = AV_TestHelper.createTareaExternalIdCustomStatusWithCustomer(usuario,'1234567',acc,'Pendiente no localizado');

		//Tarea INICIATIVA con estado Pediente
		Task tareaPendiente = AV_TestHelper.createTarea(usuario);
        
        //Tarea ALERTA COMERCIAL - Open y Pendiente no localizado
        AV_TestHelper.createTareaOtherExternalID(usuario);
        
        Task taskAlertOpen = AV_TestHelper.createTareaExternalId(usuario, 'X-00001');
        RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKALERTACOM_RT);
        taskAlertOpen.ActivityDate = System.today()-3;
        taskAlertOpen.RecordTypeId = rt.Id;
        taskAlertOpen.Status = 'Open';
        update taskAlertOpen;
	}
    
    @isTest
	static void executeBatchTaskStatusQuery() {
		Test.startTest();
		Id batchId = Database.executeBatch(new AV_TaskStatusBatch());
		Test.stopTest();
	}
}