/**********************************************************************************************************************
 Name:	  CIBE_OTeamMember_AI_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de OpportunityTeamMember AfterInsert funcionalidad para CIBE 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
    1.0								Luis Martínez 	    20/12/2022			Init version

***********************************************************************************************************************/
public class CIBE_OTeamMember_AI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<OpportunityTeamMember>)tp.newList, (Map<Id, OpportunityTeamMember>)tp.newMap, (List<OpportunityTeamMember>) tp.oldList, (Map<Id, OpportunityTeamMember>) tp.oldMap);
    }

    private void process(List<OpportunityTeamMember> listNewObj, Map<Id, OpportunityTeamMember> mapNewObj, List<OpportunityTeamMember> listOldObj, Map<Id, OpportunityTeamMember> mapOldObj) {
        List<OpportunityTeamMember> listData = CIBE_OpprtTeamMemberTriggerHelper.checkGeneralRT(listNewObj);
        
        if(!listData.isEmpty() && listData != null) {

            boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
            if (!hasCustomPermission && !System.isbatch()) {
                CIBE_OpprtTeamMemberTriggerHelper.createNotificationNewUser(listNewObj);
            }
            CIBE_OpprtTeamMemberTriggerHelper.setOpportunityUsers(listData);
        }          
    }
}