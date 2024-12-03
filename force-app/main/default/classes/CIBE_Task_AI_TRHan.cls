/**********************************************************************************************************************
 Name:	  CIBE_Task_AI_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Task AfterInsert
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		  	AUTHOR				DATE				Description
	1.0								Mikel Lezama   		29/08/2022			Init version
	1.1                             Lucia Muñoz         24/01/2024          Quitar la llamada a la clase CIBE_TaskTriggerHelperSharing
***********************************************************************************************************************/
public class CIBE_Task_AI_TRHan extends CC_TriggerHandlerBase{
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Task>)tp.newList, (Map<Id, Task>)tp.newMap, (List<Task>)tp.oldList, (Map<Id, Task>)tp.oldMap);
	}
    
    private void process(List<Task> listNewObj, Map<Id, Task> mapNewObj, List<Task> listOldObj, Map<Id, Task> mapOldObj) {
		//General check the Record type's for intouch project
        List<Task> listData = CIBE_TaskTriggerHelper.checkGeneralRT(listNewObj);
        
        // Lógica de negocio a ejecutar
        if (listData!=null && !listData.isEmpty()){
			Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
			if (!hasCustomPermission && !System.isbatch() || Test.isRunningTest()) {
				CIBE_TaskTriggerHelper.createManagementHistory(listData, mapOldObj);
			}
			//CIBE_TaskTriggerHelper.validateTaskOnboardingPositiveClosed(listData, mapOldObj);
			CIBE_TaskTriggerHelper.createCRMTask(listData, mapOldObj);
			// AV_TaskTriggerHelper.insertOrUpdateCenterAndRt(listData, mapOldObj);

        }
	}
}