public with sharing class HDT_Task_AU_TRHan extends CC_TriggerHandlerBase {

    private static Boolean run = true;

    public override void mainEntry(CC_TriggerParameters tp) {
        if (runOnce()) {
            process((Map<Id, Task>)tp.oldMap, (Map<Id, Task>)tp.newMap);
        }
	}

    private void process(Map<Id, Task> oldMapObj, Map<Id, Task> newMapObj) {
        Id rtTaskHdt = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
        Map<Id, Task> newMapObjHdt = new Map<Id, Task>();
        for (Task tarea : newMapObj.values()) {
            if (tarea.RecordTypeId == rtTaskHdt) {
                newMapObjHdt.put(tarea.Id, tarea);
            }
        }
        if (!newMapObjHdt.isEmpty()) {
            reactivarCaso(oldMapObj, newMapObjHdt);
        }
    }

    private static void reactivarCaso(Map<Id, Task> oldMapObj, Map<Id, Task> newMapObj) {
        Set<Id> idCasos = new Set<Id>();

        for (Task tareaNew : newMapObj.values()) {
            if ((tareaNew.Type == 'Traslado Colaborador' || tareaNew.Type == 'Solicitud Información')
            && oldMapObj.get(tareaNew.Id).Status != tareaNew.Status && tareaNew.Status == 'Rechazada') {
                idCasos.add(tareaNew.WhatId);
            }
        }

        List<Case> casesUpdate = new List<Case>();
        for (Case caso : [SELECT Id FROM Case WHERE Id IN :idCasos AND Status != 'Activo']) {
            caso.Status = 'Activo';
            casesUpdate.add(caso);
        }
        update casesUpdate;
    }

    /*
    public static void actualizarTasks(Set<Task> tareas) {
        //List<Task> tareas = [SELECT LastModifiedDate FROM Task WHERE Id IN :idTareas];
        List<Task> tareasUpdate = new List<Task>();
        for (Task tarea : tareas) {
            Task tareaUpdate = new Task();
            tareaUpdate.Id = tarea.Id;
            tareaUpdate.CC_Ultima_Actualizacion__c = tarea.LastModifiedDate;
            tareasUpdate.add(tareaUpdate);
        }
        update tareasUpdate;
    }

    @Testvisible
    private static void informarCampoLlamada(Set<Task> tareas) {
        List<id> lstNuevasTareas = new List<Id>();
        for(Task tareaToUpdate : tareas) {
            if (tareaToUpdate.Type != 'Cerrado' && tareaToUpdate.Type != 'Cierre Automático' && tareaToUpdate.Type != 'Cierre automático fallido'
                && tareaToUpdate.CC_Llamada_Id__c == null)
            {
                lstNuevasTareas.add(tareaToUpdate.id);
            }
        }
        CC_Llamada.informarLlamadaEnCurso(lstNuevasTareas);
    }
    */

    public static Boolean runOnce() {
        if (run) {
            run = false;
            return true;
        } else {
            return run;
        }
    }
}