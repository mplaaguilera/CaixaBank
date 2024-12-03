/**********************************************************************************************************************
 Name:	  AV_CustomActivityOpp_BI_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de AV_CustomActivityOpportunity__c BeforeInsert
-----------------------------------------------------------------------------------------------------------------------
Historial
--------------------------------------------------------
  VERSION		USER_STORY		AUTHOR				DATE				Description
  1.0     		App FSC			Álvaro López	  	13/10/2020			Init version
  2.0       	Check RT		Jashanpreet			09/12/2020			Improve common method to check RT + general RT

***********************************************************************************************************************/
public with sharing class AV_CustomActivityOpp_BI_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<AV_CustomActivityOpportunity__c>)tp.newList, (Map<Id, AV_CustomActivityOpportunity__c>)tp.newMap, (List<AV_CustomActivityOpportunity__c>) tp.oldList, (Map<Id, AV_CustomActivityOpportunity__c>) tp.oldMap);
    }
    
    private void process(List<AV_CustomActivityOpportunity__c> listNewObj, Map<Id, AV_CustomActivityOpportunity__c> mapNewObj, List<AV_CustomActivityOpportunity__c> listOldObj, Map<Id, AV_CustomActivityOpportunity__c> mapOldObj) {
      	//General check the Record type's for intouch project
      	List<AV_CustomActivityOpportunity__c> listData = AV_CustomActivityOppTriggerHelper.checkGeneralRT(listNewObj);
        if (listData!=null && !listData.isEmpty()){
      		AV_CustomActivityOppTriggerHelper.setFieldsFromOpp(listData);
          AV_CustomActivityOppTriggerHelper.fillChannelField(listData);

        }
    }
    
}