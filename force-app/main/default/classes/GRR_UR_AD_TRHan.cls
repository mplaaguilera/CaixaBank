public with sharing class GRR_UR_AD_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<GRR_UR__c>)tp.oldList);
    }
  
    private void process(List<GRR_UR__c>  listOldObj) {
        Set<String> idUrsGRR = GRR_URTriggerHelper.filtrarUrsGRRAD(listOldObj);
        if(!idUrsGRR.isEmpty()){
            GRR_URTriggerHelper.borrarLanzamientosUR(idUrsGRR);
        }    
    }

}