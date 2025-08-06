/**********************************************************************************************************************
 Name:	  CIBE_CustomActivityOpp_AI_TRHan
 Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de AV_CustomActivityOpportunity__c AfterInsert
-----------------------------------------------------------------------------------------------------------------------
Historial
--------------------------------------------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0     	App FSC		    Luis Martínez	  	13/06/2024			Init version 

***********************************************************************************************************************/
public with sharing class CIBE_CustomActivityOpp_AI_TRHan extends CC_TriggerHandlerBase  {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<AV_CustomActivityOpportunity__c>)tp.newList, (Map<Id, AV_CustomActivityOpportunity__c>)tp.newMap, (List<AV_CustomActivityOpportunity__c>) tp.oldList, (Map<Id, AV_CustomActivityOpportunity__c>) tp.oldMap);
    }
    
    private void process(List<AV_CustomActivityOpportunity__c> listNewObj, Map<Id, AV_CustomActivityOpportunity__c> mapNewObj, List<AV_CustomActivityOpportunity__c> listOldObj, Map<Id, AV_CustomActivityOpportunity__c> mapOldObj) {
        if(listNewObj != null && !listNewObj.isEmpty()){
			CIBE_CustomActivityOppTriggerHelper.updateCommentsHistoryVinculated(listNewObj,mapOldObj);
		}
	}
	
}