/**********************************************************************************************************************
 Name:	  AV_Task_AU_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Task AfterUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		  	AUTHOR				DATE				Description
	1.0			App FSC				Eric Vázquez		30/11/2020			Init version
	1.1			App FSC				David Rufo			09/12/2020			Include a general check of the Record Types
	1.2			App FSC				David Rufo			22/09/2020			Exclude callout because is sent from component
	1.3			US286825 	   		Daniel Rodríguez	13/01/2022	        Add Method updateNextManagementDateOpp
	1.4         USXXXXXX	        Daniel Rodríguez	10/03/2022          Add isBatch()
	1.5			US353735			Sandra Gómez		20/04/2022			Added method deleteUpdateTasksGCF
	1.6			Fix					Patricia Solano 	08/08/2022			Changed the method call to AV_TaskTriggerHelperSharing
	1.7			Fix					Sandra Gómez		13/11/2023			Change method updateNextManagementDateOpp add patameter mapToByPassTask
	1.8                             Oscar Moreno        16/02/2024          Comments updateTareaOpp and recordChannel methods
***********************************************************************************************************************/
public class AV_Task_AU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Task>)tp.newList, (Map<Id, Task>)tp.newMap, (List<Task>)tp.oldList, (Map<Id, Task>)tp.oldMap);
	}

    private void process(List<Task> listNewObj, Map<Id, Task> mapNewObj, List<Task> listOldObj, Map<Id, Task> mapOldObj) {
        //General check the Record type's for intouch project
        List<Task> listData = AV_TaskTriggerHelper.checkGeneralRT(listNewObj);
        List<Task> listDataOld = AV_TaskTriggerHelper.checkGeneralRT(listOldObj);
        
        // Lógica de negocio a ejecutar
        if (listData!=null && !listData.isEmpty()){
            AV_TaskTriggerHelperSharing.calculateScoreTask(listData,'update');
            Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
        	//AV_TaskTriggerHelper.validateTaskOnboardingPositiveClosed(listData,mapOldObj); //Doing in the component
        	if (!hasCustomPermission && !System.isbatch()){
        		AV_TaskTriggerHelper.updateNextManagementDateOpp(listData, mapOldObj, mapToByPassTask);
				//AV_TaskTriggerHelper.updateTareaOpp(listData, mapOldObj);
				//AV_TaskTriggerHelper.recordChannel(listData, mapOldObj);
				AV_TaskTriggerHelper.notifyExperienciaCliTask(listData,mapOldObj,true);

            }
        }
	}
    
}