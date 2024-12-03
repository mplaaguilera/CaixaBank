/**********************************************************************************************************************
 Name:	  CIBE_OpprtTeamMemberTriggerHelper
 Copyright © 2022  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Opportunity Team Member para CIBE
------------------------------------------------------------------------------------------------
Historial
------------------------------------------------------------------------------------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0							Luis Martinez		20/12/2022			Init version Opp 
------------------------------------------------------------------------------------------------
***********************************************************************************************************************/
public with sharing class CIBE_OpprtTeamMemberTriggerHelper {

    public static List<OpportunityTeamMember> checkGeneralRT(List<OpportunityTeamMember> listNews) {
        List<OpportunityTeamMember> listData = new List<OpportunityTeamMember>();

        Set<Id> setIdOpp = new Set<Id>();
        if(!listNews.isEmpty()) {
            for(OpportunityTeamMember otm : listNews){
                setIdOpp.add(otm.OpportunityId);
            }

            List<Opportunity> lstOpp = new List<Opportunity>();
            if(!setIdOpp.isEmpty()) {
                lstOpp = [SELECT Id, RecordTypeId FROM Opportunity WHERE Id IN :setIdOpp];
            }
            
            Map<Id, Opportunity> opps = new Map<Id, Opportunity>(CIBE_OpportunityTriggerHelper.checkGeneralRT(lstOpp));
            for(OpportunityTeamMember otm : listNews){
                if(opps.containsKey(otm.OpportunityId)){
                    listData.add(otm);
                }
            }
        }
        return listData;
    }

    
    /**
	* @description   Send Custom notification when create new member OTM
	* @param news  map of new Opportunity records
	* @param mapOlds map of old Opportunity records
	*/
    public static void createNotificationNewUser(List<OpportunityTeamMember> listNews){
        Set<String> setUsers = new Set<String>();
        Set<Id> setIdOpp = new Set<Id>();

        if(!listNews.isEmpty()) {
            for(OpportunityTeamMember otm: listNews){
                setUsers.add(otm.UserId);
                setIdOpp.add(otm.OpportunityId);
            }
        }

        if(setIdOpp!=null && !setIdOpp.isEmpty()) {
            List<Opportunity> opps = [SELECT Id, Name, AccountId, Account.Name, OwnerId, RecordTypeId FROM Opportunity WHERE Id IN :setIdOpp];
            List<CustomNotificationType> notificationTypes = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'CIBE_newOpportunityTeamMeamber'];
    
            if(!listNews.isEmpty() && !notificationTypes.isEmpty() && !opps.isEmpty()) {
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle(LABEL.CIBE_not_NewOppTeamMember_title);
                String textoNoti = LABEL.CIBE_not_NewOppTeamMember;
                textoNoti = textoNoti.replace('Opportunity' , opps.get(0).Name.trim());
                if(opps.get(0).AccountId !=null){
                    textoNoti = textoNoti.replace('Cliente' , opps.get(0).Account.Name);
                }
                notification.setBody(textoNoti);
                notification.setNotificationTypeId(notificationTypes.get(0).Id);
                notification.setTargetId(+opps.get(0).Id);
                if(!Test.isRunningTest() && !setUsers.isEmpty()) {
                    notification.send(setUsers);
                }
            }
        }
    }

    public static void setOpportunityUsers(List<OpportunityTeamMember> listNewObj) {
        if(Schema.SObjectType.OpportunityTeamMember.fields.UserId.isAccessible() &&
            Schema.SObjectType.OpportunityTeamMember.fields.OpportunityId.isAccessible()) {
            Set<Id> opportunityIds = new Set<Id>();
            List<OpportunityTeamMember> lstOTMAct = new List<OpportunityTeamMember>();
            Map<Id, Set<Id>> userIds = new Map<Id, Set<Id>>();

            for(OpportunityTeamMember opportunityTM : listNewObj) {
                if(opportunityTM.OpportunityId!=null){
                    opportunityIds.add(opportunityTM.OpportunityId);
                }
            }

            if(opportunityIds!=null && !opportunityIds.isEmpty() ){
                if(Schema.SObjectType.Opportunity.fields.OwnerId.isAccessible()) {
                    lstOTMAct = [SELECT Id, UserId,OpportunityId, Opportunity.OwnerId FROM OpportunityTeamMember WHERE OpportunityId IN :opportunityIds];
                }

                if(!lstOTMAct.isEmpty()){
                    for(OpportunityTeamMember otm : lstOTMAct) {
                        if(!userIds.containsKey(otm.OpportunityId)) {
                            userIds.put(otm.OpportunityId, new Set<Id>());
                        }
                        userIds.get(otm.OpportunityId).add(otm.UserId);
                        userIds.get(otm.OpportunityId).add(otm.Opportunity.OwnerId);
                    }
                }else{
                    List<Opportunity> oppList = [SELECT Id, OwnerId FROM Opportunity WHERE Id IN :opportunityIds];
                    if(!oppList.isEmpty()){
                        for (Opportunity opp : oppList) {
                            userIds.put(opp.Id, new Set<Id>());
                            userIds.get(opp.Id).add(opp.OwnerId);
                        }
                    }
                }

                List<Opportunity> toUpdate = new List<Opportunity>();
                for(Id opportunityId : userIds.keySet()) {
                    toUpdate.add(
                        new Opportunity(
                            Id = opportunityId,
                            CIBE_OpportunityTeam__c = String.join(new List<Id>(userIds.get(opportunityId)), ',')
                        ));
                }
        
                Database.SaveResult[] updates = Database.update(toUpdate, false);
                boolean hasError = false;
                List<Object> objs = new List<Object>();
                Map<String, String> msjs = new Map<String, String>();
                for (Integer i = 0; i < toUpdate.size(); i++) {
                    Database.SaveResult dr = updates[i];
                    if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
                        msjs.put(toUpdate[i].Id, ((String)dr.getErrors()[0].getMessage()));
                        objs.add(toUpdate[i]);
                        hasError = true;
                    }
                }
        
                if(hasError) {
                    CBK_Log.error(msjs, objs);
                }
            }
        }
    }
}