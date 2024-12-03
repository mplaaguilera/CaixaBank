/**********************************************************************************************************************
Name:	  AV_EventDelete_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Delete Events Test
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Jashanpreet	   	    22/03/2020		Init version
1.1			DE48668 	   Víctor Santiago 	    22/11/2021		Method testDeleteSeries added
1.1			DE48668 	   Víctor Santiago 	    22/11/2021		Method testDeleteSeries deleted
1.2		    AV_Query IT	   Daniel Rodríguez     03/03/2022	    Change AV_Query to SOQL for User, Account, Contact
1.3         US430868       Luis Fernández       17/08/2022      Added assertEquals to methods that does not have
***********************************************************************************************************************/
@isTest
public with sharing class AV_EventDelete_Test {
    
    @TestSetup
    static void setup(){
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        insert pb;
        Account acc = AV_TestHelper.createCaixaCenter();
        Account customer = AV_TestHelper.createCustomer();
        String labelProfile = 'Standard User';
        User u = AV_TestHelper.createUser(labelProfile);
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        //AV_TestHelper.createEvent(u, Datetime.now(), customer);
        // Test creation
        Datetime evActvDate = Datetime.now();
        Datetime recStartDate = Datetime.now();
        RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTCLIENTE_RT);
		Event event = new Event(
            Subject = 'Test event',
            WhatId = customer.Id,
            OwnerId = u.Id,
            AV_ExternalID__c = '000000000001',
            RecordTypeId = rt.Id,
            DurationInMinutes= 60,
            ActivityDateTime = evActvDate,
            AV_Tipo__c = 'CTO',
            StartDateTime = evActvDate,
            EndDateTime = evActvDate.addMinutes(60),
            CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE,
            AV_OrigenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP,
            AV_CodigoGestorAsignado__c = 'U0000001'
        );
		insert event;
        /*Event eventRecurrente = new Event(
            Subject = 'Test event recurrente',
            WhatId = customer.Id,
            OwnerId = u.Id,
            AV_ExternalID__c = '000000015462',
            RecordTypeId = rt.Id,
            DurationInMinutes= 60,
            ActivityDateTime = evActvDate,
            AV_Tipo__c = 'CTO',
            StartDateTime = evActvDate,
            EndDateTime = evActvDate.addMinutes(60),
            CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE,
            AV_OrigenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP,
            IsRecurrence = true,
            RecurrenceStartDateTime = System.now(),
            RecurrenceEndDateOnly = System.today()+2,
            RecurrenceType = 'RecursEveryWeekday',
            RecurrenceDayofWeekMask = 1,
            AV_CodigoGestorAsignado__c = 'U0097541'
        );
		insert eventRecurrente;*/
        //AV_TestHelper.createEventConClienteRecurrente(u, customer);
    }
    
    /**
    * Execute the class (AV_EventDelete) and Delete event GCF
    */
    @isTest
    public static void testDeleteEventFromGCF() {
        String input;
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_DELCNT','OK'));  
        Test.startTest();
       	Event e = [SELECT Id from Event Where Subject = 'Test event' Limit 1];
        input = e.Id + ',N';
        AV_EventDelete.eventDeleteFromGCF(new List<String>{input});
        Test.stopTest();
        List<Event> e2 = [SELECT Id from Event Where Subject = 'Test event' Limit 1];
        System.assertEquals(0, e2.size());
    }

    @isTest
    public static void testDeleteRecurrentEventFromGCF() {
        String input;
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_DELCNT','OK'));  
        Test.startTest();
       	Event e = [SELECT Id from Event Where Subject = 'Test event' Limit 1];
        input = e.Id + ',Y';
        List<String> response = AV_EventDelete.eventDeleteFromGCF(new List<String>{input});
        Test.stopTest();
        System.assertEquals('OK',response[0],'No se ha borrado bien el evento');
    }
    
}