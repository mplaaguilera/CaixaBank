@isTest
public with sharing class CC_SchedulableKnowledge_Test {
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
    static void scheduleKnowTest() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Usuario Admin Prueba' AND IsActive = TRUE LIMIT 1];
        List<Task> tareas = new List<Task>();

        System.runAs(supervisor)
        {
            Test.startTest();
            Knowledge__kav know = new Knowledge__kav();
            know.Title = 'Test';
            know.UrlName = 'Test';
            know.CC_Fecha_Inicio_Publicacion__c = System.now().addHours(2);
            know.CC_Fecha_Caducidad__c = System.now().addHours(4);
            //know.PublishStatus = 'Draft';
            know.ValidationStatus = 'Validated';
            Database.insert(know);

            List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();
            CBK_SCH_PendingProcess__c pendingProcessKnowPubli = new CBK_SCH_PendingProcess__c();
            pendingProcessKnowPubli.recordId__c = know.Id;
            pendingProcessKnowPubli.Schedule_Time__c = know.CC_Fecha_Inicio_Publicacion__c;
            pendingProcessKnowPubli.className__c = 'CC_SchedulableKnowledge';
            pendingProcessKnowPubli.Param1__c = 'actualizarEstadoPublicacion';
            pendingProcessKnowPubli.Param2__c = 'publicar';
            listaPendingProcess.add(pendingProcessKnowPubli);

            CC_SchedulableKnowledge sca = new CC_SchedulableKnowledge();
            sca.work(listaPendingProcess);

            System.assertNotEquals(null, sca, 'No se ha podido lanzar schedulable');
            
            Test.stopTest();
        }
    }

    @isTest
    static void scheduleKnow2Test() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Usuario Admin Prueba' AND IsActive = TRUE LIMIT 1];
        List<Task> tareas = new List<Task>();

        System.runAs(supervisor)
        {
            Test.startTest();
            Knowledge__kav know = new Knowledge__kav();
            know.Title = 'Test';
            know.UrlName = 'Test';
            know.CC_Fecha_Inicio_Publicacion__c = System.now().addHours(2);
            know.CC_Fecha_Caducidad__c = System.now().addHours(4);
            //know.PublishStatus = 'Draft';
            know.ValidationStatus = 'Validated';
            Database.insert(know);

            Knowledge__kav knowRes = [SELECT PublishStatus FROM Knowledge__kav WHERE Title = 'Test'];

            List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();
            CBK_SCH_PendingProcess__c pendingProcessKnowPubli = new CBK_SCH_PendingProcess__c();
            pendingProcessKnowPubli.recordId__c = know.Id;
            pendingProcessKnowPubli.Schedule_Time__c = know.CC_Fecha_Inicio_Publicacion__c;
            pendingProcessKnowPubli.className__c = 'CC_SchedulableKnowledge';
            pendingProcessKnowPubli.Param1__c = 'actualizarMCCKnowledge';
            pendingProcessKnowPubli.Param2__c = knowRes.PublishStatus;
            listaPendingProcess.add(pendingProcessKnowPubli);

            CC_SchedulableKnowledge sca = new CC_SchedulableKnowledge();
            sca.work(listaPendingProcess);

            System.assertNotEquals(null, sca, 'No se ha podido lanzar schedulable');
            
            Test.stopTest();
        }
    }

    @isTest
    static void scheduleKnow3Test() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Usuario Admin Prueba' AND IsActive = TRUE LIMIT 1];
        List<Task> tareas = new List<Task>();
        Boolean errorOccurred = false;
        System.runAs(supervisor)
        {
            Test.startTest();
                Knowledge__kav know = new Knowledge__kav();
                know.Title = 'Test';
                know.UrlName = 'Test';
                know.CC_Fecha_Inicio_Publicacion__c = System.now().addHours(2);
                know.CC_Fecha_Caducidad__c = System.now().addHours(4);
                //know.PublishStatus = 'Draft';
                know.ValidationStatus = 'Validated';
                Database.insert(know);

                Knowledge__kav knowRes = [SELECT PublishStatus FROM Knowledge__kav WHERE Title = 'Test'];

                List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();
                CBK_SCH_PendingProcess__c pendingProcessKnowPubli = new CBK_SCH_PendingProcess__c();
                pendingProcessKnowPubli.recordId__c = know.Id;
                pendingProcessKnowPubli.Schedule_Time__c = know.CC_Fecha_Inicio_Publicacion__c;
                pendingProcessKnowPubli.className__c = 'CC_SchedulableKnowledge';
                pendingProcessKnowPubli.Param1__c = 'notificacionVencimiento';
                pendingProcessKnowPubli.Param2__c = 'articuloVencido';
                listaPendingProcess.add(pendingProcessKnowPubli);

                CC_SchedulableKnowledge sca = new CC_SchedulableKnowledge();
                sca.lstInfoProcess = listaPendingProcess;
                try {
                    System.enqueueJob(sca);
                } catch (Exception e) {
                    errorOccurred = true;
                }
            
            Test.stopTest();

            System.assertEquals(errorOccurred, false, 'Se ha producido un error al lanzar schedulable');
        }
    }
}