public class CC_Task_BD_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Task>)tp.oldList, (Map<Id, Task>)tp.oldMap);
	}

	private void process(List<Task> listOldObj, Map<Id, Task> mapOldObj) {

		Id idRecordTypeTareaCc = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
		List<Task> tareasCc = new List<Task>();
		for (Task tarea : listOldObj) {
			if (tarea.RecordTypeId == idRecordTypeTareaCc) {
				tareasCc.add(tarea);
			}
		}
		if (!tareasCc.isEmpty()) {
			Boolean permisoBorrado = FeatureManagement.checkPermission('CC_Borrado_Task') && !Test.isRunningTest();

			List<CBK_Activity_Extension__c> lstExtDel = new List<CBK_Activity_Extension__c>();


			Map<String, SObject> extensiones = CC_MetodosUtiles.mapaCampo([SELECT AV_ActivityId__c FROM CBK_Activity_Extension__c WHERE CBK_Eliminable__c = TRUE
																			AND AV_ActivityId__c IN :mapOldObj.keySet()], 'AV_ActivityId__c');
			for (Task tarea : tareasCc) {
				if (extensiones.containsKey(tarea.Id) || permisoBorrado) {
					if (extensiones.containsKey(tarea.Id)) {
						lstExtDel.add((CBK_Activity_Extension__c)extensiones.get(tarea.Id));
					}
				} else {
					tarea.addError('No tiene permisos para eliminar el registro');
				}
			}

			//Borramos registros de activity extension
			if (!lstExtDel.isEmpty()) {
				// System.debug(lstExtDel);
				Database.delete(lstExtDel, false);
			}
		}
	}
}