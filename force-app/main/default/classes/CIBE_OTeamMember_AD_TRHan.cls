/**********************************************************************************************************************
 Name:	  CIBE_OTeamMember_AD_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de OpportunityTeamMember AfterDelete funcionalidad para CIBE 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
    1.0								Alex Campos 	    21/07/2023			Init version

***********************************************************************************************************************/
public class CIBE_OTeamMember_AD_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<OpportunityTeamMember>)tp.newList, (Map<Id, OpportunityTeamMember>)tp.newMap, (List<OpportunityTeamMember>) tp.oldList, (Map<Id, OpportunityTeamMember>) tp.oldMap);
    }

    private void process(List<OpportunityTeamMember> listNewObj, Map<Id, OpportunityTeamMember> mapNewObj, List<OpportunityTeamMember> listOldObj, Map<Id, OpportunityTeamMember> mapOldObj) {
        List<OpportunityTeamMember> listData = CIBE_OpprtTeamMemberTriggerHelper.checkGeneralRT(listOldObj);
        
        if(!listData.isEmpty() && listData != null) {
            CIBE_OpprtTeamMemberTriggerHelper.setOpportunityUsers(listData);
        }          
    }
}