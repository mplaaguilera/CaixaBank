public with sharing class GRR_Task_AU_TRHan extends CC_TriggerHandlerBase {
    private static boolean run = true;

    public override void mainEntry(CC_TriggerParameters tp) {
            process((Map<Id, Task>)tp.newMap, (Map<Id, Task>)tp.oldMap);        
    
	}

    private void process( Map<Id, Task> newMapObj,Map<Id, Task> oldMapObj) {
        Id rtTaskGRR = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
        
        Map<Id, Task> newMapObjGRR = new Map<Id, Task>();
        for (Task tarea : newMapObj.values()) {
            if (tarea.RecordTypeId == rtTaskGRR) {
                newMapObjGRR.put(tarea.Id, tarea);
            }
        }
        
        if (!newMapObjGRR.isEmpty()) {
            GRR_TaskTriggerHelper.reactivarCaso(newMapObjGRR,oldMapObj);
        }
    }

}