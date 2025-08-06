public with sharing class SEG_ContentVersion_AU_TRHan extends CC_TriggerHandlerBase{
    /**
* @description   Método principal del trigger.
* param tp -> Contexto del trigger.
*/ 
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<ContentVersion>)tp.newList, (Map<ID, ContentVersion>)tp.newMap,(List<ContentVersion>)tp.oldList, (Map<Id, ContentVersion>)tp.oldMap);
    }
    private void process(List<ContentVersion> listNewObj, Map<ID, ContentVersion> mapObj,List<ContentVersion> listOldObj, Map<ID, ContentVersion> mapOldObj)
    {
        informarAnexoFirmadoAU(listNewObj);
    }
    
    private void informarAnexoFirmadoAU(List<ContentVersion> listNewObj) {
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