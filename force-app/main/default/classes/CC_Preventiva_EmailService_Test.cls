@isTest
public with sharing class CC_Preventiva_EmailService_Test {  

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
    }
    //Test Method for main class
    @isTest 
    public static void TestinBoundEmail() {
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'preventiva@email.com';
        env.toAddress = 'preventiva@email.com';
        
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
        email.subject = 'Create Contact';
        email.fromAddress = 'preventiva@email.com';
        email.plainTextBody = '[Nombre] ANA MARIA [Apellido1] RUIZ [Apellido2] SANTOS [NIF] 76266312Z [Segmento] PARTICULAR [Oficina] 99999 [Empleado] U0152012 [Motivo] 001 [Producto] 102 [Ambito] 001 [Origen] INS [Detalle] CLIENTE QUE CONTRATA HIPOTECA 9620.312.31754043 EL 10.10.2012 Y SE LE APLICA PACTO BONIFICACIÓN POR NÓMINA, LA CLIENTA, DEJA DE TENER NÓMINA Y PASA A SER AUTÓNOMA, CUMPLIENDO CON LOS REQUISITOS DE PACTO BONIFICACIÓN DE AUTÓNOMO, SE SOLICITA A DT (SIA AUTORIZACIÓN 9999 70 154945829) EL CAMBIO DE BONIFICADOR (PASAR DE NÓMINA A AUTÓNOMO) Y SE APRUEBA EL 04-07-2018, RELIQUIDÁNDOSE LOS INTERESES Y ABONÁNDOLE A LA CLIENTA EN CUENTA 78.42 EUROS POR LA DIFERENCIA DE BONIFICADORES QUE EL SISTEMA NO RECONCE Y QUE EN ESOS MOMENTOS, LA CLIENTA CUMPLIA. ACTUALMENTE SIGUE SIN BONIFICARLE EL PACTO AUTÓNOMO [Propuesta] QUE LE SEA RETROCEDIDO EL INTERÉS COBRADO INDEBIDAMENTE Y LA CORRECTA APLICACIÓN DEL PACTO AUTÓNOMO QUE EN SU DÍA FUE AUTORIZADO DT (SIA AUTORIZACIÓN 9999 70 154945829) [Inicio] 01/10/2019 [Servicios] Otros [Riesgo] Fuga [Interlocutor] Oficina [OTROS_DOCUMENTOS] [OTROS_DOCUMENTOS_2]';
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
		CC_Preventiva_EmailService testInbound = new CC_Preventiva_EmailService();
        testInbound.handleInboundEmail(email, env);
		
    }
      
	static testMethod void TestinBoundEmail2() {
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'ac@email.com';
        env.toAddress = 'ac@email.com';
        
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
        email.subject = 'Create Contact';
        email.fromAddress = 'preventiva@email.com';
        //email.plainTextBody = 'email body\n2225256325\nTitle';
        email.htmlBody = '[Nombre] ANA MARIA [Apellido1] RUIZ [Apellido2] SANTOS [NIF] 76266312Z [Segmento] PARTICULAR [Oficina] 99999 [Empleado] U0152012 [Motivo] 001 [Producto] 102 [Ambito] 001 [Origen] INS [Detalle] CLIENTE QUE CONTRATA HIPOTECA 9620.312.31754043 EL 10.10.2012 Y SE LE APLICA PACTO BONIFICACIÓN POR NÓMINA, LA CLIENTA, DEJA DE TENER NÓMINA Y PASA A SER AUTÓNOMA, CUMPLIENDO CON LOS REQUISITOS DE PACTO BONIFICACIÓN DE AUTÓNOMO, SE SOLICITA A DT (SIA AUTORIZACIÓN 9999 70 154945829) EL CAMBIO DE BONIFICADOR (PASAR DE NÓMINA A AUTÓNOMO) Y SE APRUEBA EL 04-07-2018, RELIQUIDÁNDOSE LOS INTERESES Y ABONÁNDOLE A LA CLIENTA EN CUENTA 78.42 EUROS POR LA DIFERENCIA DE BONIFICADORES QUE EL SISTEMA NO RECONCE Y QUE EN ESOS MOMENTOS, LA CLIENTA CUMPLIA. ACTUALMENTE SIGUE SIN BONIFICARLE EL PACTO AUTÓNOMO [Propuesta] QUE LE SEA RETROCEDIDO EL INTERÉS COBRADO INDEBIDAMENTE Y LA CORRECTA APLICACIÓN DEL PACTO AUTÓNOMO QUE EN SU DÍA FUE AUTORIZADO DT (SIA AUTORIZACIÓN 9999 70 154945829) [Inicio] 01/10/2019 [Servicios] Otros [Riesgo] Fuga [Interlocutor] Oficina [OTROS_DOCUMENTOS] [OTROS_DOCUMENTOS_2]';
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
		CC_Preventiva_EmailService testInbound = new CC_Preventiva_EmailService();
        testInbound.handleInboundEmail(email, env);

    }
    
    @isTest
    public static void SemillaPreventivaSolInfo() {
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
        oCaso.Status = 'Pendiente Cliente';
        oCaso.ContactId = cId;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Canal_Operativo__c = 'Cajero';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        insert oCaso;
        
        Id recordTypeIdTematica = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'Cajero';
        insert mccTematica;
        
        Id recordTypeIdProducto = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
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
        actividadSolicitudInfo.Type = 'Solicitud Información';
        actividadSolicitudInfo.Subject = 'Solicitud Información';
        actividadSolicitudInfo.Status = 'Completed';
        actividadSolicitudInfo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadSolicitudInfo;
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'preventiva@email.com';
        env.toAddress = 'preventiva@email.com';
        
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
        email.subject = 'Create Contact';
        email.fromAddress = 'preventiva@email.com';
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
		CC_Preventiva_EmailService testInbound = new CC_Preventiva_EmailService();
        testInbound.handleInboundEmail(email, env);
    }
    
    @isTest
    public static void SemillaPreventivaTraslado() {
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
        oCaso.Status = 'Pendiente Colaborador';
        oCaso.ContactId = cId;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso.CC_Canal_Operativo__c = 'Cajero';
        insert oCaso;
        
        Id recordTypeIdTematica = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'Cajero';
        insert mccTematica;
        
        Id recordTypeIdProducto = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
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
        actividadSolicitudInfo.Type = 'Traslado Colaborador';
        actividadSolicitudInfo.Subject = 'Traslado Colaborador';
        actividadSolicitudInfo.Status = 'Completed';
        actividadSolicitudInfo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadSolicitudInfo;
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'preventiva@email.com';
        env.toAddress = 'preventiva@email.com';
        
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
        email.subject = 'Create Contact';
        email.fromAddress = 'preventiva@email.com';
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
		CC_Preventiva_EmailService testInbound = new CC_Preventiva_EmailService();
        testInbound.handleInboundEmail(email, env);
    }
    
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
        oCaso.CC_Canal_Operativo__c = 'Cajero';
        insert oCaso;
        
        Id recordTypeIdTematica = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'Cajero';
        insert mccTematica;
        
        Id recordTypeIdProducto = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
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
        actividadSolicitudInfo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadSolicitudInfo;
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'promocaixa_empleados@email.com';
        env.toAddress = 'promocaixa_empleados@email.com';
        
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
		CC_Preventiva_EmailService testInbound = new CC_Preventiva_EmailService();
        testInbound.handleInboundEmail(email, env);
    }
    
    @isTest
    public static void SemillaPreventivaRemitir() {
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
        oCaso.Status = 'Activo';
        oCaso.ContactId = cId;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso.CC_Canal_Operativo__c = 'Cajero';
        insert oCaso;
        
        Id recordTypeIdTematica = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'Cajero';
        insert mccTematica;
        
        Id recordTypeIdProducto = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
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
        actividadSolicitudInfo.Type = 'Remitir Colaborador';
        actividadSolicitudInfo.Subject = 'Remitir Colaborador';
        actividadSolicitudInfo.Status = 'Completed';
        actividadSolicitudInfo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadSolicitudInfo;
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'preventiva@email.com';
        env.toAddress = 'preventiva@email.com';
        
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
        email.subject = 'Create Contact';
        email.fromAddress = 'preventiva@email.com';
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
		CC_Preventiva_EmailService testInbound = new CC_Preventiva_EmailService();
        testInbound.handleInboundEmail(email, env);
    }
    @isTest 
    public static void TestinBoundEmailCIF() {
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'preventiva@email.com';
        env.toAddress = 'preventiva@email.com';
        
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
        email.subject = 'Create Contact';
        email.fromAddress = 'preventiva@email.com';
        email.plainTextBody = '[Nombre] ANA MARIA [Apellido1] RUIZ [Apellido2] SANTOS [NIF] U3937544I [Segmento] PARTICULAR [Oficina] 99999 [Empleado] U0152012 [Motivo] 001 [Producto] 102 [Ambito] 001 [Origen] INS [Detalle] CLIENTE QUE CONTRATA HIPOTECA 9620.312.31754043 EL 10.10.2012 Y SE LE APLICA PACTO BONIFICACIÓN POR NÓMINA, LA CLIENTA, DEJA DE TENER NÓMINA Y PASA A SER AUTÓNOMA, CUMPLIENDO CON LOS REQUISITOS DE PACTO BONIFICACIÓN DE AUTÓNOMO, SE SOLICITA A DT (SIA AUTORIZACIÓN 9999 70 154945829) EL CAMBIO DE BONIFICADOR (PASAR DE NÓMINA A AUTÓNOMO) Y SE APRUEBA EL 04-07-2018, RELIQUIDÁNDOSE LOS INTERESES Y ABONÁNDOLE A LA CLIENTA EN CUENTA 78.42 EUROS POR LA DIFERENCIA DE BONIFICADORES QUE EL SISTEMA NO RECONCE Y QUE EN ESOS MOMENTOS, LA CLIENTA CUMPLIA. ACTUALMENTE SIGUE SIN BONIFICARLE EL PACTO AUTÓNOMO [Propuesta] QUE LE SEA RETROCEDIDO EL INTERÉS COBRADO INDEBIDAMENTE Y LA CORRECTA APLICACIÓN DEL PACTO AUTÓNOMO QUE EN SU DÍA FUE AUTORIZADO DT (SIA AUTORIZACIÓN 9999 70 154945829) [Inicio] 01/10/2019 [Servicios] Otros [Riesgo] Fuga [Interlocutor] Oficina [OTROS_DOCUMENTOS] [OTROS_DOCUMENTOS_2]';
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
		CC_Preventiva_EmailService testInbound = new CC_Preventiva_EmailService();
        testInbound.handleInboundEmail(email, env);
    }
    
    @isTest 
    public static void TestinBoundEmailCIFExiste() {
        Id RecordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.CC_Numero_Documento__c  = 'H49771157';
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = RecordTypeCliente;
        contacto.Email = 'postmaster@caixabank.es';
        insert contacto;        
        Id cId = contacto.Id;
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'preventiva@email.com';
        env.toAddress = 'preventiva@email.com';
        
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
        email.subject = 'Create Contact';
        email.fromAddress = 'preventiva@email.com';
        email.plainTextBody = '[Nombre] ANA MARIA [Apellido1] RUIZ [Apellido2] SANTOS [NIF] H49771157 [Segmento] PARTICULAR [Oficina] 99999 [Empleado] U0152012 [Motivo] 001 [Producto] 102 [Ambito] 001 [Origen] INS [Detalle] CLIENTE QUE CONTRATA HIPOTECA 9620.312.31754043 EL 10.10.2012 Y SE LE APLICA PACTO BONIFICACIÓN POR NÓMINA, LA CLIENTA, DEJA DE TENER NÓMINA Y PASA A SER AUTÓNOMA, CUMPLIENDO CON LOS REQUISITOS DE PACTO BONIFICACIÓN DE AUTÓNOMO, SE SOLICITA A DT (SIA AUTORIZACIÓN 9999 70 154945829) EL CAMBIO DE BONIFICADOR (PASAR DE NÓMINA A AUTÓNOMO) Y SE APRUEBA EL 04-07-2018, RELIQUIDÁNDOSE LOS INTERESES Y ABONÁNDOLE A LA CLIENTA EN CUENTA 78.42 EUROS POR LA DIFERENCIA DE BONIFICADORES QUE EL SISTEMA NO RECONCE Y QUE EN ESOS MOMENTOS, LA CLIENTA CUMPLIA. ACTUALMENTE SIGUE SIN BONIFICARLE EL PACTO AUTÓNOMO [Propuesta] QUE LE SEA RETROCEDIDO EL INTERÉS COBRADO INDEBIDAMENTE Y LA CORRECTA APLICACIÓN DEL PACTO AUTÓNOMO QUE EN SU DÍA FUE AUTORIZADO DT (SIA AUTORIZACIÓN 9999 70 154945829) [Inicio] 01/10/2019 [Servicios] Otros [Riesgo] Fuga [Interlocutor] Oficina [OTROS_DOCUMENTOS] [OTROS_DOCUMENTOS_2]';
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
		CC_Preventiva_EmailService testInbound = new CC_Preventiva_EmailService();
        testInbound.handleInboundEmail(email, env);
    }
    
    @isTest 
    public static void TestinBoundEmailNifExiste() {        
        Id RecordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.CC_Numero_Documento__c  = '49145328D';
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = RecordTypeCliente;
        contacto.Email = 'postmaster@caixabank.es';
        insert contacto;        
        Id cId = contacto.Id;
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'preventiva@email.com';
        env.toAddress = 'preventiva@email.com';
        
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
        email.subject = 'Create Contact';
        email.fromAddress = 'preventiva@email.com';
        email.plainTextBody = '[Nombre] ANA MARIA [Apellido1] RUIZ [Apellido2] SANTOS [NIF] 49145328D [Segmento] PARTICULAR [Oficina] 99999 [Empleado] U0152012 [Motivo] 001 [Producto] 102 [Ambito] 001 [Origen] INS [Detalle] CLIENTE QUE CONTRATA HIPOTECA 9620.312.31754043 EL 10.10.2012 Y SE LE APLICA PACTO BONIFICACIÓN POR NÓMINA, LA CLIENTA, DEJA DE TENER NÓMINA Y PASA A SER AUTÓNOMA, CUMPLIENDO CON LOS REQUISITOS DE PACTO BONIFICACIÓN DE AUTÓNOMO, SE SOLICITA A DT (SIA AUTORIZACIÓN 9999 70 154945829) EL CAMBIO DE BONIFICADOR (PASAR DE NÓMINA A AUTÓNOMO) Y SE APRUEBA EL 04-07-2018, RELIQUIDÁNDOSE LOS INTERESES Y ABONÁNDOLE A LA CLIENTA EN CUENTA 78.42 EUROS POR LA DIFERENCIA DE BONIFICADORES QUE EL SISTEMA NO RECONCE Y QUE EN ESOS MOMENTOS, LA CLIENTA CUMPLIA. ACTUALMENTE SIGUE SIN BONIFICARLE EL PACTO AUTÓNOMO [Propuesta] QUE LE SEA RETROCEDIDO EL INTERÉS COBRADO INDEBIDAMENTE Y LA CORRECTA APLICACIÓN DEL PACTO AUTÓNOMO QUE EN SU DÍA FUE AUTORIZADO DT (SIA AUTORIZACIÓN 9999 70 154945829) [Inicio] 01/10/2019 [Servicios] Otros [Riesgo] Fuga [Interlocutor] Oficina [OTROS_DOCUMENTOS] [OTROS_DOCUMENTOS_2]';
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
		CC_Preventiva_EmailService testInbound = new CC_Preventiva_EmailService();
        testInbound.handleInboundEmail(email, env);
    }
        
    @isTest
    public static void SemillaPromoOficinasResponderEmpleado() {
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();    
        insert cuenta;        
        
        Id accountId = cuenta.Id;
        
        Id RecordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        
        Contact contacto1 = new Contact();
        contacto1.FirstName = 'Contacto';
        contacto1.LastName = '01';
        contacto1.CC_NumPerso__c = '12345569';
        contacto1.AccountId = cuenta.Id;
        contacto1.CC_Idioma__c = 'Es';
        contacto1.RecordTypeId = RecordTypeEmpleado;
        insert contacto1;        
        Id cId1 = contacto1.Id;
        
        Case oCaso1 = new Case();
        oCaso1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        oCaso1.Subject = 'Test Incidencia';
        oCaso1.Origin = 'Email';
        oCaso1.ContactId = cId1;
        oCaso1.CC_NotIncidencia__c = '1';
        oCaso1.CC_MailTelfNotif__c = 'test@test.es';
        oCaso1.CC_CanalNotifCli__c = 'Email';
        oCaso1.CC_Idioma__c = 'es';
        oCaso1.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso1.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso1.CC_Canal_Operativo__c = 'Cajero';
        insert oCaso1;
        
        Id recordTypeIdTematica = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'Cajero';
        insert mccTematica;
        
        Id recordTypeIdProducto = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        oCaso1.CC_MCC_Tematica__c = mccTematica.Id;
        oCaso1.CC_MCC_ProdServ__c = mccProducto.Id;
        oCaso1.CC_MCC_Motivo__c = mccMotivo.Id;
        update oCaso1;
        
        //Actividad de solicitud de información
        Task actividadSolicitudInfo = new Task();
        actividadSolicitudInfo.WhatId = oCaso1.Id;
        actividadSolicitudInfo.Type = 'Responder a cliente';
        actividadSolicitudInfo.Subject = 'Responder a cliente';
        actividadSolicitudInfo.Status = 'Completed';
        actividadSolicitudInfo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadSolicitudInfo;
        
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
            
            
        
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment1 = new Messaging.InboundEmail.BinaryAttachment();
        attachment1.body = blob.valueOf('my attachment text');
        attachment1.fileName = 'textfileone.txt';
        attachment1.mimeTypeSubType = 'text/plain';
        email1.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment1 };
        
		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment attachmenttext1 = new Messaging.InboundEmail.TextAttachment();
        attachmenttext1.body = 'my attachment text';
        attachmenttext1.fileName = 'textfiletwo3.txt';
        attachmenttext1.mimeTypeSubType = 'texttwo/plain';
        email1.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext1 };
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
    public static void semillaRespuestaCSIBankia() {
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        insert cuenta;        
        
        Id accountId = cuenta.Id;
        
        Id recordTypeEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        
        Contact contacto1 = new Contact();
        contacto1.FirstName = 'Contacto';
        contacto1.LastName = '01';
        contacto1.CC_NumPerso__c = '12345569';
        contacto1.AccountId = cuenta.Id;
        contacto1.CC_Idioma__c = 'Es';
        contacto1.RecordTypeId = recordTypeEmpleado;
        insert contacto1;        
        Id cId1 = contacto1.Id;
        
        Case oCaso1 = new Case();
        oCaso1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_CSI_Bankia');
        oCaso1.Subject = 'Test Incidencia';
        oCaso1.Origin = 'Email';
        oCaso1.ContactId = cId1;
        oCaso1.CC_NotIncidencia__c = '1';
        oCaso1.CC_MailTelfNotif__c = 'test@test.es';
        oCaso1.CC_CanalNotifCli__c = 'Email';
        oCaso1.CC_Idioma__c = 'es';
        oCaso1.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso1.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso1.CC_Canal_Operativo__c = 'Oficina';
        insert oCaso1;
        
        Id recordTypeIdTematica = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'Cajero';
        insert mccTematica;
        
        Id recordTypeIdProducto = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        oCaso1.CC_MCC_Tematica__c = mccTematica.Id;
        oCaso1.CC_MCC_ProdServ__c = mccProducto.Id;
        oCaso1.CC_MCC_Motivo__c = mccMotivo.Id;
        update oCaso1;
        
        //Actividad de solicitud de información
        Task actividadSolicitudInfo = new Task();
        actividadSolicitudInfo.WhatId = oCaso1.Id;
        actividadSolicitudInfo.Type = 'Responder a cliente';
        actividadSolicitudInfo.Subject = 'Responder a cliente';
        actividadSolicitudInfo.Status = 'Completed';
        actividadSolicitudInfo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadSolicitudInfo;
        
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
        
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment1 = new Messaging.InboundEmail.BinaryAttachment();
        attachment1.body = blob.valueOf('my attachment text');
        attachment1.fileName = 'textfileone.txt';
        attachment1.mimeTypeSubType = 'text/plain';
        email1.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment1 };
        
		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment attachmenttext1 = new Messaging.InboundEmail.TextAttachment();
        attachmenttext1.body = 'my attachment text';
        attachmenttext1.fileName = 'textfiletwo3.txt';
        attachmenttext1.mimeTypeSubType = 'texttwo/plain';
        email1.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext1 };
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
    public static void semillaResponderCliente() {
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        insert cuenta;        
        
        Id accountId = cuenta.Id;
        
        Id recordTypeEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        
        Contact contacto1 = new Contact();
        contacto1.FirstName = 'Contacto';
        contacto1.LastName = '01';
        contacto1.CC_NumPerso__c = '12345569';
        contacto1.AccountId = cuenta.Id;
        contacto1.CC_Idioma__c = 'Es';
        contacto1.RecordTypeId = recordTypeEmpleado;
        insert contacto1;        
        Id cId1 = contacto1.Id;
        
        Case oCaso1 = new Case();
        oCaso1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_CSI_Bankia');
        oCaso1.Subject = 'Test Incidencia';
        oCaso1.Origin = 'Email';
        oCaso1.ContactId = cId1;
        oCaso1.CC_NotIncidencia__c = '1';
        oCaso1.CC_MailTelfNotif__c = 'test@test.es';
        oCaso1.CC_CanalNotifCli__c = 'Email';
        oCaso1.CC_Idioma__c = 'es';
        oCaso1.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso1.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso1.CC_Canal_Operativo__c = 'Oficina';
        insert oCaso1;
        
        Id recordTypeIdTematica = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'Cajero';
        insert mccTematica;
        
        Id recordTypeIdProducto = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        oCaso1.CC_MCC_Tematica__c = mccTematica.Id;
        oCaso1.CC_MCC_ProdServ__c = mccProducto.Id;
        oCaso1.CC_MCC_Motivo__c = mccMotivo.Id;
        update oCaso1;
        
        //Actividad de solicitud de información
        Task actividadSolicitudInfo = new Task();
        actividadSolicitudInfo.WhatId = oCaso1.Id;
        actividadSolicitudInfo.Type = 'Responder a cliente';
        actividadSolicitudInfo.Subject = 'Responder a cliente';
        actividadSolicitudInfo.Status = 'Completed';
        actividadSolicitudInfo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadSolicitudInfo;
        
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
        
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment1 = new Messaging.InboundEmail.BinaryAttachment();
        attachment1.body = blob.valueOf('my attachment text');
        attachment1.fileName = 'textfileone.txt';
        attachment1.mimeTypeSubType = 'text/plain';
        email1.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment1 };
        
		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment attachmenttext1 = new Messaging.InboundEmail.TextAttachment();
        attachmenttext1.body = 'my attachment text';
        attachmenttext1.fileName = 'textfiletwo3.txt';
        attachmenttext1.mimeTypeSubType = 'texttwo/plain';
        email1.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext1 };

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
    public static void testEmailOutOfBounds () {
        
        // Create a long plainText
        String plainTextLargo = '[Nombre] ANA MARIA [Apellido1] RUIZ [Apellido2] SANTOS [NIF] 49145328D [Segmento] PARTICULAR [Oficina] 99999 [Empleado] U0152012 [Motivo] 001 [Producto] 102 [Ambito] 001 [Origen] INS [Detalle] CLIENTE QUE CONTRATA HIPOTECA 9620.312.31754043 EL 10.10.2012 Y SE LE APLICA PACTO BONIFICACIÓN POR NÓMINA, LA CLIENTA, DEJA DE TENER NÓMINA Y PASA A SER AUTÓNOMA, CUMPLIENDO CON LOS REQUISITOS DE PACTO BONIFICACIÓN DE AUTÓNOMO, SE SOLICITA A DT (SIA AUTORIZACIÓN 9999 70 154945829) EL CAMBIO DE BONIFICADOR (PASAR DE NÓMINA A AUTÓNOMO) Y SE APRUEBA EL 04-07-2018, RELIQUIDÁNDOSE LOS INTERESES Y ABONÁNDOLE A LA CLIENTA EN CUENTA 78.42 EUROS POR LA DIFERENCIA DE BONIFICADORES QUE EL SISTEMA NO RECONCE Y QUE EN ESOS MOMENTOS, LA CLIENTA CUMPLIA. ACTUALMENTE SIGUE SIN BONIFICARLE EL PACTO AUTÓNOMO [Propuesta] QUE LE SEA RETROCEDIDO EL INTERÉS COBRADO INDEBIDAMENTE Y LA CORRECTA APLICACIÓN DEL PACTO AUTÓNOMO QUE EN SU DÍA FUE AUTORIZADO DT (SIA AUTORIZACIÓN 9999 70 154945829) [Inicio] 01/10/2019 [Servicios] Otros [Riesgo] Fuga [Interlocutor] Oficina [OTROS_DOCUMENTOS] [OTROS_DOCUMENTOS_2]';
        for (Integer i = 0; i < 131089; i++){
            plainTextLargo = plainTextLargo + 'a';
        }
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'preventiva@email.com';
        env.toAddress = 'preventiva@email.com';
        
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
        
  		Account cuenta = new Account();
        cuenta.Name = 'preventiva@email.com';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.Email = 'preventiva@email.com';
        contacto.LastName ='preventiva@email.com';
        contacto.AccountId = cuenta.Id;
        insert contacto;

              
        // setup the data for the email
        email.subject = 'Create Contact Preventive';
        email.fromAddress = 'preventiva@email.com';
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
                        
        System.assertEquals('Create Contact Preventive', newCase.Subject, 'El subject del case tiene que coincidir con el del email');
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
@isTest
    public static void testEmailOutOfBoundsDetails () {
               
        // create a new plainText with long 'Detail'
        String plainLongDetail = '[Nombre] ANA MARIA [Apellido1] RUIZ [Apellido2] SANTOS [NIF] 49145328D [Segmento] PARTICULAR [Oficina] 99999 [Empleado] U0152012 [Motivo] 001 [Producto] 102 [Ambito] 001 [Origen] INS [Detalle] CLIENTE QUE CONTRATA HIPOTECA 9620.312.31754043 EL 10.10.2012 Y SE LE APLICA PACTO BONIFICACIÓN POR NÓMINA, LA CLIENTA, DEJA DE TENER NÓMINA Y PASA A SER AUTÓNOMA, CUMPLIENDO CON LOS REQUISITOS DE PACTO BONIFICACIÓN DE AUTÓNOMO, SE SOLICITA A DT (SIA AUTORIZACIÓN 9999 70 154945829) EL CAMBIO DE BONIFICADOR (PASAR DE NÓMINA A AUTÓNOMO) Y SE APRUEBA EL 04-07-2018, RELIQUIDÁNDOSE LOS INTERESES Y ABONÁNDOLE A LA CLIENTA EN CUENTA 78.42 EUROS POR LA DIFERENCIA DE BONIFICADORES QUE EL SISTEMA NO RECONCE Y QUE EN ESOS MOMENTOS, LA CLIENTA CUMPLIA. ACTUALMENTE SIGUE SIN BONIFICARLE EL PACTO AUTÓNOMO ';
        for (Integer i = 0; i < 32100; i++){
            plainLongDetail = plainLongDetail + 'a';
        }
        plainLongDetail = plainLongDetail + '[Propuesta] QUE LE SEA RETROCEDIDO EL INTERÉS COBRADO INDEBIDAMENTE Y LA CORRECTA APLICACIÓN DEL PACTO AUTÓNOMO QUE EN SU DÍA FUE AUTORIZADO DT (SIA AUTORIZACIÓN 9999 70 154945829) [Inicio] 01/10/2019 [Servicios] Otros [Riesgo] Fuga [Interlocutor] Oficina [OTROS_DOCUMENTOS] [OTROS_DOCUMENTOS_2]';
        
               // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'preventiva@email.com';
        env.toAddress = 'preventiva@email.com';
        
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
        
  		Account cuenta = new Account();
        cuenta.Name = 'preventiva@email.com';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.Email = 'preventiva@email.com';
        contacto.LastName ='preventiva@email.com';
        contacto.AccountId = cuenta.Id;
        insert contacto;

              
        // setup the data for the email
        email.subject = 'Create Contact Preventive';
        email.fromAddress = 'preventiva@email.com';
        email.plainTextBody = plainLongDetail;
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
                        
        System.assertEquals('Create Contact Preventive', newCase.Subject, 'El subject del case tiene que coincidir con el del email');
        System.assert((newCase.CC_Detalles_Consulta__c).length() <= 131072, 'El numero de caracteres debe ser menor de 131072');
        System.assertEquals(32000, (newCase.Description).length(), 'El tamaño de la descripción no puede superar los 32000 caracteres');
        
        
        //Task
        Task newTask = [SELECT WhatId, Id, Description
                       FROM Task WHERE WhatId =: newCase.Id LIMIT 1];
        
        System.assertEquals(32000, (newTask.Description).length(), 'El número de caracteres de la descripción no puede superar los 32000 caracteres');
        System.assertEquals(newCase.Id, newTask.WhatId, 'El WhatId del Task tiene que coincidir con el ID del caso');
        
        //emailMessage
        EmailMessage newEmail = [SELECT TextBody, Subject, Id
                                FROM  EmailMessage WHERE ParentId =: newCase.Id LIMIT 1];  
  
        System.assert((newEmail.TextBody).length() <= 131072, 'El numero de caracteres del cuerpo del mensaje no debe superar los 131072 caraceres');
        System.assertEquals(email.subject, newEmail.Subject, 'El subject del email se debe mantener');
        
    }

    @isTest
    public static void testEmailOutOfBoundsProposal () {
               
        //create a new plainText with long 'Propuesta'
        String plainLongProposal = '[Nombre] ANA MARIA [Apellido1] RUIZ [Apellido2] SANTOS [NIF] 49145328D [Segmento] PARTICULAR [Oficina] 99999 [Empleado] U0152012 [Motivo] 001 [Producto] 102 [Ambito] 001 [Origen] INS [Detalle] CLIENTE QUE CONTRATA HIPOTECA 9620.312.31754043 EL 10.10.2012 Y SE LE APLICA PACTO BONIFICACIÓN POR NÓMINA, LA CLIENTA, DEJA DE TENER NÓMINA Y PASA A SER AUTÓNOMA, CUMPLIENDO CON LOS REQUISITOS DE PACTO BONIFICACIÓN DE AUTÓNOMO, SE SOLICITA A DT (SIA AUTORIZACIÓN 9999 70 154945829) EL CAMBIO DE BONIFICADOR (PASAR DE NÓMINA A AUTÓNOMO) Y SE APRUEBA EL 04-07-2018, RELIQUIDÁNDOSE LOS INTERESES Y ABONÁNDOLE A LA CLIENTA EN CUENTA 78.42 EUROS POR LA DIFERENCIA DE BONIFICADORES QUE EL SISTEMA NO RECONCE Y QUE EN ESOS MOMENTOS, LA CLIENTA CUMPLIA. ACTUALMENTE SIGUE SIN BONIFICARLE EL PACTO AUTÓNOMO [Propuesta] QUE LE SEA RETROCEDIDO EL INTERÉS COBRADO INDEBIDAMENTE Y LA CORRECTA APLICACIÓN DEL PACTO AUTÓNOMO QUE EN SU DÍA FUE AUTORIZADO DT (SIA AUTORIZACIÓN 9999 70 154945829)';
        for (Integer i = 0; i < 32100; i++){
            plainLongProposal = plainLongProposal + 'a';
        }
        plainLongProposal = plainLongProposal + '[Inicio] 01/10/2019 [Servicios] Otros [Riesgo] Fuga [Interlocutor] Oficina [OTROS_DOCUMENTOS] [OTROS_DOCUMENTOS_2]';
        
               // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'preventiva@email.com';
        env.toAddress = 'preventiva@email.com';
        
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

  		Account cuenta = new Account();
        cuenta.Name = 'preventiva@email.com';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.Email = 'preventiva@email.com';
        contacto.LastName ='preventiva@email.com';
        contacto.AccountId = cuenta.Id;
        insert contacto;

              
        // setup the data for the email
        email.subject = 'Create Contact Preventive';
        email.fromAddress = 'preventiva@email.com';
        email.plainTextBody = plainLongProposal;
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
                        
        System.assertEquals('Create Contact Preventive', newCase.Subject, 'El subject del case tiene que coincidir con el del email');
        System.assert((newCase.CC_Detalles_Consulta__c).length() <= 131072, 'El numero de caracteres debe ser menor de 131072');
        System.assertEquals(32000, (newCase.Description).length(), 'El tamaño de la descripción no puede superar los 32000 caracteres');
        
        
        //Task
        Task newTask = [SELECT WhatId, Id, Description
                       FROM Task WHERE WhatId =: newCase.Id LIMIT 1];
        
        System.assertEquals(32000, (newTask.Description).length(), 'El número de caracteres de la descripción no puede superar los 32000 caracteres');
        System.assertEquals(newCase.Id, newTask.WhatId, 'El WhatId del Task tiene que coincidir con el ID del caso');
        
        //emailMessage
        EmailMessage newEmail = [SELECT TextBody, Subject, Id
                                FROM  EmailMessage WHERE ParentId =: newCase.Id LIMIT 1];  
  
        System.assert((newEmail.TextBody).length() <= 131072, 'El numero de caracteres del cuerpo del mensaje no debe superar los 131072 caraceres');
        System.assertEquals(email.subject, newEmail.Subject, 'El subject del email se debe mantener');
        
    }
}