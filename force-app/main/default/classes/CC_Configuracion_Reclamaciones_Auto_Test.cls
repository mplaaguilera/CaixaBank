@IsTest //(SeeAllData=true)
public with sharing class CC_Configuracion_Reclamaciones_Auto_Test {
    
    @testSetup
    static void makeData() {
        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
        Test.startTest();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        PermissionSet psOperadorEmpleado = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_CCO'];
        PermissionSet psSupervisor = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Supervisor_PS'];
        List<User> lUser = new List<User>(); 
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
        //insert usuarioAdmin;
        lUser.add(usuarioAdmin);        
        // System.runAs(usuarioAdmin) {
        User operadorEmpleado = new User();        
        operadorEmpleado.profileId = profileId;
        operadorEmpleado.UserRoleId = roleCC;
        operadorEmpleado.FirstName = '';
        operadorEmpleado.AV_ExternalID__c = 'U0124112';
        operadorEmpleado.LastName = 'Operador Empleado';
        operadorEmpleado.Email = 'tuser000@amamama.com';
        operadorEmpleado.Username = 'tuser000@amamama.com' + (System.currentTimeMillis()+5);
        operadorEmpleado.CompanyName = 'MST';
        operadorEmpleado.Title = 'title';
        operadorEmpleado.Alias = 'alias';
        operadorEmpleado.TimeZoneSidKey = 'Europe/Paris';
        operadorEmpleado.EmailEncodingKey = 'UTF-8';
        operadorEmpleado.LanguageLocaleKey = 'es';
        operadorEmpleado.LocaleSidKey = 'es_ES';        
        //insert operadorEmpleado;
        lUser.add(operadorEmpleado);
        
        User operadorSupervisor = new User();        
        operadorSupervisor.profileId = profileId;
        operadorSupervisor.UserRoleId = roleCC;
        operadorSupervisor.FirstName = '';
        operadorSupervisor.AV_ExternalID__c = 'U0124112';
        operadorSupervisor.LastName = 'Operador Supervisor';
        operadorSupervisor.Email = 'tuser000@amamama.com';
        operadorSupervisor.Username = 'tuser000@amamama.com' + (System.currentTimeMillis()+105);
        operadorSupervisor.CompanyName = 'MST';
        operadorSupervisor.Title = 'title';
        operadorSupervisor.Alias = 'alias';
        operadorSupervisor.TimeZoneSidKey = 'Europe/Paris';
        operadorSupervisor.EmailEncodingKey = 'UTF-8';
        operadorSupervisor.LanguageLocaleKey = 'es';
        operadorSupervisor.LocaleSidKey = 'es_ES';        
        //insert operadorEmpleado;
        lUser.add(operadorSupervisor);
        insert lUser;
        List<PermissionSetAssignment> listPSAssigment = new List<PermissionSetAssignment>();
        PermissionSetAssignment psCCO = new PermissionSetAssignment(AssigneeId = operadorEmpleado.Id, PermissionSetId = psOperadorEmpleado.Id);
        PermissionSetAssignment psASupervisor = new PermissionSetAssignment(AssigneeId = operadorSupervisor.Id, PermissionSetId = psSupervisor.Id);
        listPSAssigment.add(psCCO);
        listPSAssigment.add(psASupervisor);
        insert listPSAssigment;
        //}
        Test.stopTest();
    }
    
    @isTest
    public static void getCarpetas() {
        User usuario = [SELECT Id FROM User Where LastName = 'Administrador de sistema' AND UserRole.DeveloperName = 'Contact_Center' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            CC_Configuracion_Reclamacion__c conf1 = new CC_Configuracion_Reclamacion__c();
            conf1.Name = 'Reclamacion de pruebas';
            insert conf1;        
            
            //No se pueden crear carpetas (error DML) por lo que la única manera de probarlo es con alguna estructura ya existente
            //Si la estructura en algún momento cambiase daría error, lo cual ya va bien pq habría que revisarlo (puede dar problemas en la selección de plantillas de la entidad CC_Configuracion_Reclamacion__c)
            List<Folder> carpetas = CC_Configuracion_Reclamaciones_Auto.getCarpetas(
                'CC_Reclamaciones_Automaticas',
                [SELECT Name FROM CC_Configuracion_Reclamacion__c WHERE Name = 'Reclamacion de pruebas' LIMIT 1].Id
            );
            
            List<EmailTemplate> plantillas = CC_Configuracion_Reclamaciones_Auto.getPlantillas(carpetas[0].DeveloperName);
            
            System.assertEquals(carpetas.size(), 3, 'Fallo de assert');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void guardar() {
        User usuario = [SELECT Id FROM User Where LastName = 'Operador Empleado' AND UserRole.DeveloperName = 'Contact_Center'LIMIT 1];
        System.runAs(usuario) {
        List<BusinessHours> calendario = [SELECT Id FROM BusinessHours LIMIT 1];
        
        CC_Configuracion_Reclamacion__c configuracionTest = new CC_Configuracion_Reclamacion__c();
        configuracionTest.CC_1a_Reclamacion_Activa__c = true;
        configuracionTest.CC_Calendario__c = calendario[0].Id;
        configuracionTest.CC_Fecha_Activacion_1a_Rec__c = System.today();
        configuracionTest.CC_Horas_1a_Reclamacion__c = '24';
        insert configuracionTest;
        
        EmailTemplate template = new EmailTemplate();
        template.FolderId = UserInfo.getUserId();
        template.Name = 'Plantilla Traslado Colaborador Test';
        template.DeveloperName = 'Plantilla_Traslado_Colaborador_Test';
        template.TemplateType = 'Text';
        //System.runAs(new User(Id = UserInfo.getUserId())) {
            insert template;
        //}
        
        configuracionTest.CC_Nombre_Plantilla_1_Rec_Colab_Cast__c = template.Name;
        configuracionTest.CC_Plantilla_1_Rec_Colab_Cast__c = template.DeveloperName;
            
            Test.startTest();
            CC_Configuracion_Reclamaciones_Auto.guardar(configuracionTest);
            Test.stopTest();
            List<CC_Configuracion_Reclamacion__c> resultados = [SELECT Id FROM CC_Configuracion_Reclamacion__c
            WHERE CC_Plantilla_1_Rec_Colab_Cast__c = :template.DeveloperName];
            System.assertEquals(resultados.size(), 1, 'Fallo de assert');
        }
    }
    
    @isTest
    public static void sendMailRecTrasladoColab() {
        // Test.startTest();
          User usuario = [SELECT Id FROM User Where LastName = 'Operador Empleado' AND UserRole.DeveloperName = 'Contact_Center' LIMIT 1];
        System.runAs(usuario) {
        List<BusinessHours> calendario = [SELECT Id FROM BusinessHours LIMIT 1];
        
        EmailTemplate template = new EmailTemplate();
        template.FolderId = UserInfo.getUserId();
        template.Name = 'Plantilla Traslado Colaborador Test';
        template.DeveloperName = 'Plantilla_Traslado_Colaborador_Test';
        template.TemplateType = 'Text';
       // System.runAs (new User(Id = UserInfo.getUserId())) {
            insert template;
        //}
        
        CC_Configuracion_Reclamacion__c configuracionTest = new CC_Configuracion_Reclamacion__c();
        configuracionTest.CC_1a_Reclamacion_Activa__c = true;
        configuracionTest.CC_2a_Reclamacion_Activa__c = true;
        configuracionTest.CC_3a_Reclamacion_Activa__c = true;
        configuracionTest.CC_Calendario__c = calendario[0].Id;
        configuracionTest.CC_Fecha_Activacion_1a_Rec__c = System.today();
        configuracionTest.CC_Fecha_Activacion_2a_Rec__c = System.today();
        configuracionTest.CC_Fecha_Activacion_3a_Rec__c = System.today();
        configuracionTest.CC_Horas_1a_Reclamacion__c = '24';
        configuracionTest.CC_Horas_2a_Reclamacion__c = '48';
        configuracionTest.CC_Horas_3a_Reclamacion__c = '72';
        
        configuracionTest.CC_Email_Cliente_1a_Rec__c = true;
        configuracionTest.CC_Email_Cliente_2a_Rec__c = true;
        configuracionTest.CC_Email_Cliente_3a_Rec__c = true;
        
        configuracionTest.CC_Nombre_Plantilla_1_Rec_Cliente_Cast__c = template.Name;
        configuracionTest.CC_Plantilla_1_Rec_Cliente_Cast__c = template.DeveloperName;
        configuracionTest.CC_Nombre_Plantilla_1_Rec_Cliente_Cat__c = template.Name;
        configuracionTest.CC_Plantilla_1_Rec_Cliente_Cat__c = template.DeveloperName;
        
        configuracionTest.CC_Nombre_Plantilla_2_Rec_Cliente_Cast__c = template.Name;
        configuracionTest.CC_Plantilla_2_Rec_Cliente_Cast__c = template.DeveloperName;
        configuracionTest.CC_Nombre_Plantilla_2_Rec_Cliente_Cat__c = template.Name;
        configuracionTest.CC_Plantilla_2_Rec_Cliente_Cat__c = template.DeveloperName;
        
        configuracionTest.CC_Nombre_Plantilla_3_Rec_Cliente_Cast__c = template.Name;
        configuracionTest.CC_Plantilla_3_Rec_Cliente_Cast__c = template.DeveloperName;
        configuracionTest.CC_Nombre_Plantilla_3_Rec_Cliente_Cat__c = template.Name;
        configuracionTest.CC_Plantilla_3_Rec_Cliente_Cat__c = template.DeveloperName;
        
        configuracionTest.CC_Nombre_Plantilla_1_Rec_Colab_Cast__c = template.Name;
        configuracionTest.CC_Plantilla_1_Rec_Colab_Cast__c = template.DeveloperName;
        configuracionTest.CC_Nombre_Plantilla_1_Rec_Colab_Cat__c = template.Name;
        configuracionTest.CC_Plantilla_1_Rec_Colab_Cat__c = template.DeveloperName;
        
        configuracionTest.CC_Nombre_Plantilla_2_Rec_Colab_Cast__c = template.Name;
        configuracionTest.CC_Plantilla_2_Rec_Colab_Cast__c = template.DeveloperName;
        configuracionTest.CC_Nombre_Plantilla_2_Rec_Colab_Cat__c = template.Name;
        configuracionTest.CC_Plantilla_2_Rec_Colab_Cat__c = template.DeveloperName;
        
        configuracionTest.CC_Nombre_Plantilla_3_Rec_Colab_Cast__c = template.Name;
        configuracionTest.CC_Plantilla_3_Rec_Colab_Cast__c = template.DeveloperName;
        configuracionTest.CC_Nombre_Plantilla_3_Rec_Colab_Cat__c = template.Name;
        configuracionTest.CC_Plantilla_3_Rec_Colab_Cat__c = template.DeveloperName;
        
        insert configuracionTest;
        
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();
        grupo.Name = 'Grupo Colaborador Test';
        grupo.CC_Reclamacion_Automatica__c = configuracionTest.Id;
        grupo.RecordTypeId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        insert grupo;
        
        List<Contact> contactos = new List<Contact>();
        
        Account acc1 = new Account();
        acc1.Name = 'Account test';
        insert acc1;
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Nombre Test';
        contacto.LastName = 'Apellido Test';
        contacto.Email = 'testCliente@test.com';
        contacto.AccountId = acc1.Id;
        contacto.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactos.add(contacto);
        
        Contact contacto1Reclamacion = new Contact();
        contacto1Reclamacion.FirstName = 'Maria';
        contacto1Reclamacion.LastName = 'Pérez';
        contacto1Reclamacion.Email = 'mp@test.com';
        contacto1Reclamacion.AccountId = acc1.Id;
        contacto1Reclamacion.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        contactos.add(contacto1Reclamacion);
        
        Contact contacto2Reclamacion = new Contact();
        contacto2Reclamacion.FirstName = 'Laura';
        contacto2Reclamacion.LastName = 'Martín';
        contacto2Reclamacion.email = 'lm@test.com';
        contacto2Reclamacion.AccountId = acc1.Id;
        contacto2Reclamacion.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        contactos.add(contacto2Reclamacion);
        
        Contact contacto3Reclamacion = new Contact();
        contacto3Reclamacion.FirstName = 'Juan';
        contacto3Reclamacion.LastName = 'Palacios';
        contacto3Reclamacion.email = 'jp@test.com';
        contacto3Reclamacion.AccountId = acc1.Id;
        contacto3Reclamacion.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        contactos.add(contacto3Reclamacion);
        
        insert contactos;
        
        //Creamos los 3 colaboradores que asignaremos al grupo.
        List<CC_Grupo_Colaborador_Contact__c> colaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
        CC_Grupo_Colaborador_Contact__c colaborador1Reclamacion = new CC_Grupo_Colaborador_Contact__c (
            CC_Contacto__c = contacto1Reclamacion.Id,
            CC_Reclamacion_1__c = true,
            CC_Reclamacion_2__c = true,
            CC_Reclamacion_3__c = true,
            CC_Grupo_Colaborador__c = grupo.Id
        );
        colaboradores.add(colaborador1Reclamacion);
        
        CC_Grupo_Colaborador_Contact__c colaborador2Reclamacion = new CC_Grupo_Colaborador_Contact__c (
            CC_Contacto__c = contacto2Reclamacion.Id,
            CC_Reclamacion_2__c = true,
            CC_Reclamacion_3__c = true,
            CC_Grupo_Colaborador__c = grupo.Id
        );
        colaboradores.add(colaborador2Reclamacion);
        
        CC_Grupo_Colaborador_Contact__c colaborador3Reclamacion = new CC_Grupo_Colaborador_Contact__c (
            CC_Contacto__c = contacto3Reclamacion.Id,
            CC_Reclamacion_3__c = true,
            CC_Grupo_Colaborador__c = grupo.Id
        );
        colaboradores.add(colaborador3Reclamacion);
        insert colaboradores;
        
        List<ContentDocument> documents = [SELECT Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        
        String fromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                              WHERE DeveloperName LIKE 'CC_%' LIMIT 1].CC_Direccion_Correo__c;
        
        List<Case> listCases = new List<Case>();
        
        Case caso1 = new Case();
        caso1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        caso1.CC_Idioma__c = 'es';
        caso1.CC_Tipo_Cliente__c = 'Cliente';
        caso1.ContactId = contacto.Id;
        caso1.Status = 'Pendiente Colaborador';
        caso1.CC_Cambio_Estado_Pendiente_Externo__c = true;
        caso1.Origin = 'Email';
        caso1.CC_Canal_Procedencia__c = 'Formulario web';
        listCases.add(caso1);
        
        Case caso2 = new Case();
        caso2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        caso2.CC_Idioma__c = 'ca';
        caso2.CC_Tipo_Cliente__c = 'Cliente';
        caso2.ContactId = contacto.Id;
        caso2.Status = 'Pendiente Colaborador';
        caso2.CC_Cambio_Estado_Pendiente_Externo__c = true;
        caso2.Origin = 'Email';
        caso2.CC_Canal_Procedencia__c = 'Formulario web';
        listCases.add(caso2);
        
        Case caso3 = new Case();
        caso3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        caso3.CC_Idioma__c = 'es';
        caso3.CC_Tipo_Cliente__c = 'Cliente';
        caso3.ContactId = contacto.Id;
        caso3.Status = 'Pendiente Colaborador';
        caso3.CC_Cambio_Estado_Pendiente_Externo__c = true;
        caso3.Origin = 'Email';
        caso3.Subject = 'Primer recordatorio Comunicado número 00033960';
        listCases.add(caso3);
        
        insert listCases;
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }
        
        List<EmailMessage> listaEmailMessage = new List<EmailMessage>();
        
        EmailMessage eMessage1 = new EmailMessage();
        eMessage1.Incoming = true;
        eMessage1.ParentId = caso1.Id;
        eMessage1.RelatedToId = caso1.Id;
        eMessage1.Headers = '<html style="overflow-y: hidden;"><head><title></title></head><body>';
        eMessage1.FromAddress = fromAddress;
        eMessage1.ToAddress = 'emailColaborador@test.com';
        eMessage1.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        listaEmailMessage.add(eMessage1);
        
        EmailMessage eMessage2 = new EmailMessage();
        eMessage2.Incoming = true;
        eMessage2.Subject = 'Prueba Traslado Colaborador';
        eMessage2.FromAddress = fromAddress;
        eMessage2.ToAddress = 'emailColaborador@test.com';
        eMessage2.ParentId = caso2.Id;
        eMessage2.RelatedToId = caso2.Id;
        eMessage2.HtmlBody = 'Respuesta\nHola\n#@refResponder#\nAdios\n';
        eMessage2.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        listaEmailMessage.add(eMessage2);
        
        EmailMessage eMessage3 = new EmailMessage();
        eMessage3.Incoming = true;
        eMessage3.Subject = 'Prueba Traslado Colaborador';
        eMessage3.FromAddress = fromAddress;
        eMessage3.ToAddress = 'emailColaborador@test.com';
        eMessage3.ParentId = caso3.Id;
        eMessage3.RelatedToId = caso3.Id;
        eMessage3.HtmlBody = 'Respuesta\nHola\n#@refResponder#\nAdios\n';
        eMessage3.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        listaEmailMessage.add(eMessage3);
        
        EmailMessage emailAnterior = new EmailMessage();
        emailAnterior.Incoming = true;
        emailAnterior.Subject = 'Prueba Traslado Colaborador';
        emailAnterior.FromAddress = fromAddress;
        emailAnterior.ToAddress = 'emailColaborador@test.com';
        emailAnterior.HtmlBody = 'Respuesta\nHola\n#@refResponder#\nAdios\n';
        emailAnterior.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        listaEmailMessage.add(emailAnterior);
        
        insert listaEmailMessage;      
        
        List<ContentVersion> listaContentversion = new List<ContentVersion>();
        ContentVersion contentVersion1 = new ContentVersion();
        contentVersion1.ContentLocation = 'S';
        contentVersion1.PathOnClient = 'Pinguino';
        contentVersion1.Origin = 'H';
        contentVersion1.Title = 'Pinguino';
        contentVersion1.VersionData = Blob.valueOf('Test Content3');
        listaContentVersion.add(contentVersion1);
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S';
        contentVersion.PathOnClient = 'Pinguino2';
        contentVersion.Origin = 'H';
        contentVersion.Title = 'Pinguino2';
        contentVersion.VersionData = Blob.valueOf('Test Content2');
        listaContentVersion.add(contentVersion);
        
        insert listaContentVersion;
        
        ContentVersion cVers = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion1.Id];
        
        List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
        ContentDocumentLink cdl1 = new ContentDocumentLink(
            LinkedEntityId = eMessage1.id,
            ContentDocumentId = cVers.ContentDocumentId,
            ShareType = 'V'
        );
        listaContentDocumentLink.add(cdl1);
        
        List<Task> tareasInsertar = new List<Task>();
        
        Task tarea = new Task();
        tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        tarea.Type = 'Traslado Colaborador';
        tarea.Subject = 'Traslado Colaborador';
        tarea.Status = 'Open';
        tarea.Description = 'Clase test reclamaciones automáticas';
        tarea.WhatId = caso1.Id;
        tarea.CC_Correo_Asociado_Id__c = emailAnterior.Id;
        tarea.CC_Fecha_1_Reclamacion_Auto__c = System.today();
        tarea.CC_Fecha_2_Reclamacion_Auto__c = System.today();
        tarea.CC_Fecha_3_Reclamacion_Auto__c = System.today();
        tarea.CC_Grupo_Colaborador_Id__c = grupo.Id;
        CC_Configuracion_Reclamaciones_Auto.informarFechasReclamacionesAuto(tarea);
        tareasInsertar.add(tarea);
        
        Task tarea2Reclamacion = new Task();
        tarea2Reclamacion.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        tarea2Reclamacion.Type = 'Traslado Colaborador';
        tarea2Reclamacion.Subject = 'Traslado Colaborador';
        tarea2Reclamacion.Status = 'Open';
        tarea2Reclamacion.Description = 'Clase test reclamaciones automáticas';
        tarea2Reclamacion.WhatId = caso2.Id;
        tarea2Reclamacion.CC_Correo_Asociado_Id__c = emailAnterior.Id;
        tarea2Reclamacion.CC_Fecha_2_Reclamacion_Auto__c = System.today();
        tarea2Reclamacion.CC_Grupo_Colaborador_Id__c = grupo.Id;
        tareasInsertar.add(tarea2Reclamacion);
        
        Task tarea3Reclamacion = new Task();
        tarea3Reclamacion.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        tarea3Reclamacion.Type = 'Traslado Colaborador';
        tarea3Reclamacion.Subject = 'Traslado Colaborador';
        tarea3Reclamacion.Status = 'Open';
        tarea3Reclamacion.Description = 'Clase test reclamaciones automáticas';
        tarea3Reclamacion.WhatId = caso3.Id;
        tarea3Reclamacion.CC_Correo_Asociado_Id__c = emailAnterior.Id;
        tarea3Reclamacion.CC_Fecha_3_Reclamacion_Auto__c = System.today();
        tarea3Reclamacion.CC_Grupo_Colaborador_Id__c = grupo.Id;
        tareasInsertar.add(tarea3Reclamacion);
        insert tareasInsertar;
        
        ContentVersion cVers2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
        ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = tarea.CC_Correo_Asociado_Id__c, ContentDocumentId = cVers2.ContentDocumentId, ShareType = 'V');
        listaContentDocumentLink.add(cdl);
        
        insert listaContentDocumentLink;
        
        Task tarea2 = new Task();
        tarea2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        tarea2.Type = 'Traslado Colaborador';
        tarea2.Subject = 'Traslado Colaborador';
        tarea2.Status = 'Open';
        tarea2.Description = 'Clase test reclamaciones automáticas';
        tarea2.WhatId = caso2.Id;
        tarea2.CC_Correo_Asociado_Id__c = emailAnterior.Id;
        tarea2.CC_Fecha_3_Reclamacion_Auto__c = System.today();
        tarea2.CC_Grupo_Colaborador_Id__c = grupo.Id;
        CC_Configuracion_Reclamaciones_Auto.informarFechasReclamacionesAuto(tarea);
        insert tarea2;
        
        List<Id> tareas = new List<Id>();
        tareas.add(tarea.Id);
        tareas.add(tarea2Reclamacion.Id);
        tareas.add(tarea3Reclamacion.Id);
        
      
            Test.startTest();
            CC_Configuracion_Reclamaciones_Auto.sendMailRecTrasladoColab(tareas);
            Test.stopTest();
        
        //Comprobamos que en la 1 Reclamación una vez se ha enviado el email se borra la fecha para que ya no se envíe más.
        List<Task> listaTaskValidar = [SELECT CC_Fecha_1_Reclamacion_Auto__c, CC_Fecha_2_Reclamacion_Auto__c FROM Task WHERE Id = :tarea.Id];
        
        DateTime fecha1Reclamacion = listaTaskValidar[0].CC_Fecha_1_Reclamacion_Auto__c;
        System.assertEquals(null, fecha1Reclamacion, 'Fallo de assert');
        }
        //En este caso comprobamos que la Segunda Fecha no se ha vaciado ya que no han pasado las horas correspondientes.
        /* DateTime fecha2ReclamacionTarea = listaTaskValidar[0].CC_Fecha_2_Reclamacion_Auto__c;
System.assertEquals(tarea.CC_Fecha_2_Reclamacion_Auto__c, fecha2ReclamacionTarea, 'Fallo de assert');

//Comprobamos que en la 2 Reclamación una vez se ha enviado el email se borra la fecha para que ya no se envíe más.
DateTime fecha2Reclamacion = [SELECT CC_Fecha_2_Reclamacion_Auto__c FROM Task WHERE Id = :tarea2Reclamacion.Id].CC_Fecha_2_Reclamacion_Auto__c;
System.assertEquals(null, fecha2Reclamacion, 'Fallo de assert');*/
    }
    
    @isTest
    public static void finTrasladoColab() {
         User usuario = [SELECT Id FROM User Where LastName = 'Operador Empleado' AND UserRole.DeveloperName = 'Contact_Center' LIMIT 1];
        System.runAs(usuario) {
        Test.startTest();
        List<BusinessHours> calendario = [SELECT Id FROM BusinessHours LIMIT 1];
        
        EmailTemplate template = new EmailTemplate();
        template.FolderId = UserInfo.getUserId();
        template.Name = 'Plantilla Traslado Colaborador Test';
        template.DeveloperName = 'Plantilla_Traslado_Colaborador_Test';
        template.TemplateType = 'Text';
        //System.runAs (new User(Id = UserInfo.getUserId())) {
            insert template;
       // }
        
        CC_Configuracion_Reclamacion__c configuracionTest = new CC_Configuracion_Reclamacion__c();
        configuracionTest.OS_Fin_Reclamacion_Activa__c = true;
        configuracionTest.CC_Calendario__c = calendario[0].Id;
        configuracionTest.OS_Fecha_Activacion_Fin_Rec__c = System.today();
        configuracionTest.OS_Horas_Fin_Reclamacion__c = '0';
        
        configuracionTest.OS_Asignar_Propietario__c = true;
        configuracionTest.OS_EstadoCaso__c = 'Activo';
        
        insert configuracionTest;
        
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();
        grupo.Name = 'Grupo Colaborador Test';
        grupo.CC_Reclamacion_Automatica__c = configuracionTest.Id;
        grupo.RecordTypeId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        insert grupo;
        
        List<Contact> contactos = new List<Contact>();
        
        Account acc1 = new Account();
        acc1.Name = 'Account test';
        insert acc1;
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Nombre Test';
        contacto.LastName = 'Apellido Test';
        contacto.Email = 'testCliente@test.com';
        contacto.AccountId = acc1.Id;
        contacto.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactos.add(contacto);
        
        Contact contacto1Reclamacion = new Contact();
        contacto1Reclamacion.FirstName = 'Maria';
        contacto1Reclamacion.LastName = 'Pérez';
        contacto1Reclamacion.Email = 'mp@test.com';
        contacto1Reclamacion.AccountId = acc1.Id;
        contacto1Reclamacion.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        contactos.add(contacto1Reclamacion);
        
        Contact contacto2Reclamacion = new Contact();
        contacto2Reclamacion.FirstName = 'Laura';
        contacto2Reclamacion.LastName = 'Martín';
        contacto2Reclamacion.email = 'lm@test.com';
        contacto2Reclamacion.AccountId = acc1.Id;
        contacto2Reclamacion.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        contactos.add(contacto2Reclamacion);
        
        Contact contacto3Reclamacion = new Contact();
        contacto3Reclamacion.FirstName = 'Juan';
        contacto3Reclamacion.LastName = 'Palacios';
        contacto3Reclamacion.email = 'jp@test.com';
        contacto3Reclamacion.AccountId = acc1.Id;
        contacto3Reclamacion.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        contactos.add(contacto3Reclamacion);
        
        insert contactos;
        
        //Creamos los 3 colaboradores que asignaremos al grupo.
        List<CC_Grupo_Colaborador_Contact__c> colaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
        CC_Grupo_Colaborador_Contact__c colaborador1Reclamacion = new CC_Grupo_Colaborador_Contact__c (
            CC_Contacto__c = contacto1Reclamacion.Id,
            CC_Reclamacion_1__c = true,
            CC_Reclamacion_2__c = true,
            CC_Reclamacion_3__c = true,
            CC_Grupo_Colaborador__c = grupo.Id
        );
        colaboradores.add(colaborador1Reclamacion);
        
        CC_Grupo_Colaborador_Contact__c colaborador2Reclamacion = new CC_Grupo_Colaborador_Contact__c (
            CC_Contacto__c = contacto2Reclamacion.Id,
            CC_Reclamacion_2__c = true,
            CC_Reclamacion_3__c = true,
            CC_Grupo_Colaborador__c = grupo.Id
        );
        colaboradores.add(colaborador2Reclamacion);
        
        CC_Grupo_Colaborador_Contact__c colaborador3Reclamacion = new CC_Grupo_Colaborador_Contact__c (
            CC_Contacto__c = contacto3Reclamacion.Id,
            CC_Reclamacion_3__c = true,
            CC_Grupo_Colaborador__c = grupo.Id
        );
        colaboradores.add(colaborador3Reclamacion);
        insert colaboradores;
        
        List<ContentDocument> documents = [SELECT Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        
        String fromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                              WHERE DeveloperName LIKE 'CC_%' LIMIT 1].CC_Direccion_Correo__c;
        
        List<Case> listCases = new List<Case>();
        
        Case caso1 = new Case();
        caso1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        caso1.CC_Idioma__c = 'es';
        caso1.CC_Tipo_Cliente__c = 'Cliente';
        caso1.ContactId = contacto.Id;
        caso1.Status = 'Pendiente Colaborador';
        caso1.CC_Cambio_Estado_Pendiente_Externo__c = true;
        caso1.Origin = 'Email';
        caso1.CC_Canal_Procedencia__c = 'Formulario web';
        listCases.add(caso1);
        
        Case caso2 = new Case();
        caso2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        caso2.CC_Idioma__c = 'ca';
        caso2.CC_Tipo_Cliente__c = 'Cliente';
        caso2.ContactId = contacto.Id;
        caso2.Status = 'Pendiente Colaborador';
        caso2.CC_Cambio_Estado_Pendiente_Externo__c = true;
        caso2.Origin = 'Email';
        caso2.CC_Canal_Procedencia__c = 'Formulario web';
        listCases.add(caso2);
        
        Case caso3 = new Case();
        caso3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        caso3.CC_Idioma__c = 'es';
        caso3.CC_Tipo_Cliente__c = 'Cliente';
        caso3.ContactId = contacto.Id;
        caso3.Status = 'Pendiente Colaborador';
        caso3.CC_Cambio_Estado_Pendiente_Externo__c = true;
        caso3.Origin = 'Email';
        caso3.Subject = 'Primer recordatorio Comunicado número 00033960';
        listCases.add(caso3);
        
        insert listCases;
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }
        
        List<EmailMessage> listaEmailMessage = new List<EmailMessage>();
        
        EmailMessage eMessage1 = new EmailMessage();
        eMessage1.Incoming = true;
        eMessage1.ParentId = caso1.Id;
        eMessage1.RelatedToId = caso1.Id;
        eMessage1.Headers = '<html style="overflow-y: hidden;"><head><title></title></head><body>';
        eMessage1.FromAddress = fromAddress;
        eMessage1.ToAddress = 'emailColaborador@test.com';
        eMessage1.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        listaEmailMessage.add(eMessage1);
        
        EmailMessage eMessage2 = new EmailMessage();
        eMessage2.Incoming = true;
        eMessage2.Subject = 'Prueba Traslado Colaborador';
        eMessage2.FromAddress = fromAddress;
        eMessage2.ToAddress = 'emailColaborador@test.com';
        eMessage2.ParentId = caso2.Id;
        eMessage2.RelatedToId = caso2.Id;
        eMessage2.HtmlBody = 'Respuesta\nHola\n#@refResponder#\nAdios\n';
        eMessage2.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        listaEmailMessage.add(eMessage2);
        
        EmailMessage eMessage3 = new EmailMessage();
        eMessage3.Incoming = true;
        eMessage3.Subject = 'Prueba Traslado Colaborador';
        eMessage3.FromAddress = fromAddress;
        eMessage3.ToAddress = 'emailColaborador@test.com';
        eMessage3.ParentId = caso3.Id;
        eMessage3.RelatedToId = caso3.Id;
        eMessage3.HtmlBody = 'Respuesta\nHola\n#@refResponder#\nAdios\n';
        eMessage3.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        listaEmailMessage.add(eMessage3);
        
        EmailMessage emailAnterior = new EmailMessage();
        emailAnterior.Incoming = true;
        emailAnterior.Subject = 'Prueba Traslado Colaborador';
        emailAnterior.FromAddress = fromAddress;
        emailAnterior.ToAddress = 'emailColaborador@test.com';
        emailAnterior.HtmlBody = 'Respuesta\nHola\n#@refResponder#\nAdios\n';
        emailAnterior.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        listaEmailMessage.add(emailAnterior);
        
        insert listaEmailMessage;      
        
        List<ContentVersion> listaContentversion = new List<ContentVersion>();
        ContentVersion contentVersion1 = new ContentVersion();
        contentVersion1.ContentLocation = 'S';
        contentVersion1.PathOnClient = 'Pinguino';
        contentVersion1.Origin = 'H';
        contentVersion1.Title = 'Pinguino';
        contentVersion1.VersionData = Blob.valueOf('Test Content3');
        listaContentVersion.add(contentVersion1);
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S';
        contentVersion.PathOnClient = 'Pinguino2';
        contentVersion.Origin = 'H';
        contentVersion.Title = 'Pinguino2';
        contentVersion.VersionData = Blob.valueOf('Test Content2');
        listaContentVersion.add(contentVersion);
        
        insert listaContentVersion;
        
        ContentVersion cVers = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion1.Id];
        
        List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
        ContentDocumentLink cdl1 = new ContentDocumentLink(
            LinkedEntityId = eMessage1.id,
            ContentDocumentId = cVers.ContentDocumentId,
            ShareType = 'V'
        );
        listaContentDocumentLink.add(cdl1);
        
        
        List<Task> tareasInsertar = new List<Task>();
        
        Task tarea = new Task();
        tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        tarea.Type = 'Traslado Colaborador';
        tarea.Subject = 'Traslado Colaborador';
        tarea.Status = 'Open';
        tarea.Description = 'Clase test reclamaciones automáticas';
        tarea.WhatId = caso1.Id;
        tarea.CC_Correo_Asociado_Id__c = emailAnterior.Id;
        tarea.OS_Fecha_Fin_Reclamacion_Auto__c = System.today();
        tarea.CC_Grupo_Colaborador_Id__c = grupo.Id;
        CC_Configuracion_Reclamaciones_Auto.informarFechasReclamacionesAuto(tarea);
        tareasInsertar.add(tarea);
        
        
        Task tarea2Reclamacion = new Task();
        tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        tarea2Reclamacion.Type = 'Traslado Colaborador';
        tarea2Reclamacion.Subject = 'Traslado Colaborador';
        tarea2Reclamacion.Status = 'Open';
        tarea2Reclamacion.Description = 'Clase test reclamaciones automáticas';
        tarea2Reclamacion.WhatId = caso2.Id;
        tarea2Reclamacion.CC_Correo_Asociado_Id__c = emailAnterior.Id;
        tarea2Reclamacion.CC_Grupo_Colaborador_Id__c = grupo.Id;
        tareasInsertar.add(tarea2Reclamacion);
        
        insert tareasInsertar;
        
        
        ContentVersion cVers2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
        ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = tarea.CC_Correo_Asociado_Id__c, ContentDocumentId = cVers2.ContentDocumentId, ShareType = 'V');
        listaContentDocumentLink.add(cdl);
        
        insert listaContentDocumentLink;
        
        
        List<Id> tareas = new List<Id>();
        tareas.add(tarea.Id);
        tareas.add(tarea2Reclamacion.Id);
       
            
            CC_Configuracion_Reclamaciones_Auto.sendMailRecTrasladoColab(tareas);
        
        
        //Comprobamos que en el Fin de Reclamación una vez se ha enviado el email se borra la fecha para que ya no se envíe más.
        List<Task> listaTaskValidar = [SELECT OS_Fecha_Fin_Reclamacion_Auto__c FROM Task WHERE Id = :tarea.Id];
        
        DateTime fechaFinReclamacion = listaTaskValidar[0].OS_Fecha_Fin_Reclamacion_Auto__c;
        System.assertEquals(null, fechaFinReclamacion, 'Fallo de assert');
        Test.stopTest();
        }
    }
    
    
    /*  @isTest
public static void reclamaciones_Automaticas_CSI_Bankia() {

List<BusinessHours> calendario = [SELECT Id FROM BusinessHours LIMIT 1];

CC_Configuracion_Reclamacion__c configuracionCSIBankia = new CC_Configuracion_Reclamacion__c();
configuracionCSIBankia.CC_1a_Reclamacion_Activa__c = true;
configuracionCSIBankia.CC_Calendario__c = calendario[0].Id;
configuracionCSIBankia.CC_Fecha_Activacion_1a_Rec__c = System.today();
configuracionCSIBankia.CC_Horas_1a_Reclamacion__c = '24';
configuracionCSIBankia.OS_Negocio__c = 'CSI_Bankia';
insert configuracionCSIBankia;


List<Folder> carpetas = new List<Folder>();
List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
Test.startTest();

carpetas = CC_Configuracion_Reclamaciones_Auto.getCarpetas(null, configuracionCSIBankia.Id);

emailTemplateList = CC_Configuracion_Reclamaciones_Auto.getPlantillas('CC_Rec_Auto_Colaborador_CSI_Bankia_Cast');
Test.stopTest();

System.assertEquals(2, carpetas.size(), 'Se encuentran dos carpetas para las reclamaciones automáticas de CSI Bankia, para empleados y colaboradores');
for (Folder carpeta : carpetas)
{
if (carpeta.DeveloperName == 'CC_Rec_Auto_Colaborador_CSI_Bankia')
{
System.assertEquals('CC_Rec_Auto_Colaborador_CSI_Bankia', carpeta.DeveloperName, 'Se encuentra la carpeta CC_Rec_Auto_Colaborador_CSI_Bankia para las reclamaciones automáticas de Colaborador');
}
else
{
System.assertEquals('CC_Rec_Auto_Empleado_CSI_Bankia', carpeta.DeveloperName, 'Se encuentra la carpeta CC_Rec_Auto_Empleado_CSI_Bankia para las reclamaciones automáticas de Empleado');
}
}

System.assertEquals(3, emailTemplateList.size(), 'Se encuentra una plantilla en CC_Rec_Auto_Colaborador_CSI_Bankia_Cast');
}

*/
    
    @isTest
    public static void fechasPendingProcess() {
        User usuario = [SELECT Id FROM User Where LastName = 'Operador Empleado' AND UserRole.DeveloperName = 'Contact_Center' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            Set <Datetime> fechasReclamaciones = new Set<Datetime>();
            fechasReclamaciones.add(System.today());
            Case caso1 = new Case();
            caso1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso1.CC_Idioma__c = 'es';
            caso1.CC_Tipo_Cliente__c = 'Cliente';
            caso1.Status = 'Pendiente Colaborador';
            caso1.CC_Cambio_Estado_Pendiente_Externo__c = true;
            caso1.Origin = 'Email';
            caso1.CC_Canal_Procedencia__c = 'Formulario web';
            insert caso1;
            
            Task tarea = new Task();
            tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            tarea.Type = 'Traslado Colaborador';
            tarea.Subject = 'Traslado Colaborador';
            tarea.Status = 'Open';
            tarea.Description = 'Clase test reclamaciones automáticas';
            tarea.WhatId = caso1.Id;
            tarea.CC_Fecha_1_Reclamacion_Auto__c = System.today();
            tarea.CC_Fecha_2_Reclamacion_Auto__c = System.today();
            tarea.CC_Fecha_3_Reclamacion_Auto__c = System.today();
            tarea.OS_Fecha_Fin_Reclamacion_Auto__c = System.today();
            insert tarea;        
            
            CC_Configuracion_Reclamaciones_Auto.fechasPendingProcess(caso1, tarea);
            Test.stopTest();
            List<CBK_SCH_PendingProcess__c> lista = [SELECT Id FROM CBK_SCH_PendingProcess__c WHERE RecordId__c = :caso1.Id];
            System.assertNotEquals(0, lista.size(), 'Se encuentra un registro en CBK_SCH_PendingProcess__c');
        }        
    }
}