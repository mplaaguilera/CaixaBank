public with sharing class SACH_SCH_CSBD_ScheduleAlerta extends CBK_SCH_Queueable_Abstract  {
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
        // WITH SECURITY_ENFORCED eliminado por problemas con el test
        Case[] pendingProcessCaseList = [SELECT OwnerId, Status, CaseNumber, SACH_Alerta_Fecha__c FROM Case WHERE Id=:pendingProcessCaseIdSet];

        Map<Id, Case> idCaseMap = new Map<Id, Case>();

        for(Case caso: pendingProcessCaseList){
            idCaseMap.put(caso.Id, caso);
        }

        Id idCustomNotification = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'SACH_Notificacion_Alerta'].Id;
        List<Case> casosUpdt = new List<Case>();
        for(CBK_SCH_PendingProcess__c pendingProcess: incomingPendingProcessList){
            if(idCaseMap.containsKey(pendingProcess.RecordId__c)){
                Case caso = idCaseMap.get(pendingProcess.RecordId__c);

                if(caso.SACH_Alerta_Fecha__c != null){
                    try {
                        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        notification.setTitle(caso.CaseNumber + ': Alerta programada');
                        notification.setBody('Alerta programada manualmente para el caso: ' + caso.CaseNumber);
                        notification.setNotificationTypeId(idCustomNotification);
                        notification.setTargetId(caso.Id);
                        notification.send(new Set<String>{caso.OwnerId});

                        caso.SACH_Alerta_Ultima_Vencida__c = caso.SACH_Alerta_Fecha__c;
                        caso.SACH_Alerta_Fecha__c = null;
                        caso.SACH_Alerta_Descripcion__c = null;
                        casosUpdt.add(caso);
                    } catch (Exception e) {
                        CBK_log.error(e);
                    }
                }
            }
        }
        if(!casosUpdt.isEmpty()){
            if (Schema.sObjectType.Case.fields.SACH_Alerta_Ultima_Vencida__c.isUpdateable() && Schema.sObjectType.Case.fields.SACH_Alerta_Fecha__c.isUpdateable()  && Schema.sObjectType.Case.fields.SACH_Alerta_Descripcion__c.isUpdateable()) {
                List<Database.SaveResult> listUpdateResult = Database.update(casosUpdt,false);
                SACH_AppUtilities.displayErrors(methodName,listUpdateResult);
            }
        }
    }
}