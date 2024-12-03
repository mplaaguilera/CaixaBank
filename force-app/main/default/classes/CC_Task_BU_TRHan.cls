public class CC_Task_BU_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Task>)tp.newList, (Map<Id, Task>)tp.newMap, (Map<Id,Task>)tp.oldMap);
    }
    private void process(List<Task> listNewObj, Map<Id, Task> mapNewObj, Map<Id, Task> mapOldObj){
        
        Schema.DescribeSObjectResult recordTypeTask = task.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> recordTypeTaskList = recordTypeTask.getRecordTypeInfos();

        Set<Id> idRecordtypeOSSet = new Set<Id>();

        for (Schema.RecordTypeInfo rtTask: recordTypeTaskList){
            if(rtTask.getDeveloperName().left(3)=='OS_'){
                idRecordtypeOSSet.add(rtTask.getRecordTypeId());
            }
        }
        List<Task> listNewObjOS= new List<Task>();
        Map<Id, Task> mapOldObjOS = new Map<Id, Task>();

        for(Task tarea: listNewObj){
            if(idRecordtypeOSSet.contains(tarea.RecordTypeId)){
                listNewObjOS.add(tarea);
                Task oldTarea = mapOldObj.get(tarea.Id);
                mapOldObjOS.put(oldTarea.Id, oldTarea);
            }
        }
        if(!listNewObjOS.isEmpty()){
            copiarTaskType(listNewObjOS, mapOldObjOS);
        }
    }
    public void copiarTaskType(List<Task> listNewObj, Map<Id, Task> mapOldObj){
        for(Task tarea: listNewObj){
            if(tarea.Type != null && tarea.Type != mapOldObj.get(tarea.Id).Type){
                tarea.OS_Tipo__c = tarea.Type;
            }
        }
    }
}