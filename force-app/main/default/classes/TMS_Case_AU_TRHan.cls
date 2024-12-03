public with sharing class TMS_Case_AU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap, (List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
    }

    private void process(List<Case> listObj, Map<Id, Case> mapObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) {
        Id idRecordTypeTMS = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TMS_Expediente').getRecordTypeId();
        List<Case> casosTMS = new List<Case>();
        for (Case caso : listObj) {
            if (caso.RecordTypeId == idRecordTypeTMS) {
                casosTMS.add(caso);
            }
        }

        if (!casosTMS.isEmpty()) {
            cambiarPropietarioTareas(casosTMS, mapOldObj);
            crearTareaDeReasignacion(casosTMS, mapOldObj);
            crearTareaCambioHeredero(casosTMS, mapOldObj);
        }
    }

    private void cambiarPropietarioTareas(List<Case> casosTMS, Map<Id, Case> mapOldObj) {
        //Método para actualizar el propietario de las tareas que continúen abiertas
        Map<Id, Case> casosCambioOwner = new Map<Id, Case>();
        List<Task> tareasActualizar = new List<Task>();
        for (Case casoTMS : casosTMS) {
            if (casoTMS.OwnerId != mapOldObj.get(casoTMS.Id).OwnerId) {
                casosCambioOwner.put(casoTMS.Id, casoTMS);
            }
        }

        for (Task tarea : [SELECT WhatId FROM Task WHERE RecordType.DeveloperName = 'TMS_Tarea'
                            AND WhatId IN :casosCambioOwner.keySet() AND IsClosed = FALSE]) {
            tarea.OwnerId = casosCambioOwner.get(tarea.WhatId).OwnerId;
            tareasActualizar.add(tarea);
        }
        if (!tareasActualizar.isEmpty()) {

            try {
                update tareasActualizar;
            } catch (DmlException errorDml) {
                CBK_Log.error(errorDml, 'TMS_Case_AU_TRHan: Error al actualizar tareas con with sharing. Se reintentará con without sharing. ' + tareasActualizar);
                tareasActualizar = TMS_WS_Upd_Case_Aux.updateTasksWithoutSharing(tareasActualizar);
            }

        }
    }

    public static void crearTareaDeReasignacion(List<Case> lstCasos, Map<Id, Case> mapCaseOld) {
        List<Case> lstCasosTMS = new List<Case>();
        List<Task> lstTareasTMS = new List<Task>();

        for (Case caso : lstCasos) {
            if (caso.OwnerId != mapCaseOld.get(caso.Id).OwnerId) {
                lstCasosTMS.add(caso);
            }
        }

        Id rtTarea = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('TMS_Tarea').getRecordTypeId();

        for (Case casoTMS : lstCasosTMS) {
            Task tareaTMS = new Task();
            tareaTMS.RecordTypeId = rtTarea;
            tareaTMS.WhatId = casoTMS.Id;
            tareaTMS.Status = 'Completed';
            tareaTMS.Type = 'Reasignación';
            tareaTMS.Subject = 'Reasignación del caso';
            tareaTMS.ActivityDate = System.today();
            tareaTMS.CC_Fecha_Inicio__c = System.now();
            tareaTMS.CC_Consulta__c = casoTMS.TMS_Numexp__c;
            lstTareasTMS.add(tareaTMS);
        }

        if (!lstTareasTMS.isEmpty()) {
            insert lstTareasTMS;
        }
    }

    public static void crearTareaCambioHeredero(List<Case> lstCasos, Map<Id, Case> mapCaseOld) {
        List<Case> lstCasosTMS = new List<Case>();
        List<Task> lstTareasTMS = new List<Task>();
        for (Case caso : lstCasos) {
            if (caso.AccountId != mapCaseOld.get(caso.Id).AccountId) {
                lstCasosTMS.add(caso);
            }
        }

        Id rtTarea = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('TMS_Tarea').getRecordTypeId();

        for (Case casoTMS : lstCasosTMS) {
            Task tareaTMS = new Task();
            tareaTMS.RecordTypeId = rtTarea;
            tareaTMS.WhatId = casoTMS.Id;
            tareaTMS.Status = 'Completed';
            tareaTMS.Type = 'Cambio de heredero';
            tareaTMS.Subject = 'Cambio de heredero';
            tareaTMS.ActivityDate = System.today();
            tareaTMS.CC_Fecha_Inicio__c = System.now();
            tareaTMS.CC_Consulta__c = casoTMS.TMS_Numexp__c;
            lstTareasTMS.add(tareaTMS);
        }
        if (!lstTareasTMS.isEmpty()) {
            insert lstTareasTMS;
        }
    }
}