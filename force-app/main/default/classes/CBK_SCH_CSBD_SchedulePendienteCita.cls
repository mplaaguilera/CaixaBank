public with sharing class CBK_SCH_CSBD_SchedulePendienteCita extends CBK_SCH_Queueable_Abstract {
    public override void execute(QueueableContext ctx) {
        List<CBK_SCH_PendingProcess__c> incomingPendingProcessList = this.lstInfoProcess;
        work(incomingPendingProcessList);
 
    }
 
    private void work(List<CBK_SCH_PendingProcess__c> incomingPendingProcessList) {
        System.debug('CBK_SCH_CSBD_SchedulePendienteCita - incomingPendingProcessList - Input list: ' + JSON.serialize(incomingPendingProcessList));

        Set<Id> pendingProcessOpportunityIdSet = new Set<Id>();

        for(CBK_SCH_PendingProcess__c pendingProcess: incomingPendingProcessList){
            pendingProcessOpportunityIdSet.add(pendingProcess.RecordId__c);
        }

        Opportunity[] pendingProcessOpportunityList = [SELECT Id, CSBD_Estado__c, CSBD_Fecha_Cita__c, CSBD_Identificador__c, CSBD_Contact__r.FirstName, CSBD_Contact__r.LastName, RecordType.Name, StageName, Amount, CSBD_Dif_Importe_Preconcedido_Label__c, OwnerId FROM Opportunity WHERE Id=:pendingProcessOpportunityIdSet];

        Map<Id, Opportunity> idOpportunityMap = new Map<Id, Opportunity>();

        for(Opportunity oportunidad: pendingProcessOpportunityList){
            idOpportunityMap.put(oportunidad.Id, oportunidad);
        }

        List<CSBD_Opportunity.FinalizarClienteInput> finalizarClienteInputList = new List<CSBD_Opportunity.FinalizarClienteInput>();
        
        Id idCustomNotification = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'CC_Notificacion'].Id;
        
        for(CBK_SCH_PendingProcess__c pendingProcess: incomingPendingProcessList){
            if(idOpportunityMap.containsKey(pendingProcess.RecordId__c)){
                Opportunity oportunidad = idOpportunityMap.get(pendingProcess.RecordId__c);

                if(oportunidad.CSBD_Estado__c == 'Pendiente Cita' && oportunidad.CSBD_Fecha_Cita__c == pendingProcess.Schedule_Time__c){
                    // Ejecutar notificación campana                  
                    try {
                        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        notification.setTitle(oportunidad.CSBD_Identificador__c + ': Cita con el cliente');
                        notification.setBody('Cita con: ' + oportunidad.CSBD_Contact__r.FirstName + ' ' + oportunidad.CSBD_Contact__r.LastName +'\n'+
                        'Fecha de la cita: ' + oportunidad.CSBD_Fecha_Cita__c.format('dd/MM/yyyy HH:mm') +'\n'+
                        'Tipo: ' + oportunidad.RecordType.Name +' (Etapa de ventas: ' + oportunidad.StageName +')' +'\n'+
                        'Importe total: ' + oportunidad.Amount + 'EUR (Diferencial: ' + oportunidad.CSBD_Dif_Importe_Preconcedido_Label__c +')');
                        notification.setNotificationTypeId(idCustomNotification);
                        notification.setTargetId(oportunidad.Id);
                        notification.send(new Set<String>{oportunidad.OwnerId});
                    } catch (Exception e) {
                        CBK_Log.error(e);
                    }
                                       
                    // ACCIONES A EJECUTAR: Llamar clase de apex CSBD_Opportunity.finalizarCita()
                    CSBD_Opportunity.FinalizarClienteInput finalizarCliente = new CSBD_Opportunity.FinalizarClienteInput();
                    finalizarCliente.idOportunidad = oportunidad.Id;
                    finalizarCliente.nuevoEstado = 'Completado';
                    finalizarCliente.motivoCancelado = '';
                    finalizarClienteInputList.add(finalizarCliente);
                }
            }
        }
        CSBD_Opportunity.finalizarCita(finalizarClienteInputList);
    }
}