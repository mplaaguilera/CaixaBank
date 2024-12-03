/**********************************************************************************************************************
Name: CIBE_ConfidencialidadActivityCntr_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de la clase CIBE_ConfidencialidadActivityController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY 				AUTHOR              DATE                Description
    1.0            US479336    		        Lucia Muño         13/07/2023           Init version
***********************************************************************************************************************/

@IsTest
public with sharing class CIBE_ConfidencialidadActivityCntr_Test {
   
    @TestSetup
    static void setUp(){
        CIBE_TestInitialSetup.setupInitialDataEMP();

        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP'];

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


            RecordType rt = AV_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT);
            Task tarea  = new Task();
            tarea.Subject = 'Llamada Saliente Test';
            tarea.ownerId = u.id;	
            tarea.Status = 'Pendiente no localizado';
            tarea.Priority = 'Normal';
            tarea.AV_ExternalID__c = '01928363';
            tarea.RecordTypeId = rt.Id;
            tarea.ActivityDate = System.today()-3;
            tarea.CIBE_Confidential__c = true;
            insert tarea;

          
            }
        
    }

    @IsTest
    static void getRecordTest(){

        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP'];
        System.runAs(usuario){
        Test.StartTest();
            List<Event> e = [SELECT Id, CIBE_Confidential__c FROM Event WHERE Subject = 'Call' LIMIT 1];
            List<Task>  tsk = [SELECT Id,CIBE_Confidential__c FROM Task WHERE Subject = 'Llamada Saliente Test' AND OwnerId = :usuario.Id LIMIT 1];

            CIBE_ConfidencialidadActivityController.getRecord(e[0].Id);
            System.assertNotEquals(null, e.size());
            System.assertEquals(false, e[0].CIBE_Confidential__c);

            CIBE_ConfidencialidadActivityController.getRecord(tsk[0].Id);
            System.assertNotEquals(null, tsk.size());
            System.assertEquals(true, tsk[0].CIBE_Confidential__c);

        }
        Test.stopTest();
    }

    @IsTest
    static void saveRecordTest(){

        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP'];
        System.runAs(usuario){
        Test.StartTest();
            List<Event> e = [SELECT Id, CIBE_Confidential__c FROM Event WHERE Subject = 'Call' LIMIT 1];
            List<Task>  tsk = [SELECT Id,CIBE_Confidential__c FROM Task WHERE Subject = 'Llamada Saliente Test' AND OwnerId = :usuario.Id LIMIT 1];

            CIBE_ConfidencialidadActivityController.saveRecord(e[0].Id, true);
            System.assertNotEquals(null, e.size());
            Event eventUpdate = [SELECT Id, CIBE_Confidential__c FROM Event WHERE Subject = 'Call' LIMIT 1];
            System.assertEquals(true, eventUpdate.CIBE_Confidential__c);

            CIBE_ConfidencialidadActivityController.saveRecord(tsk[0].Id, false);
            System.assertNotEquals(null, tsk.size());
            Task  tskUpdate = [SELECT Id,CIBE_Confidential__c FROM Task WHERE Subject = 'Llamada Saliente Test' AND OwnerId = :usuario.Id LIMIT 1];
            System.assertEquals(false, tskUpdate.CIBE_Confidential__c);

        }
        Test.stopTest();

    }


    @IsTest
    static void isOwnerTest(){

        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP'];
        System.runAs(usuario){
        Test.StartTest();
            List<Event> e = [SELECT Id, OwnerId FROM Event WHERE Subject = 'Call' AND OwnerId = :usuario.Id LIMIT 1];

            Boolean owner =  CIBE_ConfidencialidadActivityController.isOwner(e[0].Id);
            System.assertEquals(false, owner);
        }
        Test.stopTest();

    }

    @IsTest
    static void getFields(){

        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP'];
        System.runAs(usuario){
        Test.StartTest();
        List<Event> e = [SELECT Id, OwnerId, CIBE_Confidential__c, AV_Task__r.CIBE_ConfidentialEventAccess__c FROM Event WHERE Subject = 'Call' AND OwnerId = :usuario.Id LIMIT 1];

        CIBE_ConfidencialidadActivityController.getFields(e[0].Id);

        System.assertNotEquals(null, e.size());
        }
        Test.stopTest();

    }

    @IsTest
    static void createNotification(){

        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP'];
        System.runAs(usuario){
        Test.StartTest();

        List<Event> e = [SELECT Id, CIBE_Confidential__c FROM Event WHERE Subject = 'Call' LIMIT 1];

        Contact employee = [SELECT Id FROM Contact WHERE FirstName = 'Empleado Test'];

        EventRelation evntr = new EventRelation();
        evntr.EventId = e[0].Id;
        evntr.RelationId = employee.Id;
        evntr.IsInvitee = true;
        insert evntr;

        CIBE_ConfidencialidadActivityController.createNotification(e[0].Id);

        System.assert(!e.isEmpty());

        }
        Test.stopTest();

    }


    

   
}