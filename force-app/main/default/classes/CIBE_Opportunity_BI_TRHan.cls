/**********************************************************************************************************************
 Name:	  CIBE_Opportunity_BD_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Opportunity BeforeInsert funcionalidad para CIBE 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Jose Maria 			07/06/2022			Init version
	2.0			US523654			Lucía Muñoz 		07/02/2023			Add newAtributtesOpp method
	3.0        	IT     				Lucía Muñoz         11/07/2023			Eliminar la llamada al metodo newAtributtesOpp


***********************************************************************************************************************/
public class CIBE_Opportunity_BI_TRHan extends CC_TriggerHandlerBase {
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Opportunity>)tp.newList, (Map<Id, Opportunity>)tp.newMap, (List<Opportunity>) tp.oldList, (Map<Id, Opportunity>) tp.oldMap);
	}
	
	private void process(List<Opportunity> listNewObj, Map<Id, Opportunity> mapNewObj, List<Opportunity> listOldObj, Map<Id, Opportunity> mapOldObj) {
		//General check the Record type's for intouch project
        List<Opportunity> listData = CIBE_OpportunityTriggerHelper.checkGeneralRT(listNewObj);
        
        if (listData!=null && !listData.isEmpty()){
			Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
			/*if (!hasCustomPermission && !System.isbatch()) {
				if(AV_Bypass__c.getOrgDefaults().AV_ForbiddenWords__c){
					CIBE_OpportunityTriggerHelper.validateForbiddenWords(listData, mapOldObj);
				}
			}*/
			
			CIBE_OpportunityTriggerHelper.calculateCurrency(listData, mapOldObj);
			CIBE_OpportunityTriggerHelper.fillFieldsFromOpp(listData, mapOldObj);
			CIBE_OpportunityTriggerHelper.saveFieldsFromOpp(listData, mapOldObj, false);
			CIBE_OpportunityTriggerHelper.retrieveComercialGroup(listData, mapOldObj);
			CIBE_OpportunityTriggerHelper.processOwnerEAPGestor(listData, mapOldObj);
			CIBE_OpportunityTriggerHelper.changeOwner(listData, mapOldObj);
			CIBE_OpportunityTriggerHelper.createOpportunityComentarios(listData, mapOldObj);
			CIBE_OpportunityTriggerHelper.opportunityValueNumeroDocumento(listData);
			CIBE_OpportunityTriggerHelper.fillClientProduct(listData);
			CIBE_OpportunityTriggerHelper.setConfidentiality(listData);
			CIBE_OpportunityTriggerHelper.updateCentro(listData, mapOldObj);
        }
	}
}