public with sharing class SPV_InteraccionBITRHan extends CC_TriggerHandlerBase{
    
    private static Set<String> objetos = new Set<String>{'SAC_Interaccion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPECONSULTA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Consulta').getRecordTypeId();


    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Interaccion__c>)tp.newList, (Map<Id, SAC_Interaccion__c>)tp.newMap);
	}

    private void process(List<SAC_Interaccion__c> listNewObj, Map<Id, SAC_Interaccion__c> mapNewObj) {

        List<SAC_Interaccion__c> listaConsultas = new List<SAC_Interaccion__c>();

        //Recorremos la lista de interacciones
        for (SAC_Interaccion__c interaccion : listNewObj) {

           if(interaccion.RecordTypeId == RECTYPECONSULTA){
                listaConsultas.add(interaccion);
            }
        }

        if(!listaConsultas.isEmpty()){
            SPV_InteraccionHelper.rellenarNifYNombreReclamante(listaConsultas);
            SPV_InteraccionHelper.rellenarGrupoCreador(listaConsultas);
            SPV_InteraccionHelper.informarOficinaConsulta(listaConsultas);
        }
    }
}