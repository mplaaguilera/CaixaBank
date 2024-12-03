@isTest 
public class CC_Task_AI_TRHan_Test 
{
    @TestSetup
    static void makeData()
    {
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
        Account accountTest = new Account();
        accountTest.Name = 'Account Test';
        insert accountTest;

        Id recordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();

        Contact testContact = new Contact();
        testContact.FirstName = 'Contacto';
        testContact.LastName = 'Test';
        testContact.CC_Matricula__c = 'U0000001';
        testContact.Email = 'test@test.com';
        testContact.AccountId = accountTest.Id;
        testContact.RecordTypeId = recordTypeEmpleado;
        testContact.CC_Idioma__c = 'ES';
        insert testContact;

        Id recordTypeIdCSIBankia = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.Status = 'Pendiente Colaborador';
        oCaso.ContactId = testContact.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso.RecordTypeId = recordTypeIdCSIBankia;
        oCaso.Canal_del_Empleado__c = 'CSI';
        oCaso.CC_Canal_Procedencia__c = 'CCO CSI';
        oCaso.CC_Canal_Respuesta__c = 'Email';
        insert oCaso;
    }

    @isTest
    public static void crearTaskManual() 
    {       
        List<Case> casosList = [SELECT Id FROM Case];

        Task tarea = new Task();
        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        tarea.Subject = 'Tarea manual para comprobar permisos';
        tarea.Status = 'Open';
        tarea.Type = 'Actividad manual';
        tarea.WhatId = casosList[0].Id;
        
        Test.startTest();
            insert tarea;   
        Test.stopTest();
        
        List<Task> tareas = [SELECT Subject, Status, Type  FROM Task WHERE Id = :tarea.Id];
        System.assertEquals(1, tareas.size(), 'Se ha creado la tarea manual');
        System.assertEquals('Tarea manual para comprobar permisos', tareas[0].Subject);
        System.assertEquals('Open', tareas[0].Status);
        System.assertEquals('Actividad manual', tareas[0].Type);
    }

    @isTest
    public static void crearTaskManualReclamacionCliente() 
    {       
        List<Case> casosList = [SELECT Id FROM Case];

        Task tarea = new Task();
        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        tarea.Subject = 'Reclamación de cliente';
        tarea.Status = 'Open';
        tarea.Type = 'Actividad manual';
        tarea.WhatId = casosList[0].Id;
        
        Test.startTest();
            insert tarea;   
        Test.stopTest();
        
        List<Task> tareas = [SELECT Subject, Status, Type  FROM Task WHERE Id = :tarea.Id];
        System.assertEquals(1, tareas.size(), 'Se ha creado la tarea manual');
        System.assertEquals('Reclamación de cliente', tareas[0].Subject);
        System.assertEquals('Open', tareas[0].Status);
        System.assertEquals('Actividad manual', tareas[0].Type);
    }

    @isTest
    public static void crearTaskManualGestionRealizar() 
    {       
        List<Case> casosList = [SELECT Id FROM Case];

        Task tarea = new Task();
        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        tarea.Subject = 'Gestiones a realizar';
        tarea.Status = 'Open';
        tarea.Type = 'Actividad manual';
        tarea.WhatId = casosList[0].Id;
        
        Test.startTest();
            insert tarea;   
        Test.stopTest();
        
        List<Task> tareas = [SELECT Subject, Status, Type  FROM Task WHERE Id = :tarea.Id];
        System.assertEquals(1, tareas.size(), 'Se ha creado la tarea manual');
        System.assertEquals('Gestiones a realizar', tareas[0].Subject);
        System.assertEquals('Open', tareas[0].Status);
        System.assertEquals('Actividad manual', tareas[0].Type);
    }

    @isTest
    public static void crearTaskManualNoPropietarioCaso() 
    {     
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1]; 
        List<Case> casosList = [SELECT Id FROM Case];

        Task tarea = new Task();
        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        tarea.Subject = 'Tarea manual para comprobar permisos';
        tarea.Status = 'Open';
        tarea.Type = 'Actividad manual';
        tarea.WhatId = casosList[0].Id;

        System.runAs(usuario) 
        {
            try {
                Test.startTest();
                    insert tarea;   
                Test.stopTest();
                
            } catch (Exception ex) {
                //System.assert(ex.getMessage().contains('Solo los propietarios de un caso pueden dar de alta este tipo de tareas.'), 'No hay permisos para tareas manuales si no es el propietario del caso');
                CBK_Log.error('Error metodo: crearTaskManualNoPropietarioCaso - ' +  ex.getMessage());
            }
        }
    }

    @isTest
    public static void crearTaskManualNoPropietarioCasoConPermisos() 
    {     
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1]; 
        // System.debug('usuario ' + usuario); 
        List<Case> casosList = [SELECT Id FROM Case];

        Task tarea = new Task();
        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        tarea.Subject = 'Gestiones a realizar';
        tarea.Status = 'Open';
        tarea.Type = 'Actividad manual';
        tarea.WhatId = casosList[0].Id;

        System.runAs(usuario) 
        {
            Test.startTest();
                insert tarea;   
            Test.stopTest();

            List<Task> tareas = [SELECT Subject, Status, Type  FROM Task WHERE Id = :tarea.Id];
            System.debug('tareas ' + tareas); 
            System.assertEquals(1, tareas.size(), 'Se ha creado la tarea manual');
            System.assertEquals('Gestiones a realizar', tareas[0].Subject);
            System.assertEquals('Open', tareas[0].Status);
            System.assertEquals('Actividad manual', tareas[0].Type);            
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
}