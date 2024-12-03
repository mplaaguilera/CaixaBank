/**********************************************************************************************************************
 Name:	  AV_Task_AI_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Task AfterInsert
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		  	AUTHOR				DATE				Description
	1.0			App FSC				Eric Vázquez		30/11/2020			Init version
	1.1			App FSC				David Rufo			09/12/2020			Include a general check of the Record Types
	1.2			US147562			Álvaro López		13/01/2020			Added new method createCRMTask
	1.3         USXXXXXX	        Daniel Rodríguez	10/03/2022          Add isBatch()
	1.4								Jose María Perez	09/05/2022			Add Scoring Task
	1.5			Fix					Patricia Solano 	08/08/2022			Changed the method call to AV_TaskTriggerHelperSharing
***********************************************************************************************************************/
public class AV_Task_AI_TRHan extends CC_TriggerHandlerBase {
    
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Task>)tp.newList, (Map<Id, Task>)tp.newMap, (List<Task>)tp.oldList, (Map<Id, Task>)tp.oldMap);
	}
    
    private void process(List<Task> listNewObj, Map<Id, Task> mapNewObj, List<Task> listOldObj, Map<Id, Task> mapOldObj) {
		//General check the Record type's for intouch project
        List<Task> listData = AV_TaskTriggerHelper.checkGeneralRT(listNewObj);
        
        // Lógica de negocio a ejecutar
        if (listData!=null && !listData.isEmpty()){
			Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
			if (!hasCustomPermission && !System.isbatch()) {
				AV_TaskTriggerHelper.createManagementHistory(listData, mapOldObj);
			}
			AV_TaskTriggerHelper.validateTaskOnboardingPositiveClosed(listData, mapOldObj);
			AV_TaskTriggerHelper.createCRMTask(listData, mapOldObj);
            AV_TaskTriggerHelperSharing.calculateScoreTask(listData,'insert');
			AV_TaskTriggerHelper.notifyExperienciaCliTask(listData,mapOldObj,false);

			// AV_TaskTriggerHelper.insertOrUpdateCenterAndRt(listData, mapOldObj);

        }
	}

}