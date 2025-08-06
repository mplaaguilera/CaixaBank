public with sharing class CBK_SCH_CSBD_ActivarGestorOportunidad extends CBK_SCH_Queueable_Abstract{
    public override void execute(QueueableContext ctx) {
        List<CBK_SCH_PendingProcess__c> incomingPendingProcessList = this.lstInfoProcess;
        work(incomingPendingProcessList);
    }
    private void work(List<CBK_SCH_PendingProcess__c> incomingPendingProcessList) {
       Set<Id> gestorOportunidadIdSet = new Set<Id>();

        for(CBK_SCH_PendingProcess__c pendingProcess: incomingPendingProcessList){
            gestorOportunidadIdSet.add(pendingProcess.RecordId__c);
        }

        List<CSBD_Gestor_Oportunidad__c> gestorOportunidadActivar = [SELECT Id, CSBD_Estado__c FROM CSBD_Gestor_Oportunidad__c 
                                                                        WHERE Id=: gestorOportunidadIdSet AND CSBD_Estado__c = 'Fuera horario contacto'];
        
        if(!gestorOportunidadActivar.isEmpty()) {
            for(CSBD_Gestor_Oportunidad__c gestorOportunidad: gestorOportunidadActivar) {
                gestorOportunidad.CSBD_Estado__c = 'Pendiente de asignar';
            }
            Update gestorOportunidadActivar;
        }                               
    }
}