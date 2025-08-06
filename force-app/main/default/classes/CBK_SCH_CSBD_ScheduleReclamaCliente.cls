public with sharing class CBK_SCH_CSBD_ScheduleReclamaCliente extends CBK_SCH_Queueable_Abstract {
    public override void execute(QueueableContext ctx) {
        List<CBK_SCH_PendingProcess__c> incomingPendingProcessList = this.lstInfoProcess;
        work(incomingPendingProcessList);
 
    }
 
    private void work(List<CBK_SCH_PendingProcess__c> incomingPendingProcessList) {
        System.debug('CBK_SCH_CSBD_ScheduleReclamacionesCliente - incomingPendingProcessList - Input list: ' + JSON.serialize(incomingPendingProcessList));

        Set<Id> pendingProcessOpportunityIdSet = new Set<Id>();

        for(CBK_SCH_PendingProcess__c pendingProcess: incomingPendingProcessList){
            pendingProcessOpportunityIdSet.add(pendingProcess.RecordId__c);
        }

        Opportunity[] pendingProcessOpportunityList = [SELECT Id, CSBD_Estado__c, CSBD_Email_Solicitud__c, CSBD_Contact__c FROM Opportunity WHERE Id=:pendingProcessOpportunityIdSet];

        Map<Id, Opportunity> idOpportunityMap = new Map<Id, Opportunity>();

        for(Opportunity oportunidad: pendingProcessOpportunityList){
            idOpportunityMap.put(oportunidad.Id, oportunidad);
        }

        List<CSBD_Reclamaciones_Prestamos.ReclamacionClienteCsbd> ReclamacionClienteCsbdInsertList = new List<CSBD_Reclamaciones_Prestamos.ReclamacionClienteCsbd>();

        for(CBK_SCH_PendingProcess__c pendingProcess: incomingPendingProcessList){
            if(idOpportunityMap.containsKey(pendingProcess.RecordId__c)){
                Opportunity oportunidad = idOpportunityMap.get(pendingProcess.RecordId__c);

                if(oportunidad.CSBD_Estado__c == 'Pendiente Cliente' && oportunidad.CSBD_Email_Solicitud__c != null && oportunidad.CSBD_Contact__c != null){

                    // ACCIONES A EJECUTAR: Llamar clase de apex CSBD_Reclamaciones_Prestamos.enviarReclamacion()

                    CSBD_Reclamaciones_Prestamos.ReclamacionClienteCsbd reclamacion = new CSBD_Reclamaciones_Prestamos.ReclamacionClienteCsbd();
                    reclamacion.numeroReclamacion = Integer.valueOf(pendingProcess.Param1__c);
                    reclamacion.idOportunidad = oportunidad.Id;

                    ReclamacionClienteCsbdInsertList.add(reclamacion);
                }
            }
        }
        CSBD_Reclamaciones_Prestamos.enviarReclamacion(ReclamacionClienteCsbdInsertList);
    }

   
}