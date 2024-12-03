public with sharing class OS_Task_BD_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Task>)tp.oldList, (Map<Id, Task>)tp.oldMap);
	}

    private void process(List<Task> listOldObj, Map<Id, Task> mapOldObj) {
        Id rtId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('OS_Task').getRecordTypeId();
        List<Task> listOldObjFilt = new List<Task>();
        for (Task t : listOldObj) {
            if (t.RecordTypeId == rtId) {
                listOldObjFilt.add(t);
            }
        }

        if (!listOldObjFilt.isEmpty()) {
            Boolean permisoBorrado = FeatureManagement.checkPermission('OS_Borrado_Task') && !Test.isRunningTest();

            for (Task tarea : listOldObjFilt) {
                //if ((mapTask.containsKey(tarea.Id)) && (rtBloqueados.contains(tarea.RecordTypeId))){
                if (!permisoBorrado) {
                    tarea.addError('No tiene permisos para eliminar el registro');
                }
            }
        }
    }
}