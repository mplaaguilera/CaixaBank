/**********************************************************************************************************************
Name:      CIBE_EventAttendesComponent_CntrTest
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase CIBE_EventAttendesComponent_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY 				AUTHOR              DATE                Description
    1.0            US743059       		    Lucia Muñoz         12/01/2024          Init version
***********************************************************************************************************************/
@IsTest
public with sharing class CIBE_EventAttendesComponent_CntrTest {
    

    @TestSetup
    static void makeData(){
        CIBE_TestInitialSetup.setupInitialDataCIB();
        List<Contact> contactos = new List<Contact>();
        List<CIBE_RelaccionadoCita__c> junctions = new List<CIBE_RelaccionadoCita__c>();
        List<EventRelation> relations = new List<EventRelation>();

        User us = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'CIB'];
        
        
        Account acc = CIBE_TestHelper.createCustomer(us);
        Event evnt = CIBE_TestHelper.createEvent(us, System.now(), acc);
        Contact cnt = [SELECT Id FROM Contact WHERE FirstName = 'Employee'];
        
        Contact cnt2 = CIBE_TestHelper.createEmployeeSinInsert(acc, us);
        contactos.add(cnt2);
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.CONTACT_APODERADO_RT);
        Contact cnt3 = new Contact();
        cnt3.RecordTypeId = rt.Id;
        cnt3.FirstName = 'Empleado 3';
        cnt3.LastName = '1';
        cnt3.CC_Idioma__c = 'es';
        cnt3.CIBE_Cartera__c = '001';
        cnt3.CIBE_Sector__c = '001';
        cnt3.AccountId = acc.Id;
        cnt3.AV_UsuarioAsociado__c = us.Id;
        contactos.add(cnt3);
        
        insert contactos;
        
        
        String header = [SELECT Id, AV_Task__c FROM Event WHERE Subject = 'Call' AND OwnerId = :us.Id].AV_Task__c;

        

        CIBE_RelaccionadoCita__c junction = new CIBE_RelaccionadoCita__c();
        junction.CIBE_Contacto__c = cnt.Id;
        junction.CIBE_CitaRelaccionada__c  = header;
        junction.CIBE_TipoAsistente__c = 'Asistentes Caixabank';
        junction.ownerId = us.Id;
        junctions.add(junction);
        
        CIBE_RelaccionadoCita__c junction2 = new CIBE_RelaccionadoCita__c();
        junction2.CIBE_Contacto__c = cnt.Id;
        junction2.CIBE_CitaRelaccionada__c  = header;
        junction2.CIBE_TipoAsistente__c = 'Asistentes Clientes';
        junction2.ownerId = us.Id;
        junctions.add(junction2);
        
        CIBE_RelaccionadoCita__c junction3 = new CIBE_RelaccionadoCita__c();
        junction3.CIBE_Contacto__c = cnt3.Id;
        junction3.CIBE_CitaRelaccionada__c  = header;
        junction3.CIBE_TipoAsistente__c = 'Asistentes sin registrar';
        junction3.ownerId = us.Id;
        junctions.add(junction3);
        
        insert junctions;
        
        
        EventRelation relation = new EventRelation();
        relation.EventId = evnt.Id;
        relation.RelationId  = cnt.Id;
        relation.IsInvitee = true;
        relations.add(relation);
        
        EventRelation relation2 = new EventRelation();
        relation2.EventId = evnt.Id;
        relation2.RelationId  = cnt2.Id;
        relation2.IsInvitee = true;
        relations.add(relation2);
        
        EventRelation relation3 = new EventRelation();
        relation3.EventId = evnt.Id;
        relation3.RelationId  = cnt3.Id;
        relation3.IsInvitee = true;
        relations.add(relation3);
        
        insert relations;

        
    }

    @IsTest
    public static void getEvent (){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'CIB'];
        System.runAs(usuario){
        Test.StartTest();
            List<Event> e = [SELECT Id, OwnerId FROM Event WHERE Subject = 'Call' AND OwnerId = :usuario.Id LIMIT 1];

            CIBE_EventAttendesComponent_Controller.getEvent(e[0].Id);
            System.assert(e != null);
        }
        Test.stopTest();
    }


    @IsTest
    public static void returnAttendeesCaixabank (){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'CIB'];
        System.runAs(usuario){
        Test.StartTest();
            List<Event> e = [SELECT Id, OwnerId FROM Event WHERE Subject = 'Call' AND OwnerId = :usuario.Id LIMIT 1];

            List<CIBE_EventAttendesComponent_Controller.AttendeeWrapper> attendees =  CIBE_EventAttendesComponent_Controller.returnAttendeesCaixabank(e[0].Id);
            System.assert(attendees != null);
        }
        Test.stopTest();
    }


    @IsTest
    public static void returnAttendeesCliente (){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'CIB'];
        System.runAs(usuario){
        Test.StartTest();
            List<Event> e = [SELECT Id, OwnerId FROM Event WHERE Subject = 'Call' AND OwnerId = :usuario.Id LIMIT 1];

            List<CIBE_EventAttendesComponent_Controller.AttendeeWrapper> attendees =  CIBE_EventAttendesComponent_Controller.returnAttendeesCliente(e[0].Id);
            System.assert(attendees != null);
        }
        Test.stopTest();
    }

    @IsTest
    public static void returnAttendeesSinRegistrar (){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'CIB'];
        System.runAs(usuario){
        Test.StartTest();
            List<Event> e = [SELECT Id, OwnerId FROM Event WHERE Subject = 'Call' AND OwnerId = :usuario.Id LIMIT 1];

            List<CIBE_EventAttendesComponent_Controller.AttendeeWrapper> attendees =  CIBE_EventAttendesComponent_Controller.returnAttendeesSinRegistrar(e[0].Id);
            System.assert(attendees != null);
        }
        Test.stopTest();
    }


    @IsTest
    public static void searchUserClientes (){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'CIB'];
        System.runAs(usuario){
        Test.StartTest();
            Account acc = [SELECT Id FROM Account WHERE  AV_NumPerso__c = '123' AND AV_Negocio__c = 'CIB' AND RecordType.DeveloperName =:CIBE_AppConstants.ACCOUNT_CLIENTE_RT limit 1];
            Event newEvnt = new Event(ownerId = usuario.Id, whatId = acc.Id,  DurationInMinutes = 30, ActivityDateTime = System.now());
            insert newEvnt;
            Contact employee = [SELECT Id, Name FROM Contact WHERE FirstName = 'Empleado 3'];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = employee.Id;
            Test.setFixedSearchResults(fixedSearchResults);
            List<String> selectIds = new List<String>();
            List<AV_LookupSearchResult> results = CIBE_EventAttendesComponent_Controller.searchUserClientes('Empl', selectIds, acc.Id,  newEvnt.Id);
            System.assert(!results.isEmpty());
        }
        Test.stopTest();
    }
    
    
    @IsTest
    public static void testProcessAsistentes (){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'CIB'];
        Contact employee = [SELECT Id, Name FROM Contact WHERE FirstName = 'Empleado'];
        Contact employee2 = [SELECT Id, Name FROM Contact WHERE FirstName = 'Empleado 3'];
        System.runAs(usuario){
        Test.StartTest();
            Account acc = [SELECT Id FROM Account limit 1];
            Event newEvnt = new Event(ownerId = usuario.Id, whatId = acc.Id,  DurationInMinutes = 30, ActivityDateTime = System.now());
            insert newEvnt;
            List<Map<String, Object>> asistentes = new List<Map<String, Object>>();
            Map<String, Object> sinRegistrar = new Map<String, Object>();
            sinRegistrar.put('id', 'Idprovisional');
            sinRegistrar.put('email', 'test@test.es');
            sinRegistrar.put('tipoAsistente', 'Sin Registrar');
            sinRegistrar.put('enviarCita', true);
            Map<String, Object> asistenteCaixaBank = new Map<String, Object>();
            asistenteCaixaBank.put('id', employee.Id);
            asistenteCaixaBank.put('tipoAsistente', 'CaixaBank');
            asistenteCaixaBank.put('enviarCita', true);
            Map<String, Object> asistenteCliente = new Map<String, Object>();
            asistenteCliente.put('id', employee.Id);
            asistenteCliente.put('tipoAsistente', 'Cliente');
            asistenteCliente.put('enviarCita', true);
            asistentes.add(sinRegistrar);
            asistentes.add(asistenteCaixaBank);
            asistentes.add(asistenteCliente);
            
            CIBE_EventAttendesComponent_Controller.processAsistentes(newEvnt.Id, asistentes);
            
            List<CIBE_RelaccionadoCita__c> relCita = [SELECT Id From CIBE_RelaccionadoCita__c WHERE CIBE_Email__c = 'test@test.es'];
            System.assert(!relCita.isEmpty());
        }
        Test.stopTest();
    }

        
    @IsTest
    public static void testSearchUserClientes (){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'CIB'];
        Account acc = [SELECT Id FROM Account limit 1];
        System.runAs(usuario){
        Test.StartTest();
            Event newEvnt = new Event(ownerId = usuario.Id, whatId = acc.Id,  DurationInMinutes = 30, ActivityDateTime = System.now());
            insert newEvnt;
            Contact cnt = [SELECT Id, accountId FROM Contact WHERE FirstName = 'Employee'];
            List<String> selectedIds = new List<String>();
            selectedIds.add(cnt.id);
            
            List<AV_LookupSearchResult> lkpSearch = CIBE_EventAttendesComponent_Controller.searchUserClientes('Empl', selectedIds, cnt.AccountId,  newEvnt.id);
            
            System.assert(lkpSearch.isEmpty());
        }
        Test.stopTest();
    }      
        
    @IsTest
    public static void testDeleteAttende (){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'CIB'];
        
        System.runAs(usuario){
        Test.StartTest();
            Event evt = [SELECT Id, AV_Task__c FROM Event WHERE Subject = 'Call' limit 1];
            CIBE_RelaccionadoCita__c relacionToDelete = [SELECT ID, CIBE_Contacto__c FROM CIBE_RelaccionadoCita__c WHERE CIBE_CitaRelaccionada__c = :evt.AV_Task__c Limit 1];
            
            CIBE_EventAttendesComponent_Controller.deleteAttende(relacionToDelete.Id, evt.Id);
            
            List<CIBE_RelaccionadoCita__c> relacionToDeleteList = [SELECT ID FROM CIBE_RelaccionadoCita__c WHERE CIBE_CitaRelaccionada__c = :evt.AV_Task__c and CIBE_Contacto__c = :relacionToDelete.CIBE_Contacto__c Limit 1];

            System.assertNotEquals(relacionToDelete, relacionToDeleteList[0] );
        }
        Test.stopTest();
    }      
}