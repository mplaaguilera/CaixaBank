/**********************************************************************************************************************
 Name:	  AV_CampaignMember_BD_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Before delete sobre el objeto CampaignMember
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			App FSC            	Sandra Gómez		30/03/2022			Init version

***********************************************************************************************************************/
public class AV_CampaignMember_BD_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CampaignMember>)tp.newList, (Map<Id, CampaignMember>)tp.newMap, (List<CampaignMember>)tp.oldList, (Map<Id, CampaignMember>)tp.oldMap);
	}
	
	private void process(List<CampaignMember> listNewObj, Map<Id, CampaignMember> mapNewObj, List<CampaignMember> listOldObj, Map<Id, CampaignMember> mapOldObj) {
		if (listOldObj!=null && !listOldObj.isEmpty()) {
			AV_CampaignMemberTriggerHelper.validateBankTeller(listOldObj);
		}
	}  
}