public with sharing class SEG_Filtros_Excepciones_BI_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SEG_Filtros_Excepciones__c>)tp.newList, (Map<Id, SEG_Filtros_Excepciones__c>)tp.newMap);
    }
    
    public void process(List<SEG_Filtros_Excepciones__c> listNewObj, Map<Id, SEG_Filtros_Excepciones__c> mapNewObj) {
        for (SEG_Filtros_Excepciones__c excepcion : listNewObj) {
            excepcion.SEG_Activo__c = true;
            if (excepcion.SEG_Activo__c) { 
                excepcion.SEG_FechaActivacion__c = DateTime.now();
            } else {
                excepcion.SEG_FechaDesactivacion__c = DateTime.now();
            }
        }
    }
}