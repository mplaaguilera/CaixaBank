public with sharing class CSBD_BatchDesestimarOportunidades implements Database.Batchable<sObject> {
    
    public CSBD_BatchDesestimarOportunidades() {

    }

    public List<Opportunity> start(Database.BatchableContext BC) {
        // Consulta para obtener los registros que deseas procesar
        List<CSBD_ParametrosBatch__c> cd = [SELECT CSBD_HorasParaBatch2__c FROM CSBD_ParametrosBatch__c LIMIT 1];
        Integer horas = 0;
        if(!cd.isEmpty()){ 
            horas = Integer.valueOf(cd[0].CSBD_HorasParaBatch2__c); 
        }
        DateTime myDate = null;
        
        myDate = System.now().addHours(-horas);
        String startTimeFormat = myDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        Id recType = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_PROAutomatica').getRecordTypeId();

        String query = 'SELECT Id, CSBD_Estado__c, RecordType.DeveloperName, CSBD_Alta_omnichannel__c FROM Opportunity  WHERE RecordTypeId = ' + '\''+ recType + '\'' +
            ' AND CSBD_Fecha_vencimiento_alta__c <= ' + startTimeFormat + 
            ' AND CSBD_Now_NUMPERSO__c = null AND CSBD_Anonimizada__c = false AND isClosed = false';

        
            /*  QUERY DINAMICA POR CUSTOM SETTING ELIMINADA POR SEGURIDAD A QUE NO SE INTRODUZCAN CORRECTAMENTE LOS VALORES
            List<CSBD_QueryDinamica__c> wheres = [SELECT CSBD_WhereCondition__c, CSBD_FieldCondition__c, CSBD_Operador__c, CSBD_TipoBatch__c FROM CSBD_QueryDinamica__c WHERE CSBD_TipoBatch__c = 'Desestimar'];
            if(!wheres.isEmpty()){
                for (CSBD_QueryDinamica__c variable : wheres) {
                    query += ' AND ' + variable.CSBD_FieldCondition__c + variable.CSBD_Operador__c + variable.CSBD_WhereCondition__c;
                }
            }*/

        return Database.query(query);
        
        
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        
        // Hacer una query a un custom metadata type o custom setting que contenga los campos a anonimizar
        if (!scope.isEmpty()) {
            // Lógica de procesamiento para cada lote de registros
            CSBD_Opportunity.cerrarOportunidad(scope, 'Rechazada', 'Caducidad fecha vencimiento alta'); 
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        // Método opcional que se ejecuta después de que el proceso de lotes ha terminado
        CBK_Log.debug('Fin batch desestimar oportunidades NIS',logginglevel.INFO);
    }
}