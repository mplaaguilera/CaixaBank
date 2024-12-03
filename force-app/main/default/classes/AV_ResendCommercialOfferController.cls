/**********************************************************************************************************************
 Name:	  AV_ResendCommercialOfferContoller
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para obtener la URL de SIA.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY			AUTHOR			        	DATE				Description
   1.0			Data access		    Vladislav Lityagin          12/15/2022		    Init version
   1.1			Fix PMD Errors	    Daniel Rodriguez	        05/10/2023		    Add WITH SECURITY_ENFORCED in queries 

***********************************************************************************************************************/

public with sharing class AV_ResendCommercialOfferController {

    @AuraEnabled
    public static String resetLeadOpp(String recordId){
        AV_LeadOpportunity__c lo = [SELECT Id, AV_Status__c, AV_EstadoEnvioOfComercial__c, AV_StatusLeadOpp__c FROM AV_LeadOpportunity__c WHERE Id =:recordId WITH SECURITY_ENFORCED LIMIT 1];
        lo.AV_Status__c = AV_AppConstants.LEADOPP_STATUS_ACTIVO;
        lo.AV_StatusLeadOpp__c = AV_AppConstants.LEADOPP_STAGE_GESTION;
        lo.AV_EstadoEnvioOfComercial__c=null;
        Database.SaveResult updateResult=Database.update(lo);
		if (!updateResult.isSuccess()){
			throw new AuraHandledException('Fallo en resetLeadOpp - Error al actualizar Lead Oportunidad.');
        }else{
            return 'ok';
        }
	}
}