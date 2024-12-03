/**********************************************************************************************************************
 Name:	  CIBE_FeedCommentTriggerHelper
 Copyright © 2022  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de FeedComment para CIBE
------------------------------------------------------------------------------------------------
Historial
------------------------------------------------------------------------------------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0							Luis Martinez		21/12/2022			Init version Opp 
------------------------------------------------------------------------------------------------
***********************************************************************************************************************/
public with sharing class CIBE_FeedCommentTriggerHelper {
    /**
	* @description   Send Custom notification when create new member OTM
	* @param news  map of new Opportunity records
	* @param mapOlds map of old Opportunity records
	*/

    public static void createNotificationNewChat(List<FeedComment> listNews){
        Set<Id> setIdOpp = new Set<Id>();
        Boolean isGestor = FeatureManagement.checkPermission(CIBE_AppConstants.CIBE_GESTOR);

        if(!listNews.isEmpty() && isGestor) {
            for(FeedComment fc: listNews){
                setIdOpp.add(fc.parentId);
            }
            Set<Id> setRTOppo = CIBE_OpportunityTriggerHelper.getAllRT();
            List<Opportunity> lstOpp = [SELECT Id, Name, Account.Name, OwnerId, RecordTypeId FROM Opportunity WHERE Id IN :setIdOpp AND RecordtypeId IN:setRTOppo];
            List<CustomNotificationType> notificationTypes = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'CIBE_NewChatMessage'];

            if(!listNews.isEmpty() && !notificationTypes.isEmpty() && !lstOpp.isEmpty()) {
                List<OpportunityTeamMember> teamMembers = [SELECT Id, UserId FROM OpportunityTeamMember WHERE OpportunityId = :lstOpp.get(0).Id AND UserId != :lstOpp.get(0).OwnerId];
                Set<String> memberIds = new Set<String>();
                for(OpportunityTeamMember teamMember : teamMembers) {
                    memberIds.add(teamMember.UserId);
                }
                memberIds.add(lstOpp.get(0).OwnerId);
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle(LABEL.CIBE_not_NewChat_title);
                String userChat = UserInfo.getName();
                String textoNoti = userChat+' '+ LABEL.CIBE_not_NewChat;
                textoNoti = textoNoti.replace('Opportunity' , lstOpp.get(0).Name.trim());
                textoNoti = textoNoti.replace('Cliente' , lstOpp.get(0).Account.Name);
                notification.setBody(textoNoti);

                notification.setNotificationTypeId(notificationTypes.get(0).Id);
                notification.setTargetId(lstOpp.get(0).Id);
                if(!Test.isRunningTest() && !teamMembers.isEmpty()) {
                    notification.send(memberIds);
                }
            }
        }
    }
}