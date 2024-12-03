public with sharing class CBK_SCH_CSBD_ScheduleReaperturaCaso extends CBK_SCH_Queueable_Abstract {
    public override void execute(QueueableContext ctx) {
        List<CBK_SCH_PendingProcess__c> incomingPendingProcessList = this.lstInfoProcess;
        work(incomingPendingProcessList);
 
    }
 
    private void work(List<CBK_SCH_PendingProcess__c> incomingPendingProcessList) {
        System.debug('CBK_SCH_CSBD_ScheduleReaperturaCaso - incomingPendingProcessList - Input list: ' + JSON.serialize(incomingPendingProcessList));
        String methodName = 'work';
        Set<Id> pendingProcessCaseIdSet = new Set<Id>();
        for(CBK_SCH_PendingProcess__c pendingProcess: incomingPendingProcessList){
            pendingProcessCaseIdSet.add(pendingProcess.RecordId__c);
        }

        // WITH SECURITY_ENFORCED eliminado por problemas con el test
        Case[] pendingProcessCaseList = [SELECT OwnerId, Status, CaseNumber, SACH_Alerta_Fecha__c FROM Case WHERE Id=:pendingProcessCaseIdSet];

        Map<Id, Case> idCaseMap = new Map<Id, Case>();

        for(Case caso: pendingProcessCaseList){
            idCaseMap.put(caso.Id, caso);
        }

        //Id idCustomNotification = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'CC_Notificacion'].Id;

       Id idCustomNotification = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'SACH_Notificacion_Alerta'].Id;
        List<Case> casosUpdt = new List<Case>();
        for(CBK_SCH_PendingProcess__c pendingProcess: incomingPendingProcessList){
            if(idCaseMap.containsKey(pendingProcess.RecordId__c)){
                Case caso = idCaseMap.get(pendingProcess.RecordId__c);

                if(caso.Status == 'Pendiente Colaborador'){
                    try {
                        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        notification.setTitle(caso.CaseNumber + ': Alerta programada');
                        notification.setBody('Alerta programada manualmente para el caso: ' + caso.CaseNumber);
                        notification.setNotificationTypeId(idCustomNotification);
                        notification.setTargetId(caso.Id);
                        notification.send(new Set<String>{caso.OwnerId});

                        //Aqui tenemos que poner el caso en Activo
                        caso.Status = 'Activo';
                        casosUpdt.add(caso);

                        //Aqui se busca la tarea que exista ya creada y que este en el estado 'Open' --> 'Completed''
                        //SACH_CaseTriggerHelper.reabrirTareaTrasladoColab(caso.Id);
                        List<Task> tareasTrasladoAbiertas = new List<Task>();
      
                        tareasTrasladoAbiertas = [SELECT Id FROM Task
                                                                WHERE WhatId = :caso.Id AND Type = 'Traslado Colaborador' AND IsClosed = FALSE WITH SECURITY_ENFORCED
                                                                ORDER BY CreatedDate DESC LIMIT 1];
                        if (!tareasTrasladoAbiertas.isEmpty()) {
                            tareasTrasladoAbiertas[0].Status = 'Completed';
                            update tareasTrasladoAbiertas;
                        }
                        
            
                    } catch (Exception e) {
                        CBK_log.error(e);
                    }
                }
            }
        }
        if(!casosUpdt.isEmpty()){
                List<Database.SaveResult> listUpdateResult = Database.update(casosUpdt,false);
                SACH_AppUtilities.displayErrors(methodName,listUpdateResult);
        }
    }    
}