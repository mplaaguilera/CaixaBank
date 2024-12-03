/**********************************************************************************************************************
 Name:      CIBE_EventosFichaCliente_Controller
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for cibe_EventosFichaCliente_Controller LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION  USER_STORY				AUTHOR				DATE            Description
	1.0      Initial				Bea		    	18/04/2023          Init version
	2.0      US479347				Luis Martínez   17/07/2023		    Cambio para la confidencialidad de Eventos	

***********************************************************************************************************************/

public with sharing class CIBE_EventosFichaCliente_Controller {

    @AuraEnabled(cacheable = true) 
    public static List<Wrapper> eventsFichaCli(String recordId) {
        
        List<Event> events = new List<Event>();
        List<EventRelation> lstEvtRelation = new List<EventRelation>();
        List<Wrapper> listReturn = new List<Wrapper>();
        List<Contact> listContLog = new List<Contact>();
        Map<String,List<String>> mapCon = new Map<String,List<String>>();
        Boolean userRelation = false;
        if(Event.SObjectType.getDescribe().isAccessible()) {
                
            events = [SELECT Id, AV_Tipo__c, Subject,toLabel(CSBD_Evento_Estado__c), StartDateTime, Owner.Name, CIBE_Confidential__c , OwnerId 
            FROM Event WHERE StartDateTime >= TODAY AND CSBD_Evento_Estado__c IN ('Pendiente', 'Pendiente no localizado') AND
            RecordType.DeveloperName IN ('CIBE_EventoCliente', 'CIBE_EventodelGestor') AND IsChild = false AND AccountId = :recordId];

            if(!events.isEmpty() && EventRelation.SObjectType.getDescribe().isAccessible()){
                for(EventRelation evr : [SELECT Id, EventId, RelationId, relation.name  FROM EventRelation WHERE EventId IN:events AND IsInvitee = true]){
                    if(!mapCon.containsKey(evr.EventId)){
                        mapCon.put(evr.EventId, new List<String>());
                    }
                    if(mapCon.containsKey(evr.EventId)){
                        mapCon.get(evr.EventId).add(evr.RelationId);
                    }
                }
            }
        }
        Map<String,String> pickListValuesMap = new Map<String,String>();
		for( Schema.PicklistEntry pickListVal : Event.AV_Tipo__c.getDescribe().getPicklistValues()){
            pickListValuesMap.put(pickListVal.getValue(),pickListVal.getLabel());
		}

        String userlog = UserInfo.getUserId();
        if(Contact.SObjectType.getDescribe().isAccessible()){
            listContLog = [SELECT id FROM Contact WHERE AV_UsuarioAsociado__c =: userLog ];
        }

        for(Event event : events) {
            if(event.OwnerId.equals(UserInfo.getUserId()) ||
                (mapCon != null && mapCon.containsKey(event.Id) &&
                ((!listContLog.isEmpty() && mapCon.get(event.id).contains(listContLog[0].Id)) || mapCon.get(event.id).contains(UserInfo.getUserId()))
                )){
                    userRelation = true;
                }

            if(!event.CIBE_Confidential__c || (event.CIBE_Confidential__c && userRelation) ){
                listReturn.add(
                    new Wrapper(
                        pickListValuesMap.containsKey(event.AV_Tipo__c) ? pickListValuesMap.get(event.AV_Tipo__c) :event.AV_Tipo__c,
                        event.Id,
                        event.Subject,
                        event.CSBD_Evento_Estado__c,
                        event.StartDateTime,
                        event.OwnerId,
                        event.Owner.Name
                    ));
            }
            userRelation = false;
        }
        return listReturn;
    }


    public class Wrapper{

        @AuraEnabled 
        public String tipo {get;set;}

        @AuraEnabled 
        public String idEvent {get;set;}

        @AuraEnabled 
        public String asunto {get;set;}

        @AuraEnabled 
        public String estado {get;set;}

        @AuraEnabled 
        public DateTime fechaInicio {get;set;}

        @AuraEnabled 
        public String ownerId {get;set;}

        @AuraEnabled 
        public String ownerName {get;set;}

        public Wrapper(String tipo, String idEvent, String asunto, String estado, DateTime fechaInicio, String ownerId, String ownerName) {
            
            this.tipo = tipo;
            this.idEvent = '/'+ idEvent;
            this.asunto = asunto;
            this.estado = estado;
            this.fechaInicio = fechaInicio;
            this.ownerId= '/'+ ownerId;
            this.ownerName = ownerName;
        }
    }

}