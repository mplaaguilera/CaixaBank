/**********************************************************************************************************************
 Name:   EV_CampaignMember_BD_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Before Delete sobre el objeto Campaign Member
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION     USER_STORY          AUTHOR                  DATE                Description
	1.0         US764367            Carolina Lopez          22/11/2023          remove old logic and add methods validateBankTeller, crearHistoricoDelete.
***********************************************************************************************************************/
public class EV_CampaignMember_BD_TRHan extends CC_TriggerHandlerBase {
        
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CampaignMember>)tp.newList, (Map<Id, CampaignMember>)tp.newMap, (List<CampaignMember>)tp.oldList, (Map<Id, CampaignMember>)tp.oldMap);
    }

    private void process(List<CampaignMember> listNewObj, Map<Id, CampaignMember> mapNewObj, List<CampaignMember> listOldObj, Map<Id, CampaignMember> mapOldObj) {
		if (listOldObj!=null && !listOldObj.isEmpty()) {

			EV_CampaignMemberTriggerHelper.crearHistoricoDelete(listOldObj);

            if(FeatureManagement.checkPermission('AV_BankTeller_Custom')) {
                EV_CampaignMemberTriggerHelper.validateBankTeller(listOldObj);
            }
		}
	}   
}