@isTest
public with sharing class CC_Activity_Test {

    @TestSetup
    static void makeData(){
        
        
        
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profile3NId = [SELECT Id FROM Profile WHERE Name = 'CC_Tercer_Nivel_CBKNow_MVP2'].Id;
        Id profileIdAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_CCO'];

        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = profileIdAdmin;
        usuario1.FirstName = 'Usuario Admin Prueba';
        usuario1.LastName = 'last211053';
        usuario1.Email = 'aalsdna@kfsb.com';
        usuario1.Username = 'tuser0001@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';

        userList.add(usuario1);
       
        UserRole rolId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
        //crear usuarios CC

        User usuario2 = new User();
        usuario2.ProfileId = profileId;
        usuario2.FirstName = 'first2';
        usuario2.LastName = 'last2';
        usuario2.Email = 'tuser000@amamama.com';
        usuario2.Username = 'tuser002@amamama.com' + System.currentTimeMillis();
        usuario2.CompanyName = 'DXC';
        usuario2.Title = 'title';
        usuario2.Alias = 'alias';
        usuario2.TimeZoneSidKey = 'Europe/Paris';
        usuario2.EmailEncodingKey = 'UTF-8';
        usuario2.LanguageLocaleKey = 'es';
        usuario2.LocaleSidKey = 'es_ES';
        userList.add(usuario2);
        insert userList;
    }
    @isTest
    public static void finalizarActividad() {
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;
        
        Id taskRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        Task actividad = new Task();
        actividad.Status = 'Open';
        actividad.WhatId= caso.Id;
        actividad.RecordTypeId = taskRecordTypeId;
        insert actividad;

        Test.startTest();
        CC_Activity.finalizarActividad(actividad.Id);
        Test.stopTest();

        actividad = [SELECT Status FROM Task WHERE Id = :actividad.Id AND RecordTypeId =: taskRecordTypeId LIMIT 1];

        System.assertEquals('Completed', actividad.Status);
    }

    @isTest
    public static void finalizarActividadCaso() {
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;

        Id taskRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        
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

        Test.startTest();
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
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;
		
        Id taskRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
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

        Test.startTest();
        CC_Activity.finalizarActividadCaso(caso.Id, 'Traslado Tercer Nivel', 'Rechazado por Tercer Nivel', 'descripción');
        Test.stopTest();

        actividad1 = [SELECT Status, CC_Tipo_Cierre__c, Description FROM Task WHERE Id = :actividad1.Id AND RecordTypeId =: taskRecordTypeId LIMIT 1];
        actividad2 = [SELECT Status, CC_Tipo_Cierre__c, Description FROM Task WHERE Id = :actividad2.Id AND RecordTypeId =: taskRecordTypeId LIMIT 1];

        System.assertEquals('Open', actividad1.Status);
        //System.assertEquals('Rechazado por Tercer Nivel', actividad1.CC_Tipo_Cierre__c);
        //System.assertEquals('descripción', actividad1.Description);
        //System.assertEquals('Open', actividad2.Status);
        //System.assertEquals(null, actividad2.CC_Tipo_Cierre__c);
        //System.assertEquals(null, actividad2.Description);
    }
    
    @isTest
    public static void finalizarActividadCasoTrasladoColaborador() {
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;
		
        Id taskRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
  		Task actividad1 = new Task();
        actividad1.WhatId = caso.Id;
        actividad1.Type = 'Traslado Colaborador';
        actividad1.Status = 'Open';
        actividad1.RecordTypeId = taskRecordTypeId;
        insert actividad1;
        
        Test.startTest();
        CC_Activity.finalizarActividadCaso(caso.Id, 'Traslado Colaborador', 'Traslado Colaborador', 'descripción');
        Test.stopTest();

        actividad1 = [SELECT Status, CC_Tipo_Cierre__c, Description FROM Task WHERE Id = :actividad1.Id AND RecordTypeId =: taskRecordTypeId LIMIT 1];

        System.assertEquals('Completed', actividad1.Status);
    }
    
    @isTest
    public static void informarFechaVencimientoSLACol() {
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;
        
        Id taskRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
  		Task actividad2 = new Task();
        actividad2.WhatId = caso.Id;
        actividad2.Status = 'Open';
        actividad2.Type = 'Traslado Grupo Colaborador';
        actividad2.RecordTypeId = taskRecordTypeId;
        insert actividad2;
        
        Task act = [SELECT Id, Status, Type FROM Task WHERE Type = 'Traslado Grupo Colaborador' AND RecordTypeId =: taskRecordTypeId LIMIT 1];
        
        String tipo = 'Grupo colaborador';
        
        CC_Activity.informarFechaVencimientoSLA(tipo, 'Grupo Colaborador', act);
    }
    
    @isTest
    public static void informarFechaVencimientoSLA3N() {
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;
        
        Id taskRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
  		Task actividad2 = new Task();
        actividad2.WhatId = caso.Id;
        actividad2.Status = 'Open';
        actividad2.Type = 'Traslado Tercer Nivel';
        actividad2.RecordTypeId = taskRecordTypeId;
        insert actividad2;
        
        Task act = [SELECT Id, Status, Type FROM Task WHERE Type = 'Traslado Tercer Nivel' AND RecordTypeId =: taskRecordTypeId LIMIT 1];
        
		String tipo = 'Grupo 3N';
        
        CC_Activity.informarFechaVencimientoSLA(tipo, 'Grupo 1', act);
    }
    
    @isTest
    public static void crearActividadTest() {
         List<User> usuario = [SELECT Id FROM User WHERE Profile.name LIKE 'CC_Usuario_CaixaBank' AND IsActive=true];
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
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
        
        System.assertNotEquals(null, CC_Activity.crearActividad(actividad1));
            }
        }
    }
    
    
    @isTest
    public static void crearActividades1Test() {
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
        
        CC_Activity.crearActividades(tareas, true);
        System.assertEquals(2,  [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
        
        List<Task> listaTareasComprobar = [SELECT Id FROM Task WHERE WhatId = :caso.Id];
        CC_Activity.finalizarActividadCaso(listaTareasComprobar[0].Id, 'Traslado Tercer Nivel', 'Devuelto por Tercer Nivel', 'comentario');
    }
    
    @isTest
    public static void crearActividades2Test() {
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
        
        CC_Activity.crearActividades(tareas);
        System.assertEquals(2, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
    }
    
    @isTest
    public static void crearActividadesPasandoRecordTypeTest() {
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
        
        CC_Activity.crearActividades(tareas, 'CC_Task');
        System.assertEquals(2, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
    }
    
     @isTest
    public static void llamadaQueueableCrearActividadesTest() {
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

        List<User> usuario = [SELECT Id FROM User WHERE Profile.name LIKE 'CC_Usuario_CaixaBank' AND IsActive=true];
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
        
        CC_Activity.llamadaQueueableCrearActividades(tareas);
        System.assertEquals(0, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
            }
        }
    }
    
         @isTest
    public static void crearActividadesTest() {
        List<User> usuario = [SELECT Id FROM User WHERE Profile.name LIKE 'CC_Usuario_CaixaBank' AND IsActive=true];
        if (!usuario.isEmpty()) {
            System.runAs(usuario[0]) {
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
        

        CC_Activity.crearActividades(tareas);
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
        System.assertEquals(2, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
            }
        }
    }
    
}