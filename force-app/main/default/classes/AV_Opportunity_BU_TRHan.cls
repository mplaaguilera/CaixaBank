/**********************************************************************************************************************
 Name:	  AV_Opportunity_BU_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Opportunity BeforeUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Esperanza Conde		21/09/2020			Init version
	1.1			OwnerId			Carolina Alonso		21/10/2020			Execute the method 'processOwnerEAPGestor' 
																		that regularizes the ownerIds
	2.0			US117506		Eric Vázquez		30/10/2020			Execute the method 'sendDataToGCF' for API Opportunity
	3.0			US117506		David Rufo			09/12/2020			Fix order methods and move 'sendDataToGCF' to AU
	3.1			App FSC			David Rufo			09/12/2020			Include a general check of the Record Types
	3.2			US147562		Sandra Gómez		14/01/2020			Added new method createOpportunityComentarios
	3.3			Bug				Sandra Gómez		29/01/2021			Include if hasCustomPermission
	3.4			US161442		Álvaro López		11/02/2021			Added new method fillClientProduct
	3.5			Fix Confiden...	Víctor Santiago		05/10/2021			Added method setConfidentiality
	3.6			Fix Performance	Carolina Alonso		21/10/2021			Include if has custom setting of Forbidden Words validation
	3.7			US312995		Carolina Alonso		07/02/2022			Include call method saveFieldsFromOpp only if the user does not have the PS AV_AvoidBulkApi
	3.9			US325412		Víctor Santiago		02/03/2022			Added checkStageName call
	4.0         USXXXXXX	    Daniel Rodríguez	10/03/2022          Add isBatch()
	4.1			US325412		Carolina Alonso		15/03/2022			Exclude the method checkStageName if the user has the PS AV_AvoidBulkApi
	4.2			US310766		Luis Fernandez		21/03/2022			Added updateFechaActivacion call
	4.3			US339508		Luis Fernandez		29/03/2022			Added updateCentro call
	4.4		 	DE63589	  		Sandra Gómez		01/09/2022		 	Add new method updateGCF
	4.5			US457715		Eduardo González	19/10/2022			Add new method updateSinGestor
	4.6			US498642		Vladislav Lityagin	19/01/2023			Include check of th Record Type Call Me and call changeOwner
	9.5		 	US411482	  	Vladislav Lityagin 	03/02/2023		 	Added call method assignPropensity
	9.6			DE70392			Sandra Gómez		08/02/2023			Add AV_AvoidBulkApi in method updateCentro
	9.7         DE80526         Elisabeth R.        14/08/2023          Added createTaskCallMe method
	9.8			Fix				Sandra Gómez		17/08/2023			Add method backReport
	9.9			US546892		Sandra Gómez		14/09/2023			Delete methods checkStageName, backReport and blockCloseDateUpdate and add methods byPassOpp and validationsOpportunity

***********************************************************************************************************************/
public class AV_Opportunity_BU_TRHan extends CC_TriggerHandlerBase {
	
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
			AV_OpportunityTriggerHelper.updateGCF(listData, mapOldObj);
			if (!hasCustomPermission && !System.isbatch()) {
				/* -- No borrar --
				if(AV_Bypass__c.getOrgDefaults().AV_ForbiddenWords__c){
					AV_OpportunityTriggerHelper.validateForbiddenWords(listData, mapOldObj);
				}*/
				AV_OpportunityTriggerHelper.saveFieldsFromOpp(listData, mapOldObj, true);
			}
			AV_OpportunityTriggerHelper.updateCloseDate(listData, mapOldObj);
            AV_OpportunityTriggerHelper.updateSinGestor(listData,mapOldObj);
			AV_OpportunityTriggerHelper.processOwnerEAPGestor(listData, mapOldObj);
			AV_OpportunityTriggerHelper.createOpportunityComentarios(listData, mapOldObj);
			AV_OpportunityTriggerHelper.opportunityValueNumeroDocumento(listData);
			AV_OpportunityTriggerHelper.fillClientProduct(listData);
			AV_OpportunityTriggerHelper.changeOwner(listData,mapOldObj);
			AV_OpportunityTriggerHelper.setConfidentiality(listData, false);
			AV_OpportunityTriggerHelper.emptyResolutionField(listData,mapOldObj);
			if (!hasCustomPermission) {	
				AV_OpportunityTriggerHelper.updateCentro(listData,mapOldObj);
			}
            AV_OpportunityTriggerHelper.updateStageName(listData,mapOldObj);
            AV_OpportunityTriggerHelper.assignPropensity(listData,mapOldObj);
			AV_OpportunityTriggerHelper.updateFechaActivacion(listData,mapOldObj);
		}
        if(listDataCM!=null && !listDataCM.isEmpty()){
			AV_OpportunityTriggerHelper.createTaskCallMe(listDataCM,mapOldObj);
        }
		if (listData!=null && !listData.isEmpty()) {
			if (!hasCustomPermission && !System.isbatch()) {
				AV_OpportunityTriggerHelper.validationsOpportunity(listData,mapOldObj);
				mapToByPass = AV_OpportunityTriggerHelper.byPassOpp(listData,mapOldObj);
			}
		}
	}
}