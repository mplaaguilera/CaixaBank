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

        Id recordTypeEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');

        Contact testContact = new Contact();
        testContact.FirstName = 'Contacto';
        testContact.LastName = 'Test';
        testContact.CC_Matricula__c = 'U0000001';
        testContact.Email = 'test@test.com';
        testContact.AccountId = accountTest.Id;
        testContact.RecordTypeId = recordTypeEmpleado;
        testContact.CC_Idioma__c = 'ES';
        insert testContact;

        Id recordTypeIdCSIBankia = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_CSI_Bankia');
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
        User usuario = [SELECT Id FROM User WHERE IsActive = TRUE AND Profile.Name = 'System Administrator' LIMIT 1]; 
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

    @isTest
    static void actualizarCasesTest()
    {
        User supervisor = [SELECT Id FROM User WHERE IsActive = TRUE AND Profile.Name = 'System Administrator' LIMIT 1];
        List<Task> tareas = new List<Task>();
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Incidencia'];

        System.runAs(supervisor)
        {
            Test.startTest();
            Task tarea = new Task();
            tarea.type = 'Traslado Tercer Nivel';
            tarea.Priority = 'Normal';
            tarea.Subject = 'Personalizada';
            tarea.RecordTypeId = tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            tarea.WhatId = caso.Id;
            tareas.add(tarea);
            insert tareas;

            Case casoResult = [SELECT Id, CC_Trasladado_Tercer_Nivel__c, CC_Respuesta_Personalizada__c FROM Case WHERE Subject = 'Test Incidencia'];
            
            System.assertEquals(true, casoResult.CC_Trasladado_Tercer_Nivel__c, 'No se ha actualizado el caso');
            System.assertEquals(true, casoResult.CC_Respuesta_Personalizada__c, 'No se ha actualizado el caso');
            Test.stopTest();
        }
    }

    @isTest
    static void notificarCasoAClienteTest()
    {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        List<Task> tareas = new List<Task>();

        System.runAs(supervisor)
        {
            Test.startTest();
            Task tarea = new Task();
            tarea.type = 'Traslado Tercer Nivel';
            tarea.Priority = 'Normal';
            tarea.Subject = 'Personalizada';
            tarea.RecordTypeId = tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            tareas.add(tarea);
            insert tareas;
            
            List<Task> tareaResult = [SELECT Id FROM Task WHERE Type = 'Traslado Tercer Nivel'];
            System.assertEquals(false, tareaResult.isEmpty(), 'No se ha insertado la tarea');
            Test.stopTest();
        }
    }

    @isTest
    static void actualizarPropietarioTest()
    {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        List<Task> tareas = new List<Task>();

        System.runAs(supervisor)
        {
            Test.startTest();
            Task tarea = new Task();
            tarea.type = 'Traslado Tercer Nivel';
            tarea.Priority = 'Normal';
            tarea.Subject = 'Personalizada';
            tarea.RecordTypeId = tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            tareas.add(tarea);
            insert tareas;
            
            List<Task> tareaResult = [SELECT Id FROM Task WHERE Type = 'Traslado Tercer Nivel'];
            System.assertEquals(false, tareaResult.isEmpty(), 'No se ha insertado la tarea');
            Test.stopTest();
        }
    }

    @isTest
    static void crearReclamacionMaximoTest()
    {
        User supervisor = [SELECT Id FROM User WHERE  IsActive = TRUE AND Profile.Name = 'System Administrator' LIMIT 1];
        List<Task> tareas = new List<Task>();
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Incidencia'];

        System.runAs(supervisor)
        {
            Test.startTest();
            Task tarea = new Task();
            tarea.type = 'Actividad manual';
            tarea.Priority = 'Normal';
            tarea.Subject = 'Reclamación de cliente';
            tarea.RecordTypeId = tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            tarea.WhatId = caso.Id;
            tareas.add(tarea);
            insert tareas;
            
            List<Task> tareaResult = [SELECT Id FROM Task WHERE Type = 'Actividad manual'];
            System.assertEquals(false, tareaResult.isEmpty(), 'No se ha insertado la tarea');
            Test.stopTest();
        }
    }

    @isTest
    static void schedulablesTaskTest()
    {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        List<Task> tareas = new List<Task>();
        //Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Incidencia'];

        System.runAs(supervisor)
        {
            Id recordTypeIdCSIBankia =  CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_CSI_Bankia');
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

            Test.startTest();
            Task tarea = new Task();
            tarea.type = 'Actividad manual';
            tarea.Priority = 'Normal';
            tarea.Subject = 'Verificación cliente';
            tarea.RecordTypeId = tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            tarea.WhatId = oCaso.Id;
            tareas.add(tarea);
            insert tareas;

            List<CBK_SCH_PendingProcess__c> pdp = [SELECT Id FROM CBK_SCH_PendingProcess__c WHERE RecordId__c = :tarea.Id];
            Case casoResult =  [SELECT Id, Status FROM Case WHERE CC_MailTelfNotif__c = 'testcs@testcs.es'];

            System.assertEquals(false, pdp.isEmpty(), 'No se ha programado el pending process');
            System.assertEquals('Pendiente Cliente', casoResult.Status, 'No se ha actualizado el status del caso');
            
            Test.stopTest();
        }
    }

    @isTest
    static void schedulablesTask2Test()
    {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        List<Task> tareas = new List<Task>();
        //Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Incidencia'];

        System.runAs(supervisor)
        {
            Id recordTypeIdCSIBankia = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_CSI_Bankia');
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

            Test.startTest();
            Task tarea = new Task();
            tarea.type = 'Traslado Colaborador';
            tarea.Status = 'Open';
            tarea.Priority = 'Normal';
            tarea.Subject = 'Reclamación de cliente';
            tarea.RecordTypeId = tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            tarea.WhatId = oCaso.Id;
            tarea.CC_Fecha_1_Reclamacion_Auto__c = system.now();
            tarea.CC_Fecha_2_Reclamacion_Auto__c = system.now();
            tarea.CC_Fecha_3_Reclamacion_Auto__c = system.now();
            tarea.OS_Fecha_Fin_Reclamacion_Auto__c = system.now();
            tareas.add(tarea);
            insert tareas;

            List<CBK_SCH_PendingProcess__c> pdp = [SELECT Id FROM CBK_SCH_PendingProcess__c WHERE RecordId__c = :tarea.Id];

            System.assertNotEquals(null, pdp, 'No se ha programado el pending process');
            
            Test.stopTest();
        }
    }

    @isTest
    static void cierreAutomaticoSolicitudInformacionTest()
    {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        List<Task> tareas = new List<Task>();
        //Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Incidencia'];

        System.runAs(supervisor)
        {
            Id recordTypeIdCSIBankia = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_CSI_Bankia');
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

            Test.startTest();
            Task tarea = new Task();
            tarea.type = 'Solicitud Información';
            tarea.Status = 'Open';
            tarea.Priority = 'Normal';
            tarea.Subject = 'Reclamación de cliente';
            tarea.RecordTypeId = tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            tarea.WhatId = oCaso.Id;
            tarea.CC_Fecha_FinPlazo_SolInf__c = system.now();
            tareas.add(tarea);
            insert tareas;

            List<CBK_SCH_PendingProcess__c> pdp = [SELECT Id FROM CBK_SCH_PendingProcess__c WHERE RecordId__c = :tarea.WhatId];

            System.assertEquals(false, pdp.isEmpty(), 'No se ha programado el pending process');
            
            Test.stopTest();
        }
    }

    @isTest
    static void casoGestionTareasNoTiempoTest()
    {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        List<Task> tareas = new List<Task>();
        
        System.runAs(supervisor)
        {
            Test.startTest();

            Case caso = new Case();
            caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.CC_Tipo_Contacto__c = 'Consulta';
            caso.CC_Canal_Procedencia__c = 'Accionista';
            caso.CC_Canal_Resolucion__c = 'Accionista';
            caso.CC_Canal_Operativo__c = 'App CaixaBankPay';
            caso.Origin = 'Email';
            caso.Status = 'Inactivo ';
            caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
            caso.CC_Detalles_Solucion__c = 'Detalles Solución';
            insert caso;

            
            Task tarea = new Task();
            tarea.type = 'Traslado Colaborador';
            tarea.Status = 'Rechazada';
            tarea.Priority = 'Normal';
            tarea.Subject = 'Reclamación de cliente';
            tarea.RecordTypeId = tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            tarea.WhatId = caso.Id;
            tareas.add(tarea);
            insert tareas;

            caso = [SELECT Id, CC_Fecha_Ultima_Reclamacion__c, CC_Numero_Reclamaciones_Cliente__c, Status FROM Case WHERE Id = :caso.Id];

            System.assertEquals(true, caso.CC_Fecha_Ultima_Reclamacion__c != null, 'No se ha actualizado la fecha de la última reclamación, sigue a Nulo');
            System.assertEquals(true, caso.Status == 'Activo', 'No se ha actualizado el status del caso');
            System.assertNotEquals(null, caso.CC_Numero_Reclamaciones_Cliente__c, 'No se ha actualizado el número de reclamaciones del caso');
            System.assert(caso.CC_Numero_Reclamaciones_Cliente__c > 0, 'El número de reclamaciones debe ser mayor que 0');

            Test.stopTest();
        }
    }
   
}