public with sharing class CSBD_BatchAnonimarOportunidades implements Database.Batchable<sObject> {

    public CSBD_BatchAnonimarOportunidades() {

    }

    public List<Opportunity> start(Database.BatchableContext BC) {
        // Consulta para obtener los registros que deseas procesar
        List<CSBD_ParametrosBatch__c> cd = [SELECT CSBD_HorasParaBatch__c FROM CSBD_ParametrosBatch__c LIMIT 1];
        List<RecordType> recordTypesCSBD = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName LIKE 'CSBD_%'];

        Set<Id> recordTypeIds = new Set<Id>();

        for (RecordType rt : recordTypesCSBD) {
            recordTypeIds.add(rt.Id);
        }

        List<String> recordTypeIdsStrList = new List<String>();
        for (Id rtId : recordTypeIds) {
            recordTypeIdsStrList.add('\'' + rtId + '\'');
        }
        String recordTypeIdsStr = String.join(recordTypeIdsStrList, ',');

        Integer horas = 0;
        if(!cd.isEmpty()){ 
            horas = Integer.valueOf(cd[0].CSBD_HorasParaBatch__c); 
        }
        DateTime myDate = null;
        myDate = System.now().addHours(-horas);
        String startTimeFormat = myDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String estado = 'Rechazada';
        
        String query = 'SELECT Id FROM Opportunity WHERE CSBD_Fecha_vencimiento_alta__c <= ' + startTimeFormat + 
        ' AND CSBD_Contact__r.CC_NumPerso__c = null AND CSBD_Anonimizada__c = false AND CSBD_Estado__c = ' + '\''+ estado + '\'' +
        ' AND RecordTypeId IN (' + recordTypeIdsStr + ')';

        /*  QUERY DINAMICA POR CUSTOM SETTING ELIMINADA POR SEGURIDAD A QUE NO SE INTRODUZCAN CORRECTAMENTE LOS VALORES
        List<CSBD_QueryDinamica__c> wheres = [SELECT CSBD_WhereCondition__c, CSBD_FieldCondition__c, CSBD_Operador__c, CSBD_TipoBatch__c FROM CSBD_QueryDinamica__c WHERE CSBD_TipoBatch__c = 'Anonimizar'];
        if(!wheres.isEmpty()){
            for (CSBD_QueryDinamica__c variable : wheres) {
                query += ' AND ' + variable.CSBD_FieldCondition__c + variable.CSBD_Operador__c + variable.CSBD_WhereCondition__c;
            }
        }*/

        return Database.query(query);
                
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        system.debug('execute ' + scope);
        // Hacer una query a un custom metadata type o custom setting que contenga los campos a anonimizar
        if (!scope.isEmpty()) {
            // Lógica de procesamiento para cada lote de registros
            List<CSBD_ParametrosAnonimizar__c> cd = [SELECT CSBD_Campo__c  FROM CSBD_ParametrosAnonimizar__c ];
            if(!cd.isEmpty()){
                for (Opportunity opp : scope) {
                    // Realiza la lógica de actualización o procesamiento aquí
                    
                    for(CSBD_ParametrosAnonimizar__c campo : cd){
                        if(campo.CSBD_Campo__c == 'CSBD_Email_Solicitud__c'){
                            opp.put(campo.CSBD_Campo__c, 'xxxxxx@xxxxx.xxx');
                        }
                        else{
                            opp.put(campo.CSBD_Campo__c, '******');
                        }
                    }
                    opp.CSBD_Anonimizada__c = true;    
                }
                // Actualiza los registros en la base de datos
                update scope;
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        // Método opcional que se ejecuta después de que el proceso de lotes ha terminado
        CBK_Log.debug('Fin batch anonimizar oportunidades NIS',logginglevel.INFO);
    }
}