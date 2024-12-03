public with sharing class CC_Enlaces_Controller {

    @AuraEnabled
    public static List<CC_Enlace__c> getEnlaces()
    {
        return [SELECT CC_Nombre__c, CC_URL__c FROM CC_Enlace__c];
    }
}