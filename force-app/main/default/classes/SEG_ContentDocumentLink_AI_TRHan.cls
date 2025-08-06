public with sharing class SEG_ContentDocumentLink_AI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        //process((List<ContentDocumentLink>)tp.newList, (Map<Id, ContentDocumentLink>)tp.newMap);
        for (ContentDocumentLink condoclink : (List<ContentDocumentLink>)tp.newList) {
            if (condoclink.LinkedEntityId.getSobjectType() == SEG_Contratos__c.SObjectType) {
                process((List<ContentDocumentLink>)tp.newList, (Map<Id, ContentDocumentLink>)tp.newMap);
                
            }
        }
    }
    
    private void process(List<ContentDocumentLink> listNewObj, Map<Id, ContentDocumentLink> mapNewObj) {
        informarAnexoFirmadoCDL(listNewObj);
    }
    
    private void informarAnexoFirmadoCDL(List<ContentDocumentLink> listNewObj) {
        Set<Id> contentDocumentIdSet = new Set<Id>();
        Set<Id> cdIDlink = new Set<Id>();
        for (ContentDocumentLink condoc : listNewObj) {
            System.System.debug('objecttype :'+condoc.LinkedEntityId.getSobjectType());
            if (condoc.LinkedEntityId.getSobjectType() == SEG_Contratos__c.SObjectType) {
                contentDocumentIdSet.add(condoc.ContentDocumentId);
                cdIDlink.add(condoc.LinkedEntityId);
            }
        }
        
        if (!cdIDlink.isEmpty()) {
            List<SEG_Contratos__c> segContList = [SELECT Id, Name, SEG_AdjuntoFirmadoPDF__c FROM SEG_Contratos__c where Id IN:cdIDlink];
            for (ContentVersion conVer : [SELECT Id, ContentDocumentId,SEG_Firmado__c,FileType FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIdSet AND SEG_Firmado__c = TRUE AND FileType = 'PDF']){
                for (SEG_Contratos__c segCon : segContList) {
                    if (!segCon.SEG_AdjuntoFirmadoPDF__c) {
                        segCon.SEG_AdjuntoFirmadoPDF__c = true;   
                    }   
                }         
            }
            
            
            if (segContList.size() > 0) {
                update segContList;
            }
        }
        
        
    }
}