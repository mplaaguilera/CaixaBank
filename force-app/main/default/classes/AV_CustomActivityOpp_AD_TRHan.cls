/**********************************************************************************************************************
 Name:	  AV_CustomActivityOpp_AD_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de CustomActivityOpportunity AfterDelete
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		  	AUTHOR				DATE				Description
	1.0			US286825			Daniel Rodríguez	07/01/2022			Init version
    1.1         USXXXXXX	        Daniel Rodríguez	09/03/2022          Add isBatch()

***********************************************************************************************************************/
public class AV_CustomActivityOpp_AD_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<AV_CustomActivityOpportunity__c>)tp.newList, (Map<Id, AV_CustomActivityOpportunity__c>)tp.newMap, (List<AV_CustomActivityOpportunity__c>)tp.oldList, (Map<Id, AV_CustomActivityOpportunity__c>)tp.oldMap);
	}

    private void process(List<AV_CustomActivityOpportunity__c> listNewObj, Map<Id, AV_CustomActivityOpportunity__c> mapNewObj, List<AV_CustomActivityOpportunity__c> listOldObj, Map<Id, AV_CustomActivityOpportunity__c> mapOldObj) {
        //General check the Record type's for intouch project
        List<AV_CustomActivityOpportunity__c> listData = AV_CustomActivityOppTriggerHelper.checkGeneralRT(listOldObj);
        // Lógica de negocio a ejecutar
        if (listData!=null && !listData.isEmpty()){
            Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
            if (!hasCustomPermission && !System.isbatch()){
            	AV_CustomActivityOppTriggerHelper.updateNextManagementDateOpp(listData);
            }
        }
	}
    
}