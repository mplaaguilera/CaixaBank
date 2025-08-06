/**********************************************************************************************************************
 Name:	  EV_CampaignMember_BI_TRHan
 Copyright © 2020  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Campaign BeforeInsert
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
    1.0                           Daniel Rodriguez      31/01/2023          Remove method generarIdSeguro to EV_CampaignMemberTriggerHelper.Modify method memberCampaignWithoutAccount.

***********************************************************************************************************************/

public class EV_CampaignMember_BI_TRHan extends CC_TriggerHandlerBase {
	
	//static Map<Id, CampaignMember> mapLeadById = new Map<Id, CampaignMember>();
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CampaignMember>)tp.newList, (Map<Id, CampaignMember>)tp.newMap, (List<CampaignMember>)tp.oldList, (Map<Id, CampaignMember>)tp.oldMap);
	}
	
	private void process(List<CampaignMember> listNewObj, Map<Id, CampaignMember> mapNewObj, List<CampaignMember> listOldObj, Map<Id, CampaignMember> mapOldObj) {
		EV_LogDebug.printLogDebug('EV_CampaignMember_BI_TRHan ',String.valueof(listNewObj) + ' '+ String.valueof(mapOldObj));
		EV_CampaignMemberTriggerHelper.generarIdSeguro(listNewObj);
		EV_CampaignMemberTriggerHelper.fillNameFromCampaignMember(listNewObj);		
		EV_CampaignMemberTriggerHelper.memberCampaignWithoutAccount(listNewObj);
		EV_CampaignMemberTriggerHelper.eventSurvey(listNewObj,mapOldObj, true);
		EV_CampaignMemberTriggerHelper.fillFormatoAsistenciaByRT(listNewObj);
		EV_CampaignMemberTriggerHelper.linkUniqueSurveyGeneration(listNewObj, mapOldObj);

	}
	

}