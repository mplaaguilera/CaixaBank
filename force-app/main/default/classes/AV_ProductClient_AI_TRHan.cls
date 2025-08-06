/**********************************************************************************************************************
 Name:	  AV_ProductClient_AI_TRHan
 Copyright © 2021  CaixaBank
------------------------------------------------
Proposito: Aux class for AV_ProductClient__c triggers after insert.
------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US161442		Álvaro López		15/02/2021			Initial version

***********************************************************************************************************************/
public with sharing class AV_ProductClient_AI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<AV_ProductClient__c>)tp.newList, (Map<Id, AV_ProductClient__c>)tp.newMap, (List<AV_ProductClient__c>) tp.oldList, (Map<Id, AV_ProductClient__c>) tp.oldMap);
	}
	
	private void process(List<AV_ProductClient__c> listNewObj, Map<Id, AV_ProductClient__c> mapNewObj, List<AV_ProductClient__c> listOldObj, Map<Id, AV_ProductClient__c> mapOldObj) {
        AV_ProductClientTriggerHelper.fillClientProduct(listNewObj);
    }
}