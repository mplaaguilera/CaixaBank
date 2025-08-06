public with sharing class CIBE_CallReportVFControllerCIB {
    
    private static Set<Id> attorneyAttendeeRTs = CIBE_AppUtilities.getRecordTypeIdsInSet(
        new Set<CIBE_AppUtilities.SearchRT>{
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.CONTACT_APODERADO_RT)
        });

    private static Set<Id> contactsAttendeeRTs = CIBE_AppUtilities.getRecordTypeIdsInSet(
        new Set<CIBE_AppUtilities.SearchRT>{
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.CONTACT_CONTACTO_COMERCIAL_RT)
        });

    private static Set<Id> employeeAttendeeRTs = CIBE_AppUtilities.getRecordTypeIdsInSet(
        new Set<CIBE_AppUtilities.SearchRT>{
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.EMPLOYEE_RT)
        });

    public String recordId { get; set; }
    public EventWrapper eventWrapper { get; set; }
    public List<Account> accounts { get; set; }
    public List<Opportunity> opportunities { get; set; }

    public CIBE_CallReportVFControllerCIB() {
        recordId = ApexPages.currentPage().getParameters().get('recordId');

        if (String.isNotBlank(recordId)) {
            accounts = new List<Account>();
            opportunities = new List<Opportunity>();
    
            fetchData();
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No recordId provided.'));
        }
    }

    private void fetchData() {
        List<Event> events = new List<Event>();
        if(Event.SObjectType.getDescribe().isAccessible()) {
            events = [SELECT Id, AV_Task__c, Subject, TOLABEL(AV_Tipo__c), ActivityDate, StartDateTime, EndDateTime, Location, WhatId, OwnerId, Owner.Name FROM Event WHERE Id = :recordId];
        }

        if(!events.isEmpty()) {
            Event ev = events.get(0);
            eventWrapper = new EventWrapper();
            eventWrapper.subject = ev.Subject;
            eventWrapper.location = ev.Location;
            eventWrapper.type = ev.AV_Tipo__c;
            eventWrapper.owner = ev.Owner.Name;
            eventWrapper.attorneyAttendees = new List<Contact>();
            eventWrapper.contactsAttendees = new List<Contact>();
            eventWrapper.employeeAttendees = new List<Contact>();
            
            DateTime now = ev.StartDateTime != null ? ev.StartDateTime : System.now();

            String preposition = ' / ';

            switch on (UserInfo.getLanguage()) {
                when 'es' {
                    preposition = ' de ';
                }
                when 'en_US' {
                    preposition = ' of ';
                }
            }

            eventWrapper.activityDate = now.day() + preposition + CIBE_AppUtilities.getMonthName(now.month(), UserInfo.getLanguage()) + preposition + now.year();
            
            String title = 'Customer Call Report ' + now.day() + '-' + now.month() + '-' + now.year();
            Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + title + '.pdf');

            List<CBK_Activity_Extension__c> activityExtensions = new List<CBK_Activity_Extension__c>();
            if(String.isNotBlank(ev.Id) && CBK_Activity_Extension__c.SObjectType.getDescribe().isAccessible()) {
                activityExtensions = [SELECT Id, CIBE_ConclusionesCliente__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :ev.Id];
            }

            eventWrapper.conclusions = !activityExtensions.isEmpty() ? activityExtensions.get(0).CIBE_ConclusionesCliente__c : '';

            List<EventRelation> eventRelations = new List<EventRelation>();
            if(String.isNotBlank(ev.Id) && EventRelation.SObjectType.getDescribe().isAccessible()) {
                eventRelations = [SELECT Id, EventId, RelationId FROM EventRelation WHERE EventId = :ev.Id AND IsInvitee = true];
            }

            List<Id> userIds = new List<Id>();
            List<Id> contactIds = new List<Id>();
            for(EventRelation eventRelation : eventRelations) {
                if(String.isNotBlank(eventRelation.RelationId)) {
                    String relationId = ((String)eventRelation.RelationId);
                    if(relationId.startsWithIgnoreCase('003')) {
                        contactIds.add(eventRelation.RelationId);
                    } else if(relationId.startsWithIgnoreCase('005')) {
                        userIds.add(eventRelation.RelationId);
                    }
                }
            }

            Map<Id, Contact> contactFromUsers = new Map<Id, Contact>();
            if(!userIds.isEmpty() && Contact.SObjectType.getDescribe().isAccessible()) {
                contactFromUsers = new Map<Id, Contact>([SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c IN :userIds]);
            }

            if(!contactFromUsers.isEmpty()) {
                contactIds.addAll(contactFromUsers.keySet());
            }

            if(!contactIds.isEmpty() && Contact.SObjectType.getDescribe().isAccessible()) {
                eventWrapper.attorneyAttendees = [SELECT Id, Name, TOLABEL(CIBE_Carrec__c) FROM Contact WHERE Id IN :contactIds AND RecordTypeId IN :attorneyAttendeeRTs];
                eventWrapper.contactsAttendees = [SELECT Id, Name, TOLABEL(CIBE_Cargo__c) FROM Contact WHERE Id IN :contactIds AND RecordTypeId IN :contactsAttendeeRTs];
                eventWrapper.employeeAttendees = [SELECT Id, Name, AV_DescFuncion__c FROM Contact WHERE Id IN :contactIds AND RecordTypeId IN :employeeAttendeeRTs];
            }

            List<Contact> owners = new List<Contact>();
            if(Contact.SObjectType.getDescribe().isAccessible()) {
                owners = [SELECT Id, Account.CC_Numero_Oficina__c, Account.BillingAddress FROM Contact WHERE AV_UsuarioAsociado__c = :ev.OwnerId];
            }

            if(!owners.isEmpty()) {
                eventWrapper.center = owners.get(0).Account.CC_Numero_Oficina__c;

                Address address = owners.get(0).Account.BillingAddress;
                String formattedAddress = '';
                if(address != null) {
                    formattedAddress = address.getStreet();
                    if(String.isNotBlank(formattedAddress)) {
                        formattedAddress += (String.isNotBlank(address.getPostalCode()) ? ', ' + address.getPostalCode() : '');
                        formattedAddress += (String.isNotBlank(address.getCity()) ? ', ' + address.getCity() : '');
                        formattedAddress += (String.isNotBlank(address.getState()) ? ', ' + address.getState() : '');
                        formattedAddress += (String.isNotBlank(address.getCountry()) ? ', ' + address.getCountry() : '');
                    }
                }
                eventWrapper.centerAddress = formattedAddress;
            }
            
            if(String.isNotBlank(ev.WhatId) && Account.SObjectType.getDescribe().isAccessible()) {
                accounts = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE Id = :ev.WhatId];
            }

            List<AV_CustomActivityOpportunity__c> activityOpportunities = new List<AV_CustomActivityOpportunity__c>();
            if(String.isNotBlank(ev.AV_Task__c) && AV_CustomActivityOpportunity__c.SObjectType.getDescribe().isAccessible()) {
                activityOpportunities = [SELECT Id, AV_Opportunity__c, AV_IsMain__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :ev.AV_Task__c];
            }

            List<Id> opportunityIds = new List<Id>();
            for(AV_CustomActivityOpportunity__c activityOpportunity : activityOpportunities) {
                if(String.isNotBlank(activityOpportunity.AV_Opportunity__c)) {
                    opportunityIds.add(activityOpportunity.AV_Opportunity__c);
                }
            }

            if(Opportunity.SObjectType.getDescribe().isAccessible()) {
                opportunities = [SELECT Id, Name FROM Opportunity WHERE Id = :opportunityIds];
            }
        }
    }

    public class EventWrapper {
        public String subject { get; set; }
        public String location { get; set; }
        public String type { get; set; }
        public String activityDate { get; set; }
        public String conclusions { get; set; }
        public String owner { get; set; }
        public String center { get; set; }
        public String centerAddress { get; set; }
        public List<Contact> attorneyAttendees { get; set; }
        public List<Contact> contactsAttendees { get; set; }
        public List<Contact> employeeAttendees { get; set; }
    }
}