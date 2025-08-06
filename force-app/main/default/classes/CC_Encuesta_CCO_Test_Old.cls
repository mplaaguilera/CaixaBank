@isTest
public class CC_Encuesta_CCO_Test_Old {
   @TestSetup
    static void makeData() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
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
        insert usuarioAdmin;

        //insertar cola
        Group groupTransfer = new Group(Name='TestColaChat', Type='Queue');
        insert groupTransfer;
        
        QueuesObject queueTransfer = new QueueSObject(QueueID = groupTransfer.id, SObjectType = 'Case');
        insert queueTransfer;
    }
    
   @isTest
    public static void SemillaPromoOficinasResponderEmpleadoDos() {
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        insert cuenta;

        Contact contacto1 = new Contact();
        contacto1.FirstName = 'Contacto';
        contacto1.LastName = '01';
        contacto1.CC_NumPerso__c = '12345569';
        contacto1.AccountId = cuenta.Id;
        contacto1.CC_Idioma__c = 'Es';
        contacto1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        insert contacto1;

        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'Cajero';
        insert mccTematica;
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        Case oCaso1 = new Case();
        oCaso1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        oCaso1.Subject = 'Test FCO';
        oCaso1.Origin = 'Email';
        oCaso1.Status = 'Cerrado';
        oCaso1.ContactId = contacto1.Id;
        oCaso1.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
        oCaso1.CC_NotIncidencia__c = '1';
        oCaso1.CC_MailTelfNotif__c = 'test@test.es';
        oCaso1.CC_CanalNotifCli__c = 'Email';
        oCaso1.CC_Idioma__c = 'es';
        oCaso1.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso1.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso1.CC_Canal_Operativo__c = 'Cajero';
        oCaso1.CC_MCC_Tematica__c = mccTematica.Id;
        oCaso1.CC_MCC_ProdServ__c = mccProducto.Id;
        oCaso1.CC_MCC_Motivo__c = mccMotivo.Id;
        insert oCaso1;
        
        //Actividad de solicitud de información
        Task actividadSolicitudInfo = new Task();
        actividadSolicitudInfo.WhatId = oCaso1.Id;
        actividadSolicitudInfo.Type = 'Responder a cliente';
        actividadSolicitudInfo.Subject = 'Responder a cliente';
        actividadSolicitudInfo.Status = 'Completed';
        actividadSolicitudInfo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadSolicitudInfo;
        
        CC_Settings__c setting = new CC_Settings__c();
        setting.Name = 'CC_FormularioConsultasOperativas';
        setting.CC_Configuracion_2__c = '0';
        insert setting;

        // create a new email and envelope object
        Messaging.InboundEmail email1 = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();
        env1.fromAddress = 'promocaixa_empleados@email.com';
        env1.toAddress = 'promocaixa_empleados@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_Preventiva') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }
        Messaging.InboundEmail.Header header = new  Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';

        // setup the data for the email
        email1.subject = 'Create Contact';
        email1.fromAddress = 'promocaixa_empleados@email.com';
        email1.plainTextBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email1.htmlBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email1.headers = new List<Messaging.InboundEmail.Header>{header};

        Test.startTest();
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        // call the email service class and test it with the data in the testMethod
        CC_Preventiva_EmailService testInbound1 = new CC_Preventiva_EmailService();
        testInbound1.handleInboundEmail(email1, env1);
        }
        List<EmailMessage> emailId = new List<EmailMessage>();
          emailId = [SELECT Id FROM EmailMessage WHERE subject = 'Create Contact' AND fromAddress = 'promocaixa_empleados@email.com' LIMIT 1];
        System.assertEquals(emailId != null, true);
        Test.stopTest();
    }

    @isTest
    public static void SemillaPromoOficinasResponderEmpleadoTres() {
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        insert cuenta;

        Contact contacto1 = new Contact();
        contacto1.FirstName = 'Contacto';
        contacto1.LastName = '01';
        contacto1.CC_NumPerso__c = '12345569';
        contacto1.AccountId = cuenta.Id;
        contacto1.CC_Idioma__c = 'Es';
        contacto1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        insert contacto1;

        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'Cajero';
        insert mccTematica;
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        Case oCaso1 = new Case();
        oCaso1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        oCaso1.Subject = 'Test FCO';
        oCaso1.Origin = 'Email';
        oCaso1.Status = 'Cerrado';
        oCaso1.ContactId = contacto1.Id;
        oCaso1.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
        oCaso1.CC_NotIncidencia__c = '1';
        oCaso1.CC_MailTelfNotif__c = 'test@test.es';
        oCaso1.CC_CanalNotifCli__c = 'Email';
        oCaso1.CC_Idioma__c = 'es';
        oCaso1.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso1.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso1.CC_Canal_Operativo__c = 'Cajero';
        oCaso1.CC_MCC_Tematica__c = mccTematica.Id;
        oCaso1.CC_MCC_ProdServ__c = mccProducto.Id;
        oCaso1.CC_MCC_Motivo__c = mccMotivo.Id;
        insert oCaso1;
        
        //Actividad de solicitud de información
        Task actividadSolicitudInfo = new Task();
        actividadSolicitudInfo.WhatId = oCaso1.Id;
        actividadSolicitudInfo.Type = 'Responder a cliente';
        actividadSolicitudInfo.Subject = 'Responder a cliente';
        actividadSolicitudInfo.Status = 'Completed';
        actividadSolicitudInfo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadSolicitudInfo;
        
        CC_Settings__c setting = new CC_Settings__c();
        setting.Name = 'CC_FormularioConsultasOperativas';
        setting.CC_Configuracion_2__c = '10';
        insert setting;

        // create a new email and envelope object
        Messaging.InboundEmail email1 = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();
        env1.fromAddress = 'promocaixa_empleados@email.com';
        env1.toAddress = 'promocaixa_empleados@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_Preventiva') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }
        Messaging.InboundEmail.Header header = new  Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';

        // setup the data for the email
        email1.subject = 'Create Contact';
        email1.fromAddress = 'promocaixa_empleados@email.com';
        email1.plainTextBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email1.htmlBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email1.headers = new List<Messaging.InboundEmail.Header>{header};

        Test.startTest();
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        // call the email service class and test it with the data in the testMethod
        CC_Preventiva_EmailService testInbound1 = new CC_Preventiva_EmailService();
        testInbound1.handleInboundEmail(email1, env1);
        }
        List<EmailMessage> emailId = new List<EmailMessage>();
            emailId = [SELECT Id FROM EmailMessage WHERE subject = 'Create Contact' AND fromAddress = 'promocaixa_empleados@email.com' LIMIT 1];
        System.assertEquals(emailId != null, true);
        Test.stopTest();
    }

    @isTest
    public static void SemillaPromoOficinasResponderEmpleadoCuatro() {
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        insert cuenta;

        Contact contacto1 = new Contact();
        contacto1.FirstName = 'Contacto';
        contacto1.LastName = '01';
        contacto1.CC_NumPerso__c = '12345569';
        contacto1.AccountId = cuenta.Id;
        contacto1.CC_Idioma__c = 'Es';
        contacto1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        insert contacto1;

        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'Cajero';
        insert mccTematica;
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        Case oCaso1 = new Case();
        oCaso1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        oCaso1.Subject = 'Test FCO';
        oCaso1.Origin = 'Email';
        oCaso1.Status = 'Cerrado';
        oCaso1.ContactId = contacto1.Id;
        oCaso1.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
        oCaso1.CC_NotIncidencia__c = '1';
        oCaso1.CC_MailTelfNotif__c = 'test@test.es';
        oCaso1.CC_CanalNotifCli__c = 'Email';
        oCaso1.CC_Idioma__c = 'es';
        oCaso1.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso1.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso1.CC_Canal_Operativo__c = 'Cajero';
        oCaso1.CC_MCC_Tematica__c = mccTematica.Id;
        oCaso1.CC_MCC_ProdServ__c = mccProducto.Id;
        oCaso1.CC_MCC_Motivo__c = mccMotivo.Id;
        insert oCaso1;
        
        //Actividad de solicitud de información
        Task actividadSolicitudInfo = new Task();
        actividadSolicitudInfo.WhatId = oCaso1.Id;
        actividadSolicitudInfo.Type = 'Responder a cliente';
        actividadSolicitudInfo.Subject = 'Responder a cliente';
        actividadSolicitudInfo.Status = 'Completed';
        actividadSolicitudInfo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadSolicitudInfo;
        
        CC_Settings__c setting = new CC_Settings__c();
        setting.Name = 'CC_FormularioConsultasOperativas';
        setting.CC_Configuracion_2__c = '10';
        insert setting;

        CBK_Resultado_Encuesta__c resultadoEncuesta = new CBK_Resultado_Encuesta__c();
        resultadoEncuesta.CBK_Respuesta__c = '5';
        resultadoEncuesta.CBK_Case__c = oCaso1.Id;
        resultadoEncuesta.CBK_Fecha_Encuesta__c = System.now();
        resultadoEncuesta.CBK_Tipo_Encuesta__c = '11111';
        insert resultadoEncuesta;

        // create a new email and envelope object
        Messaging.InboundEmail email1 = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();
        env1.fromAddress = 'promocaixa_empleados@email.com';
        env1.toAddress = 'promocaixa_empleados@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_Preventiva') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }
        Messaging.InboundEmail.Header header = new  Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';

        // setup the data for the email
        email1.subject = 'Create Contact';
        email1.fromAddress = 'promocaixa_empleados@email.com';
        email1.plainTextBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email1.htmlBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email1.headers = new List<Messaging.InboundEmail.Header>{header};

        Test.startTest();
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        // call the email service class and test it with the data in the testMethod
        CC_Preventiva_EmailService testInbound1 = new CC_Preventiva_EmailService();
        testInbound1.handleInboundEmail(email1, env1);
        }
        List<EmailMessage> emailId = new List<EmailMessage>();
            emailId = [SELECT Id FROM EmailMessage WHERE subject = 'Create Contact' AND fromAddress = 'promocaixa_empleados@email.com' LIMIT 1];
        System.assertEquals(emailId != null, true);
        Test.stopTest();
    }

    @isTest
    public static void SemillaPromoOficinasResponderEmpleadoChat() {
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        insert cuenta;

        Contact contacto1 = new Contact();
        contacto1.FirstName = 'Contacto';
        contacto1.LastName = '01';
        contacto1.CC_NumPerso__c = '12345569';
        contacto1.AccountId = cuenta.Id;
        contacto1.CC_Idioma__c = 'Es';
        contacto1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        insert contacto1;

        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'Cajero';
        insert mccTematica;
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        Case oCaso1 = new Case();
        oCaso1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        oCaso1.Subject = 'Test FCO';
        oCaso1.Origin = 'Chat';
        oCaso1.Status = 'Cerrado';
        oCaso1.ContactId = contacto1.Id;
        oCaso1.CC_Canal_Procedencia__c = 'Web';
        oCaso1.CC_NotIncidencia__c = '1';
        oCaso1.CC_MailTelfNotif__c = 'test@test.es';
        oCaso1.CC_CanalNotifCli__c = 'Email';
        oCaso1.CC_Idioma__c = 'ca';
        oCaso1.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso1.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso1.CC_Canal_Operativo__c = 'Cajero';
        oCaso1.CC_MCC_Tematica__c = mccTematica.Id;
        oCaso1.CC_MCC_ProdServ__c = mccProducto.Id;
        oCaso1.CC_MCC_Motivo__c = mccMotivo.Id;
        insert oCaso1;

        //Simular CaseHistory
        //hacer un update sobre el owner del caso
        
        //Actividad de solicitud de información
        Task actividadSolicitudInfo = new Task();
        actividadSolicitudInfo.WhatId = oCaso1.Id;
        actividadSolicitudInfo.Type = 'Responder a cliente';
        actividadSolicitudInfo.Subject = 'Responder a cliente';
        actividadSolicitudInfo.Status = 'Completed';
        actividadSolicitudInfo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadSolicitudInfo;
        
        CC_Settings__c setting2 = new CC_Settings__c();
        setting2.Name = 'CC_Encuesta_CCO';
        setting2.CC_Configuracion_2__c = '0';
        insert setting2;


        // create a new email and envelope object
        Messaging.InboundEmail email1 = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();
        env1.fromAddress = 'promocaixa_empleados@email.com';
        env1.toAddress = 'promocaixa_empleados@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_Preventiva') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }
        Messaging.InboundEmail.Header header = new  Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';

        // setup the data for the email
        email1.subject = 'Create Contact';
        email1.fromAddress = 'promocaixa_empleados@email.com';
        email1.plainTextBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email1.htmlBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email1.headers = new List<Messaging.InboundEmail.Header>{header};

        Test.startTest();
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        // call the email service class and test it with the data in the testMethod
        CC_Preventiva_EmailService testInbound1 = new CC_Preventiva_EmailService();
        testInbound1.handleInboundEmail(email1, env1);
        }
        List<EmailMessage> emailId = new List<EmailMessage>();
          emailId = [SELECT Id FROM EmailMessage WHERE subject = 'Create Contact' AND fromAddress = 'promocaixa_empleados@email.com' LIMIT 1];
        System.assertEquals(emailId != null, true);
        Test.stopTest();
    }
    
   /* @isTest
    static void testRespuestaCorreo() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Caso FCO' LIMIT 1];
        System.debug('::: caso: ' + testCase);
        User u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Test Subject';
        email.fromAddress = 'test@example.com';
        email.fromName = 'Test Sender';
        email.toAddresses = new String[] {'recipient@example.com'};
        email.ccAddresses = new String[] {'cc@example.com'};
        email.htmlBody = '<p>This is a test email.</p>';
        email.plainTextBody = 'This is a test email.';
        System.runAs(u) {
            Test.startTest();
            System.debug('::: caso: ' + email);
            CC_Encuesta_CCO.respuestaCorreo(email, testCase.Id, email.plainTextBody, 'recipient@example.com');
            Test.stopTest();
            // Verificar los resultados esperados
            Case updatedCase = [SELECT Status, OwnerId FROM Case WHERE Id = :testCase.Id];
            System.assertEquals('Closed', updatedCase.Status, 'El estado del caso debe ser Closed');
            System.assertNotEquals(null, updatedCase.OwnerId, 'El caso debe tener un nuevo propietario');
            List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :testCase.Id];
            System.assert(tasks.size() > 0, 'Debe haberse creado una tarea');
            List<EmailMessage> emails = [SELECT Id FROM EmailMessage WHERE ParentId = :testCase.Id];
            System.assert(emails.size() > 0, 'Debe haberse creado un mensaje de correo electrónico');
        }
    }
    @isTest
    static void testRespuestaCatalan() {
        User u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];
        Case testCase = [SELECT Id FROM Case where Subject = 'Caso NFCO' LIMIT 1];
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Test Subject';
        email.fromAddress = 'test@example.com';
        email.fromName = 'Test Sender';
        email.toAddresses = new String[] {'recipient@example.com'};
        email.ccAddresses = new String[] {'cc@example.com'};
        email.htmlBody = '<p>This is a test email.</p>';
        email.plainTextBody = 'This is a test email.';
        System.runAs(u) {
            Test.startTest();
            CC_Encuesta_CCO.respuestaCorreo(email, testCase.Id, email.plainTextBody, 'recipient@example.com');
            Test.stopTest();
            // Verificar los resultados esperados
            Case updatedCase = [SELECT Status, OwnerId FROM Case WHERE Id = :testCase.Id];
            System.assertEquals('Closed', updatedCase.Status, 'El estado del caso debe ser Closed');
            System.assertNotEquals(null, updatedCase.OwnerId, 'El caso debe tener un nuevo propietario');
            List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :testCase.Id];
            System.assert(tasks.size() > 0, 'Debe haberse creado una tarea');
            List<EmailMessage> emails = [SELECT Id FROM EmailMessage WHERE ParentId = :testCase.Id];
            System.assert(emails.size() > 0, 'Debe haberse creado un mensaje de correo electrónico');
        }
    }*/
}