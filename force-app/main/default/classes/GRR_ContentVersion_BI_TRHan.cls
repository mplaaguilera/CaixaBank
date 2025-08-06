public with sharing class GRR_ContentVersion_BI_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<ContentVersion>)tp.newList);
    }

    private void process(List<ContentVersion> listObj){
        List<ContentVersion> lstDocumentosGRR = GRR_ContentVersionTriggerHelper.filtrarDocumentosGRR(listObj); 
        
        if(!lstDocumentosGRR.isEmpty()){
            GRR_ContentVersionTriggerHelper.modificarSharingContentVersion(lstDocumentosGRR);
        } 
    }
}