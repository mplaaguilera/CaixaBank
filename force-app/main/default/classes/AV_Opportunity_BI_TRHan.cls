/**********************************************************************************************************************
 Name:	  AV_Opportunity_BI_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Opportunity BeforeInsert
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Esperanza Conde		21/09/2020			Init version
	2.0			US117506		Eric Vázquez		30/10/2020			Execute the method 'sendDataToGCF' for API Opportunity
	3.0			US117506		Esperanza Conde		16/11/2020			Execute the method 'validatePF'
	3.1			US117506		David Rufo			09/12/2020			Fix order methods and move 'sendDataToGCF' to AI
	3.2			App FSC			David Rufo			09/12/2020			Include a general check of the Record Types
	3.3			US147562		Sandra Gómez		14/01/2020			Added new method createOpportunityComentarios
	3.4			Bug				Sandra Gómez		29/01/2021			Include if hasCustomPermission
	3.5			US161442		Álvaro López		11/02/2021			Added new method fillClientProduct
	3.6			Fix Confiden...	Víctor Santiago		05/10/2021			Added method setConfidentiality
	3.7			Fix Performance	Carolina Alonso		21/10/2021			Include if has custom setting of Forbidden Words validation
	3.8			US312995		Carolina Alonso		07/02/2022			Include call method saveFieldsFromOpp only if the user does not have the PS AV_AvoidBulkApi
	3.9         USXXXXXX	    Daniel Rodríguez	10/03/2022          Add isBatch()
	4.1			US325412		Carolina Alonso		15/03/2022			Exclude the method checkStageName if the user has the PS AV_AvoidBulkApi
	4.2			Bug				Alex Cubells		07/04/2022			The validatePF method inside Avoid Bulk permissions validation
	4.3			DE70392			Sandra Gómez		03/01/2023			Add AV_AvoidBulkApi in method updateCentro
	4.5		 	US411482	  	Vladislav Lityagin 	03/02/2023		 	Added call method assignPropensity
	2.6			US546892		Sandra Gómez		14/09/2023			Add methods byPassOpp and validationsOpportunity
***********************************************************************************************************************/
public class AV_Opportunity_BI_TRHan extends CC_TriggerHandlerBase {
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Opportunity>)tp.newList, (Map<Id, Opportunity>)tp.newMap, (List<Opportunity>) tp.oldList, (Map<Id, Opportunity>) tp.oldMap);
	}

	public void process(List<Opportunity> listNewObj, Map<Id, Opportunity> mapNewObj, List<Opportunity> listOldObj, Map<Id, Opportunity> mapOldObj) {
		//General check the Record type's for intouch project
		List<Opportunity> listData = AV_OpportunityTriggerHelper.checkGeneralRT(listNewObj);
        List<Opportunity> listDataCM = AV_OpportunityTriggerHelper.checkCallMeRT(listNewObj);
		Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
		// Lógica de negocio a ejecutar
		if (listData!=null && !listData.isEmpty()){
			if (!hasCustomPermission && !System.isbatch()) {
				/*-- No borrar --
				if(AV_Bypass__c.getOrgDefaults().AV_ForbiddenWords__c){
					AV_OpportunityTriggerHelper.validateForbiddenWords(listData, mapOldObj);
				}*/
				AV_OpportunityTriggerHelper.saveFieldsFromOpp(listData, mapOldObj, false);
				AV_OpportunityTriggerHelper.validatePF(listData);
			}
			AV_OpportunityTriggerHelper.updateCloseDate(listData, null);
			AV_OpportunityTriggerHelper.processOwnerEAPGestor(listData, mapOldObj);
			AV_OpportunityTriggerHelper.changeOwner(listData, mapOldObj);
			AV_OpportunityTriggerHelper.createOpportunityComentarios(listData, mapOldObj);
			AV_OpportunityTriggerHelper.opportunityValueNumeroDocumento(listData);
			AV_OpportunityTriggerHelper.fillClientProduct(listData);
			AV_OpportunityTriggerHelper.fillFieldsFromOpp(listData);
			AV_OpportunityTriggerHelper.setConfidentiality(listData, true);
            AV_OpportunityTriggerHelper.assignPropensity(listData, null);
			if (!hasCustomPermission) {
				AV_OpportunityTriggerHelper.updateCentro(listData,mapOldObj);
			}
		}
		if (listData!=null && !listData.isEmpty()) {
			if (!hasCustomPermission && !System.isbatch()) {
				AV_OpportunityTriggerHelper.validationsOpportunity(listData,null);
				mapToByPass = AV_OpportunityTriggerHelper.byPassOpp(listData,null);
			}
		}
	}
}