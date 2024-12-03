/**********************************************************************************************************************
 Name:	EV_TraduccionDeEvento_BI_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para el BeforeInsert
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			                    Mamen Arias 		28/11/2022			Init version
	1.1			US585725			Daniel Rodriguez	31/08/2023			Check if Alta masiva dont check validation

***********************************************************************************************************************/
public class EV_TraduccionDeEvento_BI_TRHan extends CC_TriggerHandlerBase{
    static final String ALTA_MASIVA = 'Alta masiva';
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<EV_TraduccionDeEvento__c>)tp.newList, (Map<Id, EV_TraduccionDeEvento__c>)tp.newMap, (List<EV_TraduccionDeEvento__c>)tp.oldList, (Map<Id, EV_TraduccionDeEvento__c>)tp.oldMap);
	}
	
	private void process(List<EV_TraduccionDeEvento__c> listNewObj, Map<Id, EV_TraduccionDeEvento__c> mapNewObj, List<EV_TraduccionDeEvento__c> listOldObj, Map<Id, EV_TraduccionDeEvento__c> mapOldObj) {
        EV_LogDebug.printLogDebug('EV_TraduccionDeEvento_BI_TRHan ',String.valueof(listNewObj) + ' '+ String.valueof(mapOldObj));
        List<EV_TraduccionDeEvento__c> traduccionesEntry = new List<EV_TraduccionDeEvento__c>();
        for(EV_TraduccionDeEvento__c trad : listNewObj){
            if(Test.isRunningTest() || String.isBlank(trad.EV_OrigenCampaign__c) || trad.EV_OrigenCampaign__c != ALTA_MASIVA){
                traduccionesEntry.add(trad);
            } 
        } 
        if(!traduccionesEntry.isEmpty()){
			EV_TraduccionDeEventoTriggerHelper.checkDuplicado(traduccionesEntry, mapOldObj);
        }
	}
}