public with sharing class CC_Canal_Com_Borrado {
    @InvocableMethod
    public static void borradoConfidenciales(List<Id> cuentasId) {
        List<CC_Canal_Com__c> canales = [SELECT Id FROM CC_Canal_Com__c WHERE CC_CuentaId__c IN :cuentasId];
        delete canales;
    }
}