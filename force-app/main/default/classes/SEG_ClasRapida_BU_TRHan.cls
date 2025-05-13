public with sharing class SEG_ClasRapida_BU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SEG_ClasificacionRapida__c>)tp.newList, (Map<Id, SEG_ClasificacionRapida__c>)tp.newMap, (Map<Id, SEG_ClasificacionRapida__c>) tp.oldMap);
    }
    
    private void process(List<SEG_ClasificacionRapida__c> listNewObj, Map<Id, SEG_ClasificacionRapida__c> mapNewObj, Map<Id, SEG_ClasificacionRapida__c> mapOldObj) {

        List<Id> clasificacionesSegmentos = new List<Id>();
        
        for (SEG_ClasificacionRapida__c clasRapid : listNewObj) {
		    clasificacionesSegmentos.add(clasRapid.Id);
		}

        if(!clasificacionesSegmentos.isEmpty()){
            concatenaCR(mapNewObj, mapOldObj);	       
        }
	}   
    
    //Se concatenan los Ids de los niveles de MCC para definir un identificador único a la clasificación rápida
    public static void concatenaCR(Map<Id, SEG_ClasificacionRapida__c> mapNewObj, Map<Id, SEG_ClasificacionRapida__c> mapOldObj) {
        for (Id recordId : mapNewObj.keySet()) {
            //Si se modifica alguno de los campos que forman el identificador de la CR, se recalcula el identificador.
            if(mapNewObj.get(recordId).SEG_Tematica__c != mapOldObj.get(recordId).SEG_Tematica__c || mapNewObj.get(recordId).SEG_Producto__c != mapOldObj.get(recordId).SEG_Producto__c || mapNewObj.get(recordId).SEG_Motivo__c  != mapOldObj.get(recordId).SEG_Motivo__c  ||mapNewObj.get(recordId).SEG_Detalle__c  != mapOldObj.get(recordId).SEG_Detalle__c  ||mapNewObj.get(recordId).OS_Causa__c  != mapOldObj.get(recordId).OS_Causa__c  ||mapNewObj.get(recordId).OS_Solucion__c  != mapOldObj.get(recordId).OS_Solucion__c  || mapNewObj.get(recordId).OS_GrupoTrabajo__c  != mapOldObj.get(recordId).OS_GrupoTrabajo__c){
                String tpmv = '';
                if(mapNewObj.get(recordId).SEG_Tematica__c != null ){
                    tpmv = tpmv + String.valueOf(mapNewObj.get(recordId).SEG_Tematica__c);
                }
                if(mapNewObj.get(recordId).SEG_Producto__c != null ){
                    tpmv = tpmv + String.valueOf(mapNewObj.get(recordId).SEG_Producto__c);
                }
                if(mapNewObj.get(recordId).SEG_Motivo__c != null ){
                    tpmv = tpmv + String.valueOf(mapNewObj.get(recordId).SEG_Motivo__c);
                }
                if(mapNewObj.get(recordId).SEG_Detalle__c != null ){
                    tpmv = tpmv + String.valueOf(mapNewObj.get(recordId).SEG_Detalle__c);
                }
                if(mapNewObj.get(recordId).OS_Causa__c != null ){
                    tpmv = tpmv + String.valueOf(mapNewObj.get(recordId).OS_Causa__c);
                }
                if(mapNewObj.get(recordId).OS_Solucion__c != null ){
                    tpmv = tpmv + String.valueOf(mapNewObj.get(recordId).OS_Solucion__c);
                }
                if(mapNewObj.get(recordId).OS_GrupoTrabajo__c != null ){
                    tpmv = tpmv + String.valueOf(mapNewObj.get(recordId).OS_GrupoTrabajo__c);
                }
               mapNewObj.get(recordId).SEG_TPMV__c = tpmv;
            }
        }
    }
}