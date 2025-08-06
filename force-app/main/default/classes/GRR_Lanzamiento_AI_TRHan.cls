public with sharing class GRR_Lanzamiento_AI_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<GRR_Lanzamiento__c>) tp.newList);
    }
    
    private static void process(List<GRR_Lanzamiento__c> listNewObj) { 
        List<GRR_Lanzamiento__c> lanzamientosGRR = GRR_LanzamientoTriggerHelper.filtrarLanzamientosGRR(listNewObj);
        if(!lanzamientosGRR.isEmpty()){
            GRR_LanzamientoTriggerHelper.crearNuevasURs(lanzamientosGRR);
            GRR_LanzamientoTriggerHelper.informarLookupUR(lanzamientosGRR);
        }    
    }

}