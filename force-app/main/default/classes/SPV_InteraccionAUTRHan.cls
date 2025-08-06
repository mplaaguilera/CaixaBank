public with sharing class SPV_InteraccionAUTRHan extends CC_TriggerHandlerBase {
    private static Set<String> objetos = new Set<String>{'SAC_Interaccion__c'};

    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);
    private static final Id RECTYPEESCALADO = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Escalado').getRecordTypeId();

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Interaccion__c>) tp.newList, (Map<Id, SAC_Interaccion__c>) tp.newMap, (List<SAC_Interaccion__c>) tp.oldList, (Map<Id, SAC_Interaccion__c>) tp.oldMap);
    }    
    private void process(List<SAC_Interaccion__c> listNewObj, Map<Id, SAC_Interaccion__c> mapNewObj, List<SAC_Interaccion__c> listOldObj, Map<Id, SAC_Interaccion__c> mapOldObj){
        //Llamada al método que filtra las interacciones de SPV
        List<SAC_Interaccion__c> listInteraccionesSPV = SPV_InteraccionHelper.filtrarInteraccionesSPV(listNewObj);
        Map<Id, Case> mapaCasosActualizar = new Map<Id, Case>();


        if(!listInteraccionesSPV.isEmpty()){
            SPV_InteraccionHelper.actualizarPendienteEscaladoReclamacion(listInteraccionesSPV, mapOldObj, mapaCasosActualizar); //Si se ha resuelto un escalado, se indica en el campo "Pendiente Escalado" de su reclamación
            SPV_InteraccionHelper.actualizarReclamacionAlEnviarEscalado(listInteraccionesSPV, mapOldObj, mapaCasosActualizar); //Si se envía un escalado, la reclamación estará en pendiente de resolución
            SPV_InteraccionHelper.lanzarAlertasInteraccion(listInteraccionesSPV, mapOldObj); //Lanzamiento de alertas
            SPV_InteraccionHelper.pausarORenaudarTME(listInteraccionesSPV, mapOldObj);                                    //Si se envía escalado, se pausan ciertos TMEs
            SPV_InteraccionHelper.registrarCambiosActividades(listInteraccionesSPV, mapOldObj);                           //Cuando se cambian determinados campos, se tienen que registrar en Actividades
			SPV_InteraccionHelper.rellenarCamposAlActualizarAfterUpdate(listInteraccionesSPV, mapOldObj);
        }

        if(!mapaCasosActualizar.isEmpty()){
            SPV_DatabaseDML.updateListDML(mapaCasosActualizar.values(), false);
        }
    }
}