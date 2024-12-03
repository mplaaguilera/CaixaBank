public with sharing class CBK_SCH_CSBD_ScheduleBatchGestorOppty extends CBK_SCH_Queueable_Abstract {
    public override void execute(QueueableContext ctx) {
        List<CBK_SCH_PendingProcess__c> incomingPendingProcessList = this.lstInfoProcess;
        work(incomingPendingProcessList);
 
    }
   
    private void work(List<CBK_SCH_PendingProcess__c> incomingPendingProcessList) {
        try {
        CBK_Log.debug('CBK_SCH_CSBD_ScheduleBatchGestorOppty - incomingPendingProcessList - Input list: ' + JSON.serialize(incomingPendingProcessList));

        CBK_BatchJob.executeBatch('CSBD_BatchJob_Motor', 1);

    } catch (Exception e) {
        CBK_Log.error(e);
    }

    }
}