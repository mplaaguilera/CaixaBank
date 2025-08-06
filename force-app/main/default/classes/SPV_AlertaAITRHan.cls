public with sharing class SPV_AlertaAITRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Alerta__c>)tp.newList, (Map<Id, SAC_Alerta__c>)tp.newMap);
	}

    private void process(List<SAC_Alerta__c> listNewObj, Map<Id, SAC_Alerta__c> mapNewObj) {
        //Record types SPV
        Id recTypeAlertaSPV = Schema.SObjectType.SAC_Alerta__c.getRecordTypeInfosByDeveloperName().get('SPV_Alerta').getRecordTypeId();
        Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId();

        List<Id> idReclamaciones = new List<Id>();
        List<Case> listaReclamaciones = new List<Case>();

        //Filtrar record types
        for (SAC_Alerta__c alerta : listNewObj) {
            if (alerta.RecordTypeId == recTypeAlertaSPV) {
                idReclamaciones.add(alerta.SAC_Reclamacion__c);    
            }
        }
        
        //Select a reclamaciones
        if (!idReclamaciones.isEmpty()) {
            listaReclamaciones = [SELECT id, SAC_AlertasPtes__c FROM Case WHERE RecordTypeId = :recTypeReclamacion AND id IN :idReclamaciones];
        }

        if (!listaReclamaciones.isEmpty()) {
            sumarContadorAlertaPendiente(listaReclamaciones);
        }
    }

    public static void sumarContadorAlertaPendiente(List<Case> listaReclamaciones) {
        try {
            /*Set<String> listaReclamacionesIds = new Set<String>();
            for (Case rec : listaReclamaciones) {
                listaReclamacionesIds.add(rec.Id);
            }
            AsyncOptions options = new AsyncOptions();
            options.DuplicateSignature = QueueableDuplicateSignature.Builder()
            .addId(UserInfo.getUserId())
            .addString(String.valueOf(listaReclamacionesIds))
            .build();*/
            System.enqueueJob(new SAC_QueueableContadorAlertas(listaReclamaciones)/*, options*/);
        } catch (DuplicateMessageException ex) {
            CBK_Log.error(ex);
        }
    }
}