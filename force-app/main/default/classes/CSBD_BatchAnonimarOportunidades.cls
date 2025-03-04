public with sharing class CSBD_BatchAnonimarOportunidades implements Database.Batchable<sObject> {

    public CSBD_BatchAnonimarOportunidades() {

    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
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
        //Recuperar los campos a anonimizar como parte de la query pues se utilizarán en validaciones del execute
        List<CSBD_ParametrosAnonimizar__c> parametrosLista = [SELECT CSBD_Campo__c  FROM CSBD_ParametrosAnonimizar__c ];
        String camposQuery = '';
        if(!parametrosLista.isEmpty()){
            List<String> camposAnonimizar = new List<String>();
            for(CSBD_ParametrosAnonimizar__c pa : parametrosLista){
                camposAnonimizar.add(pa.CSBD_Campo__c);
            }
            if(!camposAnonimizar.isEmpty()){
                camposQuery = ',' + String.join(camposAnonimizar, ',');
            }
        }

        String query = 'SELECT Id ' + camposQuery + ' FROM Opportunity WHERE CSBD_Fecha_vencimiento_alta__c <= ' + startTimeFormat + 
        ' AND CSBD_Contact__r.CC_NumPerso__c = null AND CSBD_Anonimizada__c = false AND CSBD_Estado__c = ' + '\''+ estado + '\'' +
        ' AND RecordTypeId IN (' + recordTypeIdsStr + ')';

        /*  QUERY DINAMICA POR CUSTOM SETTING ELIMINADA POR SEGURIDAD A QUE NO SE INTRODUZCAN CORRECTAMENTE LOS VALORES
        List<CSBD_QueryDinamica__c> wheres = [SELECT CSBD_WhereCondition__c, CSBD_FieldCondition__c, CSBD_Operador__c, CSBD_TipoBatch__c FROM CSBD_QueryDinamica__c WHERE CSBD_TipoBatch__c = 'Anonimizar'];
        if(!wheres.isEmpty()){
            for (CSBD_QueryDinamica__c variable : wheres) {
                query += ' AND ' + variable.CSBD_FieldCondition__c + variable.CSBD_Operador__c + variable.CSBD_WhereCondition__c;
            }
        }*/

        return Database.getQueryLocator(query);
                
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        // Hacer una query a un custom metadata type o custom setting que contenga los campos a anonimizar
        if (!scope.isEmpty()) {
            // Lógica de procesamiento para cada lote de registros
            List<CSBD_ParametrosAnonimizar__c> cd = [SELECT CSBD_Campo__c  FROM CSBD_ParametrosAnonimizar__c ];
            if(!cd.isEmpty()){
                List<Opportunity> opplist=new List<Opportunity>();
                Boolean camposValidos = false; // Controla si algún campo tiene valor
                for (Opportunity opp : scope) {
                    // Realiza la lógica de actualización o procesamiento aquí
                    camposValidos = false; // Controla si algún campo tiene valor
                    for(CSBD_ParametrosAnonimizar__c campo : cd){
                        if (opp.get(campo.CSBD_Campo__c) != null) { 
                            opp.put(campo.CSBD_Campo__c, campo.CSBD_Campo__c == 'CSBD_Email_Solicitud__c' ? 'xxxxxx@xxxxx.xxx' : '******');
                            camposValidos = true; // Al menos un campo tiene valor
                        }
                        /*if(campo.CSBD_Campo__c == 'CSBD_Email_Solicitud__c'){ 
                            opp.put(campo.CSBD_Campo__c, 'xxxxxx@xxxxx.xxx');
                        }
                        else{
                            opp.put(campo.CSBD_Campo__c, '******');
                        }*/
                    }
                    if (camposValidos) { // Solo marca como anonimizada si hay al menos un campo válido
                        opp.CSBD_Anonimizada__c = true;
                        opplist.add(opp);
                    }

                   
                }
                // Actualiza los registros en la base de datos
                if (!opplist.isEmpty()) {
                    update scope;
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        // Método opcional que se ejecuta después de que el proceso de lotes ha terminado
        CBK_Log.debug('Fin batch anonimizar oportunidades NIS',logginglevel.INFO);
    }
}