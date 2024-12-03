public with sharing class GRR_Lanzamiento_AD_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<GRR_Lanzamiento__c>) tp.oldList);
    }
    
    private static void process(List<GRR_Lanzamiento__c> listOldObj) { 
        List<GRR_Lanzamiento__c> lanzamientosGRR = GRR_LanzamientoTriggerHelper.filtrarLanzamientosGRR(listOldObj);
        if(!lanzamientosGRR.isEmpty()){
            GRR_LanzamientoTriggerHelper.regularizarFechaProxUR(lanzamientosGRR);
        }    
    }
    
}