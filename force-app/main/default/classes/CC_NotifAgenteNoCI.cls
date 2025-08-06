public with sharing class CC_NotifAgenteNoCI extends CBK_SCH_Queueable_Abstract  {

    public override void execute(QueueableContext ctx) {
        List<CBK_SCH_PendingProcess__c> incomingPendingProcessList = this.lstInfoProcess;
        work(incomingPendingProcessList);
    }

    private void work(List<CBK_SCH_PendingProcess__c> incomingPendingProcessList) {  
        String methodName = 'work';
        Set<Id> oSetID = new Set<Id>();
        List<Case> lstCasosUpdt = new List<Case>();
        for(CBK_SCH_PendingProcess__c pendingProcess: incomingPendingProcessList){
            oSetID.add(pendingProcess.RecordId__c);
        }

        if(!oSetID.isEmpty()){
            Id idCustomNotification = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'CC_Aviso_Contacto_Intermedio'].Id;
            Map<Id, Case> mapCuentasCasos = new Map<Id, Case>([SELECT Id, CaseNumber, OwnerId FROM Case WHERE Id IN :oSetID]);
            for (Id idCaso : oSetID) {
                if(mapCuentasCasos.containsKey(idCaso)){
                    Case caso = mapCuentasCasos.get(idCaso);
                    caso.Id = idCaso;
                    caso.CC_Notif_Cont_Inter__c = true;
                    lstCasosUpdt.add(caso);

                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    notification.setBody('No se ha podido realizar el envío del Contacto Intermedio para el caso ' +  caso.CaseNumber +  ', dado que no tiene un mail informado.');
                    notification.setTitle('No se ha realizado el envío del Contacto Intermedio del caso ' + caso.CaseNumber);
                    notification.setNotificationTypeId(idCustomNotification);
                    notification.setTargetId(idCaso);
                    notification.send(new Set<String> { caso.OwnerId });
                }
            }
        }

        if (!lstCasosUpdt.isEmpty()) {
            Database.update(lstCasosUpdt, false);
        }
    }
}