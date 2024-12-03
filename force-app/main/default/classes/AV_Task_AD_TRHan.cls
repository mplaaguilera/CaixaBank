/**********************************************************************************************************************
 Name:	  AV_Task_AD_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Task AfterDelete
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		  	AUTHOR				DATE				Description
	1.0								Jose María Perez	10/05/2022			Add Scoring Task
    1.1			Fix					Patricia Solano 	08/08/2022			Changed the method call to AV_TaskTriggerHelperSharing
	1.2								Vlaislav Lityagin	16/01/2023			Added check permission AV_AvoidDeleteTask for skip calculateScoreTask
***********************************************************************************************************************/
public class AV_Task_AD_TRHan extends CC_TriggerHandlerBase {
    
	public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Task>)tp.newList, (Map<Id, Task>)tp.newMap, (List<Task>)tp.oldList, (Map<Id, Task>)tp.oldMap);
    }
    
    private void process(List<Task> listNewObj, Map<Id, Task> mapNewObj, List<Task> listOldObj, Map<Id, Task> mapOldObj) {
        //General check the Record type's for intouch project
        List<Task> listData = AV_TaskTriggerHelper.checkGeneralRT(listOldObj);
        Boolean hasAvoidDeleteTask = FeatureManagement.checkPermission('AV_AvoidDeleteTask');
        if (listData!=null && !listData.isEmpty()){
            if(!hasAvoidDeleteTask){
                AV_TaskTriggerHelperSharing.calculateScoreTask(listData,'delete');
            }
            AV_TaskTriggerHelper.deleteRecordsRelatedWithTask(listData);
        }
    }
    
}