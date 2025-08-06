public with sharing class CC_SchedulableTask extends CBK_SCH_Queueable_Abstract{
    public override void execute(QueueableContext ctx) {
        List<CBK_SCH_PendingProcess__c> lstInfoPp = this.lstInfoProcess;
        work(lstInfoPp);
    }

    @TestVisible
    private void work(List<CBK_SCH_PendingProcess__c> lstInfoPp) {
        try {
            List<Id> setIdsTaskVerificacionCliente = new List<Id>();
            List<Id> setIdsTaskSendMailRecTrasladoColab = new List<Id>();
            List<Id> listaIdsCasesendMailSolicitudInf = new List<Id>();

            //Recorrer los pendingProcess para sacar las ids de las task y poder llamar al proceso que corresponda
            for (CBK_SCH_PendingProcess__c pendingProcessTask : lstInfoPp) {
                if (pendingProcessTask.Param1__c == 'CC_Task_Verificacion_Cliente') {
                    setIdsTaskVerificacionCliente.add(pendingProcessTask.RecordId__c);
                } 
                else if (pendingProcessTask.Param1__c == 'sendMailRecTrasladoColab') {
                    setIdsTaskSendMailRecTrasladoColab.add(pendingProcessTask.RecordId__c);
                }
                else if (pendingProcessTask.Param1__c == 'sendMailSolicitudInf') {
                    listaIdsCasesendMailSolicitudInf.add(pendingProcessTask.RecordId__c);
                }
            }

            if (!setIdsTaskVerificacionCliente.isEmpty()) {
                CC_Task_Verificacion_Cliente.CC_Task_Verificacion_Cliente(setIdsTaskVerificacionCliente);
            }

            if (!setIdsTaskSendMailRecTrasladoColab.isEmpty()) {
                CC_Configuracion_Reclamaciones_Auto.sendMailRecTrasladoColab(setIdsTaskSendMailRecTrasladoColab);
            }
            
            if (!listaIdsCasesendMailSolicitudInf.isEmpty()) {
                CC_Cierre_Automatico_Methods.sendMailSolicitudInf(listaIdsCasesendMailSolicitudInf);
            }


        } catch (Exception e) {CBK_Log.error(e);}
    }
}