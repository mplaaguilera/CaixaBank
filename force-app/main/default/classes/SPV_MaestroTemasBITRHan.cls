public with sharing class SPV_MaestroTemasBITRHan extends CC_TriggerHandlerBase{
    
    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEMARCA = mapRTsObjects.get('SAC_MaestroTemas__c').get('SPV_Marcas').getRecordTypeId();

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_MaestroTemas__c>)tp.newList, (Map<Id, SAC_MaestroTemas__c>)tp.newMap);
	}

    private void process(List<SAC_MaestroTemas__c> listNewObj, Map<Id, SAC_MaestroTemas__c> mapNewObj) {

        List<SAC_MaestroTemas__c> listaMarcas = new List<SAC_MaestroTemas__c>();

        //Recorremos la lista de maestro temas
        for (SAC_MaestroTemas__c marca : listNewObj) {

           if(marca.RecordTypeId == RECTYPEMARCA){
                listaMarcas.add(marca);
            }
        }

        if(!listaMarcas.isEmpty()){
            SPV_MaestroTemasHelper.validarInsertMarca(listaMarcas);
        }
    }
}