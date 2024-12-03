/**********************************************************************************************************************
 Name:	  AV_LeadOpportunity_BI_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Lead Oportunidad Before Insert.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	                            	AUTHOR		   			DATE				Description
	1.0			US-371544 Estados Lead y LeadOpp	    Vladislav Lityagin	   	11//2022		    	Init version
	1.1         US449777								Carolina Alonso			06/10/2022				Add control to check forbidden words								
***********************************************************************************************************************/
public class AV_LeadOpportunity_BI_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<AV_LeadOpportunity__c>)tp.newList, (Map<Id, AV_LeadOpportunity__c>)tp.newMap);
	}
    
    private void process(List<AV_LeadOpportunity__c> listNewObj, Map<Id, AV_LeadOpportunity__c> mapNewObj) {
        Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
		List<AV_LeadOpportunity__c> listDataPPHH = AV_LeadOpportunityTriggerHelper.checkMortgagePlatformRT(listNewObj);        
		/*if (!hasCustomPermission && !System.isbatch()) {
			if(AV_Bypass__c.getOrgDefaults().AV_ForbiddenWords__c){
				AV_LeadOpportunityTriggerHelper.validateForbiddenWords(listNewObj, mapNewObj);
			}
        }*/
		
        AV_LeadOpportunityTriggerHelper.updateLeadOppStatus(listDataPPHH);
        AV_LeadOpportunityTriggerHelper.updateLeadsOrigin(listDataPPHH, null);
        AV_LeadOpportunityTriggerHelper.updateLeadOppDueDate(listDataPPHH);
		AV_LeadOpportunityTriggerHelper.changeProduct(listDataPPHH);
 	}

}