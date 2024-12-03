public with sharing class SACH_Casos_Relacionados {

    @AuraEnabled(cacheable=true)
    public static List<Case> getCasosRelacionados(Id recordId) {
        return [SELECT OwnerId, Owner.Name, Subject, CaseNumber, Status, CreatedDate, Origin, SACH_Interviniente__c
                FROM Case WHERE RecordType.DeveloperName = 'SACH_Cliente'
                AND (SACH_Interviniente__c = :recordId OR AccountId = :recordId)
                ORDER BY CreatedDate DESC LIMIT 20];
    }
}