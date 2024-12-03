/**********************************************************************************************************************
 Name:	  CIBE_Task_BD_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Task BeforeDelete
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		  	AUTHOR				DATE				Description
	1.0								Mikel Lezama   		29/08/2022			Init version
***********************************************************************************************************************/
public class CIBE_Task_BD_TRHan extends CC_TriggerHandlerBase{
	public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Task>)tp.newList, (Map<Id, Task>)tp.newMap, (List<Task>)tp.oldList, (Map<Id, Task>)tp.oldMap);
    }
    
    private void process(List<Task> listNewObj, Map<Id, Task> mapNewObj, List<Task> listOldObj, Map<Id, Task> mapOldObj) {
        //General check the Record type's for intouch project
        List<Task> listData = CIBE_TaskTriggerHelper.checkGeneralRT(listOldObj);
        
        if (listData!=null && !listData.isEmpty()){
            //CIBE_TaskTriggerHelper.deleteRecordsRelatedWithTask(listData);
            Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
            if (!hasCustomPermission) {
                CIBE_TaskTriggerHelper.validateDeleteTask(listData);
            }
        }
    }
}