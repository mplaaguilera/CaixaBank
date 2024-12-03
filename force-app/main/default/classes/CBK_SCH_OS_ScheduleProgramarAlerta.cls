public with sharing class CBK_SCH_OS_ScheduleProgramarAlerta extends CBK_SCH_Queueable_Abstract {
    public override void execute(QueueableContext ctx) {
        List<CBK_SCH_PendingProcess__c> incomingPendingProcessList = this.lstInfoProcess;
        work(incomingPendingProcessList);
    }
    
    private void work(List<CBK_SCH_PendingProcess__c> incomingPendingProcessList) {
        Set<Id> pendingProcessCaseIdSet = new Set<Id>();

        for(CBK_SCH_PendingProcess__c pendingProcess: incomingPendingProcessList){
            pendingProcessCaseIdSet.add(pendingProcess.RecordId__c);
        }

        Case[] pendingProcessCaseList = [SELECT Id, Status, OS_Alerta_Fecha__c, RecordTypeId FROM Case WHERE Id=:pendingProcessCaseIdSet];
        Map<Id, Case> idCaseMap = new Map<Id, Case>();

        for(Case caso: pendingProcessCaseList){
            idCaseMap.put(caso.Id, caso);
        }

        List<Id> casoIds = new List<Id>();

        for(CBK_SCH_PendingProcess__c pendingProcess: incomingPendingProcessList){
            if(idCaseMap.containsKey(pendingProcess.RecordId__c)){
                Case caso = idCaseMap.get(pendingProcess.RecordId__c);
                if(caso.Status == 'Pendiente Alerta' && caso.OS_Alerta_Fecha__c != null && (Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName() == 'OS_Empleado' || Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName() == 'OS_Cliente')){
                    casoIds.add(caso.Id);
                }
            }
        }
        if(!casoIds.isEmpty()) {
            OS_Programar_Alerta.programarAlerta(casoIds);
        }
    }
}