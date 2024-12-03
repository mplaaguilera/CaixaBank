/**********************************************************************************************************************
 Name:	  EV_CampaignMemberC_BI_TRHan
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de CampaignMember BeforeInsert
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0			US584499			Mamen Arias			20/04/2023			Init Version
***********************************************************************************************************************/
public with sharing class EV_CampaignMemberC_BI_TRHan extends CC_TriggerHandlerBase {
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<EV_CampaignMemberC__c>)tp.newList, (Map<Id, EV_CampaignMemberC__c>)tp.newMap, (List<EV_CampaignMemberC__c>)tp.oldList, (Map<Id, EV_CampaignMemberC__c>)tp.oldMap);
	}
	
	private void process(List<EV_CampaignMemberC__c> listNewObj, Map<Id, EV_CampaignMemberC__c> mapNewObj, List<EV_CampaignMemberC__c> listOldObj, Map<Id, EV_CampaignMemberC__c> mapOldObj) {
		EV_LogDebug.printLogDebug('EV_CampaignMemberC_BI_TRHan ',String.valueof(listNewObj) + ' '+ String.valueof(mapOldObj));
		EV_CampaignMemberCTriggerHelper.generarIdSeguro(listNewObj);
		EV_CampaignMemberCTriggerHelper.fillNameFromCampaignMember(listNewObj);
		EV_CampaignMemberCTriggerHelper.rtCampaignMember(listNewObj);				
		EV_CampaignMemberCTriggerHelper.memberCampaignWithoutAccount(listNewObj);
		EV_CampaignMemberCTriggerHelper.eventSurvey(listNewObj,mapOldObj, true);
		EV_CampaignMemberCTriggerHelper.fillFormatoAsistenciaByRT(listNewObj);
		EV_CampaignMemberCTriggerHelper.linkUniqueSurveyGeneration(listNewObj, mapOldObj);
	}
}