/**********************************************************************************************************************
Name:     AV_CampaignList
-----------------------------------------------------------------------------------------------------------------------
@description Event Manager Application Class
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION     USER_STORY          AUTHOR              DATE            Description
1.0         GEO MC              Carolina Lopez      30/09/2024      Include custom campaign member list.
***********************************************************************************************************************/
public with sharing class AV_CampaignList {
    @AuraEnabled @InvocableVariable public List<Campaign> camps;
    @AuraEnabled @InvocableVariable public List<CampaignMember> campMembers;
    @AuraEnabled @InvocableVariable public List<EV_CampaignMemberC__c> campMembersCus;
    @AuraEnabled @InvocableVariable public List<Centro_Objetivo__c> centrosObj;
}