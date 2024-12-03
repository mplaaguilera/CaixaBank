public with sharing class SEG_Filtros_Excepciones_BU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SEG_Filtros_Excepciones__c>)tp.newList, (Map<Id, SEG_Filtros_Excepciones__c>)tp.newMap, (Map<Id, SEG_Filtros_Excepciones__c>)tp.oldMap);
    }

    private void process(List<SEG_Filtros_Excepciones__c> listNewObj, Map<Id, SEG_Filtros_Excepciones__c> mapNewObj, Map<Id, SEG_Filtros_Excepciones__c> mapOldObj){
        for (SEG_Filtros_Excepciones__c excepcion : listNewObj) {      
            if (mapNewObj.get(excepcion.id).SEG_Activo__c != mapOldObj.get(excepcion.id).SEG_Activo__c) {
                if (excepcion.SEG_Activo__c) { 
                    excepcion.SEG_FechaActivacion__c = DateTime.now();
                } else {
                    excepcion.SEG_FechaDesactivacion__c = DateTime.now();
                }                    
            }
        }
    }
}