/**********************************************************************************************************************
 Name:	  AV_Event_BI_TRDispHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Dispatcher para Trigger de Event BeforeInsert
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			FIX		        Alex 			    16/11/2022			Dispatcher Previo Events

***********************************************************************************************************************/
public with sharing class AV_Event_BI_TRDispHan extends CC_TriggerHandlerBase {
	
    private static Id AV_EventoGestor_RT = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(AV_AppConstants.EVENTGESTOR_RT).getRecordTypeId();
    private static Id CIBE_EventoGestor_RT = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.EVENT_GESTOR_RT).getRecordTypeId();
    
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Event>)tp.newList, (Map<Id, Event>)tp.newMap, (List<Event>) tp.oldList, (Map<Id, Event>) tp.oldMap);
	}
	
	private void process(List<Event> listNewObj, Map<Id, Event> mapNewObj, List<Event> listOldObj, Map<Id, Event> mapOldObj) {
        List<Event> setRecordTypes = new List<Event>();
        for(Event dataNew : listNewObj){
			if(String.isBlank(dataNew.RecordTypeId)){
				setRecordTypes.add(dataNew);
			}
		}
        
        if(!setRecordTypes.isEmpty()) {
            Set<Id> ownerIds = new Set<Id>();
            for(Event e : setRecordTypes) {
                ownerIds.add(e.OwnerId);
            }

            Map<Id, User> users = new Map<Id, User>();
            if(!ownerIds.isEmpty() && User.SObjectType.getDescribe().isAccessible()
                && Schema.SObjectType.User.fields.Id.isAccessible()) {
                users = new Map<Id, User>([SELECT Id, Profile.Name FROM User WHERE Id IN :ownerIds]);
            }

            for(Event e : setRecordTypes) {
                if(users.containsKey(e.OwnerId)) {
                    String name = users.get(e.OwnerId).Profile.Name;
                    if(name == AV_AppConstants.AV_PROFILE) {
                        e.RecordTypeId = AV_EventoGestor_RT;
                        e.AV_OrigenApp__c = AV_AppConstants.OUTLOOK_ORIGENAPP;
                    } else if (name == CIBE_AppConstants.CIBE_GESTOR) {
                        e.RecordTypeId = CIBE_EventoGestor_RT;
                        e.AV_OrigenApp__c = CIBE_AppConstants.OUTLOOK_ORIGENAPP;
                    } else {
                        e.RecordTypeId = AV_EventoGestor_RT;
                        e.AV_OrigenApp__c = AV_AppConstants.OUTLOOK_ORIGENAPP;
                    }
                }
            }
        }
        
        List<Event> avEvents = new List<Event>();
        List<Event> cibeEvents = new List<Event>();
        for(Event dataNew : listNewObj) {
            if(AV_EventTriggerHelper.getAllRT().contains(dataNew.RecordTypeId)) {
                avEvents.add(dataNew);
            } else if(CIBE_EventTriggerHelper.getAllRT().contains(dataNew.RecordTypeId)) {
                cibeEvents.add(dataNew);
            }
        }
        
        if(!avEvents.isEmpty()) {
            new AV_Event_BI_TRHan().process(listNewObj, mapNewObj, listOldObj, mapOldObj);
        }

        if(!cibeEvents.isEmpty()) {
            new CIBE_Event_BI_TRHan().process(listNewObj, mapNewObj, listOldObj, mapOldObj);
        }
	}
    
}