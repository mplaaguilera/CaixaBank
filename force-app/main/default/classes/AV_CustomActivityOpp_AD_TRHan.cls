/**********************************************************************************************************************
 Name:	  AV_CustomActivityOpp_AD_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de CustomActivityOpportunity AfterDelete
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		  	AUTHOR				    DATE				    Description
	1.0			  US286825			    Daniel Rodríguez	07/01/2022			Init version
  1.1       USXXXXXX	        Daniel Rodríguez	09/03/2022      Add isBatch()
  1.2                         Oscar Moreno      16/01/2024      The only method that are invoked is eliminated, so the class is emptied.This method was updateNextManagementDateOpp
  1.3       US839366          Luis Fernández    18/03/2024      Added   updateOpportunityNextEventDateField call      
***********************************************************************************************************************/
public with sharing class AV_CustomActivityOpp_AD_TRHan extends CC_TriggerHandlerBase {

    
    
    public override  void mainEntry(CC_TriggerParameters tp) {
		process((List<AV_CustomActivityOpportunity__c>)tp.oldList);
        
    }

    private void process(List<AV_CustomActivityOpportunity__c> listOld) {
      if(listOld != null && !listOld.isEmpty()){
        AV_CustomActivityOppTriggerHelper.updateOpportunityNextEventDateField(listOld);
      }
	}
    
}