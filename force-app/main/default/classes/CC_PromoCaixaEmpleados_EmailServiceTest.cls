@isTest
public class CC_PromoCaixaEmpleados_EmailServiceTest {
    //Test Method for main class
    static testMethod void TestinBoundEmail() {
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'promocaixa_empleados@email.com';
        env.toAddress = 'promocaixa_empleados@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_PromoCaixa_Empleados') LIMIT 1];
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
        email.headers = new List<Messaging.InboundEmail.Header>{header};

        // setup the data for the email
        email.subject = 'Create Contact';
        email.fromAddress = 'promocaixa_empleados@email.com';
        email.plainTextBody = 'email body\n2225256325\nTitle';
        
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
           
		// call the email service class and test it with the data in the testMethod
		CC_PromoCaixa_Empleados_EmailService testInbound = new CC_PromoCaixa_Empleados_EmailService();
        testInbound.handleInboundEmail(email, env);

    }
    
    static testMethod void TestinBoundEmail2() {
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'promocaixa_empleados@email.com';
        env.toAddress = 'promocaixa_empleados@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_PromoCaixa_Empleados') LIMIT 1];
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
        email.subject = 'Create Contact';
        email.fromAddress = 'promocaixa_empleados@email.com';
        //email.plainTextBody = 'email body\n2225256325\nTitle';
        email.htmlBody = 'email body\n2225256325\nTitle';
        email.headers = new List<Messaging.InboundEmail.Header>{header};
        
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
           
		// call the email service class and test it with the data in the testMethod
		CC_PromoCaixa_Empleados_EmailService testInbound = new CC_PromoCaixa_Empleados_EmailService();
        testInbound.handleInboundEmail(email, env);

    }
    
    @isTest
    public static void SemillaPromoOficinasSolInfo() {
        Id centroRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id empleadoRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        
        Account cuentaCentroCaixaBank = new Account(
        	RecordTypeId = centroRecordTypeId,
            Name = 'Cuenta Centro CaixaBank Test 1',
            CC_Tipo_Centro__c = 'OF'
        );
        insert cuentaCentroCaixaBank;
        
        Contact contacto = new Contact(
            RecordTypeId = empleadoRecordTypeId,
            FirstName = 'Contacto OF',
            LastName = 'Test',
            AccountId = cuentaCentroCaixaBank.Id,
            CC_Idioma__c = 'es',
            Email = 'test@contact.com',
            CC_Cargo__c = 'DIRECCIÓN'
        );
        insert contacto;
                
        Id recordTypeIdEmpleados = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.Status = 'Pendiente Cliente';
        oCaso.CC_Canal_Procedencia__c = 'Soporte Empleados CompraEstrella';
        oCaso.CC_Canal_Resolucion__c = 'Soporte Empleados CompraEstrella';
        oCaso.AccountId = cuentaCentroCaixaBank.Id;
        oCaso.ContactId = contacto.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso.RecordTypeId = recordTypeIdEmpleados;
        insert oCaso;
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        oCaso.CC_MCC_Tematica__c = mccTematica.Id;
        oCaso.CC_MCC_ProdServ__c = mccProducto.Id;
        oCaso.CC_MCC_Motivo__c = mccMotivo.Id;
        update oCaso;
        
        //Actividad de solicitud de información
        Task actividadSolicitudInfo = new Task();
        actividadSolicitudInfo.WhatId = oCaso.Id;
        actividadSolicitudInfo.Type = 'Solicitud Información';
        actividadSolicitudInfo.Subject = 'Solicitud Información';
        actividadSolicitudInfo.Status = 'Completed';
        actividadSolicitudInfo.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadSolicitudInfo;
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'promocaixa_empleados@email.com';
        env.toAddress = 'promocaixa_empleados@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_PromoCaixa_Empleados') LIMIT 1];
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
        email.subject = 'Create Contact';
        email.fromAddress = 'promocaixa_empleados@email.com';
        email.plainTextBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email.htmlBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email.headers = new List<Messaging.InboundEmail.Header>{header};
       
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
           
		// call the email service class and test it with the data in the testMethod
		CC_PromoCaixa_Empleados_EmailService testInbound = new CC_PromoCaixa_Empleados_EmailService();
        testInbound.handleInboundEmail(email, env);
    }
    
    @isTest
    public static void SemillaPromoOficinasTraslado() {
        Id centroRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id empleadoRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        
        Account cuentaCentroCaixaBank = new Account(
        	RecordTypeId = centroRecordTypeId,
            Name = 'Cuenta Centro CaixaBank Test 1',
            CC_Tipo_Centro__c = 'OF'
        );
        insert cuentaCentroCaixaBank;
        
        Contact contacto = new Contact(
            RecordTypeId = empleadoRecordTypeId,
            FirstName = 'Contacto OF',
            LastName = 'Test',
            AccountId = cuentaCentroCaixaBank.Id,
            CC_Idioma__c = 'es',
            Email = 'test@contact.com',
            CC_Cargo__c = 'DIRECCIÓN'
        );
        insert contacto;
        
        Id recordTypeIdEmpleados = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.Status = 'Pendiente Colaborador';
        oCaso.CC_Canal_Procedencia__c = 'Soporte Empleados CompraEstrella';
        oCaso.CC_Canal_Resolucion__c = 'Soporte Empleados CompraEstrella';
        oCaso.AccountId = cuentaCentroCaixaBank.Id;
        oCaso.ContactId = contacto.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso.RecordTypeId = recordTypeIdEmpleados;
        insert oCaso;
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        oCaso.CC_MCC_Tematica__c = mccTematica.Id;
        oCaso.CC_MCC_ProdServ__c = mccProducto.Id;
        oCaso.CC_MCC_Motivo__c = mccMotivo.Id;
        update oCaso;
        
        //Actividad de solicitud de información
        Task actividadSolicitudInfo = new Task();
        actividadSolicitudInfo.WhatId = oCaso.Id;
        actividadSolicitudInfo.Type = 'Traslado Colaborador';
        actividadSolicitudInfo.Subject = 'Traslado Colaborador';
        actividadSolicitudInfo.Status = 'Completed';
        actividadSolicitudInfo.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadSolicitudInfo;
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'promocaixa_empleados@email.com';
        env.toAddress = 'promocaixa_empleados@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_PromoCaixa_Empleados') LIMIT 1];
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
        email.subject = 'Create Contact';
        email.fromAddress = 'promocaixa_empleados@email.com';
        email.plainTextBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email.htmlBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email.headers = new List<Messaging.InboundEmail.Header>{header};
        
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
           
		// call the email service class and test it with the data in the testMethod
		CC_PromoCaixa_Empleados_EmailService testInbound = new CC_PromoCaixa_Empleados_EmailService();
        testInbound.handleInboundEmail(email, env);
    }
    /*
    @isTest
    public static void SemillaPromoOficinasResponder() {
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        insert cuenta;        
        
        Id accountId = cuenta.Id;
        
        Id RecordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = RecordTypeCliente;
        insert contacto;        
        Id cId = contacto.Id;
        
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.ContactId = cId;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        insert oCaso;
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        oCaso.CC_MCC_Tematica__c = mccTematica.Id;
        oCaso.CC_MCC_ProdServ__c = mccProducto.Id;
        oCaso.CC_MCC_Motivo__c = mccMotivo.Id;
        update oCaso;
        
        //Actividad de solicitud de información
        Task actividadSolicitudInfo = new Task();
        actividadSolicitudInfo.WhatId = oCaso.Id;
        actividadSolicitudInfo.Type = 'Responder a cliente';
        actividadSolicitudInfo.Subject = 'Responder a cliente';
        actividadSolicitudInfo.Status = 'Completed';
        actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadSolicitudInfo;
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'promocaixa_empleados@email.com';
        env.toAddress = 'promocaixa_empleados@email.com';
        
        // setup the data for the email
        email.subject = 'Create Contact';
        email.fromAddress = 'promocaixa_empleados@email.com';
        email.plainTextBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email.htmlBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
           
		// call the email service class and test it with the data in the testMethod
		CC_PromoCaixa_Empleados_EmailService testInbound = new CC_PromoCaixa_Empleados_EmailService();
        testInbound.handleInboundEmail(email, env);
    }*/
    
    @isTest
    public static void SemillaPromoOficinasRemitir() {
        Id centroRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id empleadoRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        
        Account cuentaCentroCaixaBank = new Account(
        	RecordTypeId = centroRecordTypeId,
            Name = 'Cuenta Centro CaixaBank Test 1',
            CC_Tipo_Centro__c = 'OF'
        );
        insert cuentaCentroCaixaBank;
        
        Contact contacto = new Contact(
            RecordTypeId = empleadoRecordTypeId,
            FirstName = 'Contacto OF',
            LastName = 'Test',
            AccountId = cuentaCentroCaixaBank.Id,
            CC_Idioma__c = 'es',
            Email = 'test@contact.com',
            CC_Cargo__c = 'DIRECCIÓN'
        );
        insert contacto;
        
        Id recordTypeIdEmpleados = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.Status = 'Activo';
        oCaso.AccountId = cuentaCentroCaixaBank.Id;
        oCaso.ContactId = contacto.Id;
        oCaso.CC_Canal_Procedencia__c = 'Soporte Empleados CompraEstrella';
        oCaso.CC_Canal_Resolucion__c = 'Soporte Empleados CompraEstrella';
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso.RecordTypeId = recordTypeIdEmpleados;
        insert oCaso;
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        oCaso.CC_MCC_Tematica__c = mccTematica.Id;
        oCaso.CC_MCC_ProdServ__c = mccProducto.Id;
        oCaso.CC_MCC_Motivo__c = mccMotivo.Id;
        update oCaso;
        
        //Actividad de solicitud de información
        Task actividadSolicitudInfo = new Task();
        actividadSolicitudInfo.WhatId = oCaso.Id;
        actividadSolicitudInfo.Type = 'Remitir Colaborador';
        actividadSolicitudInfo.Subject = 'Remitir Colaborador';
        actividadSolicitudInfo.Status = 'Completed';
        actividadSolicitudInfo.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadSolicitudInfo;
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'promocaixa_empleados@email.com';
        env.toAddress = 'promocaixa_empleados@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_PromoCaixa_Empleados') LIMIT 1];
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
        email.subject = 'Create Contact';
        email.fromAddress = 'promocaixa_empleados@email.com';
        email.plainTextBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email.htmlBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email.headers = new List<Messaging.InboundEmail.Header>{header};
       
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
           
		// call the email service class and test it with the data in the testMethod
		CC_PromoCaixa_Empleados_EmailService testInbound = new CC_PromoCaixa_Empleados_EmailService();
        testInbound.handleInboundEmail(email, env);
    }
    
    @isTest
    public static void PromoIdentificarAuto() {
        Id centroRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id empleadoRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        
        Account cuentaCentroCaixaBank = new Account(
        	RecordTypeId = centroRecordTypeId,
            Name = 'Cuenta Centro CaixaBank Test 1',
            CC_Tipo_Centro__c = 'OF'
        );
        insert cuentaCentroCaixaBank;
        
        Contact contacto = new Contact(
            RecordTypeId = empleadoRecordTypeId,
            FirstName = 'Contacto OF',
            LastName = 'Test',
            AccountId = cuentaCentroCaixaBank.Id,
            CC_Idioma__c = 'es',
            Email = 'test@contact.com',
            CC_Cargo__c = 'DIRECCIÓN',
            CC_Num_Empleado__c = 'U0199999'
        );
        insert contacto;
               
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'test@contact.com';
        env.toAddress = 'promocaixa_empleados@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_PromoCaixa_Empleados') LIMIT 1];
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
        email.subject = 'Create Contact';
        email.fromAddress = 'test@contact.com';
        email.plainTextBody = 'Hola\n#U0199999#\nAdios\n';
        email.htmlBody = 'Hola\n#U0199999#\nAdios\n';
        email.headers = new List<Messaging.InboundEmail.Header>{header};

        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
           
		// call the email service class and test it with the data in the testMethod
		CC_PromoCaixa_Empleados_EmailService testInbound = new CC_PromoCaixa_Empleados_EmailService();
        testInbound.handleInboundEmail(email, env);
    }    
    
    @isTest
    public static void SemillaPromoOficinasResponder() {
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        insert cuenta;        
        
        Id accountId = cuenta.Id;
        
        Id RecordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = RecordTypeEmpleado;
        insert contacto;        
        Id cId = contacto.Id;
        
        Case oCaso = new Case();
        oCaso.RecordTypeId =  Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.CC_Canal_Procedencia__c = 'Servicios Centrales';
        oCaso.ContactId = cId;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        insert oCaso;
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'Oficina';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        oCaso.CC_MCC_Tematica__c = mccTematica.Id;
        oCaso.CC_MCC_ProdServ__c = mccProducto.Id;
        oCaso.CC_MCC_Motivo__c = mccMotivo.Id;
        update oCaso;
        
        //Actividad de solicitud de información
        Task actividadSolicitudInfo = new Task();
        actividadSolicitudInfo.WhatId = oCaso.Id;
        actividadSolicitudInfo.Type = 'Responder a cliente';
        actividadSolicitudInfo.Subject = 'Responder a cliente';
        actividadSolicitudInfo.Status = 'Completed';
        actividadSolicitudInfo.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadSolicitudInfo;
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'promocaixa_empleados@email.com';
        env.toAddress = 'promocaixa_empleados@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_PromoCaixa_Empleados') LIMIT 1];
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
        email.subject = 'Create Contact';
        email.fromAddress = 'promocaixa_empleados@email.com';
        email.plainTextBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email.htmlBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email.headers = new List<Messaging.InboundEmail.Header>{header};

        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
           
		// call the email service class and test it with the data in the testMethod
		CC_PromoCaixa_Empleados_EmailService testInbound = new CC_PromoCaixa_Empleados_EmailService();
        testInbound.handleInboundEmail(email, env);
    }

    @isTest
    public static void testEmailMethod () {
        
        String plainTextLargo = '';
        for (Integer i = 0; i < 131089; i++){
            plainTextLargo = plainTextLargo + 'a';
        }
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'promocaixa_empleados@email.com';
        env.toAddress = 'promocaixa_empleados@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_PromoCaixa_Empleados') LIMIT 1];
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


  		Account cuenta = new Account();
        cuenta.Name = 'promocaixa_empleados@email.com';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.Email = 'promocaixa_empleados@email.com';
        contacto.LastName ='promocaixa_empleados@email.com';
        contacto.AccountId = cuenta.Id;
        insert contacto;

              
        // setup the data for the email
        email.subject = 'Create Contact';
        email.fromAddress = 'promocaixa_empleados@email.com';
        email.plainTextBody = plainTextLargo;
        email.headers = new List<Messaging.InboundEmail.Header>{header};


		// call the email service class and test it with the data in the testMethod
		CC_PromoCaixa_Empleados_EmailService testInbound = new CC_PromoCaixa_Empleados_EmailService();
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        Test.startTest();
        result = testInbound.handleInboundEmail(email, env);
        Test.stopTest();
        
        //New Case created
        Case newCase = [SELECT Id, Description, CC_Detalles_Consulta__c, Subject
                        FROM Case WHERE Subject =: email.subject LIMIT 1];
                        
        System.assertEquals('Create Contact', newCase.Subject, 'El subject del case tiene que coincidir con el del email');
        System.assertEquals(131072, (newCase.CC_Detalles_Consulta__c).length(), 'El numero de caracteres debe ser menor de 131072');
        System.assertEquals(32000, (newCase.Description).length(), 'El tamaño de la descripción no puede superar los 32000 caracteres');
        
        
        //Task
        Task newTask = [SELECT WhatId, Id, Description
                       FROM Task WHERE WhatId =: newCase.Id LIMIT 1];
        
        System.assertEquals(32000, (newTask.Description).length(), 'El número de caracteres de la descripción no puede superar los 32000 caracteres');
        System.assertEquals(newCase.Id, newTask.WhatId, 'El WhatId del Task tiene que coincidir con el ID del caso');
        
        //emailMessage
        EmailMessage newEmail = [SELECT TextBody, Subject, Id
                                FROM  EmailMessage WHERE ParentId =: newCase.Id LIMIT 1];  
  
        System.assertEquals(131072, (newEmail.TextBody).length(), 'El numero de caracteres del cuerpo del mensaje no debe superar los 131072 caraceres');
        System.assertEquals(email.subject, newEmail.Subject, 'El subject del email se debe mantener');
        
    }
}