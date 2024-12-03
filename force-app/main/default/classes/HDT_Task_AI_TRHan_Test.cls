@isTest 
public class HDT_Task_AI_TRHan_Test 
{
    @TestSetup
    static void makeData()
    {
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

        Id recordTypeIdCSIBankia = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
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
        oCaso.CC_Canal_Procedencia__c = 'Servicios Centrales';
        oCaso.CC_Canal_Respuesta__c = 'Email';
        insert oCaso;
    }

    @isTest
    public static void crearTaskManual() 
    {       
        System.runAs(new User(Id = UserInfo.getUserId())) {

        List<Case> casosList = [SELECT Id FROM Case];
        Id userId = userinfo.getUserId();

        Task tarea = new Task();
        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
        tarea.Subject = 'Tarea manual para comprobar permisos';
        tarea.Status = 'Open';
        tarea.Type = 'Actividad manual';
        tarea.WhatId = casosList[0].Id;
        
        
        Test.startTest();
       
            insert tarea;   
        Test.stopTest();
        
        List<Task> tareas = [SELECT WhatId,Subject, Status, Type,RecordTypeId  FROM Task WHERE Id = :tarea.Id];
        //HDT_Task_AI_TRHan.validarCreacionTarea(tareas);

        System.assertEquals(1, tareas.size(), 'Se ha creado la tarea manual');
        System.assertEquals('Tarea manual para comprobar permisos', tareas[0].Subject);
        System.assertEquals('Open', tareas[0].Status);
        System.assertEquals('Actividad manual', tareas[0].Type);
        }
    }

    @isTest
    public static void crearTaskManualReclamacionCliente() 
    {   
        System.runAs(new User(Id = UserInfo.getUserId())) {
        List<Case> casosList = [SELECT Id FROM Case];

        Task tarea = new Task();
        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
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
    }

    @isTest
    public static void crearTaskManualGestionRealizar() 
    {       
        System.runAs(new User(Id = UserInfo.getUserId())) {


        List<Case> casosList = [SELECT Id FROM Case];

        Task tarea = new Task();
        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
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
    }

    @isTest
    public static void crearTaskManualNoPropietarioCaso() 
    {     
        System.runAs(new User(Id = UserInfo.getUserId())) {
        User usuario = [SELECT Id, Name, Email FROM User WHERE isActive = true AND Id <> :UserInfo.getUserId() AND Name NOT IN ('System','Automated Process','Administrador de sistema') AND Id <> :UserInfo.getUserId() LIMIT 1]; 
        List<Case> casosList = [SELECT Id FROM Case];

        Task tarea = new Task();
        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
        tarea.Subject = 'Tarea manual para comprobar permisos';
        tarea.Status = 'Open';
        tarea.Type = 'Actividad manual';
        tarea.WhatId = casosList[0].Id;

      
            try {
                Test.startTest();
                    insert tarea;   
                Test.stopTest();
                List<Task> tareas = [SELECT WhatId,Subject, Status, Type,RecordTypeId,CreatedById  FROM Task WHERE Id = :tarea.Id];
                HDT_Task_AI_TRHan.validarCreacionTarea(tareas);
                
            } catch (Exception ex) {
                System.assert(ex.getMessage().contains('Solo los propietarios de un caso pueden dar de alta este tipo de tareas.'), 'No hay permisos para tareas manuales si no es el propietario del caso');
            }
        
    }
    }

    @isTest
    public static void crearTaskManualNoPropietarioCasoConPermisos() 
    {     
        System.runAs(new User(Id = UserInfo.getUserId())) {
        User usuario = [SELECT Id, Name, Email FROM User WHERE isActive = true AND Id <> :UserInfo.getUserId() AND Name IN ('System','Automated Process','Administrador de sistema') LIMIT 1]; 
        System.debug('usuario ' + usuario); 
        List<Case> casosList = [SELECT Id FROM Case];

        Task tarea = new Task();
        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
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
    }

    @isTest
    private static void reactivacionOperativa()
    {
        System.runAs(new User(Id = UserInfo.getUserId())) {


        Account cuenta = new Account();
        cuenta.Name = 'Smith';
        cuenta.CC_Numero_Documento__c = '64850344G';
        insert cuenta;

        Contact contacto = new Contact();
        contacto.LastName = 'Smith';
        contacto.CC_Numero_Documento__c = '64850344G';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'ImaginBank';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today().addMonths(-3);
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mccTematica;

        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Migración';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today().addMonths(-3);
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto;

        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Reversión';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today().addMonths(-3);
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        Case caso1 = new Case();
        caso1.recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        caso1.CC_Idioma__c = 'es';
        caso1.Subject = 'Asunto';
        caso1.Description = 'Descripción';
        caso1.CC_Tipo_Contacto__c = 'Consulta';
        caso1.CC_Canal_Procedencia__c = 'Accionista';
        caso1.CC_Canal_Resolucion__c = 'Accionista';
        caso1.CC_Canal_Operativo__c = 'App CaixaBankPay';
        caso1.Origin = 'Email';
        caso1.Status = 'Activo';
        caso1.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso1.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso1.AccountId = cuenta.Id;
        caso1.ContactId = contacto.Id;
        caso1.CC_MCC_Tematica__c = mccTematica.Id;
        caso1.CC_MCC_ProdServ__c = mccProducto.Id;
        caso1.CC_MCC_Motivo__c = mccMotivo.Id;
        //indicamos los grupos resolutores que ha tenido ya el caso, para que cree la facturación de todos con el nuevo MCC
        caso1.CC_GruposResolutores__c = 'MST;DXC;INDRA';
        caso1.CC_Reactivado_Operativa__c = Date.today();
        insert caso1;

        Test.startTest();
        caso1.Status = 'Cerrado';
        caso1.CC_Reactivado_Operativa__c = Date.today().addDays(7);
        update caso1;
        Test.stopTest();
        List<Case> casos = [SELECT CC_Reactivado_Operativa__c, Status FROM Case WHERE Id = :caso1.Id];
        

        System.assertEquals(Date.today().addDays(7), casos[0].CC_Reactivado_Operativa__c);     
        }
	}

    @isTest
    private static void testInformarCampoLlamada() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
        // Create test tasks
        Task task1 = new Task(Type = 'Activo');
        Task task2 = new Task(Type = 'Cierre Automático');
        Task task3 = new Task(Type = 'Cierre automático fallido');
        Task task4 = new Task(Type = 'Some other type');
        
        // Add tasks to set
        List<Task> tasks = new List<Task>{ task1, task2, task3, task4 };
        
        // Call method
        Test.startTest();
        HDT_Task_AI_TRHan.informarCampoLlamada(tasks);
        Test.stopTest();
        
        // Verify expected behavior
        List<Task> updatedTasks = [SELECT Id, CC_Llamada_Id__c FROM Task WHERE Id IN :tasks];
        for (Task t : updatedTasks) {
            if (t.Type != 'Cerrado' && t.Type != 'Cierre Automático' && t.Type != 'Cierre automático fallido') {
                System.assertEquals('some value', t.CC_Llamada_Id__c, 'Expected CC_Llamada_Id__c value was not set');
            } else {
                System.assertEquals(null, t.CC_Llamada_Id__c, 'CC_Llamada_Id__c value was set when it should not have been');
            }
        }
    }
    }

}