/**********************************************************************************************************************
 Name:	  AV_CustomActivityOpp_AI_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de AV_CustomActivityOpportunity__c AfterInsert
-----------------------------------------------------------------------------------------------------------------------
Historial
--------------------------------------------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0     		App FSC			Rubén Izquierdo	  	22/03/2021			Init version
	1.1           US286825 		Daniel Rodríguez	10/01/2022			Add method updateNextManagementDateOpp
	1.2			US286825 		Daniel Rodríguez	13/01/2022			Add Method updateNextManagementDateOpp
    1.3                         Oscar Moreno        16/01/2024          The only method that are invoked is eliminated, so the class is emptied.This method was updateNextManagementDateOpp
	1.4       US839366          Luis Fernández    18/03/2024      Added   updateOpportunityNextEventDateField call      

***********************************************************************************************************************/
public with sharing class AV_CustomActivityOpp_AI_TRHan extends CC_TriggerHandlerBase  {
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<AV_CustomActivityOpportunity__c>)tp.newList);


	
	}
	
	private void process(List<AV_CustomActivityOpportunity__c> listNewObj) {
		if(listNewObj != null && !listNewObj.isEmpty()){
			AV_CustomActivityOppTriggerHelper.updateOpportunityNextEventDateField(listNewObj);
		}
	}
	
}