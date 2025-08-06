@isTest
public with sharing class CC_Activity_Test {
    private static Id taskRecordTypeId;

    static {
        taskRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
    }
    
    @TestSetup
    static void makeData(){

        Map<String, Id> profilesCC = CC_TestDataFactory.getProfiles();
        Map<String, Id> rolesCC = CC_TestDataFactory.getRoles();
        Map<String, Id> psCC = CC_TestDataFactory.getPermissionSet();

        User usuario1 = CC_TestDataFactory.createUserAdmin(profilesCC.get('System Administrator'), rolesCC.get('Contact_Center'));
        User usuario2 = CC_TestDataFactory.createtUserOperador(profilesCC.get('CC_Usuario_CaixaBank'), rolesCC.get('Contact_Center_sin_acceso_a_Directorio'), 'U0112345');
        List<User> usuarios = new List<User>{usuario1, usuario2};
        insert usuarios;

        PermissionSetAssignment psaAdminAV = new PermissionSetAssignment(AssigneeId = usuario1.Id, PermissionSetId = psCC.get('AV_GestorOperativa'));
        PermissionSetAssignment psaOperadorCliente = new PermissionSetAssignment(AssigneeId = usuario2.Id, PermissionSetId =  psCC.get('CC_Operador_Cliente'));
        PermissionSetAssignment psaOperadorEmpleado = new PermissionSetAssignment(AssigneeId = usuario2.Id, PermissionSetId =  psCC.get('CC_Operador_CCO'));
        PermissionSetAssignment psaOperadorClasses = new PermissionSetAssignment(AssigneeId = usuario2.Id, PermissionSetId = psCC.get('CC_Classes'));
        PermissionSetAssignment psaOperadorAV = new PermissionSetAssignment(AssigneeId = usuario2.Id, PermissionSetId = psCC.get('AV_GestorOperativa'));
        PermissionSetAssignment psaOperadorCSBD = new PermissionSetAssignment(AssigneeId = usuario2.Id, PermissionSetId = psCC.get('CSBD_PS_Gestor'));
        
        List<PermissionSetAssignment> insertPSAssOperadores = new List<PermissionSetAssignment>{
            psaOperadorCliente, 
            psaOperadorEmpleado,
            psaOperadorClasses,
            psaOperadorAV,
            psaOperadorCSBD,
            psaAdminAV
        };    

        insert insertPSAssOperadores;

 
        // User usuario1 = CC_TestDataFactory.insertUserAdmin();
        // User usuario2 = CC_TestDataFactory.insertUserOperadorCliente('U0112345');

        System.runAs(usuario1) {
            Id rtEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
            Id rtCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
            Id rtCentroId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            Id rtClientePA = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
            Id rtOportunidad = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_MAC');
            List<ContactShare> totalPermisosContact = new List<ContactShare>();
            List<AccountShare> totalPermisosAccount = new List<AccountShare>();
     
            //Cuenta
            List <Account> insertAccount = new List <Account>();

            Account cuenta = new Account();
            cuenta.Name = 'Cuenta01';
            insertAccount.add(cuenta);

            Account cuenta2 = new Account();
            cuenta2.Name = 'Cuenta02';
            insert cuenta2;  

            Account oficina1 = new Account(
            Name = 'Oficina 1',
            CC_Email__c = 'cuenta@test.com',
            CC_Numero_Empresa__c = '123',
            CC_Numero_Oficina_Empresa__c = '000-12345',
            CC_Numero_Oficina__c = '123',
            CC_Numero_Documento__c = '45729937A',
            RecordtypeId =  rtCentroId
            );
            insertAccount.add(oficina1);

            insert insertAccount;

            //Contacto
            List <Contact> insertContact = new List <Contact>();

            Contact contacto = new Contact();
            contacto.FirstName = 'Contacto';
            contacto.LastName = '01';
            contacto.CC_NumPerso__c = '12345569';
            contacto.AccountId = cuenta.Id;
            contacto.CC_Idioma__c = 'Es';
            contacto.RecordTypeId = rtEmpleado;

            insertContact.add(contacto);

            
            Contact contacto2 = new Contact();
            contacto2.FirstName = 'Contacto';
            contacto2.LastName = '02';
            contacto2.CC_NumPerso__c = '12345568';
            contacto2.AccountId = cuenta2.Id;
            contacto2.CC_Idioma__c = 'Es';
            contacto2.RecordTypeId = rtCliente;
            insert contacto2; 

            insert insertContact; 


            List<Account> accounts = [SELECT Id FROM Account];

            for (Account a : accounts) {
                AccountShare acshare = new AccountShare();
                acshare.AccountId = a.Id;
                acshare.UserOrGroupId = usuario2.Id;
                acshare.AccountAccessLevel = 'Edit';
                acshare.OpportunityAccessLevel = 'Edit';
                acshare.CaseAccessLevel = 'Edit';
                totalPermisosAccount.add(acshare);
            }
            insert totalPermisosAccount;
            
            ContactShare contactShare = new ContactShare();
            contactShare.ContactId = contacto2.Id;
            contactShare.UserOrGroupId = usuario2.Id;
            contactShare.ContactAccessLevel = 'Edit';
            totalPermisosContact.add(contactShare);

            ContactShare contactShare2 = new ContactShare();
            contactShare2.ContactId = contacto.Id;
            contactShare2.UserOrGroupId = usuario2.Id;
            contactShare2.ContactAccessLevel = 'Edit';
            totalPermisosContact.add(contactShare2);

            Boolean excepcion = false;
            
            try {
                //Database.insert(totalPermisosAccount, true);
                insert totalPermisosAccount;
            } catch(Exception e) {
                excepcion = true;
            }

            try {
                //Database.insert(totalPermisosContact, true);
                insert totalPermisosContact;
            } catch(Exception e) {
                excepcion = true;
            }
            
            //Casos
            List <Case> insertCase = new List <Case>();

            Case casoConOportunidad = new Case(
                Description = 'casoConOportunidad',
                Subject = 'casoConOportunidad',
                Origin = 'Email',
                Status = 'Activo',
                accountId = cuenta.Id,
                CC_Idioma__c = 'es',
                CC_Canal_Respuesta__c = 'Email',
                CC_Grupo_3N__c = 'Grupo 3N',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                OwnerId = usuario2.Id,
                ContactId = contacto2.Id,
                RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoConOportunidad);

            Case casoGenerico = new Case(
                Description = 'casoGenerico',
                Subject = 'casoGenerico',
                Origin = 'Email',
                Status = 'Activo',
                accountId = cuenta.Id,
                CC_Idioma__c = 'es',
                CC_Canal_Respuesta__c = 'Email',
                CC_Grupo_3N__c = 'Grupo 3N',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                OwnerId = usuario2.Id,
                ContactId = contacto2.Id,
                RecordTypeId = recordTypeCaso
            );

            insertCase.add(casoGenerico);

            insert insertCase;

            List<CC_Settings__c> configuraciones = new List<CC_Settings__c>();
            CC_Settings__c configuracion = new CC_Settings__c(
                Name = 'CC_MecanismoFirmaCircuitos',
                CC_Configuracion_1__c = 'Circuito cliente en el extranjero',
                CC_Configuracion_2__c = 'Circuito cliente envío código de firma '
            );
            configuraciones.add(configuracion);
            CC_Settings__c configuracionUnblu = new CC_Settings__c(
                Name = 'CC_Url_Unblu',
                CC_Configuracion_1__c = 'https://test.com/es/conversation/'
            );
            configuraciones.add(configuracionUnblu);

            insert configuraciones;
        }

    }

    @isTest
    public static void finalizarActividad() {
        Test.startTest();
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;
        
        Id taskRecordTypeId = taskRecordTypeId;
        Task actividad = new Task();
        actividad.Status = 'Open';
        actividad.WhatId= caso.Id;
        actividad.RecordTypeId = taskRecordTypeId;
        insert actividad;

        CC_Activity.finalizarActividad(actividad.Id);
        Test.stopTest();

        actividad = [SELECT Status FROM Task WHERE Id = :actividad.Id AND RecordTypeId =: taskRecordTypeId LIMIT 1];

        System.assertEquals('Completed', actividad.Status);
    }

    @isTest
    public static void finalizarActividadCaso() {
        Test.startTest();
        List<Task> insertTareas = new List<Task>();
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;

        Id taskRecordTypeId = taskRecordTypeId;
        
        Task actividad1 = new Task();
        actividad1.WhatId = caso.Id;
        actividad1.Type = 'Rechazar Primer Nivel';
        actividad1.Status = 'Open';
        actividad1.RecordTypeId = taskRecordTypeId;
        insertTareas.add(actividad1);

        Task actividad2 = new Task();
        actividad2.WhatId = caso.Id;
        actividad2.Status = 'Open';
        actividad2.Type = 'Traslado Tercer Nivel';
        actividad2.RecordTypeId = taskRecordTypeId;
        insertTareas.add(actividad2);

        insert insertTareas;

        CC_Activity.finalizarActividadCaso(caso.Id, 'Rechazar Primer Nivel', 'Devuelta 3N', 'descripción');
        Test.stopTest();

        actividad1 = [SELECT Status, CC_Tipo_Cierre__c, Description FROM Task WHERE Id = :actividad1.Id AND RecordTypeId =: taskRecordTypeId LIMIT 1];
        actividad2 = [SELECT Status, CC_Tipo_Cierre__c, Description FROM Task WHERE Id = :actividad2.Id AND RecordTypeId =: taskRecordTypeId LIMIT 1];

        System.assertEquals('Completed', actividad1.Status);
        System.assertEquals('Devuelta 3N', actividad1.CC_Tipo_Cierre__c);
        System.assertEquals('descripción', actividad1.Description);
        System.assertEquals('Open', actividad2.Status);
        System.assertEquals(null, actividad2.CC_Tipo_Cierre__c);
        System.assertEquals(null, actividad2.Description);
    }
    
    @isTest
    public static void finalizarActividadCaso3N() {
        Test.startTest();
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;
		
        Id taskRecordTypeId = taskRecordTypeId;
  		Task actividad1 = new Task();
        actividad1.WhatId = caso.Id;
        actividad1.Type = 'Rechazar Primer Nivel';
        actividad1.Status = 'Open';
        actividad1.RecordTypeId = taskRecordTypeId;
        insert actividad1;

        Task actividad2 = new Task();
        actividad2.WhatId = caso.Id;
        actividad2.Status = 'Open';
        actividad2.Type = 'Traslado Tercer Nivel';
        actividad2.RecordTypeId = taskRecordTypeId;
        insert actividad2;

        CC_Activity.finalizarActividadCaso(caso.Id, 'Traslado Tercer Nivel', 'Rechazado por Tercer Nivel', 'descripción');
        Test.stopTest();

        actividad1 = [SELECT Status, CC_Tipo_Cierre__c, Description FROM Task WHERE Id = :actividad1.Id AND RecordTypeId =: taskRecordTypeId LIMIT 1];
        //actividad2 = [SELECT Status, CC_Tipo_Cierre__c, Description FROM Task WHERE Id = :actividad2.Id AND RecordTypeId =: taskRecordTypeId LIMIT 1];

        System.assertEquals('Open', actividad1.Status);
        //System.assertEquals('Rechazado por Tercer Nivel', actividad1.CC_Tipo_Cierre__c);
        //System.assertEquals('descripción', actividad1.Description);
        //System.assertEquals('Open', actividad2.Status);
        //System.assertEquals(null, actividad2.CC_Tipo_Cierre__c);
        //System.assertEquals(null, actividad2.Description);
    }
    
    @isTest
    public static void finalizarActividadCasoTrasladoColaborador() {
        Test.startTest();
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;
		
        Id taskRecordTypeId = taskRecordTypeId;
  		Task actividad1 = new Task();
        actividad1.WhatId = caso.Id;
        actividad1.Type = 'Traslado Colaborador';
        actividad1.Status = 'Open';
        actividad1.RecordTypeId = taskRecordTypeId;
        insert actividad1;
        
        CC_Activity.finalizarActividadCaso(caso.Id, 'Traslado Colaborador', 'Traslado Colaborador', 'descripción');
        Test.stopTest();

        actividad1 = [SELECT Status, CC_Tipo_Cierre__c, Description FROM Task WHERE Id = :actividad1.Id AND RecordTypeId =: taskRecordTypeId LIMIT 1];

        System.assertEquals('Completed', actividad1.Status);
    }
    
    @isTest
    public static void informarFechaVencimientoSLACol() {
        Test.startTest();
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;
        
        Id taskRecordTypeId = taskRecordTypeId;
  		Task actividad2 = new Task();
        actividad2.WhatId = caso.Id;
        actividad2.Status = 'Open';
        actividad2.Type = 'Traslado Grupo Colaborador';
        actividad2.RecordTypeId = taskRecordTypeId;
        insert actividad2;
        
        Task act = [SELECT Id, Status, Type FROM Task WHERE Type = 'Traslado Grupo Colaborador' AND RecordTypeId =: taskRecordTypeId LIMIT 1];
        
        String tipo = 'Grupo colaborador';
        CC_Activity.informarFechaVencimientoSLA(tipo, 'Grupo Colaborador', act);
        Test.stopTest();

    }
    
    @isTest
    public static void informarFechaVencimientoSLA3N() {
        Test.startTest();
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;
        
        Id taskRecordTypeId = taskRecordTypeId;
  		Task actividad2 = new Task();
        actividad2.WhatId = caso.Id;
        actividad2.Status = 'Open';
        actividad2.Type = 'Traslado Tercer Nivel';
        actividad2.RecordTypeId = taskRecordTypeId;
        insert actividad2;
        
        Task act = [SELECT Id, Status, Type FROM Task WHERE Type = 'Traslado Tercer Nivel' AND RecordTypeId =: taskRecordTypeId LIMIT 1];
        
		String tipo = 'Grupo 3N';
        CC_Activity.informarFechaVencimientoSLA(tipo, 'Grupo 1', act);
        Test.stopTest();

    }
    
    @isTest
    public static void crearActividadTest() {
         List<User> usuario = [SELECT Id FROM User WHERE Profile.name LIKE 'CC_Usuario_CaixaBank' AND IsActive=true];
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
                Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
                Test.startTest();
                Case caso = new Case();
                caso.Subject = 'Prueba';
                caso.RecordTypeId = recordTypeCaso;
                caso.CC_Idioma__c = 'es';
                caso.CC_Tipo_Cliente__c = 'Empleado';
                caso.Status = 'Activo';
                caso.Origin = 'Email';
                caso.CC_Tipo_Contacto__c = 'Petición de servicio';
                caso.CC_Canal_Procedencia__c = 'Oficina Feedback';        
                caso.CC_Canal_Resolucion__c = 'Oficina Feedback';        
                insert caso;     
                
                Task actividad1 = new Task();
                actividad1.WhatId = caso.Id;
                actividad1.Type = 'Rechazar Primer Nivel';
                actividad1.Status = 'Open';
                Task actividad = CC_Activity.crearActividad(actividad1);
                Test.stopTest();

                System.assertNotEquals(null, actividad);
            }
        }
    }
    
    
    @isTest
    public static void crearActividades1Test() {
     	Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        
        Test.startTest();
        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Cliente__c = 'Empleado';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
		caso.CC_Tipo_Contacto__c = 'Petición de servicio';
        caso.CC_Canal_Procedencia__c = 'Oficina Feedback';        
        caso.CC_Canal_Resolucion__c = 'Oficina Feedback';        
        insert caso;     
        
  		Task actividad1 = new Task();
        actividad1.WhatId = caso.Id;
        actividad1.Type = 'Rechazar Primer Nivel';
        actividad1.Status = 'Open';
        
        Task actividad2 = new Task();
        actividad2.WhatId = caso.Id;
        actividad2.Type = 'Rechazar Primer Nivel';
        actividad2.Status = 'Open';
        
        List<Task> tareas = new List<Task>();
        tareas.add(actividad1);
        tareas.add(actividad2); 

        CC_Activity.crearActividades(tareas, true);
        Test.stopTest();

        System.assertEquals(2,  [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
        
        List<Task> listaTareasComprobar = [SELECT Id FROM Task WHERE WhatId = :caso.Id];
        CC_Activity.finalizarActividadCaso(listaTareasComprobar[0].Id, 'Traslado Tercer Nivel', 'Devuelto por Tercer Nivel', 'comentario');
    }
    
    @isTest
    public static void crearActividades2Test() {
     	Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');

        Test.startTest();
        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Cliente__c = 'Empleado';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
		caso.CC_Tipo_Contacto__c = 'Petición de servicio';
        caso.CC_Canal_Procedencia__c = 'Oficina Feedback';        
        caso.CC_Canal_Resolucion__c = 'Oficina Feedback';        
        insert caso;     
        
  		Task actividad1 = new Task();
        actividad1.WhatId = caso.Id;
        actividad1.Type = 'Rechazar Primer Nivel';
        actividad1.Status = 'Open';
        
        Task actividad2 = new Task();
        actividad2.WhatId = caso.Id;
        actividad2.Type = 'Rechazar Primer Nivel';
        actividad2.Status = 'Open';
        
        List<Task> tareas = new List<Task>();
        tareas.add(actividad1);
        tareas.add(actividad2);  

        CC_Activity.crearActividades(tareas);
        Test.stopTest();

        System.assertEquals(2, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
    }
    
    @isTest
    public static void crearActividadesPasandoRecordTypeTest() {
     	Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        Test.startTest();
        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Cliente__c = 'Empleado';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
		caso.CC_Tipo_Contacto__c = 'Petición de servicio';
        caso.CC_Canal_Procedencia__c = 'Oficina Feedback';        
        caso.CC_Canal_Resolucion__c = 'Oficina Feedback';        
        insert caso;     
        
  		Task actividad1 = new Task();
        actividad1.WhatId = caso.Id;
        actividad1.Type = 'Rechazar Primer Nivel';
        actividad1.Status = 'Open';
        
        Task actividad2 = new Task();
        actividad2.WhatId = caso.Id;
        actividad2.Type = 'Rechazar Primer Nivel';
        actividad2.Status = 'Open';
        
        List<Task> tareas = new List<Task>();
        tareas.add(actividad1);
        tareas.add(actividad2);       
        
        CC_Activity.crearActividades(tareas, 'CC_Task');
        Test.stopTest();

        System.assertEquals(2, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
    }
    
     @isTest
    public static void llamadaQueueableCrearActividadesTest() {
        List<User> usuario = [SELECT Id FROM User WHERE Profile.name LIKE 'CC_Usuario_CaixaBank' AND IsActive=true];
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
                Test.startTest();
                Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
                Case caso = new Case();
                caso.Subject = 'Prueba';
                caso.RecordTypeId = recordTypeCaso;
                caso.CC_Idioma__c = 'es';
                caso.CC_Tipo_Cliente__c = 'Empleado';
                caso.Status = 'Activo';
                caso.Origin = 'Email';
                caso.CC_Tipo_Contacto__c = 'Petición de servicio';
                caso.CC_Canal_Procedencia__c = 'Oficina Feedback';        
                caso.CC_Canal_Resolucion__c = 'Oficina Feedback';        
                insert caso;     
                
                  Task actividad1 = new Task();
                actividad1.WhatId = caso.Id;
                actividad1.Type = 'Rechazar Primer Nivel';
                actividad1.Status = 'Open';
                
                Task actividad2 = new Task();
                actividad2.WhatId = caso.Id;
                actividad2.Type = 'Rechazar Primer Nivel';
                actividad2.Status = 'Open';
                
                List<Task> tareas = new List<Task>();
                tareas.add(actividad1);
                tareas.add(actividad2);    

                CC_Activity.llamadaQueueableCrearActividades(tareas);
                Test.stopTest(); 
                System.assertEquals(2, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
            }
        }
    }
    
         @isTest
    public static void crearActividadesTest() {
        List<User> usuario = [SELECT Id FROM User WHERE Profile.name LIKE 'CC_Usuario_CaixaBank' AND IsActive=true];
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
                Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');

                Test.startTest();
                Case caso = new Case();
                caso.Subject = 'Prueba';
                caso.RecordTypeId = recordTypeCaso;
                caso.CC_Idioma__c = 'es';
                caso.CC_Tipo_Cliente__c = 'Empleado';
                caso.Status = 'Activo';
                caso.Origin = 'Email';
                caso.CC_Tipo_Contacto__c = 'Petición de servicio';
                caso.CC_Canal_Procedencia__c = 'Oficina Feedback';        
                caso.CC_Canal_Resolucion__c = 'Oficina Feedback';        
                insert caso;     
                
                Task actividad1 = new Task();
                actividad1.WhatId = caso.Id;
                actividad1.Type = 'Rechazar Primer Nivel';
                actividad1.Status = 'Open';
                
                Task actividad2 = new Task();
                actividad2.WhatId = caso.Id;
                actividad2.Type = 'Rechazar Primer Nivel';
                actividad2.Status = 'Open';
                
                List<Task> tareas = new List<Task>();
                tareas.add(actividad1);
                tareas.add(actividad2);       
                
                CC_Activity.crearActividades(tareas);
                Test.stopTest();

                System.assertEquals(2, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
            }
        }
    }
    
         @isTest
    public static void crearActividadesRTTest() {
        List<User> usuario = [SELECT Id FROM User WHERE Profile.name LIKE 'CC_Usuario_CaixaBank' AND IsActive=true];
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
                Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');

                Test.startTest();
                Case caso = new Case();
                caso.Subject = 'Prueba';
                caso.RecordTypeId = recordTypeCaso;
                caso.CC_Idioma__c = 'es';
                caso.CC_Tipo_Cliente__c = 'Empleado';
                caso.Status = 'Activo';
                caso.Origin = 'Email';
                caso.CC_Tipo_Contacto__c = 'Petición de servicio';
                caso.CC_Canal_Procedencia__c = 'Oficina Feedback';        
                caso.CC_Canal_Resolucion__c = 'Oficina Feedback';        
                insert caso;     
                
                Task actividad1 = new Task();
                actividad1.WhatId = caso.Id;
                actividad1.Type = 'Rechazar Primer Nivel';
                actividad1.Status = 'Open';
                
                Task actividad2 = new Task();
                actividad2.WhatId = caso.Id;
                actividad2.Type = 'Rechazar Primer Nivel';
                actividad2.Status = 'Open';
                
                List<Task> tareas = new List<Task>();
                tareas.add(actividad1);
                tareas.add(actividad2);       

                CC_Activity.crearActividades(tareas, 'CC_Task');
                Test.stopTest();
                
                System.assertEquals(2, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
            }
        }
    }
    
    @isTest
    public static void createActivityTrasladosTest() {
        List<User> usuario = [SELECT Id FROM User WHERE Profile.name LIKE 'CC_Usuario_CaixaBank' AND IsActive=true];
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
                Test.startTest();
                Case caso = new Case();
                caso.CC_Idioma__c = 'es';
                caso.Subject = 'Prueba';
                caso.CC_Tipo_Cliente__c = 'Cliente';
                caso.Status = 'Activo';
                caso.Origin = 'Comentarios Stores';
                caso.CC_Tipo_Contacto__c = 'Consulta';
                caso.CC_Canal_Procedencia__c = 'Google Play Store';
                insert caso;

               // Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
                Id recordTypeGrupoColaborador =  Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
                //Id recordTypeGrupoColaborador = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador','CC_Grupo_Colaborador');
                CC_Grupo_Colaborador__c grupoColaborador  = new CC_Grupo_Colaborador__c();
                grupoColaborador.RecordTypeId = recordTypeGrupoColaborador;
                grupoColaborador.Name = 'Servicio bastanteo';
                grupoColaborador.OS_Negocio__c = 'CC';
                insert grupoColaborador;

                String comentario = 'Comentario de prueba';
                String subject = 'Asunto de la tarea';
                String tipoTarea = 'Traslado Tercer Nivel';
                String grupo3N = 'Grupo 3N';
                String grupoId = grupoColaborador.Id; 
                Id llamadaId = null;
                String estado = 'Open';

                CC_Activity.createActivityTraslados(caso.Id, comentario, subject, tipoTarea, grupo3N, grupoId, llamadaId, estado);
                Test.stopTest();

                System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
            }
        }
    }

    @isTest
    public static void crearActividadOportunidadTest() {
     
        Contact contacto = [SELECT Id FROM Contact WHERE LastName ='01'];
        User operadorCliente = CC_TestDataFactory.getUserAdmin();
        System.runAs(operadorCliente) {
            Test.startTest();

            Case caso = new Case();
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Prueba';
            caso.CC_Tipo_Cliente__c = 'Cliente';
            caso.Status = 'Activo';
            caso.Origin = 'Comentarios Stores';
            caso.CC_Tipo_Contacto__c = 'Consulta';
            caso.CC_Canal_Procedencia__c = 'Google Play Store';
            caso.OwnerId = operadorCliente.Id;
            insert caso;               

            CC_Activity.crearActividadOportunidad(caso.Id, caso);

            Test.stopTest();

            System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
        }      
    }

    @isTest
    public static void crearActividadBaseDerivarTest() {
        List<User> usuario = [SELECT Id FROM User WHERE Profile.Name LIKE 'CC_Usuario_CaixaBank' AND IsActive=true LIMIT 1];
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
                Id taskRecordTypeId = taskRecordTypeId;

                String asunto = 'Derivación de Caso';
                String comentarios = 'Comentarios de prueba';
                Date todayDate = CBK_UtilsDate.todayDT();
                Date fechaActividad = todayDate.addDays(7);

                Test.startTest();
                Task tarea = CC_Activity.crearActividadBaseDerivar(taskRecordTypeId, asunto, comentarios, fechaActividad);
                insert tarea;
                Test.stopTest();

                System.assertEquals(1, [SELECT COUNT() FROM Task WHERE RecordTypeId = :taskRecordTypeId]);
            }
        }
    }

    @isTest
    public static void crearTareaDirectorTest() {
        List<User> usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0112345' AND IsActive=true LIMIT 1];
        Account oficina1 = [SELECT Id, CC_Numero_Oficina__c FROM Account WHERE Name = 'Oficina 1' LIMIT 1];
        Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');

        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
                Test.startTest();
                Case caso = new Case();
                caso.RecordTypeId = recordTypeCaso;
                caso.CC_Idioma__c = 'es';
                caso.Subject = 'Caso Director';
                caso.CC_Tipo_Cliente__c = 'Cliente';
                caso.Status = 'Activo';
                caso.Origin = 'Chat';
                caso.CC_Tipo_Contacto__c = 'Consulta';
                caso.CC_Canal_Procedencia__c = 'Web';
                caso.OwnerId = usuario[0].Id;
                caso.AccountId = oficina1.Id;

                insert caso;
    
                Id gestorClienteId = caso.OwnerId;
                Id taskRecordTypeId = taskRecordTypeId;
    
                Map<String, Object> respuesta = new Map<String, Object>{
                    'recordTypeTarea' => taskRecordTypeId,
                    'asunto' => 'Tarea para Director',
                    'comentarios' => 'Se requiere revisión del caso',
                    'recordId' => caso.Id,
                    'accountId' =>  caso.AccountId,
                    'numeroOficina' => oficina1.CC_Numero_Oficina__c,
                    'gestorClienteId' => gestorClienteId
                };
    
                Task tarea = CC_Activity.crearTareaDirector(respuesta);
                insert tarea;
                Test.stopTest();

                System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :oficina1.Id]);
            }
        }
    }
 
    
    @isTest
    public static void crearTareaGestorTest() {
        List<User> usuario = [SELECT Id FROM User WHERE Profile.Name LIKE 'CC_Usuario_CaixaBank' AND IsActive=true LIMIT 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = '01' LIMIT 1];
    
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {

                Test.startTest();
                Case caso = new Case();
                caso.CC_Idioma__c = 'es';
                caso.Subject = 'Caso Gestor';
                caso.CC_Tipo_Cliente__c = 'Cliente';
                caso.Status = 'Activo';
                caso.Origin = 'Comentarios Stores';
                caso.CC_Tipo_Contacto__c = 'Consulta';
                caso.CC_Canal_Procedencia__c = 'Google Play Store';
                caso.OwnerId = usuario[0].Id;
                insert caso;
    
                Id gestorClienteId = caso.OwnerId;
                Id taskRecordTypeId = taskRecordTypeId;
                Date todayDate = CBK_UtilsDate.todayDT();
    
                Map<String, Object> respuesta = new Map<String, Object>{
                    'recordTypeTarea' => taskRecordTypeId,
                    'asunto' => 'Tarea para Gestor',
                    'comentarios' => 'Se requiere seguimiento del caso',
                    'fechaActividad' => todayDate.addDays(5),
                    'whatId' => caso.Id,
                    'ownerId' => gestorClienteId
                };
    
                Task tarea = CC_Activity.crearTareaGestor(respuesta);
                insert tarea;
                Test.stopTest();
    
                System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
            }
        }  
    }
    
    
    @isTest
    public static void crearActividadFraudeTest() {
        List<User> usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0112345' AND IsActive=true LIMIT 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = '02' LIMIT 1];
        
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
                Test.startTest();
                Case caso = new Case();
                caso.CC_Idioma__c = 'es';
                caso.Subject = 'Caso de Fraude';
                caso.CC_Tipo_Cliente__c = 'Cliente';
                caso.Status = 'Activo';
                caso.Origin = 'Comentarios Stores';
                caso.CC_Tipo_Contacto__c = 'Consulta';
                caso.CC_Canal_Procedencia__c = 'Google Play Store';
                caso.OwnerId = usuario[0].Id;
                insert caso;
    
                Id ownerId = caso.OwnerId;

                CC_Activity.crearActividadFraude(caso.Id, caso);
                Test.stopTest();
    
                System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
            }
        }
    }

    @isTest
    public static void crearTareaRellamadaCSBD() {
        List<User> usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0112345' AND IsActive=true LIMIT 1];
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
                Test.startTest();
                Case caso = [SELECT Id FROM Case WHERE Subject = 'casoConOportunidad' LIMIT 1];
                String descripcion = 'descripcion';
                String type = 'Cita gestor';

                Id rtOportunidad = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_MAC');

                Opportunity oportunidad = new Opportunity(
                    RecordTypeId = rtOportunidad,
                    Name = 'Oportunidad Test',
                    StageName = 'Solicitud',
                    CSBD_Estado__c = 'Activa',
                    CSBD_CasoOrigen__c = caso.Id,
                    OwnerId = usuario[0].Id
                );
            
                insert oportunidad;

                Task tarea = CC_Activity.crearTareaRellamadaCSBD(oportunidad, caso, descripcion);
                Test.stopTest();

                System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :oportunidad.Id]);

            }
        }
    }
    
    @isTest
    public static void crearTareaRellamadaCC() {
        List<User> usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0112345' AND IsActive=true LIMIT 1];
        Account cuenta = [SELECT Id FROM Account WHERE Name = 'Cuenta02' LIMIT 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = '02' LIMIT 1];
        
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {

                Test.startTest();

                Case caso = new Case(
                    Description = 'casoConOportunidad',
                    Subject = 'casoConOportunidad',
                    Origin = 'Email',
                    Status = 'Activo',
                    accountId = cuenta.Id,
                    CC_Idioma__c = 'es',
                    CC_Canal_Respuesta__c = 'Email',
                    CC_Grupo_3N__c = 'Grupo 3N',
                    CC_Tipo_Contacto__c = 'Consulta',
                    CC_Canal_Procedencia__c = 'Formulario web',
                    CC_Detalles_Consulta__c = 'Caso de Contact Center',
                    OwnerId = usuario[0].Id,
                    ContactId = contacto.Id
                );
                insert caso;

                String descripcion = 'Descripcion';
                String type = 'Consulta oportunidad formalizada';


                Task tarea = CC_Activity.crearTareaRellamadaCC(caso, descripcion, type);
                Test.stopTest();

                System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);

            }
        }
    }

    @isTest
    public static void permisosNuevaTareaTest() {
        List<User> usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0112345' AND IsActive=true LIMIT 1];
        Account cuenta = [SELECT Id FROM Account WHERE Name = 'Cuenta02' LIMIT 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = '02' LIMIT 1];
        
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {

                Test.startTest();

                Case caso = new Case(
                    Description = 'casoConOportunidad',
                    Subject = 'casoConOportunidad',
                    Origin = 'Email',
                    Status = 'Activo',
                    accountId = cuenta.Id,
                    CC_Idioma__c = 'es',
                    CC_Canal_Respuesta__c = 'Email',
                    CC_Grupo_3N__c = 'Grupo 3N',
                    CC_Tipo_Contacto__c = 'Consulta',
                    CC_Canal_Procedencia__c = 'Formulario web',
                    CC_Detalles_Consulta__c = 'Caso de Contact Center',
                    OwnerId = usuario[0].Id,
                    ContactId = contacto.Id
                );
                insert caso;

                String descripcion = 'Descripcion';
                String type = 'Consulta oportunidad formalizada';

                Boolean valor = CC_Task.permisosNuevaTarea(caso.Id);
                Test.stopTest();

                System.assertEquals(true, valor, 'Error al recuperar el permisosNuevaTarea');
            }
        }
    }

        
    @isTest
    public static void crearActividadCSBDTelefonoNoCoincidenteTest() {
        List<User> usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0112345' AND IsActive=true LIMIT 1];
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
                Test.startTest();
                
                Account cuenta = [SELECT Id FROM Account WHERE Name = 'Cuenta02' LIMIT 1];
                Contact contacto = [SELECT Id FROM Contact WHERE LastName = '02' LIMIT 1];

                Case caso = new Case(
                    Description = 'caso',
                    Subject = 'caso',
                    Origin = 'Email',
                    Status = 'Activo',
                    accountId = cuenta.Id,
                    CC_Idioma__c = 'es',
                    CC_Canal_Respuesta__c = 'Email',
                    CC_Grupo_3N__c = 'Grupo 3N',
                    CC_Tipo_Contacto__c = 'Consulta',
                    CC_Canal_Procedencia__c = 'Formulario web',
                    CC_Detalles_Consulta__c = 'Caso de Contact Center',
                    OwnerId = usuario[0].Id,
                    ContactId = contacto.Id
                );

                insert caso;


                CC_Activity.crearActividadCSBDTelefonoNoCoincidente(caso.Id);
                Test.stopTest();
                System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
            }
        }
    }

    @isTest
    public static void crearActividadMecanismoFirmaTest() {
        List<User> usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0112345' AND IsActive=true LIMIT 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = '02' LIMIT 1];
        
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
                Case caso = new Case();
                caso.CC_Idioma__c = 'es';
                caso.Subject = 'Caso Mecanismo Firma';
                caso.CC_Tipo_Cliente__c = 'Cliente';
                caso.Status = 'Activo';
                caso.Origin = 'Comentarios Stores';
                caso.CC_Tipo_Contacto__c = 'Consulta';
                caso.CC_Canal_Procedencia__c = 'Google Play Store';
                caso.OwnerId = usuario[0].Id;
                
                insert caso;
    
                Test.startTest();
                CC_Activity.crearActividadMecanismoFirma(caso, caso.OwnerId);
                Test.stopTest();
    
                System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
            }
        }
    }

    
    @isTest
    public static void crearActividadCajerosTest() {
        List<User> usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0112345' AND IsActive=true LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'casoGenerico' LIMIT 1];
        
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
                Test.startTest();
                CC_Activity.crearActividadCajeros(caso.Id);
                Test.stopTest();
    
                System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
            }
        }
    }

    @isTest
    public static void crearTaskPhishingSinRiesgoTest() {
        List<User> usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0112345' AND IsActive=true LIMIT 1];
        Case caso = [SELECT Id, OwnerId, ContactId, Contact.AccountId FROM Case WHERE Subject = 'casoGenerico' LIMIT 1];
        
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
                Test.startTest();
                CC_Activity.crearTaskPhishingSinRiesgo(caso, 'Comentario de prueba', 'Consulta oportunidad formalizada');
                Test.stopTest();
    
                System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
            }
        }
    }

    @isTest
    public static void crearActividadPhishingSinRiesgoTest() {
        List<User> usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0112345' AND IsActive=true LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'casoGenerico' LIMIT 1];
        
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
                Test.startTest();
                CC_Activity.crearActividadPhishingSinRiesgo(caso.Id, 'Comentario de prueba');
                Test.stopTest();
    
                System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
            }
        }
    }

        @isTest
    public static void crearActividadOficinaSinTareaTest() {
        List<User> usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0112345' AND IsActive=true LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'casoGenerico' LIMIT 1];
        
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
                Test.startTest();
                CC_Activity.crearActividadOficinaSinTarea(caso.Id);
                Test.stopTest();
    
                System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
            }
        }
    }

    @isTest
    public static void crearActividadComunidadesPropietarios() {
        List<User> usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0112345' AND IsActive=true LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'casoGenerico' LIMIT 1];
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
                Test.startTest();
                CC_Activity.crearActividadComunidadesPropietarios(caso.Id, '', 'MENSAJE');
                Test.stopTest();
    
                System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
            }
        }
        
    }

    
    @isTest
    public static void crearActividadCobrowsingTest() {
        List<User> usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0112345' AND IsActive=true LIMIT 1];
        List<Case> caso = [SELECT Id FROM Case WHERE Subject = 'casoGenerico' LIMIT 1];
        List<String> listacasos = new List <String>();
        listacasos.add(caso[0].Id.toString());
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
                Test.startTest();
                CC_Activity.crearActividadCobrowsing(listacasos);
                Test.stopTest();
    
                System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :caso[0].Id]);
            }
        }
        
    }

    @isTest
    public static void crearActividadIdentificadorBloqueadoTest(){
        List<User> usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0112345' AND IsActive=true LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'casoGenerico' LIMIT 1];
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
                Test.startTest();
                CC_Activity.crearActividadIdentificadorBloqueado(caso.Id);
                Test.stopTest();
    
                System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
            }
        }

    }
}