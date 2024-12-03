/**********************************************************************************************************************
 Name:	  EV_CampaignMemberC_BU_TRHan
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de CampaignMember BeforeUpdate
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0         US584499            Mamen Arias         20/04/2023          Init Version
	1.1			US586998			Daniel Rodriguez	07/06/2023			Commented method actualizarContadorCheckInVirtual
***********************************************************************************************************************/
public with sharing class EV_CampaignMemberC_BU_TRHan extends CC_TriggerHandlerBase {
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<EV_CampaignMemberC__c>)tp.newList, (Map<Id, EV_CampaignMemberC__c>)tp.newMap, (List<EV_CampaignMemberC__c>)tp.oldList, (Map<Id, EV_CampaignMemberC__c>)tp.oldMap);
	}
	
	private void process(List<EV_CampaignMemberC__c> listNewObj, Map<Id, EV_CampaignMemberC__c> mapNewObj, List<EV_CampaignMemberC__c> listOldObj, Map<Id, EV_CampaignMemberC__c> mapOldObj) {
		EV_LogDebug.printLogDebug('EV_CampaignMemberC_BU_TRHan ',String.valueof(listNewObj) + ' '+ String.valueof(mapOldObj));
		EV_CampaignMemberCTriggerHelper.actualizarContadorCheckInVirtual(listNewObj,mapOldObj, false);
		EV_CampaignMemberCTriggerHelper.processCampaignMemberForQR(listNewObj, mapOldObj);
		EV_CampaignMemberCTriggerHelper.fillNameFromCampaignMember(listNewObj);
		EV_CampaignMemberCTriggerHelper.eventSurvey(listNewObj, mapOldObj, false);
		EV_CampaignMemberCTriggerHelper.linkUniqueSurveyGeneration(listNewObj, mapOldObj);
	}
}