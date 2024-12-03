/**********************************************************************************************************************
Name:	  AV_CitaPrevia_SyncEvents_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Sync de Eventos Test
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY	   AUTHOR		   		DATE			Description
    1.0			Test Class	   Jashanpreet	   	    20/10/2020		Init version
	1.1			Test Class	   David Rufo	   	    11/05/2021		Update sync recurrent event's for employees
	1.2		    AV_Query IT	   Daniel Rodríguez	    07/02/2022	    Change AV_Query to SOQL for User and Account
	1.3			US456937	   Patricia Solano		13/11/2022		Added method createRecurrentEventHeaderTes 
                                                                    and modified testSyncInsert, testSyncUpdate,
                                                                    insertOrUpdateEventTrueTest, insertOrUpdateEventFalseTest  
                                                                    and testSyncTelephoneContracting for add assertion
	1.4			PPM100538432   Sandra Gómez			19/09/2024		Change to CBK_IntegrationSetting__c
***********************************************************************************************************************/
@isTest
public with sharing class AV_CitaPrevia_SyncEvents_Test {
    
    @TestSetup
    static void setup(){
        AV_TestHelper.activateLogger();
        insert new List<CBK_IntegrationSetting__c>{
        new CBK_IntegrationSetting__c(
            Name = 'AV_citaprevia_int',
            NamedCredential__c = 'callout:API_GWT_PRO/tech/asesorventasactivitiesapi/employees/{employeeId}/activities/eventsPremium',
            CBK_Method__c = 'POST'
        ), new CBK_IntegrationSetting__c(
            Name = 'AV_citaprevia_mo',
            NamedCredential__c = 'callout:API_GWT_PRO/tech/asesorventasactivitiesapi/activities/eventsPremium/{id}',
            CBK_Method__c = 'POST'
        )};
        AV_TestHelper.createPricebook2();
        User userCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        Account caixaCenter;
        Account customer;
        System.runAs(userCli) {
            caixaCenter = AV_TestHelper.createCaixaCenter();
        	//customer = AV_TestHelper.createCustomer();
        }
        User user = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U0009003');
        User user2 = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U0009005');
        List<User> listUser = new List<User>{user,user2};
        insert listUser;
        Contact contactAux = AV_TestHelper.createEmployeeSinInsert(caixaCenter, user,'U0009003');
        Contact contactAux2 = AV_TestHelper.createEmployeeSinInsert(caixaCenter, user,'U0009005');
        List<Contact> listContact = new List<Contact>{contactAux,contactAux2};
        insert listContact;
        System.runAs(userCli) {
            customer = AV_TestHelper.createCustomerWithEAPGestor(contactAux);
        }
        User userGCF = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];

    
        Event customerRecurrenceEvent = AV_TestHelper.createEventConClienteRecurrente(user, customer);
        List<EventRelation> listEventRela = [SELECT Id FROM EventRelation WHERE RelationId =:user2.Id AND EventId = :customerRecurrenceEvent.Id];
        if (listEventRela != null && !listEventRela.isEmpty()) {
            System.runAs(userGCF) {
                AV_TestHelper.insertNeededPermissions(user);
                EventRelation evRel = new EventRelation();
                evRel.RelationId = user2.Id;
                evRel.EventId = customerRecurrenceEvent.Id;
                evRel.isWhat = false;
                evRel.isParent = false;
                evRel.isInvitee = true;
                insert evRel;
            }
        }
    }
    
    /**
    * Execute the class (AV_CitaPrevia_SyncEvents) and insert event GCF
    */
    @isTest
    public static void testSyncInsert() {
        Account customer =  [SELECT Id FROM Account Where AV_NumPerso__c = '123' Limit 1];
        User user = [SELECT Id,AV_ExternalID__c,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U0009003' Limit 1];
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        Test.startTest();
        Event customerEvent;
        Event recurrenceEvent;
        System.runAs(user) {
            customerEvent = AV_TestHelper.createEventConCliente(user, System.now(), customer);
        	recurrenceEvent = AV_TestHelper.createEventConClienteRecurrente(user, customer);
        }
        Test.stopTest();
        //Check results
        List<AV_HeaderCustomActivity__c> headerCustAct  = [Select Id, IDTask__c, AV_ExternalID__c From AV_HeaderCustomActivity__c Where IDTask__c = :recurrenceEvent.Id];
        System.assertEquals(true, headerCustAct != null, 'Cabecera-Tarea no creada');
    }
    
    /**
    * Execute the class (AV_CitaPrevia_SyncEvents) and update event GCF
    */
    @isTest
    public static void testSyncUpdate() {
        Account customer =  [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' Limit 1];
        User user = [SELECT Id,AV_ExternalID__c,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U0009003' Limit 1];
        Event event = AV_TestHelper.createEventConCliente(user, dateTime.now(), customer);
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_MOCNT','OK'));
        Test.startTest();
        String result;
        System.runAs(user) {
            result = event.Description = 'Update event';
        	update event;
        }
        Test.stopTest();
        System.assertEquals(event.Description, result);
    }
    
    /**
    * Execute the class (AV_CitaPrevia_SyncEvents) and insert TelephoneContracting event GCF 
    */
    @isTest
    public static void testSyncTelephoneContracting() {
        Account customer =  [SELECT Id FROM Account Where AV_NumPerso__c = '123' Limit 1];
        User user = [SELECT Id,AV_ExternalID__c,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U0009003' Limit 1];
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        Test.startTest();
        Opportunity oppo = AV_TestHelper.createOpportunityWithContract(customer,user);
        List<Opportunity> listOpps = new  List<Opportunity>{oppo};
        String jsonString = json.serialize(listOpps);
        System.runAs(user) {
            AV_CitaPrevia_SyncEvents.insertEventTelephoneContracting(jsonString);
        }
        Test.stopTest();
        System.assertNotEquals(null, jsonString);
    }
    
    /**
    * Execute the class (AV_CitaPrevia_SyncEvents) and insert Event update event  
    */
    @isTest
    public static void insertOrUpdateEventTrueTest() {
        Account customer =  [SELECT Id FROM Account Where AV_NumPerso__c = '123' Limit 1];
        List<User> users = [SELECT Id,AV_ExternalID__c,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c in ('U0009003','U0009005')];
        User us1;
        User us2;
        for (User us : users) {
            if (us.AV_ExternalID__c == 'U0009003') {
                us1 = us;
            } else {
                us2 = us;
            }
        }
        Event customerEvent = AV_TestHelper.createEventConCliente(us1, System.now(), customer);
        //Event customerRecurrenceEvent = AV_TestHelper.createEventConClienteRecurrente(us1, customer);
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        Test.startTest();
        List<Event> listEvent = [SELECT Id, Subject, WhatId, RecordTypeId, OwnerId, DurationInMinutes, ActivityDateTime, IsRecurrence, RecurrenceStartDateTime, RecurrenceEndDateOnly ,RecurrenceType,
        RecurrenceDayofWeekMask ,AV_OrigenApp__c, CreatedDate, StartDateTime, EndDateTime, AV_CodigoGestorAsignado__c FROM EVENT WHERE Subject in ('Call','Test Event 001-A')];
        String jsonString = json.serialize(listEvent);
        
        System.runAs(us1) {
            AV_CitaPrevia_SyncEvents.insertOrUpdateEvent(jsonString, true);
        }
        Test.stopTest();
        System.assertNotEquals(null, jsonString);
    }
    
    /**
    * Execute the class (AV_CitaPrevia_SyncEvents) and insert Event not update event 
    */
    @isTest
    public static void insertOrUpdateEventFalseTest() {
        Account customer =  [SELECT Id FROM Account Where AV_NumPerso__c = '123' Limit 1];
        User user = [SELECT Id,AV_ExternalID__c,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U0009003' Limit 1];
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        Test.startTest();
        Event customerEvent = AV_TestHelper.createEventConCliente(user, System.now(), customer);
        List<Event> listEvent = new  List<Event>{customerEvent};
        String jsonString = json.serialize(listEvent);
        System.runAs(user) {
            AV_CitaPrevia_SyncEvents.insertOrUpdateEvent(jsonString, false);
        }
        Test.stopTest();
        System.assertNotEquals(null, jsonString);
    }
   
    /**
    * Execute the class (AV_CitaPrevia_SyncEvents) for test the method createRecurrentEventHeader
    */
    @isTest
    public static void createRecurrentEventHeaderTest() {
        Account customer =  [SELECT Id FROM Account Where AV_NumPerso__c = '123' Limit 1];
        User user = [SELECT Id,AV_ExternalID__c,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U0009003' Limit 1];
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        Test.startTest();
        AV_HeaderCustomActivity__c result;
        System.runAs(user) {
            Event customerEvent = AV_TestHelper.createEventConClienteRecurrente(user, customer);
        	result = AV_CitaPrevia_SyncEvents.createRecurrentEventHeader(customerEvent, user.AV_ExternalID__c);
        }
        Test.stopTest();
        System.assertNotEquals(null, result);
    }
}