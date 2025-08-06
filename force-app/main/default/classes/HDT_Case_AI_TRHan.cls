public with sharing class HDT_Case_AI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap, (List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
	}

	private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) {

		Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        List<Case> lstCasesCC = new List<Case>();
        for (Case caso : listNewObj) {
            if (caso.RecordTypeId == rtEmpleado) {
                lstCasesCC.add(caso);
            }
        }


        if (!lstCasesCC.isEmpty()) {
			reactivacionOperativa(lstCasesCC);
			//Map<Id, CC_MCC__c> mapMCC = HDT_CaseTriggerHelper.obtencionMCCAplicacionesYServicios();
			HDT_CaseTriggerHelper.comprobacionContactoAI(lstCasesCC);
			//CC_CaseTriggerHelper.casosFaxAI(lstCasesCC);
			HDT_CaseTriggerHelper.estadoCerradoAI(lstCasesCC);
			CC_CaseTriggerHelperNoSharing.creacionCasoAI(JSON.serialize(lstCasesCC));
			HDT_CaseTriggerHelper.informarDireccionTerritorialAI(lstCasesCC);
        }
	}

	private void reactivacionOperativa(List<Case> listNewObj) {
		Id idTaskCC = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
		List<Task> tareasReactivacion = new List<Task>();
		for (Case caso : listNewObj) {
			if (caso.CC_Reactivado_Operativa__c != null && caso.Status != null) {
				Task tareaReactivacion = new Task();
				tareaReactivacion.CC_Fecha_Inicio__c = Datetime.now();
				tareaReactivacion.Description = caso.CC_Motivo_Reactivacion__c;
				tareaReactivacion.Priority = 'Normal';
				tareaReactivacion.Status = 'Completada';
				tareaReactivacion.Subject = 'Reactivación';
				tareaReactivacion.Type = 'Reactivación';
				tareaReactivacion.WhatId = caso.id;
				tareaReactivacion.RecordTypeId = idTaskCC;
				tareasReactivacion.add(tareaReactivacion);
			}
		}
		if (!tareasReactivacion.isEmpty()) {
			insert tareasReactivacion;
		}
	}
}