public with sharing class AM_Task_AU_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((Map<Id, Task>)tp.oldMap, (Map<Id, Task>)tp.newMap, (List<Task>)tp.newList);
	}

	private void process(Map<Id, Task> mapOldObj, Map<Id, Task> mapNewObj, List<Task> listNewObj) {

        List<Task> listTasks = new List<Task>();
        Id idRecordTypeTask = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('AM_Task').getRecordTypeId();
        for (Task task : listNewObj) {
            if (task.recordTypeId == idRecordTypeTask) {
                listTasks.add(task);
            }
        }

        if (!listTasks.isEmpty()) {
            rechazoActividadTraslado(listTasks);
        }
        
	}

    private void rechazoActividadTraslado(List<Task> listTasks) {
        List <Case> casosActualizar = new List<Case>();
        for (Task task : listTasks) {
            if (task.Status == 'Rechazada' && (task.Type == 'Traslado Colaborador'  || task.Type == 'Solicitud Información')) {
                if(task.WhatId != null) {   
                    Case caso = new Case();
                    caso.Id = task.WhatId;
                    caso.Status = 'Activo';
                    casosActualizar.add(caso);
                }
            }
        }

        if (!casosActualizar.isEmpty()) {
            update casosActualizar;
        }
    }

}