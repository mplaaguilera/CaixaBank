/**********************************************************************************************************************
 Name:	  EV_CampaignMemberC_BD_TRHan
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de CampaignMember BeforeDelete
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0         US584499            Mamen Arias         20/04/2023          Init Version.
***********************************************************************************************************************/
public with sharing class EV_CampaignMemberC_BD_TRHan extends CC_TriggerHandlerBase {
	static Map<Id, String> mapNameForLeads = new Map<Id, String>();
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<EV_CampaignMemberC__c>)tp.newList, (Map<Id, EV_CampaignMemberC__c>)tp.newMap, (List<EV_CampaignMemberC__c>)tp.oldList, (Map<Id, EV_CampaignMemberC__c>)tp.oldMap);
	}
	
	private void process(List<EV_CampaignMemberC__c> listNewObj, Map<Id, EV_CampaignMemberC__c> mapNewObj, List<EV_CampaignMemberC__c> listOldObj, Map<Id, EV_CampaignMemberC__c> mapOldObj) {
		EV_LogDebug.printLogDebug('EV_CampaignMemberC_BD_TRHan ',String.valueof(listNewObj) + ' '+ String.valueof(mapOldObj));
		for(EV_CampaignMemberC__c member : [SELECT Id, EV_LeadId__c, EV_LeadId__r.Name FROM EV_CampaignMemberC__c WHERE Id IN :listOldObj]) {
			mapNameForLeads.put(member.EV_LeadId__c, member.EV_LeadId__r.Name);
		}
		EV_CampaignMemberCTriggerHelper.crearHistoricoDelete(listOldObj, mapNameForLeads);
	}
}