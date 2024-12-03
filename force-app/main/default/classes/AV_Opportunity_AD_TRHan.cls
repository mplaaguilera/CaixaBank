/**********************************************************************************************************************
 Name:	  AV_Opportunity_AD_TRHan
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para triger de opportunity after delete
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Luis Fernández	    27/12/2023			Init version
    1.1			DT08			Luis Fernández		23/04/2024			Added calculateScoreOpp called from AV_OpportunityTriggerHelperAux

***********************************************************************************************************************/
public with sharing class AV_Opportunity_AD_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Opportunity>)tp.newList, (Map<Id, Opportunity>)tp.newMap, (List<Opportunity>)tp.oldList, (Map<Id, Opportunity>)tp.oldMap);
    }
    private void process(List<Opportunity> listNewObj, Map<Id, Opportunity> mapNewObj, List<Opportunity> listOldObj, Map<Id, Opportunity> mapOldObj) {
        List<Opportunity> listData = AV_OpportunityTriggerHelper.checkGeneralRT(listOldObj);        
        AV_OpportunityTriggerHelperAux.calculateScoreOpp(null,null,listData,'AD');
    }
}