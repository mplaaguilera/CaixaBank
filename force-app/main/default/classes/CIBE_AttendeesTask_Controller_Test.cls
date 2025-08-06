@isTest
public with sharing class CIBE_AttendeesTask_Controller_Test {
    
    @TestSetup
    public static void testSetup(){
        User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
        Account center = CIBE_TestHelper.createCaixaCenter();
        CIBE_TestHelper.createEmployee(center, usrTest);
        Account customer = CIBE_TestHelper.createCustomer();

        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);

        Task task = new Task();
        task.Subject = 'Task Subject';
        task.RecordTypeId = rt.Id;
        task.WhatId = customer.Id;
        task.OwnerId= UserInfo.getUserId();
        task.Description = 'Description';
        task.AV_CodigoGestorAsignado__c = '123456';
        task.Status = CIBE_AppConstants.TASK_STATUS_PENDIENTE;
        task.ActivityDate = System.now().Date();
        task.AV_AssociatedOpportunityId__c='1234';
        insert task;
    }

    @isTest
    public static void searchUserTest(){
        List<Contact> employee = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CC_Empleado'];
        
        Test.startTest();
        List<AV_LookupSearchResult> results = CIBE_AttendeesTask_Controller.searchUser('pleado', new List<String>());
        System.assert(results.isEmpty());
        
        results = CIBE_AttendeesTask_Controller.searchUser('pleado', new List<String>{employee[0].Id});
        System.assert(results.isEmpty());
        Test.stopTest();
    }

    @isTest
    public static void getAttendeesTest(){
        Task task = [SELECT Id FROM Task LIMIT 1];
        List<Contact> employee = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CC_Empleado'];

        Test.startTest();
        CIBE_AttendeesTask_Controller.createAttendees(task.Id, employee[0].Id);
        List<CIBE_AttendeesTask_Controller.Attendee> result = CIBE_AttendeesTask_Controller.getAttendees(task.Id);

        System.assertEquals(1, result.size());
        Test.stopTest();
   }

    @isTest
    public static void createAttendeesTest(){
        Task task = [SELECT Id FROM Task LIMIT 1];
        List<Contact> employee = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CC_Empleado'];
        
        Test.startTest();
        List<CIBE_AttendeesTask_Controller.Attendee> result = CIBE_AttendeesTask_Controller.getAttendees(task.Id);

        System.assertEquals(0, result.size());

        CIBE_AttendeesTask_Controller.createAttendees(task.Id, employee[0].Id);
        result = CIBE_AttendeesTask_Controller.getAttendees(task.Id);

        System.assertEquals(1, result.size());
        Test.stopTest();
    }

    @isTest
    public static void deleteAttendeesTest(){
        Task task = [SELECT Id FROM Task LIMIT 1];
        List<Contact> employee = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CC_Empleado'];
        
        Test.startTest();
        CIBE_AttendeesTask_Controller.createAttendees(task.Id, employee[0].Id);
        List<CIBE_AttendeesTask_Controller.Attendee> result = CIBE_AttendeesTask_Controller.getAttendees(task.Id);

        System.assertEquals(1, result.size());

        TaskRelation tr = [SELECT Id FROM TaskRelation WHERE TaskId = :task.Id AND Relation.RecordType.DeveloperName = 'CC_Empleado' LIMIT 1];
        System.debug([SELECT Id, TaskId, Relation.Name, Account.Name FROM TaskRelation]);
        CIBE_AttendeesTask_Controller.deleteAttendees(tr.Id);

        result = CIBE_AttendeesTask_Controller.getAttendees(task.Id);
        System.assertEquals(0, result.size());
        Test.stopTest();
    }

}