/**********************************************************************************************************************
 Name:	  AV_CustomActivityOpp_AU_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de AV_CustomActivityOpportunity__c AfterUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				    DATE				Description
  	1.0			App FSC			Esperanza Conde	   		13/10/2020			Init version
  	2.0       	Check RT		Jashanpreet			    09/12/2020			Improve common method to check RT + general RT
  	2.1       	Bug				Sandra Gómez		    04/02/2021			Include if hasCustomPermission
    2.2         USXXXXXX	    Daniel Rodríguez	    10/03/2022          Add isBatch()

***********************************************************************************************************************/
public with sharing class AV_CustomActivityOpp_AU_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
		  process((List<AV_CustomActivityOpportunity__c>)tp.newList, (Map<Id, AV_CustomActivityOpportunity__c>)tp.newMap, (List<AV_CustomActivityOpportunity__c>) tp.oldList, (Map<Id, AV_CustomActivityOpportunity__c>) tp.oldMap);
    }
    
    private void process(List<AV_CustomActivityOpportunity__c> listNewObj, Map<Id, AV_CustomActivityOpportunity__c> mapNewObj, List<AV_CustomActivityOpportunity__c> listOldObj, Map<Id, AV_CustomActivityOpportunity__c> mapOldObj) {
    	//General check the Record type's for intouch project
      	List<AV_CustomActivityOpportunity__c> listData = AV_CustomActivityOppTriggerHelper.checkGeneralRT(listNewObj);
        if (listData!=null && !listData.isEmpty()){
            Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
            if (!hasCustomPermission && !System.isbatch()) {
                AV_CustomActivityOppTriggerHelper.setFieldsToOpp(listData, mapOldObj);
            }
            //AV_CustomActivityOppTriggerHelper.setActOppFields(listData); REVISAR FUNCIONALIDAD
        }
    }
    
}