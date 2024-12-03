@isTest
public with sharing class HDT_Activity_Test {

    @testSetup
    static void data() {
        Contact contacto = new Contact();
        contacto.LastName = 'Test';
        contacto.CC_Numero_Documento__c = '36592162J';
        contacto.CC_Sexo__c = 'V';
        insert contacto;

        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.ContactId = contacto.Id;
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        insert caso;
    }

    /**
     * Comprobar creación de lista de tareas.
    */
    @isTest
    private static void crearEventoTest() {

        System.runAs(new User(Id = UserInfo.getUserId())) {


        Map<String, Object> campos = new Map<String, Object>();
		Date fecha = Date.today();
        campos.put('Type', 'Alerta programada');
        campos.put('Subject','Alerta programada');
        campos.put('Description','descripcion');
        campos.put('StartDateTime',fecha);
        campos.put('EndDateTime',fecha);

        Test.startTest();

            HDT_Activity.crearEvento('HDT_Event', campos);
       

        Test.stopTest();
        List<Event> lstEventos = [SELECT Id FROM Event];
        System.assertEquals(lstEventos.isEmpty(), false, 'No se ha creado el evento');
        }
    }

    /**
     * Comprobar reabrir tarea de colaborador.
    */
    @isTest
    private static void testReabrirTareaTrasladoColab() {
        System.runAs(new User(Id = UserInfo.getUserId())) {


        Map<String, Object> camposTarea = new Map<String, Object>();
        Id rtTarea = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();

        Case caso = [Select contactId from Case where Subject = 'Caso Test' limit 1];

        Task tarea = new Task();
        tarea.RecordTypeId = rtTarea;
        tarea.WhatId = caso.Id;
        tarea.WhoId = caso.ContactId;
        tarea.Status = 'Completed';
        tarea.Type = 'Traslado Colaborador';
        tarea.TaskSubtype = 'Email';
        tarea.Subject = 'Test Subject';
        tarea.ActivityDate = System.today();
        insert tarea;

        Test.startTest();
       
            HDT_Activity.reabrirTareaTrasladoColab(caso.Id);
        
        Test.stopTest();

        Task tareaUpdate = [Select id, Status from Task where Id = :tarea.Id limit 1];

		system.assertEquals('Open', tareaUpdate.Status, 'No coincide el campo Status de la tarea.');
        }
    }

    /**
     * Comprobar creación de lista de tareas.
    */
    @isTest
    private static void crearActividadRetipificacionTest() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

		Case caso = [SELECT Id from Case];
        Test.startTest();
        Id tareaCreada = HDT_Activity.crearActividadRetipificacion(caso.Id, 'TematicaTest', 'ProductoTest', 'MotivoTest');
        Test.stopTest();

        
            System.assertEquals(tareaCreada != null, true, 'No se ha creado la tarea');
        }


        

    }

    /**
     * Comprobar creación de lista de tareas.
    */
    @isTest
    private static void finalizarActividadesCasoTest() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

		Task tarea = new Task();
        List<Task> lstTareas = new List<Task>();
        lstTareas.add(tarea);

        Test.startTest();
       
            HDT_Activity.crearlstTareas(lstTareas);
            List<Task> lstTareasCreadas = [SELECT Id from Task];
            HDT_Activity.finalizarActividadesCaso(lstTareasCreadas,'Traslado Colaborador');
        

        Test.stopTest();

        List<Task> lstTareasCreadasDos = [SELECT Id, Status from Task];
        System.assertEquals(lstTareasCreadasDos[0].Status, 'Completed', 'No se ha finalizado la tarea');
        }
    }

     /**
     * Comprobar creación de lista de tareas.
    */
    @isTest
    private static void crearlstTareasTest() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

		Task tarea = new Task();
        List<Task> lstTareas = new List<Task>();
        lstTareas.add(tarea);

        Test.startTest();
        
            HDT_Activity.crearlstTareas(lstTareas);
        
        Test.stopTest();


        List<Task> lstTaskCreadas = [Select Id FROM Task];
        System.assertEquals(lstTaskCreadas.isEmpty(), false, 'No se han creado las tareas');
        }
    }

    @isTest
    public static void finalizarActividad() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        Caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Empleado';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        insert caso;

        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
        Task actividad = new Task();
        actividad.Status = 'Open';
        actividad.WhatId= caso.Id;
        actividad.RecordTypeId = taskRecordTypeId;
        insert actividad;

        Test.startTest();

     
            HDT_Activity.finalizarActividad(actividad.Id);
        

        Test.stopTest();

        actividad = [SELECT Status FROM Task WHERE Id = :actividad.Id AND RecordTypeId =: taskRecordTypeId LIMIT 1];

        System.assertEquals('Completed', actividad.Status);
        }
    }

    @isTest
    public static void finalizarActividadCaso() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        Caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso.CC_Tipo_Cliente__c = 'Empleado';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
        insert caso;

        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();

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
       
            HDT_Activity.finalizarActividadCaso(caso.Id, 'Rechazar Primer Nivel', 'Devuelta 3N', 'descripción');
        

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
    }

    @isTest
    public static void finalizarActividadCaso3N() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        Caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso.CC_Tipo_Cliente__c = 'Empleado';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
        insert caso;

        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
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

      
            HDT_Activity.finalizarActividadCaso(caso.Id, 'Traslado Tercer Nivel', 'Rechazado por Tercer Nivel', 'descripción');
        

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
    }

    @isTest
    public static void finalizarActividadCasoTrasladoColaborador() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso.CC_Tipo_Cliente__c = 'Empleado';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
        insert caso;

        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
  		Task actividad1 = new Task();
        actividad1.WhatId = caso.Id;
        actividad1.Type = 'Traslado Colaborador';
        actividad1.Status = 'Open';
        actividad1.RecordTypeId = taskRecordTypeId;
        insert actividad1;

        Test.startTest();
        
            HDT_Activity.finalizarActividadCaso(caso.Id, 'Traslado Colaborador', 'Traslado Colaborador', 'descripción');
        

        Test.stopTest();

        actividad1 = [SELECT Status, CC_Tipo_Cierre__c, Description FROM Task WHERE Id = :actividad1.Id AND RecordTypeId =: taskRecordTypeId LIMIT 1];

        System.assertEquals('Completed', actividad1.Status);
        }
    }

    @isTest
    public static void informarFechaVencimientoSLACol() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Empleado';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
        insert caso;

        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
  		Task actividad2 = new Task();
        actividad2.WhatId = caso.Id;
        actividad2.Status = 'Open';
        actividad2.Type = 'Traslado Grupo Colaborador';
        actividad2.RecordTypeId = taskRecordTypeId;
        insert actividad2;

        Task act = [SELECT Id, Status, Type,CC_Tiempo_Resolucion__c FROM Task WHERE Type = 'Traslado Grupo Colaborador' AND RecordTypeId =: taskRecordTypeId LIMIT 1];

        String tipo = 'Grupo colaborador';
       
            HDT_Activity.informarFechaVencimientoSLA(tipo, 'Grupo Colaborador', act);
        
        
        System.assertEquals(null, act.CC_Tiempo_Resolucion__c);
        }
    }

    @isTest
    public static void informarFechaVencimientoSLA3N() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Empleado';
        caso.Status = 'Activo';
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso.Origin = 'Email';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
        insert caso;

        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
  		Task actividad2 = new Task();
        actividad2.WhatId = caso.Id;
        actividad2.Status = 'Open';
        actividad2.Type = 'Traslado Tercer Nivel';
        actividad2.RecordTypeId = taskRecordTypeId;
        insert actividad2;

        Task act = [SELECT Id, Status, Type,CC_Tiempo_Resolucion__c FROM Task WHERE Type = 'Traslado Tercer Nivel' AND RecordTypeId =: taskRecordTypeId LIMIT 1];

		String tipo = 'Grupo 3N';
        
            HDT_Activity.informarFechaVencimientoSLA(tipo, 'Grupo 1', act);
        

        System.assertEquals(null, act.CC_Tiempo_Resolucion__c);
        }
    }

    @isTest
    public static void crearActividadTest() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

     	Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Cliente__c = 'Empleado';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
		caso.CC_Tipo_Contacto__c = 'Petición de servicio';
        caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
        caso.CC_Canal_Resolucion__c = 'Servicios Centrales';
        insert caso;

  		Task actividad1 = new Task();
        actividad1.WhatId = caso.Id;
        actividad1.Type = 'Rechazar Primer Nivel';
        actividad1.Status = 'Open';

      
            System.assertNotEquals(null, HDT_Activity.crearActividad(actividad1));
        
        }    
    }

    @isTest
    public static void crearActividades1Test() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

     	Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Cliente__c = 'Empleado';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
		caso.CC_Tipo_Contacto__c = 'Petición de servicio';
        caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
        caso.CC_Canal_Resolucion__c = 'Servicios Centrales';
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
        
        
            HDT_Activity.crearActividades(tareas, true);
            System.assertEquals(2, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
        

       

        }
    }

    @isTest
    public static void crearActividades2Test() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

     	Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Cliente__c = 'Empleado';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
		caso.CC_Tipo_Contacto__c = 'Petición de servicio';
        caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
        caso.CC_Canal_Resolucion__c = 'Servicios Centrales';
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

      
            HDT_Activity.crearActividades(tareas);
        

      
        System.assertEquals(2, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
    }
    }

    @isTest
    public static void crearActividadesPasandoRecordTypeTest() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

     	Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Cliente__c = 'Empleado';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
		caso.CC_Tipo_Contacto__c = 'Petición de servicio';
        caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
        caso.CC_Canal_Resolucion__c = 'Servicios Centrales';
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
     
          HDT_Activity.crearActividades(tareas, 'HDT_Task');
        


       
        System.assertEquals(2, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);
    }
    }

    @isTest
    static void testCrearLstTareas() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        // Preparar datos de prueba
        List<Task> lstTarea = new List<Task>();
        Task tarea1 = new Task(Subject = 'Test Tarea 1', Status = 'Not Started', Priority = 'Normal');
        Task tarea2 = new Task(Subject = 'Test Tarea 2', Status = 'Not Started', Priority = 'Normal');
        lstTarea.add(tarea1);
        lstTarea.add(tarea2);

        // Ejecutar método
        Test.startTest();
       
            HDT_Activity.crearlstTareas(lstTarea);
        

        
        Test.stopTest();

        // Verificar resultados
        List<Task> insertedTasks = [SELECT Id, Subject FROM Task WHERE Subject IN ('Test Tarea 1', 'Test Tarea 2')];
        System.assertEquals(2, insertedTasks.size(), 'Se deben insertar dos tareas');
    }
    }

    @isTest
    static void testCrearTarea() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        // Preparar datos de prueba
        String recordTypeDeveloperName = 'HDT_Task';
        Map<String, Object> campos = new Map<String, Object>{
            'Subject' => 'Test Tarea 3',
            'Status' => 'Not Started',
            'Priority' => 'Normal'
        };

        // Ejecutar método
        Test.startTest();
        Task tarea;
     
            tarea = HDT_Activity.crearTarea(recordTypeDeveloperName, campos);
        


        
        Test.stopTest();

        // Verificar resultados
        System.assertEquals('Test Tarea 3', tarea.Subject, 'El asunto de la tarea debe ser "Test Tarea 3"');
        System.assertEquals('Not Started', tarea.Status, 'El estado de la tarea debe ser ');
        System.assertEquals('Normal', tarea.Priority, 'La prioridad de la tarea debe ser "Normal"');
        System.assertNotEquals(null, tarea.RecordTypeId, 'El RecordTypeId no debe ser nulo');
    }
    }


}