/**********************************************************************************************************************
 Name:	  AV_LeadOpportunity_AI_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Lead Oportunidad After Insert.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	                            	AUTHOR		   			DATE				Description
	1.0			US378818 - Incorporar Tarea automática 	Vladislav Lityagin		14/10/2022			Added createTaskIfOfferIsSent
***********************************************************************************************************************/
public class AV_LeadOpportunity_AI_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<AV_LeadOpportunity__c>)tp.newList, (Map<Id, AV_LeadOpportunity__c>)tp.newMap);
	}
    
    private void process(List<AV_LeadOpportunity__c> listNewObj, Map<Id, AV_LeadOpportunity__c> mapNewObj) {
		List<AV_LeadOpportunity__c> listDataPPHH = AV_LeadOpportunityTriggerHelper.checkMortgagePlatformRT(listNewObj);        
        AV_LeadOpportunityTriggerHelper.createTaskIfOfferIsSent(null, listDataPPHH);
	}

}