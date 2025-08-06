public with sharing class SPV_InteraccionAITRHan extends CC_TriggerHandlerBase {

    private static Set<String> objetos = new Set<String>{'SAC_Interaccion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPECONSULTA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Consulta').getRecordTypeId();
    private static final Id RECTYPECONSULTA_TAREA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_ConsultaTarea').getRecordTypeId();
    private static final Id RECTYPEESCALADO = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Escalado').getRecordTypeId();


    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Interaccion__c>)tp.newList, (Map<Id, SAC_Interaccion__c>)tp.newMap);
	}

    private void process(List<SAC_Interaccion__c> listNewObj, Map<Id, SAC_Interaccion__c> mapNewObj) {

        List<SAC_Interaccion__c> listaConsultas = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaEscalados = new List<SAC_Interaccion__c>();

        //Recorremos la lista de interacciones
        for (SAC_Interaccion__c interaccion : listNewObj) {

           if(interaccion.RecordTypeId == RECTYPECONSULTA || interaccion.RecordTypeId == RECTYPECONSULTA_TAREA){
                listaConsultas.add(interaccion);
            }
            if(interaccion.RecordTypeId == RECTYPEESCALADO){
                listaEscalados.add(interaccion);
            }
        }

        if(!listaConsultas.isEmpty()){
            SPV_InteraccionHelper.crearThreadId(listaConsultas);
            // SPV_InteraccionHelper.insertarTME(listaConsultas);
        }

         if(!listaEscalados.isEmpty()){
            SPV_InteraccionHelper.lanzarAlertasInteraccion(listaEscalados, null);
            SPV_InteraccionHelper.registrarCreacionEscaladoActividades(listaEscalados);
            SPV_InteraccionHelper.crearFormularios(listaEscalados);
        }
    }
}