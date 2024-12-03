/**********************************************************************************************************************
 Name:	  CIBE_Task_AU_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Task AfterUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		  	AUTHOR				DATE				Description
	1.0								Mikel Lezama   		29/08/2022			Init version
***********************************************************************************************************************/
public class CIBE_Task_AU_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Task>)tp.newList, (Map<Id, Task>)tp.newMap, (List<Task>)tp.oldList, (Map<Id, Task>)tp.oldMap);
	}

    private void process(List<Task> listNewObj, Map<Id, Task> mapNewObj, List<Task> listOldObj, Map<Id, Task> mapOldObj) {
        //General check the Record type's for intouch project
        List<Task> listData = CIBE_TaskTriggerHelper.checkGeneralRT(listNewObj);
        List<Task> listDataOld = CIBE_TaskTriggerHelper.checkGeneralRT(listOldObj);
        
        // Lógica de negocio a ejecutar
        if (listData!=null && !listData.isEmpty()){
            CIBE_TaskTriggerHelperSharing.calculateScoreTask(listData,'update');
            Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
        	//AV_TaskTriggerHelper.validateTaskOnboardingPositiveClosed(listData,mapOldObj); //Doing in the component
        	if (!hasCustomPermission && !System.isbatch() || test.isRunningTest()){
        		CIBE_TaskTriggerHelper.updateNextManagementDateOpp(listData, mapOldObj);
				CIBE_TaskTriggerHelper.updateTareaOpp(listData, mapOldObj);
            }
        }
	}
}