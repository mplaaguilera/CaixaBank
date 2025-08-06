public with sharing class AM_SchedulableTask extends CBK_SCH_Queueable_Abstract {
    public override void execute(QueueableContext ctx) {List<CBK_SCH_PendingProcess__c> lstInfoPp = this.lstInfoProcess; work(lstInfoPp);}

    @TestVisible
    private void work(List<CBK_SCH_PendingProcess__c> lstInfoPp) {
        try {
            List<Id> listIdCase = new List<Id>();
            for (CBK_SCH_PendingProcess__c pendingProcessTask : lstInfoPp) {
                listIdCase.add(pendingProcessTask.RecordId__c);
            }

            if (!listIdCase.isEmpty()) {
                AM_Cierre_Automatico_Methods.closeTaskSolicitudInfCAM(listIdCase);
            }
        } catch (Exception e) {CBK_Log.error(e);}
    }
}