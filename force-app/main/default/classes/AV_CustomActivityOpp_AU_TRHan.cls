/**********************************************************************************************************************
 Name:	  AV_CustomActivityOpp_AU_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de AV_CustomActivityOpportunity__c AfterUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				    DATE				Description
  	1.0			App FSC			Esperanza Conde	   		13/10/2020			Init version
  	2.0       	Check RT		Jashanpreet			    09/12/2020			Improve common method to check RT + general RT
  	2.1       	Bug				Sandra Gómez		    04/02/2021			Include if hasCustomPermission
    2.2         USXXXXXX	    Daniel Rodríguez	    10/03/2022          Add isBatch()
    2.3                         Oscar Moreno            16/01/2024         The only method that is invoked is eliminated, so the class is emptied.The Method was setFieldsToOpp
***********************************************************************************************************************/
public with sharing class AV_CustomActivityOpp_AU_TRHan extends CC_TriggerHandlerBase {
    
    public  override void mainEntry(CC_TriggerParameters tp) {
		 
    }
    
    
    
}