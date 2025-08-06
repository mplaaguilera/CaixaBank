public with sharing class GRR_UR_AU_TRHan extends CC_TriggerHandlerBase {
   
    public override void mainEntry(CC_TriggerParameters tp) { 
        process((List<GRR_UR__c>)tp.newList, (Map<Id, GRR_UR__c>)tp.oldMap);
    }
    
    private void process(List<GRR_UR__c> listNewObj, Map<Id, GRR_UR__c> mapOldObj) {
        List<GRR_UR__c> ursGRR = GRR_URTriggerHelper.filtrarUrsGRRAU(listNewObj);
        if(!ursGRR.isEmpty()){
            GRR_URTriggerHelper.regularizarCambioURFechas(ursGRR,mapOldObj);
        }    
    }
 
}