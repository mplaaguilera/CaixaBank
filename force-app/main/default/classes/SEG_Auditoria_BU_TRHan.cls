public with sharing class SEG_Auditoria_BU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SEG_Auditoria__c>)tp.newList, (Map<Id, SEG_Auditoria__c>)tp.newMap, (Map<Id, SEG_Auditoria__c>) tp.oldMap);
    }
    
    private void process(List<SEG_Auditoria__c> listNewObj, Map<Id, SEG_Auditoria__c> mapNewObj, Map<Id, SEG_Auditoria__c> mapOldObj) {

        List<Id> clasificacionesSegmentos = new List<Id>();
        
        for (SEG_Auditoria__c clasRapid : listNewObj) {
		    clasificacionesSegmentos.add(clasRapid.Id);
		}

        if(!clasificacionesSegmentos.isEmpty()){
            concatFechaNif(mapNewObj, mapOldObj);	       
        }
	}   
    

    public static void concatFechaNif(Map<Id, SEG_Auditoria__c> mapNewObj, Map<Id, SEG_Auditoria__c> mapOldObj) {
        for (Id recordId : mapNewObj.keySet()) {
            if((mapNewObj.get(recordId).SEG_NIF__c != mapOldObj.get(recordId).SEG_NIF__c || mapNewObj.get(recordId).SEG_FechaAuditoriaFormato__c != mapOldObj.get(recordId).SEG_FechaAuditoriaFormato__c) && mapNewObj.get(recordId).SEG_FechaAuditoriaFormato__c != null){
                String fechaAuditoria = '';
                if(mapNewObj.get(recordId).SEG_NIF__c != null ){
                    fechaAuditoria = fechaAuditoria + String.valueOf(mapNewObj.get(recordId).SEG_NIF__c);
                }
                mapNewObj.get(recordId).NIF_FechaAuditoria__c = fechaAuditoria + String.valueOf(mapNewObj.get(recordId).SEG_FechaAuditoriaFormato__c);
            }
        }
    }
}