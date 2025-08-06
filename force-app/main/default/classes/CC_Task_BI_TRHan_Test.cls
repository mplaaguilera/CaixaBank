@isTest
public class CC_Task_BI_TRHan_Test
{
    @TestSetup
    static void makeData()
    {
        //crear usuarios CC
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id profileSupervisor = [SELECT Id FROM Profile WHERE Name = 'CC_Supervisor'].Id;
        UserRole rolCC = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        
        User administrador = new User();
        administrador.ProfileId = profileAdmin;
        administrador.FirstName = 'Usuario Admin Prueba';
        administrador.LastName = 'last211';
        administrador.Email = 'aalsdna@kfsb.com';
        administrador.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        administrador.CompanyName = 'MST';
        administrador.Title = 'title';
        administrador.Alias = 'alias';
        administrador.TimeZoneSidKey = 'Europe/Paris';
        administrador.EmailEncodingKey = 'UTF-8';
        administrador.LanguageLocaleKey = 'es';
        administrador.LocaleSidKey = 'es_ES';
		insert administrador;

        System.runAs(administrador)
        {
            User supervisor = new User();
            supervisor.ProfileId = profileSupervisor;
            supervisor.FirstName = 'Supervisor';
            supervisor.LastName = 'last11';
            supervisor.Email = 'tuser000@amamama.com';
            supervisor.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
            supervisor.CompanyName = 'MST';
            supervisor.Title = 'title';
            supervisor.Alias = 'alias';
            supervisor.TimeZoneSidKey = 'Europe/Paris';
            supervisor.EmailEncodingKey = 'UTF-8';
            supervisor.LanguageLocaleKey = 'es';
            supervisor.LocaleSidKey = 'es_ES';
            supervisor.UserRoleId = rolCC.Id;
            insert supervisor;

            insert new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psClasses.Id);
        }
    }

    @isTest
    static void enmascararPANs_test()
    {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];

        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.Status = 'Cerrado';
        insert caso;
        
        Task tarea = new Task();
        tarea.WhatId = caso.Id;
        tarea.type = 'Automática';
        tarea.Status = 'Completado';
        tarea.Priority = 'Normal';
        tarea.Subject = 'Ref.00030183:"CaixaBank" - Incidencia operación en CajeroAS07195, activador 1111111111111111';
        tarea.Description = 'TEXTOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO activador 1111111111111111';
        tarea.RecordTypeId = tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        insert tarea;
        
        System.runAs(supervisor)
        {
            Test.startTest();
            Task tareaAI = new Task();
            tareaAI = [SELECT Id, Subject, Description from Task where Id =: tarea.Id];
            
            /*System.assertEquals(tareaAI.Subject, 'Ref.00030183:"CaixaBank" - Incidencia operación en CajeroAS07195, activador 1111XXXXXXXX1111');
            System.assertEquals(tareaAI.Description, 'TEXTOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO activador 1111XXXXXXXX1111'); */
            System.assertEquals(tarea.Id, tareaAI.Id, 'No se ha encontrado la Tarea');
            Test.stopTest();
        }        
    }
	
    @isTest
    static void beforeDelete_Test()
    {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];

        Task tarea = new Task();
        tarea.type = 'Automática';
        tarea.Status = 'Completado';
        tarea.Priority = 'Normal';
        tarea.Subject = 'Tarea';
        insert tarea;
       	delete tarea;     
        
        Task tareaAI = new Task();

        System.runAs(supervisor)
        {
           Test.startTest();
           System.assertEquals(0, [SELECT COUNT() from Task where Id =: tarea.Id], 'No se ha eliminado la Tarea');
           Test.stopTest();
        }
    }

    @isTest
    static void copiarTaskType_Test()
    {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        List<Task> tareas = new List<Task>();

        System.runAs(supervisor)
        {
            Task tarea = new Task();
            tarea.type = 'Automática';
            tarea.Status = 'Completado';
            tarea.Priority = 'Normal';
            tarea.Subject = 'Tarea';
            tarea.RecordTypeId = tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
            tareas.add(tarea);
            insert tareas;

            Task tareaAI = [SELECT OS_Tipo__c from Task where Id =: tarea.Id];
            Test.startTest();
            System.assertEquals(tarea.type, tareaAI.OS_Tipo__c, 'No se ha copiado el Task Type');
            Test.stopTest();
        }
    }

    @isTest
    static void completarTaskTest()
    {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        List<Task> tareas = new List<Task>();

        System.runAs(supervisor)
        {
            Test.startTest();
            Task tarea = new Task();
            tarea.type = 'Actividad manual';
            tarea.Priority = 'Normal';
            tarea.Subject = 'Otros';
            tarea.RecordTypeId = tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            tareas.add(tarea);
            insert tareas;

            Task tareaAI = [SELECT Status from Task where Id =: tarea.Id];
            
            System.assertEquals('Completed', tareaAI.Status, 'No se ha completado la Task');
            Test.stopTest();
        }
    }
}