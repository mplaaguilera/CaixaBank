public with sharing class GRR_Lanzamiento_BI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<GRR_Lanzamiento__c>)tp.newList);
    }

    private void process(List<GRR_Lanzamiento__c> listObj){
        List<GRR_Lanzamiento__c> lanzamientosGRR = GRR_LanzamientoTriggerHelper.filtrarLanzamientosGRR(listObj);
        if(!lanzamientosGRR.isEmpty()){
            GRR_LanzamientoTriggerHelper.informarClaveLanzamiento(lanzamientosGRR);
        } 
    }
    
}