public with sharing class CC_SchedulableKnowledge extends CBK_SCH_Queueable_Abstract{
    public override void execute(QueueableContext ctx) {
        List<CBK_SCH_PendingProcess__c> lstInfoPp = this.lstInfoProcess;
        work(lstInfoPp);
    }

    @TestVisible
    private void work(List<CBK_SCH_PendingProcess__c> lstInfoPp) {
        try {
            List<CC_Knowledge_Publicar.EstadoKnowledge> listEstadoKnowPubli = new List<CC_Knowledge_Publicar.EstadoKnowledge>();
            List<CC_MCC_Knowledge_Actualizar.EstadoKnowledge> listEstadoKnowMCC = new List<CC_MCC_Knowledge_Actualizar.EstadoKnowledge>();
            List<Id> listIdsNotificacionVencimiento = new List<Id>();

            //Recorrer los pendingProcess para sacar las ids de los knowledge y poder llamar al proceso que corresponda
            for (CBK_SCH_PendingProcess__c pendingProcessKnow : lstInfoPp) {
                if (pendingProcessKnow.Param1__c == 'actualizarEstadoPublicacion') {
                    CC_Knowledge_Publicar.EstadoKnowledge eKnow = new CC_Knowledge_Publicar.EstadoKnowledge();
                    eKnow.idArticulo = pendingProcessKnow.RecordId__c;
                    eKnow.estadoArticulo = pendingProcessKnow.Param2__c;
                    listEstadoKnowPubli.add(eKnow);
                } 
                else if (pendingProcessKnow.Param1__c == 'actualizarMCCKnowledge') {
                    CC_MCC_Knowledge_Actualizar.EstadoKnowledge eKnow = new CC_MCC_Knowledge_Actualizar.EstadoKnowledge();
                    eKnow.idArticulo = pendingProcessKnow.RecordId__c;
                    eKnow.estadoArticulo = pendingProcessKnow.Param2__c;
                    listEstadoKnowMCC.add(eKnow);
                }
                else if (pendingProcessKnow.Param1__c == 'notificacionVencimiento') {
                    listIdsNotificacionVencimiento.add(pendingProcessKnow.RecordId__c);
                }
            }

            if (!listEstadoKnowPubli.isEmpty()) {
                CC_Knowledge_Publicar.actualizarEstadoPublicacion(listEstadoKnowPubli);
            }
            if (!listEstadoKnowMCC.isEmpty()) {
                CC_MCC_Knowledge_Actualizar.actualizarMCCKnowledge(listEstadoKnowMCC);
            }
            if (!listIdsNotificacionVencimiento.isEmpty()) {
                CC_KnowledgeCaseHandler.procesarNotificacionArticulosVencidos(listIdsNotificacionVencimiento);
            }
        } catch (Exception e) {CBK_Log.error(e);}
    }
}