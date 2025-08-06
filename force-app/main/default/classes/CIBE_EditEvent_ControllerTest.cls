@IsTest
public with sharing class CIBE_EditEvent_ControllerTest {

    //eventsInfo = [SELECT Id, AccountId, Account.Name, RecordType.DeveloperName, Who.Name, OwnerId, Owner.Name, Subject,
    //Description, AV_Tipo__c, StartDateTime, EndDateTime, ActivityDate, Location, CIBE_Confidential__c, CreatedById

    
    @TestSetup
    static void makeData(){

        List <String> psA = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        ID rtOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.OPP_INICIATIVAEMP_RT).getRecordTypeId();

        CIBE_TestInitialSetup.setupInitialData(null, CIBE_AppConstants.CIBE_ROLEMP, null, null, null, psA);
        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        User usrGes = [SELECT Id, Name FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usrSetup){
        Test.startTest();
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            
            Account acc = new Account();
            acc.Name = 'Acc Test';
            acc.RecordTypeId = rt.Id;
            acc.AV_NumPerso__c = '123';
            acc.AV_Negocio__c = 'EMP';
            acc.OwnerId = usrGes.Id;
            insert acc;

            DateTime activityDate = Datetime.now();
            RecordType rtE = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
            Event nEvent = CIBE_TestHelper.createEventConCliente(usrGes, activityDate, acc);
            nEvent.Subject = 'Call';
            nEvent.WhatId = acc.Id;
            nEvent.AV_Tipo__c = 'VLD';
            nEvent.OwnerId = usrGes.Id;
            
            DateTime now = System.now();
            String randomExternalId = String.valueof((Math.random() * 10000000));
            nEvent.AV_ExternalID__c = randomExternalId;
            nEvent.RecordTypeId = rtE.Id;
            nEvent.DurationInMinutes= 60;
            nEvent.ActivityDateTime = now;
            nEvent.StartDateTime = now;
            nEvent.EndDateTime = System.now().addMinutes(60);
            nEvent.CSBD_Evento_Estado__c = CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
            nEvent.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
            nEvent.Description = 'Prueba';
            update nEvent;

            Event evTest = CIBE_TestHelper.createEventConCliente(usrGes, activityDate, acc);
            evTest.Subject = 'Test Evento';
            evTest.WhatId = acc.Id;
            evTest.AV_Tipo__c = 'VLD';
            update evTest;
        }
        Test.stopTest();
    }    


    @isTest
    public static void getInfoClienteTest(){
        User usuario = [SELECT Id, Name FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            CIBE_EditEvent_Controller.Wrapper w;

            Event ev = [SELECT id FROM Event where Subject='Call'];
            Account acc =  [SELECT id FROM Account where Account.Name='Acc Test'];
            Contact cont =  [SELECT id FROM Contact where AV_UsuarioAsociado__r.AV_ExternalID__c = 'U0000001'];
        
            EventRelation evRelation = new EventRelation();
            evRelation.RelationId = cont.Id;
            evRelation.EventId = ev.Id;
            evRelation.IsInvitee = true;
            insert evRelation;

            w = CIBE_EditEvent_Controller.getInfoCliente(ev.Id.toString());
            System.assertNotEquals(null, w);
        }
        
        Test.stopTest();
    }



    @isTest
    public static void updateEvent(){
        User usuario = [SELECT Id, Name FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            String evStr;
            Event evento = [SELECT Id, AccountId, Account.Name, RecordTypeId, RecordType.DeveloperName, WhoId, Who.Name, OwnerId, Owner.Name, Subject, Description, AV_Tipo__c, StartDateTime, EndDateTime, ActivityDate, Location, CIBE_Confidential__c
            FROM Event WHERE Subject='Test Evento' LIMIT 1];
            Contact cont =  [SELECT id FROM Contact where AV_UsuarioAsociado__r.AV_ExternalID__c = 'U0000001' LIMIT 1];
            List<Event> evList;
            evStr = '{"Id":"'+evento.Id+'","RecordTypeId":"'+evento.RecordTypeId+'","WhatId":"'+evento.accountId+'","WhoId":"'+cont.Id+'","OwnerId":"'+evento.OwnerId+'","Subject":"Test update 2","Duration":"60","Description":"Cerrar cita 20/06 1650","Tipo":"VC","StartDateTime":"2024-06-20 05:00","EndDateTime":"2024-06-20 06:00","ActivityDate":"2024-06-20","Location":"Gijon","Confidential":false}';
            evList = CIBE_EditEvent_Controller.updateEvent(evStr);
            System.assertNotEquals(null, evList);
        }
        Test.stopTest();
    }

    @isTest
    public static void createRelation(){
        User usuario = [SELECT Id, Name FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            List<String>result = new List<String>();
            
            Event ev = [SELECT id FROM Event where Subject='Test Evento'];
            List<String> attendes = new List<String>();
            Contact cont =  [SELECT id FROM Contact where AV_UsuarioAsociado__r.AV_ExternalID__c = 'U0000001'];
            attendes.add(cont.Id);
            result = CIBE_EditEvent_Controller.createEventRelation2(ev.Id, attendes, cont.Id);
            System.assertNotEquals(null, result);
        }
        Test.stopTest();

    }
    
    
    @isTest
    public static void createRelationWihoutContact(){
        User usuario = [SELECT Id, Name FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            List<String>result = new List<String>();
            Contact cont =  [SELECT id FROM Contact where AV_UsuarioAsociado__r.AV_ExternalID__c = 'U0000001'];
            Event ev = [SELECT id FROM Event where Subject='Test Evento'];
            List<String> attendes = new List<String>();
            attendes.add(cont.Id);
            result = CIBE_EditEvent_Controller.createEventRelation2(ev.Id, attendes, null);
            System.assertNotEquals(null, result);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void createRelationWihoutEvent(){
        User usuario = [SELECT Id, Name FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            List<String>result = new List<String>();
            List<String> attendes = new List<String>();
            Contact cont =  [SELECT id FROM Contact where AV_UsuarioAsociado__r.AV_ExternalID__c = 'U0000001'];
            attendes.add(cont.Id);
            result = CIBE_EditEvent_Controller.createEventRelation2(null, attendes, cont.Id);
            System.assertNotEquals(null, result);
        }
        Test.stopTest();
    }
    
    
    @isTest
    public static void createRelationWihoutAttendes(){
        User usuario = [SELECT Id, Name FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            List<String>result = new List<String>();
            Event ev = [SELECT id FROM Event where Subject='Test Evento'];
            Contact cont =  [SELECT id FROM Contact where AV_UsuarioAsociado__r.AV_ExternalID__c = 'U0000001'];
            result = CIBE_EditEvent_Controller.createEventRelation2(ev.Id, null, cont.Id);
            System.assertNotEquals(null, result);
        }
        Test.stopTest();

    }
    
/*    @isTest
    public static void testCallApiTeams(){
        User usuario = [SELECT Id, Name FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Event ev = [SELECT id, RecordTypeId, AV_Tipo__c, CreatedById FROM Event where Subject='Call'];
            List<String> attendes = new List<String>();
            Contact cont =  [SELECT id FROM Contact where AV_UsuarioAsociado__r.AV_ExternalID__c = 'U0000001'];
            attendes.add(cont.Id);
            CIBE_EditEvent_Controller.callApiTeams(ev, attendes, cont.Id);
            List<EventRelation> evntRelation = [SELECT Id FROM EventRelation WHERE EventId = :ev.Id];
            System.assert(evntRelation != null);
        }
        Test.stopTest();
    }
        */
    

}