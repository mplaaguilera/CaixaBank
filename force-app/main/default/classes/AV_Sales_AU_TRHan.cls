/**********************************************************************************************************************
 Name:	  AV_Sales_AU_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Venta AfterUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US132474			Eric Vázquez		16/11/2020			Init version
	1.1			App FSC				David Rufo			09/12/2020			Include a general check of the Record Types
    1.2         US246855            Sandra Gómez		31/01/2022			Add method changeTypeSales
    1.3         Fix                 Sandra Gómez        19/01/2023          Add Custom Setting AV_SalesOld__c

***********************************************************************************************************************/
public with sharing class AV_Sales_AU_TRHan extends CC_TriggerHandlerBase{
    
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<AV_Sales__c>)tp.newList, (Map<Id, AV_Sales__c>)tp.newMap, (List<AV_Sales__c>) tp.oldList, (Map<Id, AV_Sales__c>) tp.oldMap);
    }
    
    private void process(List<AV_Sales__c> listNewObj, Map<Id, AV_Sales__c> mapNewObj, List<AV_Sales__c> listOldObj, Map<Id, AV_Sales__c> mapOldObj) {
        //General check the Record type's for intouch project
        List<AV_Sales__c> listData = AV_SalesTriggerHelper.checkGeneralRT(listNewObj);
        
        if (listData!=null && !listData.isEmpty()){
            if (AV_Bypass__c.getOrgDefaults().AV_SalesOld__c) {
                AV_SalesTriggerHelper.changeTypeSalesOld(listData,mapOldObj);
            }else {
                AV_SalesTriggerHelper.changeTypeSales(listData,mapOldObj);
            }
        }
    }
}