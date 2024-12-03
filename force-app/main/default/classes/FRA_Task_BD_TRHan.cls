public with sharing class FRA_Task_BD_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Task>)tp.oldList, (Map<Id, Task>)tp.oldMap);
	}

    private void process(List<Task> listOldObj, Map<Id, Task> mapOldObj) {
        List<Task> tareasFRA = FRA_TaskTriggerHelper.filtrarTareasFRA(listOldObj);

        if(!tareasFRA.isEmpty()){  
            FRA_TaskTriggerHelper.validarBorradoTareas(tareasFRA);
        }  
    }   
}