public with sharing class GRR_TaskTriggerHelper {

    public static void reactivarCaso(Map<Id, Task> newMapObj, Map<Id, Task> oldMapObj) {
        Set<Id> idCasos = new Set<Id>();

        for (Task tareaNew : newMapObj.values()) {
            if ((tareaNew.Type == 'Traslado Colaborador' || tareaNew.Type == 'Solicitud Información') && oldMapObj.get(tareaNew.Id).Status != tareaNew.Status && tareaNew.Status == 'Rechazada') {
                idCasos.add(tareaNew.WhatId);
            }
        }

        List<Case> casesUpdate = new List<Case>();
        for (Case caso : [SELECT Id FROM Case WHERE Id IN :idCasos AND Status != 'Activo']) {
            caso.Status = 'Activo';
            casesUpdate.add(caso);
        }

        if(!casesUpdate.isEmpty()){
            update casesUpdate;
        }
    }

}