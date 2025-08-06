public with sharing class CC_CaseExtensionController {

    @AuraEnabled(cacheable=true)
    public static Id getCaseExtensionId(Id recordId) {
        List<CBK_Case_Extension__c> caseExtensions = [SELECT Id FROM CBK_Case_Extension__c
                                                            WHERE Case_Id__c = :recordId LIMIT 1];
        return caseExtensions.isEmpty() ? null : caseExtensions[0].Id;
    }
}