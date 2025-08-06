public without sharing class SAC_Alerta_AI_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Alerta__c>)tp.newList, (Map<Id, SAC_Alerta__c>)tp.newMap);
	}

    private void process(List<SAC_Alerta__c> listNewObj, Map<Id, SAC_Alerta__c> mapNewObj) {

        //Record types SAC
        Id recTypeAlertaSAC = Schema.SObjectType.SAC_Alerta__c.getRecordTypeInfosByDeveloperName().get('SAC_Alerta').getRecordTypeId();
        Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();

        List<Id> idReclamaciones = new List<Id>();
        List<Case> listaReclamaciones = new List<Case>();

        //Filtrar record types
        for (SAC_Alerta__c alerta : listNewObj) {
            if (alerta.RecordTypeId == recTypeAlertaSAC) {
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
        DateTime dt = DateTime.now();
        Long dateInMilliseconds = dt.getTime();
        AsyncOptions options = new AsyncOptions();
        options.DuplicateSignature = QueueableDuplicateSignature.Builder().addId(UserInfo.getUserId()).addString(String.valueOf(dateInMilliseconds)).build();
        ID jobID;
        try {
            jobID = System.enqueueJob(new SAC_QueueableContadorAlertas(listaReclamaciones), options);    
        } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);                 } 
    }
}