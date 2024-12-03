public with sharing class CBK_SCH_Reclamaciones_Auto extends CBK_SCH_Queueable_Abstract {
    public override void execute(QueueableContext ctx) {
        List<CBK_SCH_PendingProcess__c> incomingPendingProcessList = this.lstInfoProcess;
        work(incomingPendingProcessList);
 
    }
 
    private void work(List<CBK_SCH_PendingProcess__c> incomingPendingProcessList) {
        System.debug('CBK_SCH_CSBD_SchedulePendienteCita - incomingPendingProcessList - Input list: ' + JSON.serialize(incomingPendingProcessList));

        List<Id> pendingProcessCaseIdSet = new List<Id>();
        List<Id> taskIdSet = new List<Id>();
        Map<Id, Task> mapaCaseTask = new Map<Id, Task>();

        for(CBK_SCH_PendingProcess__c pendingProcess: incomingPendingProcessList){
            pendingProcessCaseIdSet.add(pendingProcess.RecordId__c);
        }

        List<Task> listaTareas = [SELECT Id, CC_Fecha_1_Reclamacion_Auto__c, CC_Fecha_2_Reclamacion_Auto__c, CC_Fecha_3_Reclamacion_Auto__c, OS_Fecha_Fin_Reclamacion_Auto__c, WhatId
                                     FROM Task WHERE WhatId IN :pendingProcessCaseIdSet AND Type = 'Traslado Colaborador' AND Status = 'Open'];

        for(CBK_SCH_PendingProcess__c pendingProcess : incomingPendingProcessList){
            for(Task tarea : listaTareas){
                if(tarea.WhatId == pendingProcess.RecordId__c && (tarea.CC_Fecha_1_Reclamacion_Auto__c == pendingProcess.Schedule_Time__c || tarea.CC_Fecha_2_Reclamacion_Auto__c == pendingProcess.Schedule_Time__c ||
                tarea.CC_Fecha_3_Reclamacion_Auto__c == pendingProcess.Schedule_Time__c || tarea.OS_Fecha_Fin_Reclamacion_Auto__c == pendingProcess.Schedule_Time__c)){
                    taskIdSet.add(tarea.Id);
                }
            }
        }
        CC_Configuracion_Reclamaciones_Auto.sendMailRecTrasladoColab(taskIdSet);
    }
}