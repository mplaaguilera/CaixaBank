/**********************************************************************************************************************
Name:	  CIBE_PathEventCIBController
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC Cibe_PathEventCIB
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			US743059    	Lucia	  	        19/12/2023		Init version
	
***********************************************************************************************************************/

public with sharing class CIBE_PathEventCIBController {
    

    @AuraEnabled(cacheable=true)
    public static List<Event> getEvent(String recordId){
        List<Event> evento = new List<Event>();

        if(Event.SObjectType.getDescribe().isAccessible() &&
        Schema.SObjectType.Event.fields.CSBD_Evento_Estado__c.isAccessible()){
         evento = [SELECT Id, CSBD_Evento_Estado__c, recordTypeId, ActivityDateTime FROM Event WHERE Id = :recordId];
        }
    

        return evento;
    }



    @AuraEnabled
    public static String updateEvent(String recordId, String stage){
        List<Event> evento = new List<Event>();
        String resultado = '';
        Boolean validate = true;

        if(stage == 'Realizada'){
            validate = validateRealizado(recordId);
        }
        
        if(validate && Event.SObjectType.getDescribe().isAccessible() &&
        Schema.SObjectType.Event.fields.CSBD_Evento_Estado__c.isAccessible()){
            evento = [SELECT Id, CSBD_Evento_Estado__c, recordTypeId FROM Event WHERE Id = :recordId];
        }

        if(!evento.isEmpty()){
            for (Event evnt : evento) {
                evnt.CSBD_Evento_Estado__c = stage;
            }

            //update evento;
            Database.SaveResult[] results = Database.update(evento, false);
            for(Database.SaveResult result: results) {
                if(!result.isSuccess()) {
                    //throw new AuraHandledException(result.getErrors()[0].getMessage());
                    resultado = result.getErrors()[0].getMessage();
                }
            }
        }

        if(validate == false){
            resultado = System.Label.CIBE_ObligatorioCerrarCitaCIB;
        }
        

        return resultado;
        
    }

    

    public static Boolean validateRealizado(String eventId){
        CBK_Activity_Extension__c actExtension = [SELECT Id,  CIBE_ConclusionesCita__c From CBK_Activity_Extension__c WHERE AV_ActivityId__c = :eventId limit 1];

        if(actExtension != null &&  actExtension.CIBE_ConclusionesCita__c != null){
            return true;
        }
        return false;
    }
}