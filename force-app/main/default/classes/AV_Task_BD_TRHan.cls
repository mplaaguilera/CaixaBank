/**********************************************************************************************************************
 Name:	  AV_Task_BD_TRHan
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase para Trigger de Task BeforeDelete
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		  	AUTHOR				DATE				Description
	1.0			US118509			Eric Vázquez		27/10/2020			Init version
	1.1			App FSC				David Rufo			09/12/2020			Include a general check of the Record Types

***********************************************************************************************************************/
public class AV_Task_BD_TRHan extends CC_TriggerHandlerBase {
    
	public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Task>)tp.newList, (Map<Id, Task>)tp.newMap, (List<Task>)tp.oldList, (Map<Id, Task>)tp.oldMap);
    }
    
    private void process(List<Task> listNewObj, Map<Id, Task> mapNewObj, List<Task> listOldObj, Map<Id, Task> mapOldObj) {
        //General check the Record type's for intouch project
        List<Task> listData = AV_TaskTriggerHelper.checkGeneralRT(listOldObj);
        
        if (listData!=null && !listData.isEmpty()){
            Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
            if (!hasCustomPermission) {
        	    AV_TaskTriggerHelper.validateDeleteTask(listData);
            }
        }
    }
    
}