public with sharing class SAC_LCMP_InfoSubsanaciones {

    @AuraEnabled(cacheable=true)
    public static List<SPV_Formulario__c> getSubsanaciones(Id casoId) {
        return [SELECT Name, SAC_FechaSubsanacion__c, SAC_Subsanador__c, SAC_GrupoSubsanador__c FROM SPV_Formulario__c WHERE SPV_Caso__c = :casoId];
    }
}