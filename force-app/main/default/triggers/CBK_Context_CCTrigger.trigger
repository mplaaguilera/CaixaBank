trigger CBK_Context_CCTrigger on CBK_Context_CC__e (after insert) {
   try{
        list<String> lstBatchApex = new list<String>();
        list<String> lstSchedProc = new list<String>();
        
        for (CBK_Context_CC__e event : Trigger.New) {
            if (event.Tipo__c =='BatchProcess') {
                lstBatchApex.add(event.JobId__c);    
            } else if (event.Tipo__c =='SchedProcess') {
                List<String> listado = (list<String>)JSON.deserialize(event.JobList__c, List<String>.class);
        	    lstSchedProc.addAll(listado);
            }        
        }
       
       
        if (lstBatchApex.size()>0){
            cbk_log.debug('procesaBatchApex');
            CBK_ContextTrigger_Helper.procesaBatchApex(lstBatchApex);    
        }
        
        if (lstSchedProc.size()>0){
            cbk_log.debug('procesaSchedProc');
            CBK_ContextTrigger_Helper.procesaSchedProc(lstSchedProc);    
        }
    } catch (Exception e){
        cbk_log.error(e);
    }
 
}