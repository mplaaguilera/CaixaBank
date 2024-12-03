/**********************************************************************************************************************
 Name:	  AV_CustomActivityOpp_AI_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de AV_CustomActivityOpportunity__c AfterInsert
-----------------------------------------------------------------------------------------------------------------------
Historial
--------------------------------------------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0     		App FSC			Rubén Izquierdo	  	22/03/2021			Init version
	1.1           US286825 		Daniel Rodríguez	10/01/2022			Add method updateNextManagementDateOpp
	1.2			US286825 		Daniel Rodríguez	13/01/2022			Add Method updateNextManagementDateOpp

***********************************************************************************************************************/
public with sharing class AV_CustomActivityOpp_AI_TRHan extends CC_TriggerHandlerBase {
	public override void mainEntry(CC_TriggerParameters tp) {
	process((List<AV_CustomActivityOpportunity__c>)tp.newList, (Map<Id, AV_CustomActivityOpportunity__c>)tp.newMap, (List<AV_CustomActivityOpportunity__c>) tp.oldList, (Map<Id, AV_CustomActivityOpportunity__c>) tp.oldMap);
	}	
	private void process(List<AV_CustomActivityOpportunity__c> listNewObj, Map<Id, AV_CustomActivityOpportunity__c> mapNewObj, List<AV_CustomActivityOpportunity__c> listOldObj, Map<Id, AV_CustomActivityOpportunity__c> mapOldObj) {
		List<AV_CustomActivityOpportunity__c> listData = AV_CustomActivityOppTriggerHelper.checkGeneralRT(listNewObj);
		if (listData!=null && !listData.isEmpty()){
			//AV_CustomActivityOppTriggerHelper.setActOppFields(listData); REVISAR FUNCIONALIDAD
			Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
			if (!hasCustomPermission) {
				AV_CustomActivityOppTriggerHelper.updateNextManagementDateOpp(listData);
			}
			//AV_CustomActivityOppTriggerHelper.setFieldsFromOpp(listData);
		}
	}
}