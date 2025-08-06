public with sharing class CC_Formulario_Tarea_Controller {

    @AuraEnabled(cacheable=true)
    public static Id getActivityExtensionId(Id recordId) {
        List<CBK_Activity_Extension__c> actExtensions = [SELECT Id FROM CBK_Activity_Extension__c
                                                            WHERE AV_ActivityId__c = :recordId LIMIT 1];
        return actExtensions.isEmpty() ? null : actExtensions[0].Id;
    }
}