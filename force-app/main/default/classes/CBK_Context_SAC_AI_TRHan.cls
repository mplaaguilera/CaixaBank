public with sharing class CBK_Context_SAC_AI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CBK_Context_SAC__e>)tp.newList, (Map<Id, CBK_Context_SAC__e>)tp.newMap);
    }

    private void process(List<CBK_Context_SAC__e> listNewObj, Map<Id, CBK_Context_SAC__e> mapNewObj) {
        List<String> lstBatchApex = new List<String>();
        List<String> lstSchedProc = new List<String>();
        
        for (CBK_Context_SAC__e event : listNewObj) {
            if (event.Tipo__c =='BatchProcess') {
                lstBatchApex.add(event.JobId__c);    
            } else if (event.Tipo__c =='SchedProcess') {
                List<String> listado = (List<String>)JSON.deserialize(event.JobList__c, List<String>.class);
                lstSchedProc.addAll(listado);  
            }        
        }
        
        if (lstBatchApex.size()>0){
            CBK_ContextTrigger_Helper.procesaBatchApex(lstBatchApex);    
        }
        
        if (lstSchedProc.size()>0){
            CBK_ContextTrigger_Helper.procesaSchedProc(lstSchedProc);    
        }
    }
  
}