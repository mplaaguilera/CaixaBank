public with sharing class SEG_ContentVersion_AI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<ContentVersion>)tp.newList, (Map<Id, ContentVersion>)tp.newMap);
    }
    
    private void process(List<ContentVersion> listNewObj, Map<Id, ContentVersion> mapNewObj) {
        informarAnexoFirmado(listNewObj);
    }
    
    private void informarAnexoFirmado(List<ContentVersion> listNewObj) {
        Set<Id> contentDocumentIdSet = new Set<Id>();
        Set<Id> cdIDlink = new Set<Id>();
        for (ContentVersion conVer : listNewObj) {
            if(conVer.ContentDocumentId != null && conver.SEG_Firmado__c == true && conver.FileType == 'PDF'){
                contentDocumentIdSet.add(conVer.ContentDocumentId);
            }
        }
        
        /*if (!Schema.sObjectType.ContentDocumentLink.fields.Name.isUpdateable()) {
			return null;
			}*/
        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
        if(!contentDocumentIdSet.isEmpty()){
            cdl = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN:contentDocumentIdSet];
            //}
            
            for (ContentDocumentLink contdoc : cdl) {
                cdIDlink.add(contdoc.LinkedEntityId);
            }
            
            //List<SEG_Contratos__c> segContList = [SELECT Id, Name, SEG_AdjuntoFirmadoPDF__c FROM SEG_Contratos__c where Id =:cdl.LinkedEntityId];
            if (!cdIDlink.isEmpty()) {
                List<SEG_Contratos__c> segContList = [SELECT Id, Name, SEG_AdjuntoFirmadoPDF__c FROM SEG_Contratos__c where Id IN:cdIDlink];   
                
                for (SEG_Contratos__c segCon : segContList) {
                    if (!segCon.SEG_AdjuntoFirmadoPDF__c) {
                        segCon.SEG_AdjuntoFirmadoPDF__c = true;   
                    }   
                }
                
                if (segContList.size() > 0) {
                    update segContList;
                }
            } 
        } 
        
    }
}