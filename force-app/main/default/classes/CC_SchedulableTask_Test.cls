@isTest
public with sharing class CC_SchedulableTask_Test {
    @TestSetup
    static void makeData(){
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
    static void scheduleTaskTest() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Usuario Admin Prueba' AND IsActive = TRUE LIMIT 1];
        List<Task> tareas = new List<Task>();
        //Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Incidencia'];

        System.runAs(supervisor)
        {
            Test.startTest();
            Task tarea = new Task();
            tarea.type = 'Actividad manual';
            tarea.Priority = 'Normal';
            tarea.Subject = 'Verificación cliente';
            tarea.RecordTypeId = tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            tareas.add(tarea);
            insert tareas;

            Task tareaResult = [SELECT Id, CreatedDate FROM Task WHERE Type = 'Actividad manual'];

            List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();
            CBK_SCH_PendingProcess__c pendingProcessTask = new CBK_SCH_PendingProcess__c();
            pendingProcessTask.recordId__c = tareaResult.Id;
            pendingProcessTask.Schedule_Time__c = tareaResult.CreatedDate.addHours(24);
            pendingProcessTask.className__c = 'CC_SchedulableTask';
            pendingProcessTask.Param1__c = 'CC_Task_Verificacion_Cliente';
            listaPendingProcess.add(pendingProcessTask);

            CC_SchedulableTask sca = new CC_SchedulableTask();
            sca.work(listaPendingProcess);

            System.assertNotEquals(null, sca, 'No se ha podido lanzar schedulable');
            
            Test.stopTest();
        }
    }

    @isTest
    static void scheduleTask2Test() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Usuario Admin Prueba' AND IsActive = TRUE LIMIT 1];
        List<Task> tareas = new List<Task>();
        //Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Incidencia'];

        System.runAs(supervisor)
        {
            Test.startTest();
            Task tarea = new Task();
            tarea.type = 'Traslado Colaborador';
            tarea.Priority = 'Normal';
            tarea.Subject = 'Personalizada';
            tarea.Status = 'Pending';
            tarea.RecordTypeId = tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            tareas.add(tarea);
            insert tareas;

            Task tareaResult = [SELECT Id, CreatedDate FROM Task WHERE Type = 'Traslado Colaborador'];

            List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();
            CBK_SCH_PendingProcess__c pendingProcessTask = new CBK_SCH_PendingProcess__c();
            pendingProcessTask.recordId__c = tareaResult.Id;
            pendingProcessTask.Schedule_Time__c = tareaResult.CreatedDate.addHours(24);
            pendingProcessTask.className__c = 'CC_SchedulableTask';
            pendingProcessTask.Param1__c = 'sendMailRecTrasladoColab';
            listaPendingProcess.add(pendingProcessTask);

            CC_SchedulableTask sca = new CC_SchedulableTask();
            sca.work(listaPendingProcess);

            System.assertNotEquals(null, sca, 'No se ha podido lanzar schedulable');
            
            Test.stopTest();
        }
    }

    @isTest
    static void scheduleTask3Test() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Usuario Admin Prueba' AND IsActive = TRUE LIMIT 1];
        List<Task> tareas = new List<Task>();
        //Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Incidencia'];

        System.runAs(supervisor)
        {
            Test.startTest();
            Id recordTypeIdCSIBankia = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
            Case oCaso = new Case();
            oCaso.Subject = 'Test Incidencia';
            oCaso.Origin = 'Email';
            oCaso.Status = 'Pendiente Colaborador';
            //oCaso.ContactId = testContact.Id;
            oCaso.CC_NotIncidencia__c = '1';
            oCaso.CC_MailTelfNotif__c = 'testcs@testcs.es';
            oCaso.CC_CanalNotifCli__c = 'Email';
            oCaso.CC_Idioma__c = 'es';
            oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
            oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
            oCaso.RecordTypeId = recordTypeIdCSIBankia;
            oCaso.Canal_del_Empleado__c = 'CSI';
            oCaso.CC_Canal_Procedencia__c = 'CCO CSI';
            oCaso.CC_Canal_Respuesta__c = 'Email';
            insert oCaso;

            Task tarea = new Task();
            tarea.type = 'Traslado Colaborador';
            tarea.Priority = 'Normal';
            tarea.Subject = 'Personalizada';
            tarea.Status = 'Pending';
            tarea.RecordTypeId = tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            tarea.WhatId = oCaso.Id;
            tareas.add(tarea);
            insert tareas;

            Task tareaResult = [SELECT Id, CreatedDate, WhatId FROM Task WHERE Type = 'Traslado Colaborador'];

            List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();
            CBK_SCH_PendingProcess__c pendingProcessTask = new CBK_SCH_PendingProcess__c();
            pendingProcessTask.recordId__c = tareaResult.WhatId;
            pendingProcessTask.Schedule_Time__c = tareaResult.CreatedDate.addHours(24);
            pendingProcessTask.className__c = 'CC_SchedulableTask';
            pendingProcessTask.Param1__c = 'sendMailSolicitudInf';
            listaPendingProcess.add(pendingProcessTask);

            CC_SchedulableTask sca = new CC_SchedulableTask();
            sca.work(listaPendingProcess);

            System.assertNotEquals(null, sca, 'No se ha podido lanzar schedulable');
            
            Test.stopTest();
        }
    }
}