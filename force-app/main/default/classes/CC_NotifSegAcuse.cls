public with sharing class CC_NotifSegAcuse extends CBK_SCH_Queueable_Abstract{

    public override void execute(QueueableContext ctx) {
        List<CBK_SCH_PendingProcess__c> incomingPendingProcessList = this.lstInfoProcess;
        work(incomingPendingProcessList);
    }

    private void work(List<CBK_SCH_PendingProcess__c> incomingPendingProcessList) {
        String methodName = 'work';
        Set<Id> pendingProcessCaseIdSet = new Set<Id>();

        for(CBK_SCH_PendingProcess__c pendingProcess: incomingPendingProcessList){
            pendingProcessCaseIdSet.add(pendingProcess.RecordId__c);
        }

        if(!pendingProcessCaseIdSet.isEmpty()){
            List<Id> idRegistros = new List<Id>(pendingProcessCaseIdSet);
            for (Integer i = 0; i < idRegistros.size(); i += 50) {
                CC_NotifSegCaso.gestionarBatchNotificacionCliente((List<Id>)CC_MetodosUtiles.subLista(idRegistros, i, 50), 'CC_AcuseRecibo');
            }
        }
    }
}