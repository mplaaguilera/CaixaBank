public with sharing class AM_Task_AI_TRHan extends CC_TriggerHandlerBase {

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
            planificarCierreAutomatico(listTasks);
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

    private void planificarCierreAutomatico(List<Task> listTasks) {
        List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();

        for (Task newTask : listTasks) {
            if (String.isNotBlank(newTask.WhatId) && newTask.WhatId.getSObjectType().getDescribe().getName() == 'Case' && newTask.Type == 'Solicitud Información' && newTask.Status == 'Open' && newTask.CC_Fecha_FinPlazo_SolInf__c != null) {
                //Preparar schedulable
                CBK_SCH_PendingProcess__c pendingProcessTask = new CBK_SCH_PendingProcess__c();
                pendingProcessTask.recordId__c = newTask.WhatId;
                pendingProcessTask.Schedule_Time__c = newTask.CC_Fecha_FinPlazo_SolInf__c;
                pendingProcessTask.className__c = 'AM_SchedulableTask';
                listaPendingProcess.add(pendingProcessTask);
            }
        }

        //Insertar pending process en caso de que los haya
        if (!listaPendingProcess.isEmpty()) {
            insert listaPendingProcess;
        }
    }

}