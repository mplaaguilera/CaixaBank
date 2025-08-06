/**********************************************************************************************************************
 Name:	  AV_ProrrogaVencimiento
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY	         AUTHOR		   		DATE				Description

   	1.0			Fix PMD Errors       Daniel Rodriguez   05/10/2023			Add WITH SECURITY_ENFORCED in queries and isUpdateable in database
***********************************************************************************************************************/
public with sharing class AV_ProrrogaVencimiento {
   
   
    @AuraEnabled    
    public static boolean sumaDiasFechaVencimiento (String recordId){
        String methodName = '';
        String className = '';
        methodName = 'sumaDiasFechaVencimiento';
        className = 'AV_ProrrogaVencimiento';
        // Recojo de la query el valor de la fecha de vencimiento actual AV_DueDate__c
        AV_LeadOpportunity__c lo = new AV_LeadOpportunity__c();
        lo = [SELECT AV_DueDate__c FROM AV_LeadOpportunity__c WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
       
        // Días para sumar son 30
        integer days = 0;
        days = 30;
        // Añado los 30 días a la fecha de vencimiento
        lo.AV_DueDate__c = lo.AV_DueDate__c.addDays(days);
       
        try {
            // actualizo la bbdd con el nuevo valor de fecha de vencimiento
            if(Schema.sObjectType.AV_LeadOpportunity__c.isUpdateable()){
                Database.update(lo);
            }
            return true;
        } catch (DmlException e) {
            AV_LogDebug.printException(methodName, e);
            return false;
        }
       
    }
   
        
    }