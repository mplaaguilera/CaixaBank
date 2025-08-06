/**********************************************************************************************************************
 Name:	  EV_CampaignMemberC_AD_TRHan
 Copyright © 2024  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de CampaignMember AfterDelete
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		  	CStatistics			Mamen Arias			13/04/2024			Init version
***********************************************************************************************************************/
public with sharing class EV_CampaignMemberC_AD_TRHan extends CC_TriggerHandlerBase {
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<EV_CampaignMemberC__c>)tp.newList, (Map<Id, EV_CampaignMemberC__c>)tp.newMap, (List<EV_CampaignMemberC__c>)tp.oldList, (Map<Id, EV_CampaignMemberC__c>)tp.oldMap);
	}

	private void process(List<EV_CampaignMemberC__c> listNewObj, Map<Id, EV_CampaignMemberC__c> mapNewObj, List<EV_CampaignMemberC__c> listOldObj, Map<Id, EV_CampaignMemberC__c> mapOldObj) {
		EV_LogDebug.printLogDebug('EV_CampaignMemberC_AD_TRHan ', String.valueof(listOldObj));
		EV_CampaignMemberCTriggerHelper.updateRollupLeadsContacts(null,mapOldObj);
		EV_CampaignMemberCTriggerHelper.updateRollup(null,mapOldObj);
	}
}