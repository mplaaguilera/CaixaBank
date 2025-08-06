public class CC_Case_AI_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap, (List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
	}

	private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) {

		Id rtCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
		Id rtEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        
        List<Case> lstCasesCC = new List<Case>();
        for(Case caso : listNewObj){
            if(caso.RecordTypeId == rtCliente || caso.RecordTypeId == rtEmpleado){
                lstCasesCC.add(caso);   
            }
        }

		//Llamadas CAM
		List<Id> idsCAM = obtenerIdsCAM(listNewObj);
		if (!idsCAM.isEmpty()) {
			crearActividadCierreCAM(listNewObj, idsCAM);
		}
		//reactivacionOperativa(listNewObj);
        if(!lstCasesCC.isEmpty()){
			Map<Id, CC_MCC__c> mapMCC = CC_CaseTriggerHelper.obtencionMCCAplicacionesYServicios();
            CC_CaseTriggerHelper.getOficinaPersonAccount(lstCasesCC, mapOldObj);
			CC_CaseTriggerHelper.comprobacionContactoAI(lstCasesCC);
			CC_CaseTriggerHelper.casosFaxAI(lstCasesCC);
			CC_CaseTriggerHelper.casosWebAI(lstCasesCC);
			CC_CaseTriggerHelper.estadoCerradoAI(lstCasesCC);
			CC_CaseTriggerHelperNoSharing.creacionCasoAI(JSON.serialize(lstCasesCC));
			CC_CaseTriggerHelper.nuevoCasoPreventivaAI(lstCasesCC, mapMCC);
			CC_CaseTriggerHelper.notificacionAgenteNoCiAI(lstCasesCC, mapMCC);
			CC_CaseTriggerHelper.nuevoCasoACAI(lstCasesCC, mapMCC);
			CC_CaseTriggerHelper.informarDireccionTerritorialAI(lstCasesCC);
			reactivacionOperativa(lstCasesCC);
        }
	}

	private void crearActividadCierreCAM(List<Case> listNewObj, List<Id> idsCAM) {
		List<Task> tareasCierre = new List<Task>();
		for (Case caso : listNewObj) {
			if (idsCAM.contains(caso.Id) && caso.Status == 'Cerrado') {
				Task tareaCierre = new Task();
				tareaCierre.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task');
				tareaCierre.WhatId = caso.Id;
				tareaCierre.Type = 'Cerrado';
				tareaCierre.Subject = 'Cerrado';
				tareaCierre.ActivityDate = System.today();
				tareaCierre.CC_Fecha_Inicio__c = System.now();
				tareaCierre.CC_Detalles_Consulta__c = caso.CC_Detalles_Consulta__c != null ? caso.CC_Detalles_Consulta__c.left(255) : null;
				tareaCierre.CC_Detalles_Solucion__c = caso.CC_Detalles_Solucion__c != null ? caso.CC_Detalles_Solucion__c.left(255) : null;
				tareaCierre.Status = 'Completed';
				tareasCierre.add(tareaCierre);
			}
		}
		insert tareasCierre;
	}

	private static List<Id> obtenerIdsCAM(List<Case> casos) {
		List<Id> idsCAM = new List<Id>();
		for (Case caso : casos) {
			if (caso.RecordTypeId != null //Necesario ya que en ocasiones el caso aún no tiene RT al hacer insert
			&& Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName().startsWith('AM_')) {
				idsCAM.add(caso.Id);
			}
		}
		return idsCAM;
	}

	private void reactivacionOperativa(List<Case> listNewObj) {
		Id idTaskCC = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
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
				tareaReactivacion.recordTypeId = idTaskCC;
				tareasReactivacion.add(tareaReactivacion);
			}
		}
		if (!tareasReactivacion.isEmpty()) {
			insert tareasReactivacion;
		}
	}
}