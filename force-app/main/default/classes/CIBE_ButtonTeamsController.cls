/**********************************************************************************************************************
 Name:	  CIBE_ButtonTeamsController
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class of CIBE_ButtonTeams
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			Init version		Jose Maria		    27/01/2023  		Init version (Copy class from Retail)
***********************************************************************************************************************/
public with sharing class CIBE_ButtonTeamsController {
    
    public final String recordId;
    
    @AuraEnabled
    public static String getUrlTeams(String recordId) {
        if(String.isNotBlank(recordId)){     
            List<Event> listEv = new List<Event>();
            if(
                Event.SObjectType.getDescribe().isAccessible() &&
                Schema.SObjectType.Event.fields.AV_Task__c.isAccessible()
            ) {
                listEv = [SELECT Id, AV_Task__c FROM Event WHERE Id = :recordId LIMIT 1];   
            }       
            if (!listEv.isEmpty() && String.isNotBlank(listEv[0].AV_Task__c)) {
                List< AV_HeaderCustomActivity__c> listCabeceraTarea=  new  List<AV_HeaderCustomActivity__c>();
                if( 
                    AV_HeaderCustomActivity__c.SObjectType.getDescribe().isAccessible() &&
                    Schema.SObjectType.AV_HeaderCustomActivity__c.fields.AV_UrlTeams__c.isAccessible()
                ) {
                    listCabeceraTarea  = [SELECT Id, AV_UrlTeams__c FROM AV_HeaderCustomActivity__c WHERE Id = :listEv[0].AV_Task__c];
                }
                if(!listCabeceraTarea.isEmpty()){
                	return listCabeceraTarea[0].AV_UrlTeams__c;
                }
            }
            
        }
        return null;
    } 
}