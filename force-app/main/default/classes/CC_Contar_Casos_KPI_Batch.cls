public with sharing class CC_Contar_Casos_KPI_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    // Id batchJobId = Database.executeBatch(new CC_Contar_Casos_KPI_Batch(), 200);
    public CC_Contar_Casos_KPI_Batch() {
        CBK_Log.debug('Inicia - CC_Contar_Casos_KPI_Batch',logginglevel.INFO);
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
         if (Test.isRunningTest()){
            query = 'SELECT id, CaseNumber,  CC_Repetitivo__c, CC_NumeroCasoOrigenRep__c  FROM Case WHERE RecordType.DeveloperName = \'CC_Cliente\' AND Status != \'Rechazado\' AND CreatedDate = TODAY AND CC_NumeroCasoOrigenRep__c != NULL ORDER BY CC_NumeroCasoOrigenRep__c ASC';
         } else {
            query = 'SELECT id, CaseNumber,  CC_Repetitivo__c, CC_NumeroCasoOrigenRep__c  FROM Case WHERE RecordType.DeveloperName = \'CC_Cliente\' AND Status != \'Rechazado\' AND CreatedDate = YESTERDAY AND CC_NumeroCasoOrigenRep__c != NULL ORDER BY CC_NumeroCasoOrigenRep__c ASC';
         }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Case> scope) {
        Map < String, Integer > mapCaseNumAndRep = new Map < String, Integer >();
        Set<String> setCaseNumber = new Set<String>();

        for(Case c :scope){
            setCaseNumber.add(c.CC_NumeroCasoOrigenRep__c);
            String key = c.CC_NumeroCasoOrigenRep__c;
                if (!mapCaseNumAndRep.containsKey(key)) {
                    mapCaseNumAndRep.put(key, 1);
                } else {
                    mapCaseNumAndRep.put(key, mapCaseNumAndRep.get(key) + 1);
                }
        }
        List<Case> lstCasosOrigRep = new  List<Case>();
        List<Case> lstUpdate = new  List<Case>();
        if(!setCaseNumber.isEmpty()){
            lstCasosOrigRep = [SELECT CaseNumber, CC_Cantidad_Repeticiones__c, CC_Repetitivo__c, CC_NumeroCasoOrigenRep__c  FROM Case WHERE CaseNumber IN :setCaseNumber];
        }

        for (Case caso : lstCasosOrigRep) {
            String key = caso.CaseNumber;
            if (mapCaseNumAndRep.containsKey(key)) {
                caso.CC_Cantidad_Repeticiones__c = caso.CC_Cantidad_Repeticiones__c + Integer.valueOf(mapCaseNumAndRep.get(key));
                caso.CC_Repetitivo__c = true;
                lstUpdate.add(caso);
            }
        }
        if (!lstUpdate.isEmpty()){
            Database.update(lstUpdate, false);
        }


    }

    public void finish(Database.BatchableContext bc) {
        CBK_Log.debug('Finalización - CC_Contar_Casos_KPI_Batch',logginglevel.INFO);

    }
}