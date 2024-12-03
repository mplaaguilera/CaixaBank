public with sharing class HDT_Task_BU_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Task>)tp.newList, (Map<Id, Task>)tp.newMap, (Map<Id,Task>)tp.oldMap);
    }
    private void process(List<Task> listNewObj, Map<Id, Task> mapNewObj, Map<Id, Task> mapOldObj) {
        Id idRtHdt = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
        List<Task> listNewObjHdt = new List<Task>();
        Map<Id, Task> mapOldObjHdt = new Map<Id, Task>();
        for (Task tarea : listNewObj) {
            if (tarea.RecordTypeId == idRtHdt) {
                listNewObjHdt.add(tarea);
                mapOldObjHdt.put(tarea.Id, mapOldObj.get(tarea.Id));
            }
        }
        if (!listNewObjHdt.isEmpty()) {
            copiarTaskType(listNewObjHdt, mapOldObjHdt);
        }
    }

    public void copiarTaskType(List<Task> listNewObj, Map<Id, Task> mapOldObj) {
        for (Task tareaNew : listNewObj) {
            if (tareaNew.Type != null && tareaNew.Type != mapOldObj.get(tareaNew.Id).Type) {
                tareaNew.OS_Tipo__c = tareaNew.Type;
            }
        }
    }
}