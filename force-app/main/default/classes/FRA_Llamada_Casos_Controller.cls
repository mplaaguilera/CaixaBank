public with sharing class FRA_Llamada_Casos_Controller {

    @AuraEnabled
    public static List<Case> getCasos(Id recordId) {
        CBK_log.debug('Inicio FRA_Llamada_Casos_Controller - getCasos (recordId: ' + recordId + ')');
        List<Id> casosId = new List<Id>();
        for (Task tarea : [SELECT WhatId FROM Task
                            WHERE CC_Llamada_Id__c = :recordId AND RecordType.DeveloperName = 'FRA_Task']) {
            casosId.add(tarea.WhatId);
        }
        CBK_log.debug('Fin FRA_Llamada_Casos_Controller - getCasos');
        return [SELECT CaseNumber, Status, Subject, CC_Canal_Procedencia__c, CC_MCC_Tematica__r.Name
                FROM Case WHERE Id IN :casosId ORDER BY CreatedDate ASC LIMIT 25];
    }
}