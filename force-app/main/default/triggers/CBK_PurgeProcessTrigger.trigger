/**********************************************************************************************************************
 Name:	  CBK_PurgeProcessTrigger
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Trigger de objeto CBK_PurgeProcess__c
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	25/11/2021			Init version
***********************************************************************************************************************/
trigger CBK_PurgeProcessTrigger on CBK_PurgeProcess__c (before delete, after insert, after update) {
    CC_TriggerFactory.createTriggerDispatcher(CBK_PurgeProcess__c.sObjectType);
}