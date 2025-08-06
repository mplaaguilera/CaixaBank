public with sharing class CSBD_Batch_RechazoOppChat implements Database.Batchable<sObject> {

    public CSBD_Batch_RechazoOppChat() {

    }

    public List<Opportunity> start(Database.BatchableContext BC) {
        // Consulta para obtener los registros que deseas procesar
        String usuarioGestorId = [SELECT Id, name FROM User WHERE UserName LIKE 'csbd_generico@cc-caixabank.com%' LIMIT 1].Id;
        String usuarioAutoProcessId = [SELECT Id FROM User WHERE Name = 'Automated Process' LIMIT 1].Id;
        Id recType = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Chat').getRecordTypeId();
        DateTime myDate = System.now();
        if(!Test.isRunningTest()){
            myDate = myDate.addMinutes(-30);
        }
        String startTimeFormat = myDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

        
        String query = 'SELECT Id, CSBD_Estado__c, RecordType.DeveloperName, CSBD_Alta_omnichannel__c FROM Opportunity' +
            ' WHERE RecordTypeId = ' + '\''+ recType + '\'' +
            ' AND ( OwnerId = ' + '\''+ usuarioGestorId + '\''+ ' OR OwnerId = '  + '\''+ usuarioAutoProcessId + '\''+ ') ' + 
            ' AND CreatedDate = LAST_N_DAYS:7' + 
            ' AND IsClosed = false';

        return Database.query(query);
        
        
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        
        if (!scope.isEmpty()) {
            // Lógica de procesamiento para cada lote de registros
            CSBD_Opportunity.cerrarOportunidad(scope, 'Rechazada', 'Chat no iniciado'); 
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        // Método opcional que se ejecuta después de que el proceso de lotes ha terminado
        CBK_Log.debug('Fin batch rechazo oportunidades chat NIS',logginglevel.INFO);
    }
}