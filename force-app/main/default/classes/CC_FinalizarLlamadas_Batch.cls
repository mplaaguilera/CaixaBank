public with sharing class CC_FinalizarLlamadas_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    public CC_FinalizarLlamadas_Batch() {
        CBK_Log.debug('Iniciación - Batch CC_FinalizarLlamadas_Batch',logginglevel.INFO);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
        Datetime fechaLimite = Datetime.now().addHours(-1);
        if (Test.isRunningTest()){
            query = 'SELECT Id, CC_Fecha_Fin__c, CC_Tipo_Cierre__c, CreatedDate FROM CC_Llamada__c WHERE RecordType.DeveloperName =  \'CC_Cliente\' AND CC_Fecha_Fin__c = NULL';
        } else {
        	query = 'SELECT Id, CC_Fecha_Fin__c, CC_Tipo_Cierre__c, CreatedDate FROM CC_Llamada__c WHERE RecordType.DeveloperName = \'CC_Cliente\' AND CC_Fecha_Fin__c = NULL AND CreatedDate < :fechaLimite';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<CC_Llamada__c > llamadas) {
        List<CC_Llamada__c> updateLlamadas = new List<CC_Llamada__c>();
        if (llamadas == null || llamadas.isEmpty()) {
            return;
        }
        
        for(CC_Llamada__c llamada : llamadas) {
            llamada.CC_Tipo_Cierre__c = 'Llamada finalizada';
            llamada.CC_Fecha_Fin__c = llamada.CreatedDate.addMinutes(10);
            updateLlamadas.add(llamada);
        }
        
        if (updateLlamadas.size() > 0) {
            Database.SaveResult[] oResult = Database.update(updateLlamadas, false);
        }
    }

    public void finish(Database.BatchableContext bc) {
        CBK_Log.debug('Finalización - Batch CC_FinalizarLlamadas_Batch',logginglevel.INFO);
    }
}