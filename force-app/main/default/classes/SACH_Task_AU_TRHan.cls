public with sharing class SACH_Task_AU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
            process((Map<Id, Task>)tp.newMap, (Map<Id, Task>)tp.oldMap);
	}
    
    private void process(Map<Id, Task> newMap, Map<Id, Task> oldMap) {
        Map<Id, Task> newMapSach = descartarCorreosNoSach(newMap);
        rechazoTareasTrasladarColaborador(newMapSach, oldMap);
    }

    private static void rechazoTareasTrasladarColaborador(Map<Id, Task> newMap, Map<Id, Task> oldMap) {
        List<Case> casosUpdate = new List<Case>();
        for (Task task : newMap.values()) {
            if (task.Type == 'Traslado Colaborador'
            && oldMap.get(task.Id).Status == 'Open' && task.Status == 'Rechazada') {
                Case caso = new Case(Id = task.WhatId);
                caso.Status = 'Activo';
                casosUpdate.add(caso);
            }
        }
        update casosUpdate;
    }
    
    private static Map<Id, Task> descartarCorreosNoSach(Map<Id, Task> newMap) {
        Id idRecordTypeSach = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task');
        Map<Id, Task> newMapSach = new Map<Id, Task>();
        for (Id idTask : newMap.keySet()) {
            if (newMap.get(idTask).RecordTypeId == idRecordTypeSach) {
                newMapSach.put(idTask, newMap.get(idTask));
            }
        }
        return newMapSach;
    }
}