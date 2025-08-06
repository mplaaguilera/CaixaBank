/**********************************************************************************************************************
 Name:	  AV_NotifyMe_BU_TRHan
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase para Trigger de NotifyMe BeforeUpdate
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Esperanza Conde	   	14/12/2020			Init version

***********************************************************************************************************************/
public class AV_NotifyMe_BU_TRHan extends CC_TriggerHandlerBase{
	
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<AV_NotifyMe__c>)tp.newList, (Map<Id, AV_NotifyMe__c>)tp.newMap, (List<AV_NotifyMe__c>) tp.oldList, (Map<Id, AV_NotifyMe__c>) tp.oldMap);
	}
	
	private void process(List<AV_NotifyMe__c> listNewObj, Map<Id, AV_NotifyMe__c> mapNewObj, List<AV_NotifyMe__c> listOldObj, Map<Id, AV_NotifyMe__c> mapOldObj) {
		//General check the Record type's for intouch project
        List<AV_NotifyMe__c> listData = AV_NotifyMeTriggerHelper.checkGeneralRT(listNewObj);
        
        if (listData!=null && !listData.isEmpty()){
            AV_NotifyMeTriggerHelper.processOwner(listData, mapOldObj);
        }
	}
}