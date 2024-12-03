/**********************************************************************************************************************
 Name:	  AV_ButtonTeamsController
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class of AV_ButtonTeams
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			Init version		Manuel Hernando		05/05/2021			Init version
    1.1			US202459 		    Sandra Gómez    	12/05/2021			Change apex class
    1.2	        AV_Query IT	        Daniel Rodríguez	02/03/2022	        Change AV_Query to SOQL for User, Account, Contact

***********************************************************************************************************************/
public with sharing class AV_ButtonTeamsController {
    
    public final String recordId;
    
    @AuraEnabled
    public static String getUrlTeams(String recordId) {
        if(String.isNotBlank(recordId)){     
            Event ev = [Select Id, AV_Task__c From Event Where Id = :recordId limit 1];          
            /*Event ev = (Event)new AV_Query('Event')
                .selectFields('Id, AV_Task__c')
                .addConditionEq('Id', recordId)
                .fetch();*/
            if (String.isNotBlank(ev.AV_Task__c)) {
                AV_HeaderCustomActivity__c cabeceraTarea  = [Select Id, AV_UrlTeams__c From AV_HeaderCustomActivity__c Where Id = :ev.AV_Task__c limit 1];
                /*AV_HeaderCustomActivity__c cabeceraTarea = (AV_HeaderCustomActivity__c)new AV_Query('AV_HeaderCustomActivity__c')
                    .selectFields('Id, AV_UrlTeams__c')
                    .addConditionEq('Id', ev.AV_Task__c)
                    .fetch();*/
                return cabeceraTarea.AV_UrlTeams__c;
            }
        }
        return null;
    } 
}