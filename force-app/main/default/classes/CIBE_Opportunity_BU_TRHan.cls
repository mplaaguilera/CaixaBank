/**********************************************************************************************************************
 Name:	  CIBE_Opportunity_BU_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Opportunity BeforeUpdate funcionalidad para CIBE 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Jose Maria 			07/06/2022			Init version
	2.0			US717936			Bea					07/12/2023			Added the call to method of updateStageName
	
***********************************************************************************************************************/
public class CIBE_Opportunity_BU_TRHan extends CC_TriggerHandlerBase {
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Opportunity>)tp.newList, (Map<Id, Opportunity>)tp.newMap, (List<Opportunity>) tp.oldList, (Map<Id, Opportunity>) tp.oldMap);
	}
	
	private void process(List<Opportunity> listNewObj, Map<Id, Opportunity> mapNewObj, List<Opportunity> listOldObj, Map<Id, Opportunity> mapOldObj) {
		//General check the Record type's for intouch project
        List<Opportunity> listData = CIBE_OpportunityTriggerHelper.checkGeneralRT(listNewObj);
        
        if (listData!=null && !listData.isEmpty()){
			Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
			if (!hasCustomPermission && !System.isbatch()) {
				// if(AV_Bypass__c.getOrgDefaults().AV_ForbiddenWords__c){
				// 	CIBE_OpportunityTriggerHelper.validateForbiddenWords(listData, mapOldObj);
				// }
				CIBE_OpportunityTriggerHelper.saveFieldsFromOpp(listData, mapOldObj, true);

			}
			
			CIBE_OpportunityTriggerHelper.calculateCurrency(listData, mapOldObj);
			CIBE_OpportunityTriggerHelper.fillFieldsFromOpp(listData, mapOldObj);
			CIBE_OpportunityTriggerHelper.retrieveComercialGroup(listData, mapOldObj);
            CIBE_OpportunityTriggerHelper.asignAltaValues(listData, mapOldObj);
			CIBE_OpportunityTriggerHelper.processOwnerEAPGestor(listData, mapOldObj);
			CIBE_OpportunityTriggerHelper.updateGCF(listData, mapOldObj);
			CIBE_OpportunityTriggerHelper.createOpportunityComentarios(listData, mapOldObj);
			CIBE_OpportunityTriggerHelper.opportunityValueNumeroDocumento(listData);
			CIBE_OpportunityTriggerHelper.fillClientProduct(listData);			
			CIBE_OpportunityTriggerHelper.changeOwner(listData,mapOldObj);
			//CIBE_OpportunityTriggerHelper.checkUserFields(listData, mapOldObj);
			CIBE_OpportunityTriggerHelper.setConfidentiality(listData);
			CIBE_OpportunityTriggerHelper.updateFechaActivacion(listData,mapOldObj);
			CIBE_OpportunityTriggerHelper.updateCentro(listData,mapOldObj);
			CIBE_OpportunityTriggerHelper.checkCloseDate(listData,mapOldObj);
			CIBE_OpportunityTriggerHelper.stateOpportunity(listData,mapOldObj);
			CIBE_OpportunityTriggerHelper.updateStageName(listData,mapOldObj);
            CIBE_OpportunityTriggerHelper.insertOppTM(listData, mapOldObj);
        }
	}
}