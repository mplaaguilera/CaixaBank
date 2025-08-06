public with sharing class SEG_Schedule_TaskConnect extends CBK_SCH_Queueable_Abstract{
    
    public override void execute(QueueableContext ctx) {
        try {
            if (!this.lstInfoProcess.isEmpty()) {
                work(this.lstInfoProcess);
            }
        } catch(Exception ex) {
            CBK_Log.error(ex);
        }
    }

    private void work(List<CBK_SCH_PendingProcess__c> incomingPendingProcessList) {
        for(CBK_SCH_PendingProcess__c pendingProcess: incomingPendingProcessList){
            Map<Id, String> mapCasosTaskConnect = (Map<Id, String>) JSON.deserialize(pendingProcess.CBK_ParamTextArea__c, Map<Id, String>.class);
            SEG_TaskConnect.envioComunicacionTrigger(mapCasosTaskConnect);
        }       
    }
}