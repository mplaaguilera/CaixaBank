/**********************************************************************************************************************
 Name:	  AV_CustomActivityOpp_BI_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de AV_CustomActivityOpportunity__c BeforeInsert
-----------------------------------------------------------------------------------------------------------------------
Historial
--------------------------------------------------------
  VERSION		USER_STORY		AUTHOR				DATE				Description
  1.0     		App FSC			Álvaro López	  	13/10/2020			Init version
  2.0       	Check RT		Jashanpreet			09/12/2020			Improve common method to check RT + general RT
  2.1                     Oscar Moreno    16/01/2024      The only methods that are invoked are eliminated, so the class is emptied.Methods were setFieldsFromOpp,fillChannelField

***********************************************************************************************************************/
public with sharing class AV_CustomActivityOpp_BI_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
	
      
    }
    
    
    
}