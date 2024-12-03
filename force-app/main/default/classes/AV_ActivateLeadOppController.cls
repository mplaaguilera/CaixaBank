/**********************************************************************************************************************
 Name:	  AV_ActivateLeadOppController
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora del componente aura AV_ActivateLeadOppButton.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	                            	AUTHOR		   			DATE				Description
	1.0			US-371544 Estados Lead y LeadOpp	    Vladislav Lityagin	   	27/05/2022		    	Init version
***********************************************************************************************************************/
public with sharing class AV_ActivateLeadOppController {
    
    @AuraEnabled
    public static boolean updateStatus(String leadOppId){
        String methodName = 'updateStatus';
        boolean desactivado = false;
        try{
			AV_LeadOpportunity__c lo = [SELECT Name, AV_Status__c, AV_StatusLeadOpp__c, AV_RejectReason__c FROM AV_LeadOpportunity__c WHERE Id = :leadOppId AND RecordType.DeveloperName = :AV_AppConstants.LEAD_PPHH_RT LIMIT 1];
            //Si el estado está en 'Cerrado' y se da a activar que vuelva a la etapa anterior y se vuelva a quedar en activo
            if(lo.AV_Status__c.equals(AV_AppConstants.LEADOPP_STATUS_CERRADO) || lo.AV_Status__c.equals(AV_AppConstants.LEADOPP_STATUS_NUEVO) || lo.AV_Status__c.equals(AV_AppConstants.LEADOPP_STATUS_ENVIADA) || lo.AV_Status__c.equals(AV_AppConstants.LEADOPP_STATUS_RECHAZADO)){
                lo.AV_StatusLeadOpp__c = AV_AppConstants.LEADOPP_STAGE_GESTION;
                lo.AV_Status__c = AV_AppConstants.LEADOPP_STATUS_ACTIVO;
                lo.AV_FechaCierreGestion__c = null;
                lo.AV_RejectReason__c = null;
                try{
                    Database.SaveResult sr = database.update(lo); 
                    if(sr.isSuccess()){
                        desactivado = true;
                    }
                    return desactivado;
                }catch(DmlException e){
                    AV_LogDebug.printLogDebug(methodName, 'Error: ' + e.getMessage());
                    return false;
                }
            }
        }catch(QueryException e){
            AV_LogDebug.printLogDebug(methodName, 'Error: ' + e.getMessage());
            return false;
        }
        
        return desactivado;
    }
    
}