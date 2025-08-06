/*****************************************************************************************
 * Name: CIBE_OTeamMember_BD_TRHan
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Clase para Trigger de OpportunityTeamMember BeforeDelete funcionalidad para CIBE 
 * 
 * -------
 * VERSION        USER_STORY         AUTHOR           DATE            Description
 * 1.0            US615974           Ali              30/10/2023      Init Version
 * 
******************************************************************************************/
public class CIBE_OTeamMember_BD_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<OpportunityTeamMember>)tp.newList, (Map<Id, OpportunityTeamMember>)tp.newMap, (List<OpportunityTeamMember>) tp.oldList, (Map<Id, OpportunityTeamMember>) tp.oldMap);
    }

    private void process(List<OpportunityTeamMember> listNewObj, Map<Id, OpportunityTeamMember> mapNewObj, List<OpportunityTeamMember> listOldObj, Map<Id, OpportunityTeamMember> mapOldObj) {

        List<OpportunityTeamMember> listData = CIBE_OpprtTeamMemberTriggerHelper.checkGeneralRT(listOldObj);
        Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');

        if(!listData.isEmpty() && listData != null && ! hasCustomPermission) {
            CIBE_OpportunityEmail.emailDeleteOppTM(listData);
        }          
    }
}