public class CSBD_Task_AU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((Map<Id, Task>)tp.newMap, (Map<Id, Task>)tp.oldMap);
	}
    
    private static void process(Map<Id, Task> newMap, Map<Id, Task> oldMap) {
        Id idRecordTypeCSBD = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CSBD_Task');
        for (Id idTarea : newMap.keySet()) {
            if (newMap.get(idTarea).RecordTypeId == idRecordTypeCSBD) {
                if (newMap.get(idTarea).Type == 'Pendiente Cliente'
                && oldMap.get(idTarea).Status == 'Open' && newMap.get(idTarea).Status == 'Rechazada') {
                    CSBD_Opportunity.reactivarOportunidad(newMap.get(idTarea).WhatId);
                }
            }
        }
    }
}