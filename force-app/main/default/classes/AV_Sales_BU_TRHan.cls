/**********************************************************************************************************************
 Name:	  AV_Sales_BU_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de AV_Sales__c BeforeUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US373676		Víctor Santiago	    26/05/2022			Init version
	1.1			Fix				Sandra Gómez		28/02/2024			delete updateProductoPFField and add productoPFField
***********************************************************************************************************************/
public class AV_Sales_BU_TRHan extends CC_TriggerHandlerBase{
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<AV_Sales__c>)tp.newList, (Map<Id, AV_Sales__c>)tp.newMap, (List<AV_Sales__c>) tp.oldList, (Map<Id, AV_Sales__c>) tp.oldMap);
	}
	
	private void process(List<AV_Sales__c> listNewObj, Map<Id, AV_Sales__c> mapNewObj, List<AV_Sales__c> listOldObj, Map<Id, AV_Sales__c> mapOldObj) {
		//General check the Record type's for intouch project
		List<AV_Sales__c> listData = AV_SalesTriggerHelper.checkGeneralRT(listNewObj);
        
		if (listData!=null && !listData.isEmpty()){
			AV_SalesTriggerHelper.setCancellation(listData, mapOldObj);
			AV_SalesTriggerHelper.productoPFField(listData);
		}
	}
}