/**********************************************************************************************************************
 Name:	  EV_CMCustomController
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para controllador del lwc ev_cmCustomSearch 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR								DATE				Description
	1.0			US474068            Daniel Rodriguez       				10/11/2023          Init Version
***********************************************************************************************************************/

public with sharing class EV_CMCustomController {
    
    @AuraEnabled
    public static List<EV_CampaignMemberC__c> getCampaignMembers(String pageSize, String pageNumber, String recordId, String typeUpdate){
        Integer ps = Integer.valueOf(pageSize);
        Integer pn = Integer.valueOf(pageNumber)-1;
        List<EV_CampaignMemberC__c> cms = new List<EV_CampaignMemberC__c>();
        if(typeUpdate == 'Asistió'){
            cms = [SELECT
               Id, EV_FirstName__c,EV_LastName__c, EV_Email__c, EV_Status__c
               FROM EV_CampaignMemberC__c WHERE EV_CampaignId__c = :recordId AND (EV_Status__c = 'Registro confirmado' OR EV_Status__c = 'QR enviado')  WITH SECURITY_ENFORCED LIMIT :Integer.valueOf(ps) OFFSET :(ps*pn)];
        }else if(typeUpdate == 'Registro confirmado' ){
            cms = [SELECT
            Id, EV_FirstName__c,EV_LastName__c, EV_Email__c, EV_Status__c
            FROM EV_CampaignMemberC__c WHERE EV_CampaignId__c = :recordId AND (EV_Status__c = 'Pendiente' OR EV_Status__c = 'Invitación enviada')  WITH SECURITY_ENFORCED LIMIT :Integer.valueOf(ps) OFFSET :(ps*pn)];
        }else{
            cms = [SELECT
               Id, EV_FirstName__c,EV_LastName__c, EV_Email__c, EV_Status__c
               FROM EV_CampaignMemberC__c WHERE EV_CampaignId__c = :recordId AND EV_Status__c = 'Pendiente'  WITH SECURITY_ENFORCED LIMIT :Integer.valueOf(ps) OFFSET :(ps*pn)];
        }
        return cms;
    }

    @AuraEnabled
    public static void updateCampaignMemberStatus(List<String> selection, String typeUpdate) {
        List<EV_CampaignMemberC__c> membersToUpdate = new List<EV_CampaignMemberC__c>();
        if(typeUpdate == 'Asistió'){
            for (String memberId : selection) {
                EV_CampaignMemberC__c member = new EV_CampaignMemberC__c(Id = memberId, EV_Status__c = 'Asistió');
                membersToUpdate.add(member);
            }
        }else if(typeUpdate == 'Registro confirmado' ){
            for (String memberId : selection) {
                EV_CampaignMemberC__c member = new EV_CampaignMemberC__c(Id = memberId, EV_Status__c = 'Registro confirmado');
                membersToUpdate.add(member);
            }
        }else{
            for (String memberId : selection) {
                EV_CampaignMemberC__c member = new EV_CampaignMemberC__c(Id = memberId, EV_Status__c = 'Invitación enviada');
                membersToUpdate.add(member);
            }
        }
        if (!membersToUpdate.isEmpty() && Schema.sObjectType.EV_CampaignMemberC__c.isUpdateable()) {
            update membersToUpdate;
        }
    }
}