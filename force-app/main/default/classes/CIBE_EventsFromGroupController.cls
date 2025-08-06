/*
Name:	  CIBE_EventsFromGroupController
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for CIBE_EventsFromGroup and reporting LWCs
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			    	        Jose Maria Perez 	23/09/2022		Init version
*/
public with sharing class CIBE_EventsFromGroupController {

    private static List<String> stages = new List<String>{'Pendiente','Planificada'};
    
    private static Set<Id> recordTypes = CIBE_AppUtilities.getRecordTypeIdsInSet(
        new Set<CIBE_AppUtilities.SearchRT>{
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT),
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_CIB_RT),
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_GESTOR_RT)
        });

    @AuraEnabled(cacheable = true) 
    public static List<EventWrapper> getRecords(Integer offSet, List<String> recordIds) {
        List<Event> events = new List<Event>();
        if(!recordIds.isEmpty() &&  Event.SObjectType.getDescribe().isAccessible()) {
            events = [SELECT    Id,
                                Subject,
                                AccountId,
                                Account.Name,
                                AV_Task__c,
                                StartDateTime,
                                What.Name,
                                toLabel(AV_Tipo__c),
                                Owner.Name
                        FROM Event
                        WHERE RecordTypeId IN :recordTypes AND WhatId = :recordIds AND CSBD_Evento_Estado__c IN :stages AND AV_ToDelete__c = FALSE  
                        ORDER BY StartDateTime ASC LIMIT 10 OFFSET :offSet];
        }

        List<String> headerCustomActivities = new List<Id>();
        for(Event e : events) {
            if(String.isNotBlank(e.AV_Task__c)) {
                headerCustomActivities.add(e.AV_Task__c);
            }
        }

        Map<String, Integer> mapCount = new Map<String, Integer>();
        Map<Id, AV_CustomActivityOpportunity__c> mapHigher = new Map<Id, AV_CustomActivityOpportunity__c>();
        if(!headerCustomActivities.isEmpty()) {
            List<AV_CustomActivityOpportunity__c> customActivityOpportunities =new List<AV_CustomActivityOpportunity__c>();
            if(AV_CustomActivityOpportunity__c.SObjectType.getDescribe().isAccessible()) {
                customActivityOpportunities = [SELECT Id, 
                                        AV_Task__c, 
                                        AV_Task__r.Name,
                                        AV_IsMain__c,
                                        AV_Opportunity__c,
                                        AV_Opportunity__r.Name 
                                FROM AV_CustomActivityOpportunity__c 
                                WHERE AV_Task__c = :headerCustomActivities];
            }
            
            for(AV_CustomActivityOpportunity__c cao : customActivityOpportunities) {
                if(!mapCount.containsKey(cao.AV_Task__c)){
                    mapCount.put(cao.AV_Task__c, 1);
                } else {
                    Integer currentInt = mapCount.get(cao.AV_Task__c) + 1;
                    mapCount.put(cao.AV_Task__c, currentInt);
                }

                if(cao.AV_IsMain__c){
                    mapHigher.put(cao.AV_Task__c, cao);
                }
            }
        }

        List<EventWrapper> result = new List<EventWrapper>();
        for(Event e : events) {
            EventWrapper ew = new EventWrapper();
            ew.id = e.Id;
            ew.idUrl = '/' + e.Id;
            ew.name = e.Subject;
            ew.accountId = e.AccountId;
            ew.accountIdUrl = '/' + e.AccountId;
            ew.accountName = e.Account.Name;
            ew.type = e.AV_Tipo__c;
            ew.startDateTime = e.StartDateTime.date();
            ew.numberOfOpps = mapCount.containsKey(e.AV_Task__c) ? mapCount.get(e.AV_Task__c) : 0;
            ew.mainOpp = mapHigher.containsKey(e.AV_Task__c) ? mapHigher.get(e.AV_Task__c).AV_Opportunity__r.Name : null;
            ew.mainOppId = mapHigher.containsKey(e.AV_Task__c) ? mapHigher.get(e.AV_Task__c).AV_Opportunity__c : null;
            ew.mainOppIdUrl = mapHigher.containsKey(e.AV_Task__c) ? ('/' + mapHigher.get(e.AV_Task__c).AV_Opportunity__c) : '';
            ew.owner = e.Owner.Name;
            ew.ownerIdUrl = '/' + e.OwnerId;
            result.add(ew);
        }
        return result;
    }

    public class EventWrapper {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String idUrl {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String accountId {get;set;}
        @AuraEnabled public String accountIdUrl {get;set;}
        @AuraEnabled public String accountName {get;set;}
        @AuraEnabled public String type {get;set;}
        @AuraEnabled public Date startDateTime {get;set;}
        @AuraEnabled public Integer numberOfOpps {get;set;}
        @AuraEnabled public String mainOpp {get;set;}
        @AuraEnabled public String mainOppId {get;set;}
        @AuraEnabled public String mainOppIdUrl {get;set;}
        @AuraEnabled public String owner {get;set;}
        @AuraEnabled public String ownerIdUrl {get;set;}
    }

}