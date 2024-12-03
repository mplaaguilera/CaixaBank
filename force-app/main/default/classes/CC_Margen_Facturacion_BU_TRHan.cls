/**
 * @description       : 
 * @author            : Adrian Mariscal
 * @group             : 
 * @last modified on  : 07-01-2022
 * @last modified by  : Adrian Mariscal 
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   07-01-2022   Adrian Mariscal   Initial Version
**/
public with sharing class CC_Margen_Facturacion_BU_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CBK_Margen_Facturacion__c>)tp.newList, (Map<Id, CBK_Margen_Facturacion__c>)tp.newMap, (List<CBK_Margen_Facturacion__c>)tp.oldList, (Map<Id, CBK_Margen_Facturacion__c>)tp.oldMap);
	}

    private void process(List<CBK_Margen_Facturacion__c> listNewObj, Map<Id, CBK_Margen_Facturacion__c> mapNewObj, List<CBK_Margen_Facturacion__c> listOldObj, Map<Id, CBK_Margen_Facturacion__c> mapOldObj) {
               
        CC_Margen_Facturacion_BI_TRHan.validarRegistros(listNewObj);
    }
}