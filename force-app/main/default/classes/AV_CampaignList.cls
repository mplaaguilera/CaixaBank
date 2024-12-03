/**
 * Clase de la aplicacion Gestor de Eventos
 */

public with sharing class AV_CampaignList {

    @AuraEnabled @InvocableVariable public List<Campaign> camps;
    @AuraEnabled @InvocableVariable public List<CampaignMember> campMembers;
    @AuraEnabled @InvocableVariable public List<Centro_Objetivo__c> centrosObj;
    


    public AV_CampaignList() {

    }
}