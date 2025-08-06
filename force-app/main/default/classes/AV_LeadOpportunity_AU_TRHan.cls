/**********************************************************************************************************************
 Name:	  AV_LeadOpportunity_BU_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Lead Oportunidad Before Update.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	                            	AUTHOR		   			DATE				Description
	1.0			US-371544 Estados Lead y LeadOpp	    Vladislav Lityagin	   	02/03/2023		    	Init version
***********************************************************************************************************************/
public class AV_LeadOpportunity_AU_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<AV_LeadOpportunity__c>)tp.newList, (Map<Id, AV_LeadOpportunity__c>)tp.newMap, (List<AV_LeadOpportunity__c>) tp.oldList, (Map<Id, AV_LeadOpportunity__c>) tp.oldMap);
	}
    
    private void process(List<AV_LeadOpportunity__c> listNewObj, Map<Id, AV_LeadOpportunity__c> mapNewObj, List<AV_LeadOpportunity__c> listOldObj, Map<Id, AV_LeadOpportunity__c> mapOldObj) {
		List<AV_LeadOpportunity__c> listDataPPHH = AV_LeadOpportunityTriggerHelper.checkMortgagePlatformRT(listNewObj);

        AV_LeadOpportunityTriggerHelper.createTaskIfOfferIsSent(mapOldObj, listDataPPHH);
	}
}