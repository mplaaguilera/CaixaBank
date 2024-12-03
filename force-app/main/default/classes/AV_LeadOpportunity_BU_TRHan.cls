/**********************************************************************************************************************
 Name:	  AV_LeadOpportunity_BU_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Lead Oportunidad Before Update.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	                            	AUTHOR		   			DATE				Description
	1.0			US-371544 Estados Lead y LeadOpp	    Vladislav Lityagin	   	11/05/2022		    	Init version
	1.1         US449777								Carolina Alonso			06/10/2022				Add control to check forbidden words
	1.2			US378818 - Incorporar Tarea automática	Vladislav Lityagin		14/10/2022				Add createTaskIfOfferIsSent
***********************************************************************************************************************/
public class AV_LeadOpportunity_BU_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<AV_LeadOpportunity__c>)tp.newList, (Map<Id, AV_LeadOpportunity__c>)tp.newMap, (List<AV_LeadOpportunity__c>) tp.oldList, (Map<Id, AV_LeadOpportunity__c>) tp.oldMap);
	}
    
    private void process(List<AV_LeadOpportunity__c> listNewObj, Map<Id, AV_LeadOpportunity__c> mapNewObj, List<AV_LeadOpportunity__c> listOldObj, Map<Id, AV_LeadOpportunity__c> mapOldObj) {
        Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
		List<AV_LeadOpportunity__c> listDataPPHH = AV_LeadOpportunityTriggerHelper.checkMortgagePlatformRT(listNewObj);

		/*if (!hasCustomPermission && !System.isbatch()) {
			if(AV_Bypass__c.getOrgDefaults().AV_ForbiddenWords__c){
				AV_LeadOpportunityTriggerHelper.validateForbiddenWords(listNewObj, mapOldObj);
			}
        }*/
        AV_LeadOpportunityTriggerHelper.updateLeadOppStatus(listDataPPHH, mapOldObj);
        AV_LeadOpportunityTriggerHelper.checkLeadOppStage(mapOldObj, listDataPPHH);
        AV_LeadOpportunityTriggerHelper.updateLeadsOrigin(listDataPPHH, mapOldObj);
        //AV_LeadOpportunityTriggerHelper.createTaskIfOfferIsSent(mapOldObj, listDataPPHH);
        
	}
}