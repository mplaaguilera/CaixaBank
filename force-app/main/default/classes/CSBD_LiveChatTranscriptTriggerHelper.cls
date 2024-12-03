/**********************************************************************************************************************
Name:     CSBD_LiveChatTranscriptTriggerHelper
Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Clase apex con los métodos usados en los triggers del objeto LiveChatTranscprit
=======================================================================================================================
Historial
---------------------
VERSION     USER_STORY      AUTHOR              DATE                Description
1.0         App CSBD        Esperanza Conde	    01/02/2022          Init version
***********************************************************************************************************************/
public with sharing class CSBD_LiveChatTranscriptTriggerHelper {


    private final static Id RECORDTYPECHATID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Chat').getRecordTypeId();
    private final static Id RTLIVECHATID = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByName().get('Gestor').getRecordTypeId();

    /**
	 * @description		 	Revisa el tipo de chat entrante
	 * @param listNews  	list of new records
	*/
	public static List<LiveChatTranscript> checkTipo(List<LiveChatTranscript> listTranscript){
        
        List<LiveChatTranscript> listData = new List<LiveChatTranscript>();
		
        for(LiveChatTranscript dataNew : listTranscript){
			if(dataNew.CC_Tipo__c == 'CSBD'){
				listData.add(dataNew);
			}
		}

		return listData;
	}


	/**
	 * @description		 	Asigna el record types
	 * @param listNews  	list of new records
	*/
	public static void assignRTCSBD(List<LiveChatTranscript> listNews){
        
        Id recordTypeCSBD;

        if(recordTypeCSBD == null){
            recordTypeCSBD = RTLIVECHATID;
        }
        for(LiveChatTranscript transcript : listNews){
            transcript.RecordTypeId = recordTypeCSBD;
        }
        
	}
    
    /**
	 * @description		 	Asigna el owner del transcript a la opp
	 * @param listNews  	list of new records
	*/
	public static void asignarOwnerOpp(List<LiveChatTranscript> listNews){
        
        Set<Id> setOppId = new Set<Id>();
        Map<Id, Id> mapOpportunityTranscript = new Map<Id, Id>();
        List<Opportunity> lstOpp = new List<Opportunity>();
        
        for(LiveChatTranscript transcript : listNews){
            if(transcript.CSBD_OTP_Chat__c != null){
                setOppId.add(transcript.CSBD_Oportunidad_Id__c);
                mapOpportunityTranscript.put(transcript.CSBD_Oportunidad_Id__c, transcript.OwnerId); 
            }
        }
        
		List<Opportunity> lstOpportunity = [Select Id, OwnerId from Opportunity where Id in :setOppId];

        if(!lstOpportunity.isEmpty()){
            for(Opportunity opp : lstOpportunity){
                if(mapOpportunityTranscript.containsKey(opp.Id)){
                    opp.OwnerId = mapOpportunityTranscript.get(opp.Id);
                    lstOpp.add(opp);
                }
        	}
        }
        
        if(!lstOpp.isEmpty()){
            Database.update(lstOpp);
        }
	}


    /**
	 * @description		 	Valida que coincida el OTP del chat con el del cliente obtenido por el servicio de Salesforce
	 * @param listNews  	list of new records
	*/
	public static void validarOTP(List<LiveChatTranscript> listNews){

        Set<String> setOTP = new Set<String>();
        Map<String,CBK_OTP_Generado__c> mapNumPersoOTP = new Map<String,CBK_OTP_Generado__c>();
        Datetime dateAhora = system.now();
        Map<String, String> mapIdioma = new Map<String, String>{'Castellano' => 'es', 'Catalán' => 'ca', 'Inglés' => 'en'};

        for(LiveChatTranscript transcript : listNews){
            if(transcript.CSBD_OTP_Chat__c != null){
                setOTP.add(transcript.CSBD_OTP_Chat__c);
            }
        }
        if(!setOTP.isEmpty()){

            List<CBK_OTP_Generado__c> lstOTPGenerado = [Select CBK_Codigo_OTP__c, CBK_Fecha_Codigo_OTP__c, CBK_Oportunidad__c, CBK_Oportunidad__r.Account.Name, CBK_Oportunidad__r.AccountId, CBK_Oportunidad__r.ContactId, CBK_Oportunidad__r.CSBD_Now_NUMPERSO__c, CBK_Oportunidad__r.CSBD_Idioma_Solicitud__c, CBK_Oportunidad__r.CSBD_Familia_Producto__c from CBK_OTP_Generado__c where CBK_Codigo_OTP__c in :setOTP];
            
            if(!lstOTPGenerado.isEmpty()){
                for(CBK_OTP_Generado__c otp : lstOTPGenerado){
                    if(otp.CBK_Codigo_OTP__c != null){
                    	mapNumPersoOTP.put(otp.CBK_Codigo_OTP__c, otp);    
                    }
                }  
                
                //Si el chat viene sin el OTP entonces da error
                //Si el tiempo transcurrido desde que se pidió la sessionId y el momento de la llamada al chat es superior a 30min entonces error.
                for(LiveChatTranscript transcript : listNews){

                    if(!mapNumPersoOTP.containsKey(transcript.CSBD_OTP_Chat__c)){
                       //Error
                       transcript.addError('No hay ningún código OTP que coincide con ese SessionId. Por favor, solicita de nuevo el SessionId.');
                   }else{

                       Long minPeticion = CSBD_AppUtilities.calculateTimeDifferences(mapNumPersoOTP.get(transcript.CSBD_OTP_Chat__c).CBK_Fecha_Codigo_OTP__c, dateAhora);
                
                       if(minPeticion >= 10){
                           //Error
                           transcript.addError('Transcurrido el tiempo de validez de la sesión. Por favor, solicita de nuevo el SessionId.');
                       }else{
                           transcript.AccountId                    = mapNumPersoOTP.get(transcript.CSBD_OTP_Chat__c).CBK_Oportunidad__r.AccountId;
                           transcript.ContactId                    = mapNumPersoOTP.get(transcript.CSBD_OTP_Chat__c).CBK_Oportunidad__r.ContactId;
                           transcript.CC_Subject__c                = mapNumPersoOTP.get(transcript.CSBD_OTP_Chat__c).CBK_Oportunidad__r.Account.Name;
                           transcript.CSBD_Oportunidad_Id__c       = mapNumPersoOTP.get(transcript.CSBD_OTP_Chat__c).CBK_Oportunidad__c;
                           transcript.CC_NumPerso__c               = mapNumPersoOTP.get(transcript.CSBD_OTP_Chat__c).CBK_Oportunidad__r.CSBD_Now_NUMPERSO__c;
                           transcript.CC_Idioma__c                 = mapIdioma.get(mapNumPersoOTP.get(transcript.CSBD_OTP_Chat__c).CBK_Oportunidad__r.CSBD_Idioma_Solicitud__c);
                           transcript.CSBD_Now_Codigo_Producto__c  = mapNumPersoOTP.get(transcript.CSBD_OTP_Chat__c).CBK_Oportunidad__r.CSBD_Familia_Producto__c;
                       }

                    }
                   
               }

            }

        }else{
            for(LiveChatTranscript transcript : listNews){
                //Error
                transcript.addError('Es necesario obtener el sessionId para conectar.');
            }    
        }

	}


    /**
	 * @description		 	Crea la tarea relacionada con el chat
	 * @param listNews  	list of new records
	*/
	public static void createTaskRelated(List<LiveChatTranscript> listNews, Map<Id, LiveChatTranscript> mapOldObj){

        List<LiveChatTranscript> lstTranscripciones = new List<LiveChatTranscript>();

        for(LiveChatTranscript transcript : listNews){

            
            if(transcript.CSBD_Oportunidad_Id__c != null && 
                (mapOldObj == null || 
                (mapOldObj != null && transcript.CSBD_Oportunidad_Id__c != mapOldObj.get(transcript.Id).CSBD_Oportunidad_Id__c))){
                lstTranscripciones.add(transcript);          
            }    
        }

        if(!lstTranscripciones.isEmpty()){
            String jsonTranscripciones = JSON.serialize(lstTranscripciones);
            crearTarea(jsonTranscripciones);
        }

	}

    /**
    * @description       Método para creación de tareas.
    * @param jsonTranscripciones     -> Json con las transcripciones
	* @return None
    */
	@future(callout = true)
    public static void crearTarea(String jsonTranscripciones) {
		
		List<LiveChatTranscript> lstTranscripciones = (List<LiveChatTranscript>) JSON.deserialize(jsonTranscripciones, List<LiveChatTranscript>.class);
        List<Task> lstTask = new List<Task>();

        if(!lstTranscripciones.isEmpty()){
            for(LiveChatTranscript transcript : lstTranscripciones){
                Date todaysDate = system.today();
                Task task = new Task();
                task.ActivityDate = todaysDate;
                task.Subject = 'Conversación con agente chat';
                task.Description = 'Conversación con agente chat.';
                task.Type = 'Automática'; 
                task.Status = 'Completed';
                task.WhatId = transcript.CSBD_Oportunidad_Id__c;
                task.CC_LiveChatTranscript_Id__c = transcript.Id;
                task.Priority = 'Normal';
                lstTask.add(task);
            }
        }

        Database.insert(lstTask);

    }
}