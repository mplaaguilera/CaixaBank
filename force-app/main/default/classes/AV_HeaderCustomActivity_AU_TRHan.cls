/**********************************************************************************************************************
 Name:	  AV_HeaderCustomActivity_AU_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de AV_HeaderCustomActivity__c AfterUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				    DATE				Description
  	1.0			App FSC			Jashanpreet	   		    02/06/2021			Init version

***********************************************************************************************************************/
public with sharing class AV_HeaderCustomActivity_AU_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
		  process((List<AV_HeaderCustomActivity__c>)tp.newList, (Map<Id, AV_HeaderCustomActivity__c>)tp.newMap, (List<AV_HeaderCustomActivity__c>) tp.oldList, (Map<Id, AV_HeaderCustomActivity__c>) tp.oldMap);
    }
    
    private void process(List<AV_HeaderCustomActivity__c> listNewObj, Map<Id, AV_HeaderCustomActivity__c> mapNewObj, List<AV_HeaderCustomActivity__c> listOldObj, Map<Id, AV_HeaderCustomActivity__c> mapOldObj) {
    	//General check the Record type's for intouch project
      	List<AV_HeaderCustomActivity__c> listData = AV_HeaderCustomActivityTriggerHelper.checkGeneralRT(listNewObj);
        if (listData!=null && !listData.isEmpty()){
            //AV_HeaderCustomActivityTriggerHelper.syncEvents(listData, mapOldObj);
        }
    }
    
}