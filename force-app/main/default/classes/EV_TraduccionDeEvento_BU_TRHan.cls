/**********************************************************************************************************************
 Name:	EV_TraduccionDeEvento_BU_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para el BeforeUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			                    Mamen Arias 		28/11/2022			Init version
	1.1			US585725			Daniel Rodriguez	31/08/2023			Add log

***********************************************************************************************************************/
public class EV_TraduccionDeEvento_BU_TRHan extends CC_TriggerHandlerBase{
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<EV_TraduccionDeEvento__c>)tp.newList, (Map<Id, EV_TraduccionDeEvento__c>)tp.newMap, (List<EV_TraduccionDeEvento__c>)tp.oldList, (Map<Id, EV_TraduccionDeEvento__c>)tp.oldMap);
	}
	
	private void process(List<EV_TraduccionDeEvento__c> listNewObj, Map<Id, EV_TraduccionDeEvento__c> mapNewObj, List<EV_TraduccionDeEvento__c> listOldObj, Map<Id, EV_TraduccionDeEvento__c> mapOldObj) {
        EV_LogDebug.printLogDebug('EV_TraduccionDeEvento_BU_TRHan ',String.valueof(listNewObj) + ' '+ String.valueof(mapOldObj));
		EV_TraduccionDeEventoTriggerHelper.checkDuplicado(listNewObj, mapOldObj); 
	}
}