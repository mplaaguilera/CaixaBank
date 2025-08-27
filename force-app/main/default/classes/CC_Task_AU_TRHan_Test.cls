@isTest 
public class CC_Task_AU_TRHan_Test
{
    @TestSetup
    static void makeData(){
        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
        PermissionSet psSupervisor = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Supervisor_PS'];
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        
        List<User> userList = new List<User>();
        User usuarioAdmin = new User();
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = roleCC;
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';
		userList.add(usuarioAdmin);
        
        User usuario1 = new User();
        usuario1.ProfileId = profileId;
        usuario1.FirstName = 'Usuario Supervisor';
        usuario1.LastName = 'last211053Supervisor';
        usuario1.Email = 'aalsdna@kfsb.com';
        usuario1.Username = 'tuser0001@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';
        usuario1.UserRoleId = roleCC;
        userList.add(usuario1);
        insert userList; 
        
        insert new PermissionSetAssignment(AssigneeId = usuario1.id, PermissionSetId = psSupervisor.Id);
        
        System.runAs(usuarioAdmin){
            Task tarea = new Task();
            tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
            tarea.Subject = 'Tarea para ver si se actualiza el campo última actualización';
            tarea.Status = 'Open';
            insert tarea;
    
            Case csReadOnly = new Case(
                Subject = 'TestData', 
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(), 
                Status = 'Activo', 
                Origin = 'Phone', 
                CC_Canal_Procedencia__c = 'Tarjetas',
                CC_Canal_Resolucion__c = 'Tarjetas',
                CC_Canal_Respuesta__c = 'Phone'
            );
    
            insert csReadOnly;

            Task tareaReadOnly = new Task();
            tareaReadOnly.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_ReadOnly').getRecordTypeId();
            tareaReadOnly.Subject = 'Tarea test ReadOnly';
            tareaReadOnly.Status = 'Open';
            tareaReadOnly.Type = 'Llamada entrante';
            tareaReadOnly.CC_Tipo_Cierre__c = 'Llamada no atendida';
            tareaReadOnly.WhatId = csReadOnly.Id;
            insert tareaReadOnly;

            Account cuenta = new Account();
            cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
            cuenta.FirstName = 'Cuenta';
            cuenta.LastName = 'Test';
            cuenta.CC_Email__c = 'cuenta@test.com';
            cuenta.PersonMobilePhone = '+34 123456789';
            cuenta.PersonBirthdate = CBK_UtilsDate.todayDT().addYears(-24);
            cuenta.CC_NumPerso__c = '206';
            insert cuenta;

            Contact contacto = new Contact();
            contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
            contacto.FirstName = 'Contacto';
            contacto.LastName = 'Test';
            contacto.CC_Idioma__c = 'es';
            contacto.Email = 'contacto@test.com';
            insert contacto;

            List<Case> casos = new List<Case>();
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
            casos.add(caso);

            Case caso2 = new Case();
            caso2.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso2.AccountId = cuenta.Id;
            caso2.ContactId = contacto.Id;
            caso2.CC_Idioma__c = 'es';
            caso2.Subject = 'Caso para prueba de oportunidad';
            caso2.Description = 'Descripción del caso';
            caso2.CC_Tipo_Contacto__c = 'Consulta';
            caso2.CC_Canal_Procedencia__c = 'Accionista';
            caso2.CC_Canal_Resolucion__c = 'Accionista';
            caso2.CC_Canal_Operativo__c = 'App CaixaBankPay';
            caso2.Origin = 'Email';
            caso2.Status = 'Activo';
            caso2.CC_Detalles_Consulta__c = 'Detalles Consulta';
            caso2.CC_Detalles_Solucion__c = 'Detalles Solución';
            casos.add(caso2);
            insert casos;

            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
            caseExtension.Case_Id__c = caso2.Id;
            caseExtension.CC_CrearOportunidadTrigger__c = true;
            insert caseExtension;

            caso2.CBK_Case_Extension_Id__c = caseExtension.Id;
            update caso2;

            CC_Llamada__c llamada = new CC_Llamada__c();
            llamada.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'CC_Cliente');
            llamada.CC_Case_Consulta__c = caso2.Id;
            llamada.CC_Id_Cognitivo__c = '1234567890';
            llamada.CC_Tipo__c = 'Entrante';
            llamada.CC_ConnId__c = '1234567890';
            llamada.CC_Idioma__c = 'es';
            llamada.CC_Asunto__c = 'Asunto';
            llamada.CC_Datos_Genesys__c = 'Datos Genesys';
            llamada.CC_ConnId_Cognitivo__c = '1234567890';
            llamada.CC_NumPerso__c = '1234567890';
            insert llamada;

            List<Task> tareas = new List<Task>();
            Task tareaNoTiempo = new Task();
            tareaNoTiempo.type = 'Otros';
            tareaNoTiempo.Status = 'Pendiente no localizado';
            tareaNoTiempo.Priority = 'Normal';
            tareaNoTiempo.Subject = 'Reclamación';
            tareaNoTiempo.RecordTypeId = tareaNoTiempo.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            tareaNoTiempo.WhatId = caso.Id;
            tareas.add(tareaNoTiempo);

            Task tareaOportunidad = new Task();
            tareaOportunidad.Subject = 'Tarea para generar oportunidad';
            tareaOportunidad.Status = 'Open';
            tareaOportunidad.Type = 'Llamada';
            tareaOportunidad.CC_Tipo_Cierre__c = 'Llamada finalizada';
            tareaOportunidad.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            tareaOportunidad.CC_Llamada_Id__c = llamada.Id;
            tareaOportunidad.WhatId = caso2.Id;
            tareas.add(tareaOportunidad);
            insert tareas;

            CC_Lista_Valores__c listaOportunidadTareaExistente = new CC_Lista_Valores__c();
            listaOportunidadTareaExistente.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            listaOportunidadTareaExistente.CC_Activa__c = true;
            listaOportunidadTareaExistente.Name = 'Texto oportunidad tarea existente';
            listaOportunidadTareaExistente.CC_Mensajes_Mostrar__c = 'No es posible crear una oportunidad porque ya existe una cita o tarea creada';
            insert listaOportunidadTareaExistente;
        }
    }

    @isTest
    private static void crearTaskTest() {       
        Task tarea = new Task();
        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        tarea.Subject = 'Tarea para ver si se actualiza el campo última actualización';
        tarea.Status = 'Completed';
        User supervisor = [SELECT Id FROM User WHERE LastName LIKE 'last211053Supervisor' AND IsActive=true AND UserRole.DeveloperName = 'Contact_Center' LIMIT 1];
        System.runAs(supervisor) {
        Test.startTest();
            insert tarea;   
        Test.stopTest();
        }
        List<Task> tareas = [SELECT LastModifiedDate, CC_Ultima_Actualizacion__c FROM Task WHERE Id = :tarea.Id];
        
        System.assertNotEquals(null, tareas[0].CC_Ultima_Actualizacion__c);
        //System.assertEquals(tareas[0].LastModifiedDate, tareas[0].CC_Ultima_Actualizacion__c);        
    }
    
    @isTest
    private static void actualizarTaskTest() 
    {      
        User supervisor = [SELECT Id FROM User WHERE LastName LIKE 'last211053Supervisor' AND IsActive=true AND UserRole.DeveloperName = 'Contact_Center' LIMIT 1];
        System.runAs(supervisor){
        //Obtenemos la tarea creada anteriormente
       Task tarea = new Task();
            tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
            tarea.Subject = 'Tarea para ver si se actualiza el campo última actualización';
            tarea.Status = 'Open';
            insert tarea; 
           List<Task> tareasAntes = [SELECT Id, LastModifiedDate, CC_Ultima_Actualizacion__c FROM Task WHERE Subject = 'Tarea para ver si se actualiza el campo última actualización' and Status = 'Open' LIMIT 1];
           System.assertEquals(1, tareasAntes.size());
        //system.debug('');
        //Actualizamos la tarea
        tareasAntes[0].Status = 'Completed';
        	
        Test.startTest();
            update tareasAntes;   
        Test.stopTest();
        
        List<Task> tareas = [SELECT LastModifiedDate, CC_Ultima_Actualizacion__c FROM Task WHERE Id = :tareasAntes[0].Id];            
        System.assertNotEquals(null, tareas[0].CC_Ultima_Actualizacion__c);
        System.assertEquals(1, tareas.size());
       
        //Comprobamos que la tarea
        //Datetime fechaLastUpdateOld = Datetime.newInstance(tareasAntes[0].LastModifiedDate.year(), tareasAntes[0].LastModifiedDate.month(), tareasAntes[0].LastModifiedDate.day(), tareasAntes[0].LastModifiedDate.hour(), tareasAntes[0].LastModifiedDate.minute(), 0);
        //Datetime fechaLastUpdateOld = Datetime.newInstance(tareas[0].LastModifiedDate.year(), tareas[0].LastModifiedDate.month(), tareas[0].LastModifiedDate.day(), tareas[0].LastModifiedDate.hour(), tareas[0].LastModifiedDate.minute(), 0);
        //Datetime fechaUltimaActualizacion = Datetime.newInstance(tareas[0].CC_Ultima_Actualizacion__c.year(), tareas[0].CC_Ultima_Actualizacion__c.month(), tareas[0].CC_Ultima_Actualizacion__c.day(), tareas[0].CC_Ultima_Actualizacion__c.hour(), tareas[0].CC_Ultima_Actualizacion__c.minute(), 0);       
        
        //System.assertEquals(fechaLastUpdateOld, fechaUltimaActualizacion);
             }
    }

    @isTest
    private static void cambiarRTyRechazarCasoRonaTest() 
    { 
        Task tarea = [SELECT Id, WhatId, LastModifiedDate, CC_Ultima_Actualizacion__c, Status, CC_Tipo_Cierre__c FROM Task WHERE Subject = 'Tarea test ReadOnly' LIMIT 1];
        Case caso = [SELECT Status, Subject, RecordTypeId, RecordType.DeveloperName FROM Case WHERE Id =: tarea.WhatId LIMIT 1];
        
        tarea.Status = 'Completed';
        Test.startTest();
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            update tarea;   
        }
        Test.stopTest();

        Task tareaV2 = [SELECT Id, WhatId, LastModifiedDate, CC_Ultima_Actualizacion__c, Status FROM Task WHERE Subject = 'Tarea test ReadOnly' LIMIT 1];
        Case casoV2 = [SELECT Status, Subject, RecordTypeId, RecordType.DeveloperName FROM Case WHERE Id =: tarea.WhatId LIMIT 1];
        
        System.assertNotEquals(caso.Status, casov2.Status, 'La ejecución del trigger ha fallado.');
        System.assertNotEquals(caso.RecordTypeId, casov2.RecordTypeId, 'La ejecución del trigger ha fallado.');
        System.assertNotEquals(caso.RecordType.DeveloperName, casov2.RecordType.DeveloperName, 'La ejecución del trigger ha fallado.');
    }
    
     @isTest
    static void copiarTaskType_Test()
    {
        User supervisor = [SELECT Id FROM User WHERE LastName LIKE 'last211053Supervisor' AND IsActive=true AND UserRole.DeveloperName = 'Contact_Center' LIMIT 1];
        List<Task> tareas = new List<Task>();

        System.runAs(supervisor)
        {
            Task tarea = new Task();
            tarea.type = 'Automática';
            tarea.Status = 'Open';
            tarea.Priority = 'Normal';
            tarea.Subject = 'Tarea';
            tarea.RecordTypeId = tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
            tareas.add(tarea);
            insert tareas;
            
        tarea.Status = 'Completed';
        Test.startTest();
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            update tarea;   
        }
        Test.stopTest();

            Task tareaAI = [SELECT OS_Tipo__c from Task where Id =: tarea.Id];
           // Test.startTest();
            System.assertEquals(tarea.type, tareaAI.OS_Tipo__c, 'No se ha copiado el Task Type');
            //Test.stopTest();
        }
    }

    @isTest
    static void casoGestionTareasNoTiempoTest()
    {
        User administrador = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        List<Task> tareas = new List<Task>();
        
        System.runAs(administrador)
        {
            Test.startTest();



            Case caso = [SELECT Id FROM Case WHERE Subject = 'Asunto' LIMIT 1];

            Task tareaNoTiempo = [SELECT Id, Subject, Status, Type FROM Task WHERE Status = 'Pendiente no localizado' LIMIT 1];


            tareaNoTiempo.Subject = 'Reclamación de cliente';
            tareaNoTiempo.Status = 'Rechazada';
            tareaNoTiempo.Type = 'Traslado Colaborador';
            update tareaNoTiempo;
            
            System.debug('tareaNoTiempo: ' + tareaNoTiempo);

            Task tareaNoTiempoUpdate = [SELECT Id, Subject, Status, Type, CC_Fecha_Fin__c FROM Task WHERE Id = :tareaNoTiempo.Id];

            Case casoUpdate = [SELECT Id, CC_Fecha_Ultima_Reclamacion__c, CC_Numero_Reclamaciones_Cliente__c, Status FROM Case WHERE Id = :caso.Id];

            System.assertEquals(tareaNoTiempoUpdate.Subject, 'Reclamación de cliente', 'No se ha actualizado el subject de la tarea');
            System.assertEquals(tareaNoTiempoUpdate.Status, 'Rechazada', 'No se ha actualizado el status de la tarea');
            System.assertEquals(tareaNoTiempoUpdate.Type, 'Traslado Colaborador', 'No se ha actualizado el type de la tarea');

            System.assertEquals(true, tareaNoTiempoUpdate.CC_Fecha_Fin__c != null, 'No se ha actualizado la fecha de la última reclamación, sigue a Nulo');
            System.assertEquals(true, casoUpdate.Status == 'Activo', 'No se ha actualizado el status del caso');


            Test.stopTest();
        }
    }

    @isTest
    static void generarOportunidadLlamadaFinalizadaTest() {
        User administrador = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso para prueba de oportunidad' LIMIT 1];
        Task tarea = [SELECT Status FROM Task WHERE WhatId = :caso.Id AND Subject = 'Tarea para generar oportunidad' LIMIT 1];
        
        Test.startTest();
        tarea.Status = 'Completed';
        update tarea;
        Test.stopTest();
        
        Task tareaActualizada = [SELECT Status, CC_Tipo_Cierre__c FROM Task WHERE Id = :tarea.Id];
        CBK_Case_Extension__c caseExtensionAct = [SELECT CC_CrearOportunidadTrigger__c FROM CBK_Case_Extension__c WHERE Case_Id__c = :caso.Id LIMIT 1];
        System.runAs(administrador) {
            System.assertEquals('Completed', tareaActualizada.Status, 'La tarea no se actualizó correctamente');
            System.assertEquals('Llamada finalizada', tareaActualizada.CC_Tipo_Cierre__c, 'El tipo de cierre no es correcto');
            System.assertEquals(false, caseExtensionAct.CC_CrearOportunidadTrigger__c, 'El campo no se ha actualizado correctamente');
        }
    }
}