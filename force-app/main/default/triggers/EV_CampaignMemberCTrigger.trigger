/**********************************************************************************************************************
 Name:   EV_CampaignMemberCTrigger
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Trigger del objeto EV_CampaignMemberC__c
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION     USER_STORY          AUTHOR              DATE                Description
	1.0			US584499			Mamen Arias			26/04/2023			Init Version.
***********************************************************************************************************************/
trigger EV_CampaignMemberCTrigger on EV_CampaignMemberC__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	CC_TriggerFactory.createTriggerDispatcher(EV_CampaignMemberC__c.sObjectType);
}