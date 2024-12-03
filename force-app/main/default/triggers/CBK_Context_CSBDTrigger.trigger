trigger CBK_Context_CSBDTrigger on CBK_Context_CSBD__e (after insert) {

    list<String> lstBatchApex = new list<String>();
    list<String> lstSchedProc = new list<String>();
    
    for (CBK_Context_CSBD__e event : Trigger.New) {
        if (event.Tipo__c =='BatchProcess') {
        	lstBatchApex.add(event.JobId__c);    
        } else if (event.Tipo__c =='SchedProcess') {
        	List<String> listado = (list<String>)JSON.deserialize(event.JobList__c, List<String>.class);
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