/**********************************************************************************************************************
 Name:	  AV_Sales_BI_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de AV_Sales__c BeforeInsert
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US744932		Oscar Moreno		16/11/2023		Init version. Add productoPFField method
***********************************************************************************************************************/


public class AV_Sales_BI_TRHan  extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<AV_Sales__c>)tp.newList, (Map<Id, AV_Sales__c>)tp.newMap, (List<AV_Sales__c>) tp.oldList, (Map<Id, AV_Sales__c>) tp.oldMap);
    }

    public void process(List<AV_Sales__c> listNewObj, Map<Id, AV_Sales__c> mapNewObj, List<AV_Sales__c> listOldObj, Map<Id, AV_Sales__c> mapOldObj) { 
		//General check the Record type's for intouch project
		List<AV_Sales__c> listData = AV_SalesTriggerHelper.checkGeneralRT(listNewObj);
		if (listData!=null && !listData.isEmpty()){
            AV_SalesTriggerHelper.productoPFField(listData);
			
		}
	}

}