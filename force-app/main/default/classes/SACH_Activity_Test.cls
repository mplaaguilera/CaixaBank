@isTest
public with sharing class SACH_Activity_Test {
    
    @testSetup
    static void data(){
        
        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        
        Contact contacto = new Contact(LastName = 'Test', CC_Numero_Documento__c = '36592162J', CC_Sexo__c = 'V');
        insert contacto;
        
        //Preparación de los datos
        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.ContactId = contacto.Id;
        caso.RecordTypeId = rtCaso;
        insert caso;
               
    }
    
    /**
     * Comprobar creación de lista de tareas.
    */
    @isTest
    private static void crearlstTareasTest() {
		Task tarea = new Task();
        List<Task> lstTareas = new List<Task>();
        lstTareas.add(tarea);
        
        Test.startTest();
        SACH_Activity.crearlstTareas(lstTareas);
        Test.stopTest();
        
        List<Task> lstTaskCreadas = [Select Id FROM Task];
        System.assertEquals(lstTaskCreadas.isEmpty(), false, 'No se han creado las tareas');
    }

    /**
     * Comprobación al crear una tarea con campos específicos.
    */
    @isTest
    private static void testCrearTareaConCampos() {
        
        Map<String, Object> camposTarea = new Map<String, Object>();
        
        Case caso = [Select Id, contactId from Case where Subject = 'Caso Test' limit 1];
        
        // Creación de Caso
        camposTarea.put('Type', 'Correo - Entrada');
        camposTarea.put('TaskSubtype', 'Email');
        camposTarea.put('Subject', 'Test Subject');
        camposTarea.put('ActivityDate', System.today());
        camposTarea.put('Status', 'Completed');
        camposTarea.put('Description', 'Test Description');
        camposTarea.put('WhatId', caso.Id);
        camposTarea.put('WhoId', caso.ContactId);
        
        Test.startTest();
        Task tareaCreada = SACH_Activity.crearTarea('Task', camposTarea);
        Test.stopTest();

        system.assertEquals('Correo - Entrada', tareaCreada.Type, 'No coincide el campo type de la tarea.');
        system.assertEquals('Email', tareaCreada.TaskSubtype, 'No coincide el campo subtype de la tarea.');
        system.assertEquals('Test Subject', tareaCreada.Subject, 'No coincide el campo subject de la tarea.');
        system.assertEquals(System.today(), tareaCreada.ActivityDate, 'No coincide el campo ActivityDate de la tarea.');
        system.assertEquals('Completed', tareaCreada.Status, 'No coincide el campo Status de la tarea.');
        system.assertEquals('Test Description', tareaCreada.Description, 'No coincide el campo Description de la tarea.');
        system.assertEquals(caso.Id, tareaCreada.WhatId, 'No coincide el campo WhatId de la tarea.');
        system.assertEquals(caso.ContactId, tareaCreada.WhoId, 'No coincide el campo WhoId de la tarea.');
    }
    
    /**
     * Comprobación cierre de tarea de colaborador.
    */
    @isTest
    private static void testFinalizarActividadCaso() {
        
        Map<String, Object> camposTarea = new Map<String, Object>();
        Id rtTarea = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Task').getRecordTypeId();
        
        Case caso = [Select Id, contactId from Case where Subject = 'Caso Test' limit 1];
        
        Task tarea = new Task();
        tarea.RecordTypeId = rtTarea;
        tarea.WhatId = caso.Id;
        tarea.WhoId = caso.ContactId;
        tarea.Status = 'Open';
        tarea.Type = 'Traslado Colaborador';
        tarea.TaskSubtype = 'Email';
        tarea.Subject = 'Test Subject';
        tarea.ActivityDate = System.today();
        insert tarea;

        Test.startTest();
        SACH_Activity.finalizarActividadCaso(caso.Id, 'Traslado Colaborador', null, null);
        Test.stopTest();

        Task tareaUpdate = [Select id, Status, CC_Fecha_Fin__c, CC_Fecha_1_Reclamacion_Auto__c, CC_Fecha_2_Reclamacion_Auto__c, CC_Fecha_3_Reclamacion_Auto__c from Task where WhatId = :caso.Id limit 1];
        
        system.assertEquals('Completed', tareaUpdate.Status, 'No coincide el campo Status de la tarea.');
    }
    
    /**
     * Comprobar reabrir tarea de colaborador.
    */
    @isTest
    private static void testReabrirTareaTrasladoColab() {
    
        Map<String, Object> camposTarea = new Map<String, Object>();
        Id rtTarea = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Task').getRecordTypeId();
        
        Case caso = [Select Id, contactId from Case where Subject = 'Caso Test' limit 1];
        
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
        SACH_Activity.reabrirTareaTrasladoColab(caso.Id);
        Test.stopTest();

        Task tareaUpdate = [Select id, Status from Task where Id = :tarea.Id limit 1];
        
		system.assertEquals('Open', tareaUpdate.Status, 'No coincide el campo Status de la tarea.');
        
    }
    
    /**
     * Comprobar creación de lista de tareas.
    */
    @isTest
    private static void crearEventoTest() {
        
        Map<String, Object> campos = new Map<String, Object>();
		Date fecha = Date.today();
        campos.put('Type', 'Alerta programada');
        campos.put('Subject','Alerta programada');
        campos.put('Description','descripcion');
        campos.put('StartDateTime',fecha);
        campos.put('EndDateTime',fecha);
        
        Test.startTest();
        SACH_Activity.crearEvento('SACH_Event',campos);
        Test.stopTest();
        List<Event> lstEventos = [SELECT Id from Event];
        System.assertEquals(lstEventos.isEmpty(), false, 'No se ha creado el evento');
        
    }
    
    /**
     * Comprobar creación de lista de tareas.
    */
    @isTest
    private static void finalizarActividadesCasoTest() {
		Task tarea = new Task();
        List<Task> lstTareas = new List<Task>();
        lstTareas.add(tarea);
        
        Test.startTest();
        SACH_Activity.crearlstTareas(lstTareas);
        List<Task> lstTareasCreadas = [SELECT Id from Task];
        SACH_Activity.finalizarActividadesCaso(lstTareasCreadas,'Traslado Colaborador');
        Test.stopTest();
        List<Task> lstTareasCreadasDos = [SELECT Id, Status from Task];
        System.assertEquals(lstTareasCreadasDos[0].Status, 'Completed', 'No se ha finalizado la tarea');
        
    }
    
    /**
     * Comprobar creación de lista de tareas.
    */
    @isTest
    private static void eliminarTareasTest() {
		
        Date fecha = Date.today();
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('Type', 'Alerta programada');
        campos.put('Subject','Alerta programada');
        campos.put('Description','descripcion');
        campos.put('StartDateTime',fecha);
        campos.put('EndDateTime',fecha);

        Event tarea = SACH_Activity.crearEvento('SACH_Event', campos);
        
        Test.startTest();
        List<Event> lstEventosCreadas = [SELECT Id from Event];
        SACH_Activity.eliminarTareas(lstEventosCreadas);
        Test.stopTest();
        List<Event> eventoCreado = [SELECT Id from Event WHERE Id =: lstEventosCreadas[0].Id];
        System.assertEquals(eventoCreado.isEmpty(), true, 'No se ha borrado el evento');
    }
    
    /**
     * Comprobar creación de lista de tareas.
    */
    @isTest
    private static void crearActividadRetipificacionTest() {

		Case caso = [SELECT Id from Case];        
        Test.startTest();
        Id tareaCreada = SACH_Activity.crearActividadRetipificacion(caso.Id, 'TematicaTest', 'ProductoTest', 'MotivoTest');
        Test.stopTest();
        
        System.assertEquals(tareaCreada != null, true, 'No se ha creado la tarea');
        
    }
 
}