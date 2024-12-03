/**********************************************************************************************************************
Name:      CIBE_EventAttendeesController
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller del componente CIBE_EventAttendees
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY 				AUTHOR              DATE                Description
    1.0            US379969    		        Alex Campos         10/07/2022          Init version
***********************************************************************************************************************/
public with sharing class CIBE_EventAttendeesController {
    
	private final static Id EMPLEADO_RT     = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
    private final static Id APODERADOS_RT   = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CIBE_Apoderado').getRecordTypeId();
	private final static Id COMERCIAL_RT    = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CIBE_ContactoComercial').getRecordTypeId();

    @AuraEnabled(cacheable=true)
    public static Boolean isOwner(String recordId) {
        if(Event.SObjectType.getDescribe().isAccessible()) {
            return [SELECT OwnerId FROM Event WHERE Id = :recordId].OwnerId == UserInfo.getUserId();
        }
        return false;   
    }

    @AuraEnabled(cacheable=true)
    public static List<AttendeeWrapper> getRecord(String recordId) {
        List<AttendeeWrapper> result = new List<AttendeeWrapper>();
        if(String.isNotBlank(recordId) && Event.SObjectType.getDescribe().isAccessible()) {
            Event ev = [SELECT Id, OwnerId FROM Event WHERE Id = :recordId];

            List<EventRelation> attendees = new List<EventRelation>();
            if(EventRelation.SObjectType.getDescribe().isAccessible()) {
                attendees = [SELECT Id, EventId, RelationId, IsInvitee FROM EventRelation WHERE EventId = :recordId AND IsInvitee = true];
            }

            Set<String> userIds = new Set<String>{ ev.OwnerId };
            Set<String> contactIds = new Set<String>();
            for(EventRelation attende : attendees) {
                if(String.isNotBlank(attende.RelationId)) {
                    if(((String)attende.RelationId).startsWith('005')) {
                        userIds.add(attende.RelationId);
                    } else {
                        contactIds.add(attende.RelationId);
                    }
                } 
            }

            Map<Id, Contact> contactos = new Map<Id, Contact>();
            if(Contact.SObjectType.getDescribe().isAccessible()) {
                contactos = new Map<Id, Contact>([SELECT Id, Name, AV_UsuarioAsociado__c FROM Contact WHERE (Id IN :contactIds OR AV_UsuarioAsociado__c IN :userIds)]);
            }

            for(Contact contacto : contactos.values()) {
                if(String.isNotBlank(contacto.AV_UsuarioAsociado__c) && userIds.contains(contacto.AV_UsuarioAsociado__c)) {
                    contactos.put(contacto.AV_UsuarioAsociado__c, contacto);
                }
            }

            Set<Id> accepteds = new Set<Id>();
            if(AcceptedEventRelation.SObjectType.getDescribe().isAccessible()) {
                for(AcceptedEventRelation accepted : [SELECT Id, EventId, RelationId FROM AcceptedEventRelation WHERE EventId = :recordId]) {
                    accepteds.add(accepted.RelationId);
                }
            }

            Set<Id> undecideds = new Set<Id>();
            if(UndecidedEventRelation.SObjectType.getDescribe().isAccessible()) {
                for(UndecidedEventRelation undecided : [SELECT Id, EventId, RelationId FROM UndecidedEventRelation WHERE EventId = :recordId]) {
                    undecideds.add(undecided.RelationId);
                }
            }

            Set<Id> declineds = new Set<Id>();
            if(DeclinedEventRelation.SObjectType.getDescribe().isAccessible()) {
                for(DeclinedEventRelation declined : [SELECT Id, EventId, RelationId FROM DeclinedEventRelation WHERE EventId = :recordId]) {
                    declineds.add(declined.RelationId);
                }
            }

            AttendeeWrapper owner = new AttendeeWrapper();
            if(contactos.containsKey(ev.OwnerId)){
                owner.id = contactos.get(ev.OwnerId).Id;
                owner.name = contactos.get(ev.OwnerId).Name;
                owner.isOwner = true;
                owner.accepted = true;
                owner.undecided = false;
                owner.declined = false;
                owner.contactId = '/' + contactos.get(ev.OwnerId).Id;
                result.add(owner);
            }


            for(EventRelation attendee : attendees) {
                if(contactos.containsKey(attendee.RelationId)) {
                    AttendeeWrapper record = new AttendeeWrapper();
                    record.id = attendee.Id;
                    record.name = contactos.get(attendee.RelationId).Name;
                    record.isOwner = false;
                    record.accepted = accepteds.contains(attendee.RelationId);
                    record.undecided = undecideds.contains(attendee.RelationId);
                    record.declined = declineds.contains(attendee.RelationId);
                    record.contactId = '/' + contactos.get(attendee.RelationId).Id;
                    result.add(record);
                }
                
            }
        }
        return result;
    }

    @AuraEnabled
	public static List<AV_LookupSearchResult> search(String recordId, String searchTerm, List<String> selectedIds) {
        searchTerm = String.isNotBlank(searchTerm) ? searchTerm + '*' : '*';
        
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
        if(String.isNotBlank(recordId) && Contact.SObjectType.getDescribe().isAccessible() && Event.SObjectType.getDescribe().isAccessible()) {
            Event ev = [SELECT Id, AccountId FROM Event WHERE Id = :recordId LIMIT 1];
            String cliente = ev.AccountId;
            List<List<SObject>> searchResults = search.query('FIND { '+searchTerm+' } IN ALL FIELDS RETURNING Contact (Id, Name, RecordType.Name, AccountId, Account.Name WHERE Id NOT IN :selectedIds AND ((RecordTypeId = :EMPLEADO_RT) OR ((RecordTypeId = :APODERADOS_RT OR RecordTypeId = :COMERCIAL_RT) AND AccountId = :cliente))) LIMIT 5');
       
            if(searchResults != null && !searchResults.isEmpty()) {
                List<Contact> contacts = (List<Contact>) searchResults[0];
                for (Contact c : contacts) {
                    results.add(
                        new AV_LookupSearchResult(
                            c.Id, 
                            'Contact', 
                            'standard:contact', 
                            c.Name, 
                            c.RecordType.Name.toUpperCase() + (c.AccountId != null ? ' - ' + c.Account.Name : '')));
                }
                results.sort();
            }
        }
		return results;
    }

    @AuraEnabled
    public static void createAttendee(String recordId, String contactId) {
        if(String.isNotBlank(recordId) && String.isNotBlank(contactId)) {
            List<EventRelation> attendees = new List<EventRelation>();
            if(EventRelation.SObjectType.getDescribe().isAccessible()) {
                attendees = [SELECT Id, EventId, RelationId, IsInvitee FROM EventRelation WHERE EventId = :recordId AND IsInvitee = true];
            }

            List<String> relationIds = new List<String>();
            for(EventRelation attendee : attendees) {
                if(String.isNotBlank(attendee.RelationId)) {
                    relationIds.add(attendee.RelationId);
                }
            }

            if(relationIds.isEmpty() || (!relationIds.isEmpty() && !relationIds.contains(contactId))) {
                insert new EventRelation(
                    EventId = recordId,
                    RelationId = contactId,
                    IsInvitee = true
                );

                updateAccessList(new List<String>{recordId});
            }
        }
    }

    @AuraEnabled
    public static void removeAttendee(String recordId, String attendeeId) {
        if(String.isNotBlank(recordId) && String.isNotBlank(attendeeId)) {
            List<EventRelation> attendees = new List<EventRelation>();
            if(EventRelation.SObjectType.getDescribe().isAccessible()) {
                attendees = [SELECT Id, EventId, RelationId, IsInvitee FROM EventRelation WHERE Id = :attendeeId AND IsInvitee = true];
            }

            if(!attendees.isEmpty()) {
                delete attendees;

                updateAccessList(new List<String>{recordId});
            }
        }
    }

    @InvocableMethod(label='Update Event Access')
    public static void updateAccessList(List<String> recordId) {
        List<EventRelation> attendees = new List<EventRelation>();
        if(EventRelation.SObjectType.getDescribe().isAccessible()) {
            attendees = [SELECT Id, EventId, RelationId, IsInvitee FROM EventRelation WHERE EventId = :recordId AND IsInvitee = true];
        }

        System.debug(attendees);

        Set<String> userIds = new Set<String>();
        Set<String> contactIds = new Set<String>();
        for(EventRelation attende : attendees) {
            if(String.isNotBlank(attende.RelationId)) {
                if(((String)attende.RelationId).startsWith('005')) {
                    userIds.add(attende.RelationId);
                } else {
                    contactIds.add(attende.RelationId);
                }
            } 
        }

        List<Id> users = new List<Id>();
        if(User.SObjectType.getDescribe().isAccessible()) {
            for(User u : [SELECT Id FROM User WHERE Id IN :userIds]) {
                users.add(u.Id);
            }
        }
        
        if(Contact.SObjectType.getDescribe().isAccessible()) {
            for(Contact c : [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE Id IN :contactIds]) {
                if(String.isNotBlank(c.AV_UsuarioAsociado__c) && !users.contains(c.AV_UsuarioAsociado__c)) {
                    users.add(c.AV_UsuarioAsociado__c);
                }
            }
        }

        if(Event.SObjectType.getDescribe().isAccessible()) {
            List<String> access = new List<String>();
            for(Id userId : users) {
                if(!access.contains(userId)) {
                    access.add(userId);
                }
            }

            Event ev = [SELECT Id, OwnerId, AV_Task__c FROM Event WHERE Id = :recordId LIMIT 1];
            if(!access.contains(ev.OwnerId)) {
                access.add(ev.OwnerId);
            }

            if(String.isNotBlank(ev.AV_Task__c)) {
                List<AV_HeaderCustomActivity__c> header = new List<AV_HeaderCustomActivity__c>();
                if(AV_HeaderCustomActivity__c.SObjectType.getDescribe().isAccessible()) {
                    header = [SELECT Id, CIBE_ConfidentialEvent__c FROM AV_HeaderCustomActivity__c WHERE Id = :ev.AV_Task__c];
                }

                if(!header.isEmpty() && ev != null) {
                    header.get(0).CIBE_ConfidentialEvent__c = String.join(access, ',');
                    update header;
                    update ev;
                }
            }
        }
    }

    public class AttendeeWrapper {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public Boolean isOwner {get;set;}
        @AuraEnabled public Boolean accepted {get;set;}
        @AuraEnabled public Boolean undecided {get;set;}
        @AuraEnabled public Boolean declined {get;set;}
        @AuraEnabled public String contactId {get;set;}
    }

}