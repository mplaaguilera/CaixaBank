public with sharing class HDT_Case_AU_TRHan extends CC_TriggerHandlerBase {
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
            actualizarEstadisticasComunicacionInformativa(mapOldObj, lstCasesCC);
            crearPlantillasAgrupadores(mapOldObj, lstCasesCC);
            HDT_CaseTriggerHelper.calcularNumAgrupadores(lstCasesCC, mapOldObj);
            HDT_CaseTriggerHelper.crearActividadCierreCC(lstCasesCC, mapOldObj);
            HDT_CaseTriggerHelper.crearActividadReactivacionCC(lstCasesCC, mapOldObj);
            HDT_CaseTriggerHelper.crearActividadTraslado(lstCasesCC, mapOldObj);
            HDT_CaseTriggerHelper.desvinculacionAgrupadorAU(lstCasesCC, mapOldObj);
            HDT_CaseTriggerHelper.cambioPropietarioAU(lstCasesCC, mapOldObj);
            HDT_CaseTriggerHelper.cambioPropietarioActividades(lstCasesCC, mapOldObj);
            HDT_CaseTriggerHelper.estadoCerradoAU(lstCasesCC, mapOldObj);
            HDT_CaseTriggerHelper.modificaCausaDeCasoAU(lstCasesCC, mapOldObj);
            HDT_CaseTriggerHelper.enviarEncuestaAU(lstCasesCC, mapOldObj);
            HDT_CaseTriggerHelper.actualizarAgrupadorAU(lstCasesCC, mapOldObj);
            HDT_CaseTriggerHelper.asociaActivoAU(lstCasesCC, mapOldObj);
            HDT_CaseTriggerHelper.envioCorreoAcuseRecibo(lstCasesCC);
            HDT_CaseTriggerHelper.cierreCasoHDT1N(lstCasesCC, mapOldObj);
            HDT_CaseTriggerHelper.cierreCasoAU(lstCasesCC, mapOldObj);
            // HDT_CaseTriggerHelper.cierreCasoHDT2N(lstCasesCC, mapOldObj);
        }
    }

    @TestVisible
    private static void actualizarEstadisticasComunicacionInformativa(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        Set<Id> idsComunicacionInformativa = new Set<Id>();
        Set<Id> idsComunicacionInformativaCampana = new Set<Id>();
        for (Case caso : listNewObj) {

            Case casoAnterior = mapOldObj.get(caso.Id);
            if (casoAnterior.CC_Comunicacion_Informativa__c != caso.CC_Comunicacion_Informativa__c) { //El caso se ha vinculado o desvinculado de una CI
                if (casoAnterior.CC_Comunicacion_Informativa__c != null && caso.CC_Comunicacion_Informativa__c != null) { //El caso se ha desvinculado de una CI y se ha vinculado a otra
                    idsComunicacionInformativa.add(casoAnterior.CC_Comunicacion_Informativa__c);
                    idsComunicacionInformativa.add(caso.CC_Comunicacion_Informativa__c);
                } else if (casoAnterior.CC_Comunicacion_Informativa__c != null && caso.CC_Comunicacion_Informativa__c == null) { //El caso se ha desvinculado de una CI y no se ha vinculado a otra
                    idsComunicacionInformativa.add(casoAnterior.CC_Comunicacion_Informativa__c);
                } else if (casoAnterior.CC_Comunicacion_Informativa__c == null && caso.CC_Comunicacion_Informativa__c != null) { //El caso no tenía CI vinculada y se ha vinculado a una
                    idsComunicacionInformativa.add(caso.CC_Comunicacion_Informativa__c);
                }
            }

            if (casoAnterior.CC_Comunicacion_Informativa_Campana__c != caso.CC_Comunicacion_Informativa_Campana__c) { //El caso se ha vinculado o desvinculado de una CI de Campaña
                if (casoAnterior.CC_Comunicacion_Informativa_Campana__c != null && caso.CC_Comunicacion_Informativa_Campana__c != null) { //El caso se ha desvinculado de una CI de Campaña y se ha vinculado a otra
                    idsComunicacionInformativaCampana.add(casoAnterior.CC_Comunicacion_Informativa_Campana__c);
                    idsComunicacionInformativaCampana.add(caso.CC_Comunicacion_Informativa_Campana__c);
                } else if (casoAnterior.CC_Comunicacion_Informativa_Campana__c != null && caso.CC_Comunicacion_Informativa_Campana__c == null) { // El caso se ha desvinculado de una CI de Campaña y no se ha vinculado a otra
                    idsComunicacionInformativaCampana.add(casoAnterior.CC_Comunicacion_Informativa_Campana__c);
                } else if (casoAnterior.CC_Comunicacion_Informativa_Campana__c == null && caso.CC_Comunicacion_Informativa_Campana__c != null) { // El caso no tenía CI de Campaña vinculada y se ha vinculado a una
                    idsComunicacionInformativaCampana.add(caso.CC_Comunicacion_Informativa_Campana__c);
                }
            }
        }

        if (!idsComunicacionInformativa.isEmpty()) {
            CC_Comunicaciones_Informativas_Metodos.actualizarEstadisticasComunicacionInformativa(idsComunicacionInformativa);
        }
        if (!idsComunicacionInformativaCampana.isEmpty()) {
            CC_Comunicaciones_Informativas_Metodos.actualizarEstadisticasComunicacionInformativaCampana(idsComunicacionInformativaCampana);
        }
    }

    @TestVisible
    private static void crearPlantillasAgrupadores(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        Set<Id> idAgrupadores = new Set<Id>();
        for (Case newCaso : listNewObj) {
            Case oldCaso = mapOldObj.get(newCaso.Id);
            // Si el caso está o ha estado pendiente de activo...
            if ((newCaso.CC_NotIncidencia__c == '1' || oldCaso.CC_NotIncidencia__c == '1') &&
                // y alguno de estos campos ha cambiado...
                (((newCaso.Status != 'Cerrado' || oldCaso.Status != 'Cerrado') && (newCaso.Status != 'Pendiente Revisión' || oldCaso.Status != 'Pendiente Revisión')) ||
                 (newCaso.CC_NotIncidencia__c != oldCaso.CC_NotIncidencia__c) ||
                 (newCaso.CC_Agrupador_Id__c  != oldCaso.CC_Agrupador_Id__c) ||
                 (newCaso.RecordTypeId        != oldCaso.RecordTypeId) ||
                 (newCaso.CC_CanalNotifCli__c != oldCaso.CC_CanalNotifCli__c) ||
                 (newCaso.CC_Idioma__c        != oldCaso.CC_Idioma__c)))
            {
                // actualizamos los agrupadores, el nuevo y el antiguo
                if (newCaso.CC_Agrupador_Id__c != null) {
                    idAgrupadores.add(newCaso.CC_Agrupador_Id__c);
                }
                if (oldCaso.CC_Agrupador_Id__c != null) {
                    idAgrupadores.add(oldCaso.CC_Agrupador_Id__c);
                }
            }
        }
        if (!idAgrupadores.isEmpty()) {
            CC_Agrupador_Metodos.crearPlantillasNecesarias(idAgrupadores);
        }
    }

}