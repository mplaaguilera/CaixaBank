public with sharing class GRR_ContentVersion_AI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<ContentVersion>)tp.newList, (Map<Id, ContentVersion>)tp.newMap);
    }

    private void process(List<ContentVersion> listNewObj, Map<Id, ContentVersion> mapNewObj) {
        List<ContentVersion> lstDocumentosGRR = GRR_ContentVersionTriggerHelper.filtrarDocumentosGRR(listNewObj); 
        
        if(!lstDocumentosGRR.isEmpty()){
            GRR_ContentVersionTriggerHelper.crearContentDocumentLink(lstDocumentosGRR);
        } 
    }
}