public with sharing class SPV_InteraccionBUTRHan extends CC_TriggerHandlerBase {

    private static Set<String> objetos = new Set<String>{'SAC_Interaccion__c'};

    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);
    private static final Id RECTYPECONSULTA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Consulta').getRecordTypeId();
    private static final Id RECTYPECONSULTA_TAREA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_ConsultaTarea').getRecordTypeId();
    private static final Id RECTYPEESCALADO = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Escalado').getRecordTypeId();
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Interaccion__c>) tp.newList, (Map<Id, SAC_Interaccion__c>) tp.newMap, (List<SAC_Interaccion__c>) tp.oldList, (Map<Id, SAC_Interaccion__c>) tp.oldMap);
    }    

    private void process(List<SAC_Interaccion__c> listNewObj, Map<Id, SAC_Interaccion__c> mapNewObj, List<SAC_Interaccion__c> listOldObj, Map<Id, SAC_Interaccion__c> mapOldObj){

        List<SAC_Interaccion__c> listaConsultasSPV = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__C> listaEscalados = new List<SAC_Interaccion__C>();

        //Recorremos la lista de interacciones
        for (SAC_Interaccion__c interaccion : listNewObj) {
            if(interaccion.RecordTypeId == RECTYPECONSULTA || interaccion.RecordTypeId == RECTYPECONSULTA_TAREA){
                listaConsultasSPV.add(interaccion);
            }else if(interaccion.RecordTypeId == RECTYPEESCALADO){
                listaEscalados.add(interaccion);
            }
        }

        if(!listaConsultasSPV.isEmpty()){
            SPV_InteraccionHelper.cambiarOficinaConsulta(listaConsultasSPV, mapOldObj);
            SPV_InteraccionHelper.informarPreguntaConsulta(listaConsultasSPV, mapOldObj);
        }

        if(!listaEscalados.isEmpty()){
            SPV_InteraccionHelper.validarCamposCambioEstadoEscalado(listaEscalados, mapOldObj);
            SPV_InteraccionHelper.validarObservacionesEscalado(listaEscalados, mapOldObj);
            SPV_InteraccionHelper.rellenarCamposAlActualizarBeforeUpdate(listaEscalados, mapOldObj);
        }
    }
}