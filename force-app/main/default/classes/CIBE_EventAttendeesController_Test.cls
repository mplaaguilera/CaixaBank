/**********************************************************************************************************************
Name: CIBE_EventAttendeesController_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de la clase CIBE_EventAttendeesController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY 				AUTHOR              DATE                Description
    1.0            US479336    		        Lucia Muño         13/07/2023           Init version
***********************************************************************************************************************/

@IsTest
public with sharing class CIBE_EventAttendeesController_Test {
   

    @TestSetup
    static void makeData(){
        CIBE_TestInitialSetup.setupInitialDataEMP();

        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP'];

        Test.StartTest();
        System.runAs(new User(Id = UserInfo.getUserId())){

            User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');

            Account acc =  CIBE_TestHelper.createCustomer();

            Event evnt = CIBE_TestHelper.createEvent(u, System.now(), acc);

            RecordType rtC = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.EMPLOYEE_RT);
            
            Contact employee = new Contact();
            employee.RecordTypeId = rtC.Id;
            employee.FirstName = 'Empleado Test';
            employee.LastName = '1';
            employee.CC_Idioma__c = 'es';
            employee.CC_Matricula__c = 'U01';
            employee.CIBE_Cartera__c = '001';
            employee.CIBE_Sector__c = '001';
            employee.AccountId = acc.Id;
            employee.AV_UsuarioAsociado__c = usrTest.Id;
            employee.OwnerId = u.Id;
            insert employee;

            Contact employee2 = new Contact();
            employee2.RecordTypeId = rtC.Id;
            employee2.FirstName = 'Test';
            employee2.LastName = '2';
            employee2.CC_Idioma__c = 'es';
            employee2.CC_Matricula__c = 'U02';
            employee2.CIBE_Cartera__c = '001';
            employee2.CIBE_Sector__c = '001';
            employee2.AccountId = acc.Id;
            employee2.AV_UsuarioAsociado__c = usrTest.Id;
            employee2.OwnerId = u.Id;
            insert employee2;

            EventRelation evntr = new EventRelation();
            evntr.EventId = evnt.Id;
            evntr.RelationId = employee2.Id;
            evntr.IsInvitee = true;
            insert evntr;

            Test.stopTest();
        }
    }

    @IsTest
    static void isOwnerTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP'];
        System.runAs(usuario){
        Test.StartTest();
            List<Event> e = [SELECT Id, OwnerId FROM Event WHERE Subject = 'Call' AND OwnerId = :usuario.Id LIMIT 1];

            Boolean owner =  CIBE_EventAttendeesController.isOwner(e[0].Id);
            System.assertEquals(true, owner);
        }
        Test.stopTest();
    }


    @IsTest
    static void createAttendeeTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP'];
        System.runAs(usuario){
        Test.StartTest();
            List<Event> e = [SELECT Id, OwnerId FROM Event WHERE Subject = 'Call' AND OwnerId = :usuario.Id LIMIT 1];

            Contact employee = [SELECT Id FROM Contact WHERE FirstName = 'Empleado Test'];

            CIBE_EventAttendeesController.createAttendee(e[0].Id, employee.Id);

            EventRelation evntR = [SELECT Id FROM EventRelation WHERE EventId =: e[0].Id AND RelationId = :employee.Id];
            System.assert(evntR != null);
        }
        Test.stopTest();
    }

    @IsTest
    static void removeAttendeeTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP'];
        System.runAs(usuario){
        Test.StartTest();
            List<Event> e = [SELECT Id, OwnerId FROM Event WHERE Subject = 'Call' AND OwnerId = :usuario.Id LIMIT 1];
            Contact employee = [SELECT Id FROM Contact WHERE LastName = '2'];
            EventRelation evntR = [SELECT Id FROM EventRelation WHERE EventId = :e[0].Id AND RelationId = :employee.Id AND IsInvitee = :true];
            System.assert(evntR != null);

            CIBE_EventAttendeesController.removeAttendee(e[0].Id, evntR.Id);

            List<EventRelation> evntRUpdate = [SELECT Id FROM EventRelation WHERE EventId =: e[0].Id AND RelationId = :employee.Id AND IsInvitee = :true];
            System.assert(evntRUpdate.isEmpty());
            
        }
        Test.stopTest();
    }

    @IsTest
    static void searchTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP'];
        System.runAs(usuario){
        Test.StartTest();
            List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
            List<Event> e = [SELECT Id, OwnerId FROM Event WHERE Subject = 'Call' AND OwnerId = :usuario.Id LIMIT 1];
            Contact employee = [SELECT Id, Name FROM Contact WHERE FirstName = 'Empleado Test'];
            System.debug('@@@ ' + employee);
            String searchTerm= 'Empleado';
            List<String> selectedIds= new List<String>();
            results = CIBE_EventAttendeesController.search(e[0].Id, searchTerm, selectedIds);
            System.assert(results != null);
            
        }
        Test.stopTest();
    }


    @IsTest
    static void getRecordTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP'];
        System.runAs(usuario){
        Test.StartTest();
            List<Event> e = [SELECT Id, OwnerId FROM Event WHERE Subject = 'Call' AND OwnerId = :usuario.Id LIMIT 1];
            
           
            List<CIBE_EventAttendeesController.AttendeeWrapper> result = CIBE_EventAttendeesController.getRecord(e[0].Id);
            System.assert(true, result[0].undecided);
            
        }
        Test.stopTest();
    }

    
}