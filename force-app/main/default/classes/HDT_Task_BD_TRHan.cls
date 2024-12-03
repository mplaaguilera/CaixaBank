public with sharing class HDT_Task_BD_TRHan extends CC_TriggerHandlerBase {


	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Task>)tp.oldList, (Map<Id, Task>)tp.oldMap);
	}

    private void process(List<Task> listOldObj, Map<Id, Task> mapOldObj) {
        Id idRecordTypeTareaHdt = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
		List<Task> listOldObjHdt = new List<Task>();
        Map<Id, Task> mapOldObjHdt = new Map<Id, Task>();
		for (Task tarea : listOldObj) {
			if (tarea.RecordTypeId == idRecordTypeTareaHdt) {
				listOldObjHdt.add(tarea);
				mapOldObjHdt.put(tarea.Id, tarea);
			}
		}

        Boolean permisoBorrado = FeatureManagement.checkPermission('HDT_Borrado_Tasks') && !Test.isRunningTest();

        List<CBK_Activity_Extension__c> lstExtDel = new List<CBK_Activity_Extension__c>();
        Map<Id, CBK_Activity_Extension__c> mapTask = new Map<Id, CBK_Activity_Extension__c>();
        for (CBK_Activity_Extension__c extTask : [SELECT CBK_Eliminable__c, AV_ActivityId__c FROM CBK_Activity_Extension__c
                                                    WHERE AV_ActivityId__c IN :mapOldObjHdt.keySet() AND AV_ActivityId__c != NULL]) {
            mapTask.put(extTask.AV_ActivityId__c, extTask);
        }

        for (Task tarea : listOldObjHdt) {
            Boolean eliminable = mapTask.containsKey(tarea.Id);
            if (eliminable) {
                eliminable = mapTask.get(tarea.Id).CBK_Eliminable__c;
            }

            if (eliminable || permisoBorrado) {
                if (mapTask.containsKey(tarea.Id)) {
                    lstExtDel.add(mapTask.get(tarea.Id));
                }
            } else {
                tarea.addError('No tiene permisos para eliminar el registro');
            }
        }

        //Borramos registros de la extendida de registros autorizados
        if (!lstExtDel.isEmpty()) {
            Database.delete(lstExtDel, false);
        }
    }
}