@isTest
public class CC_CAU_Bankia_EmailService_Test {

    
    @TestSetup
    static void makeData(){
        Group cola = new Group();
        cola.Name = 'Test Queue';
        cola.DeveloperName = 'CC_Test_Queue';
        cola.Type = 'Queue'; 

        insert cola;

        QueuesObject testQueue = new QueueSObject(QueueID = cola.id, SobjectType = 'Case');
        insert testQueue;
    }

    @isTest 
    public static void testinBoundEmail() {
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

        Group colaEmail = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CC_Cola_correos_entrantes_CSI_Bankia' LIMIT 1];

        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'cau@email.com';
        env.toAddress = 'cauCaixaBank@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_CAU_Bankia') LIMIT 1];
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
        email.subject = 'RV: Nuevo Caso #12487398 # de PeopleSoft (INTEC ) [Puesto ]';
        email.fromAddress = 'cau@email.com';
        email.plainTextBody = exampleEmail(null);
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
        CC_CAU_Bankia_EmailService testInboundCau = new CC_CAU_Bankia_EmailService();
        
        Test.startTest();
            testInboundCau.handleInboundEmail(email, env);
        Test.stopTest();

        Case newCase = [SELECT Id, OwnerId, Subject, Origin, CC_Idioma__c, CC_Canal_Procedencia__c, CC_Tipo_Contacto__c, SuppliedName, 
                                CC_SuppliedIdioma__c, CC_MailTelfNotif__c, CC_SuppliedUser__c, CC_Id_CAU_Bankia__c
                        FROM Case WHERE Subject = 'RV: Nuevo Caso #12487398 # de PeopleSoft (INTEC ) [Puesto ]' LIMIT 1];

        System.assertEquals(colaEmail.Id, newCase.OwnerId, 'Caso asignado a la cola de correos entrantes para CSI Bankia');
        System.assertEquals('RV: Nuevo Caso #12487398 # de PeopleSoft (INTEC ) [Puesto ]', newCase.Subject);
        System.assertEquals('12487398', newCase.CC_Id_CAU_Bankia__c);

        //System.assertEquals('cau@email.com', newCase.CC_MailTelfNotif__c);
        System.assertEquals('Email', newCase.Origin);
        System.assertEquals('es', newCase.CC_Idioma__c);
        System.assertEquals('HDT CSI', newCase.CC_Canal_Procedencia__c);
        System.assertEquals('Avería', newCase.CC_Tipo_Contacto__c);
        System.assertEquals('U0000001', newCase.CC_SuppliedUser__c);
        System.assertEquals('Contacto Test', newCase.SuppliedName);
        System.assertEquals('es', newCase.CC_SuppliedIdioma__c);
		
    }

    @isTest 
    public static void testinBoundEmailContactNoExist() {
        Account accountTest = new Account();
        accountTest.Name = 'Account Test';
        insert accountTest;

        Id recordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();

        Contact testContact = new Contact();
        testContact.FirstName = 'Contacto';
        testContact.LastName = 'Test';
        testContact.CC_Matricula__c = 'U0000003';
        testContact.Email = 'test@test.com';
        testContact.AccountId = accountTest.Id;
        testContact.RecordTypeId = recordTypeEmpleado;
        testContact.CC_Idioma__c = 'ES';
        insert testContact;

        Group colaEmail = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CC_Cola_correos_entrantes_CSI_Bankia' LIMIT 1];

        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'cau@email.com';
        env.toAddress = 'cauCaixaBank@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_CAU_Bankia') LIMIT 1];
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
        email.subject = 'RV: Nuevo Caso #12487398 # de PeopleSoft (INTEC ) [Puesto ]';
        email.fromAddress = 'cau@email.com';
        email.plainTextBody = exampleEmail(null);
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
        CC_CAU_Bankia_EmailService testInboundCau = new CC_CAU_Bankia_EmailService();
        
        Test.startTest();
            testInboundCau.handleInboundEmail(email, env);
        Test.stopTest();

        Case newCase = [SELECT Id, OwnerId, Subject, Origin, CC_Idioma__c, CC_Canal_Procedencia__c, CC_Tipo_Contacto__c, SuppliedName, 
                                CC_SuppliedIdioma__c, CC_MailTelfNotif__c, CC_SuppliedUser__c, CC_Id_CAU_Bankia__c, ContactId, AccountId
                        FROM Case WHERE Subject = 'RV: Nuevo Caso #12487398 # de PeopleSoft (INTEC ) [Puesto ]' LIMIT 1];

        System.assertEquals(colaEmail.Id, newCase.OwnerId, 'Caso asignado a la cola de correos entrantes para CSI Bankia');
        System.assertEquals('RV: Nuevo Caso #12487398 # de PeopleSoft (INTEC ) [Puesto ]', newCase.Subject);
        System.assertEquals('12487398', newCase.CC_Id_CAU_Bankia__c);
        System.assertEquals('cau@email.com', newCase.CC_MailTelfNotif__c);
        System.assertEquals('Email', newCase.Origin);
        System.assertEquals('es', newCase.CC_Idioma__c);
        System.assertEquals('HDT CSI', newCase.CC_Canal_Procedencia__c);
        System.assertEquals('Avería', newCase.CC_Tipo_Contacto__c);
        System.assertEquals('U0000001', newCase.CC_SuppliedUser__c);
        System.assertEquals(null, newCase.ContactId);
        System.assertEquals(null, newCase.AccountId);
        System.assertEquals('es', newCase.CC_SuppliedIdioma__c);	
    }

    @isTest 
    public static void testInBoundEmailFormatoCorreoSinSemilla() {
        
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

        Group colaEmail = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CC_Cola_Respuesta_CSI_Bankia' LIMIT 1];

        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'cau@email.com';
        env.toAddress = 'cauCaixaBank@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_CAU_Bankia') LIMIT 1];
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
        email.subject = 'RV: Nuevo Caso #12487398 # de PeopleSoft (INTEC ) [Puesto ]';
        email.fromAddress = 'cau@email.com';
        email.plainTextBody = 'Esto es un email de ejemplo con formato correo sin semilla';
        email.headers = new List<Messaging.InboundEmail.Header>{header};
        
		// call the email service class and test it with the data in the testMethod
        CC_CAU_Bankia_EmailService testInboundCau = new CC_CAU_Bankia_EmailService();
        
        Test.startTest();
            testInboundCau.handleInboundEmail(email, env);
        Test.stopTest();

        Case newCase = [SELECT Id, OwnerId, Subject, Origin, CC_Idioma__c, CC_Canal_Procedencia__c, CC_Tipo_Contacto__c, SuppliedName, 
                                CC_SuppliedIdioma__c, CC_MailTelfNotif__c, CC_SuppliedUser__c, CC_Id_CAU_Bankia__c
                        FROM Case WHERE Subject = 'RV: Nuevo Caso #12487398 # de PeopleSoft (INTEC ) [Puesto ]' LIMIT 1];

        System.assertEquals(colaEmail.Id, newCase.OwnerId, 'Caso asignado a la cola de respuestas para CSI Bankia');
        System.assertEquals('RV: Nuevo Caso #12487398 # de PeopleSoft (INTEC ) [Puesto ]', newCase.Subject);
        System.assertEquals(null, newCase.CC_Id_CAU_Bankia__c);
        System.assertEquals('cau@email.com', newCase.CC_MailTelfNotif__c);
        System.assertEquals('Email', newCase.Origin);
        System.assertEquals('es', newCase.CC_Idioma__c);
        System.assertEquals(null, newCase.CC_Canal_Procedencia__c);
        System.assertEquals(null, newCase.CC_Tipo_Contacto__c);
        System.assertEquals(null, newCase.CC_SuppliedUser__c);
        System.assertEquals(null, newCase.SuppliedName);
        System.assertEquals('es', newCase.CC_SuppliedIdioma__c);
		
    }

    @isTest 
    public static void testinBoundEmailTrasladoColaborador() {
        OrgWideEmailAddress fromEmail = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Atención Empleados Csi Bankia' LIMIT 1];

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

        Id recordTypeIdCSIBankia = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        
        Group gr = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CC_Test_Queue'];

        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.Status = 'Pendiente Colaborador';
        oCaso.ContactId = testContact.Id;        
        oCaso.CC_En_Tercer_Nivel__c = true;
        oCaso.CC_Grupo_3N__c = gr.Name;
        oCaso.OwnerId = gr.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso.RecordTypeId = recordTypeIdCSIBankia;
        oCaso.Canal_del_Empleado__c = 'CSI';
        oCaso.CC_Canal_Procedencia__c = 'CCO CSI';
        oCaso.CC_Canal_Respuesta__c = 'Email';
        insert oCaso;
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'CSI Bankia';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'CSI Bankia';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'CSI Bankia';
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

        
        //Actividad de traslado colaborador
        Task actividadSolicitudInfo = new Task();
        actividadSolicitudInfo.WhatId = oCaso.Id;
        actividadSolicitudInfo.Type = 'Traslado Colaborador';
        actividadSolicitudInfo.Subject = 'Traslado Colaborador';
        actividadSolicitudInfo.Status = 'Pendiente';
        actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        actividadSolicitudInfo.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        insert actividadSolicitudInfo;

        Group colaEmail = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CC_Cola_correos_entrantes_CSI_Bankia' LIMIT 1];

        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'test@email.com';
        env.toAddress = 'operativasCSIBankia@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_CAU_Bankia') LIMIT 1];
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
        email.subject = 'Traslado Colaborador Response';
        email.fromAddress = 'test@email.com';
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
        CC_CAU_Bankia_EmailService testInboundCau = new CC_CAU_Bankia_EmailService();
        
        Test.startTest();
            testInboundCau.handleInboundEmail(email, env);
        Test.stopTest();

        Case caseInfo = [SELECT Id, OwnerId, Status, CC_Ultima_Interaccion__c,CC_Fecha_Ultima_Interaccion__c  FROM Case WHERE Id = :oCaso.Id LIMIT 1];
        System.assertEquals('Pendiente Interno', caseInfo.Status, 'El cambio de estado no se ha efecutado correctamente.');
        System.assertEquals('Respuesta de colaborador', caseInfo.CC_Ultima_Interaccion__c);
        System.assertEquals(System.today(), caseInfo.CC_Fecha_Ultima_Interaccion__c.date());

    }

    @isTest
    public static void semillaSolicitudInformacion() {
        OrgWideEmailAddress fromEmail = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Atención Empleados Csi Bankia' LIMIT 1];

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        insert cuenta;        
        
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = recordTypeCliente;
        insert contacto;        
        
        Id recordTypeIdCSIBankia = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.Status = 'Pendiente Cliente';
        oCaso.ContactId = contacto.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso.RecordTypeId = recordTypeIdCSIBankia;
        oCaso.Canal_del_Empleado__c = 'CSI';
        oCaso.CC_Canal_Procedencia__c = 'CCO CSI';
        oCaso.CC_Canal_Respuesta__c = 'Email';
        insert oCaso;
                
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'CSI Bankia';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'CSI Bankia';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'CSI Bankia';
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
        env.fromAddress = 'csiBankia@email.com';
        env.toAddress = 'csiBankia@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_CAU_Bankia') LIMIT 1];
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
        email.fromAddress = 'csiBankia@email.com';
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
		CC_CAU_Bankia_EmailService testInbound = new CC_CAU_Bankia_EmailService();
        Test.startTest();
            testInbound.handleInboundEmail(email, env);
        Test.stopTest();

        Case caseInfo = [SELECT Id, OwnerId, Status, CC_Ultima_Interaccion__c,CC_Fecha_Ultima_Interaccion__c  FROM Case WHERE Id = :oCaso.Id LIMIT 1];
        System.assertEquals('Activo', caseInfo.Status);
        System.assertEquals('Respuesta de solicitud de información', caseInfo.CC_Ultima_Interaccion__c);

    }

    @isTest
    public static void semillaResponder() {
        OrgWideEmailAddress fromEmail = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Atención Empleados Csi Bankia' LIMIT 1];

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        insert cuenta;        
        
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = recordTypeCliente;
        insert contacto;        
        
        Id recordTypeIdCSIBankia = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.Status = 'Activo';
        oCaso.ContactId = contacto.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso.RecordTypeId = recordTypeIdCSIBankia;
        oCaso.Canal_del_Empleado__c = 'CSI';
        oCaso.CC_Canal_Procedencia__c = 'CCO CSI';
        oCaso.CC_Canal_Respuesta__c = 'Email';
        insert oCaso;
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'CSI Bankia';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'CSI Bankia';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'CSI Bankia';
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
        
        //Actividad de Responder a cliente
        Task actividadSolicitudInfo = new Task();
        actividadSolicitudInfo.WhatId = oCaso.Id;
        actividadSolicitudInfo.Type = 'Responder Cliente';
        actividadSolicitudInfo.Subject = 'Responder Cliente';
        actividadSolicitudInfo.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadSolicitudInfo;
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'empleadosCSIBankia@email.com';
        env.toAddress = 'empleadosCSIBankia@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_CAU_Bankia') LIMIT 1];
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
        email.fromAddress = 'empleadosCSIBankia@email.com';
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
		CC_CAU_Bankia_EmailService testInbound = new CC_CAU_Bankia_EmailService();
        Test.startTest();
            testInbound.handleInboundEmail(email, env);
        Test.stopTest();

        Case caseInfo = [SELECT Id, OwnerId, Status, CC_Ultima_Interaccion__c,CC_Fecha_Ultima_Interaccion__c  FROM Case WHERE Id = :oCaso.Id LIMIT 1];
        System.assertEquals('Activo', caseInfo.Status);
        System.assertEquals('Nuevo', caseInfo.CC_Ultima_Interaccion__c);

    }
    
    @isTest
    public static void semillaRemitir() {
        OrgWideEmailAddress fromEmail = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Atención Empleados Csi Bankia' LIMIT 1];

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        insert cuenta;        
        
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = recordTypeCliente;
        insert contacto;        
        
        Id recordTypeIdCSIBankia = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.Status = 'Activo';
        oCaso.ContactId = contacto.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso.RecordTypeId = recordTypeIdCSIBankia;
        oCaso.Canal_del_Empleado__c = 'CSI';
        oCaso.CC_Canal_Procedencia__c = 'CCO CSI';
        oCaso.CC_Canal_Respuesta__c = 'Email';
        insert oCaso;
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'CSI Bankia';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'CSI Bankia';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'CSI Bankia';
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
        
        //Actividad de Remitir Colaborador
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
        env.fromAddress = 'csiBankia@email.com';
        env.toAddress = 'csiBankia@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_CAU_Bankia') LIMIT 1];
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
        email.fromAddress = 'csiBankia@email.com';
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
		CC_CAU_Bankia_EmailService testInbound = new CC_CAU_Bankia_EmailService();
        Test.startTest();
            testInbound.handleInboundEmail(email, env);
        Test.stopTest();

        Case caseInfo = [SELECT Id, OwnerId, Status, CC_Ultima_Interaccion__c,CC_Fecha_Ultima_Interaccion__c  FROM Case WHERE Id = :oCaso.Id LIMIT 1];
        System.assertEquals('Activo', caseInfo.Status);
        System.assertEquals('Nuevo', caseInfo.CC_Ultima_Interaccion__c);
        
    }



    //Comprobar el tamaño de caracteres del correo.
    @isTest
    public static void testinBoundEmailCampos() {


        
        String plainTextLargo = '';
        for (Integer i = 0; i < 131300; i++){
            plainTextLargo = plainTextLargo + 'a';
        }
       String textEmail = exampleEmail(plainTextLargo.left(32000)) + plainTextLargo;
        

       

        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'cau@email.com';
        env.toAddress = 'cauCaixaBank@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_CAU_Bankia') LIMIT 1];
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
        email.subject = 'Atención al cliente';
        email.fromAddress = 'cau@email.com';
        email.plainTextBody = textEmail;
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
        CC_CAU_Bankia_EmailService testInboundCau = new CC_CAU_Bankia_EmailService();
        
        Test.startTest();
            testInboundCau.handleInboundEmail(email, env);
        Test.stopTest();

        //Nuevo caso creado
        Case nuevoCaso = [SELECT Id, Description, Subject FROM Case WHERE Subject =: email.subject LIMIT 1];
  
        System.assertEquals('Atención al cliente', nuevoCaso.Subject);
        System.assertEquals(32000, (nuevoCaso.Description).length(), 'Campos descripcion del caso');
   
        //Task
        Task nuevaTask = [SELECT WhatId, Id, Description FROM Task WHERE WhatId =: nuevoCaso.Id LIMIT 1];
        System.assertEquals(32000, nuevaTask.Description.length());
   

        
        //Tamaño del cuerpo de email
        EmailMessage nuevoEmail = [SELECT Id, TextBody FROM  EmailMessage WHERE ParentId =: nuevoCaso.Id LIMIT 1];  
     
        System.assertEquals(131072, (nuevoEmail.TextBody).length());
        
		
    }


    public static String exampleEmail (String descripcionIncidencia)

    {

        

        String emailPlainText = ''
        + 'De: PLANIFICACION INSTALACIONES <test@test.com>'
        + 'Enviado el: jueves, 3 de diciembre de 2020 10:18'
        + 'Para: CAU TECNICO <test@testCau.com>'
        + 'Asunto: RV: Nuevo Caso #12487398 # de PeopleSoft (INTEC ) [Puesto ]'
        + '-----Mensaje original-----'
        + 'De: centroatencion@test.com <centroatencion@test.com> Enviado el: miércoles, 2 de diciembre de 2020'
        + '11:44'
        + 'Para: PLANIFICACION INSTALACIONES <test@test.com>; Tareas Servidor Funcionamiento'
        + '<test@test2.com>'
        + 'Asunto: Nuevo Caso #12487398 # de PeopleSoft (INTEC ) [Puesto ]'
        + 'Se ha generado un nuevo caso de PeopleSoft'
        + '[Id. problema : 12487398 ]' 
        + '[Fecha/Hora inicio: 01/12/2020 09:18 ]'
        + '[Relacionado con : ]'
        + '[Prioridad: Oficina BMN ]'
        + '[Gravedad: Normal ]'
        + '[Fecha/Hora limite de cierre: ]'
        + '------------------------------------------------------------------'
        + '[Entidad: 0900 ]'
        + '[Oficina: 2476 ]'
        + '[Tfno. oficina: 916585040 ]'
        + '[Direccion oficina: PLAZA DE LA MORALEJA 9 ]'
        + '[Cod. Postal: 28109 ]'
        + '[Ciudad: ALCOBENDAS ]'
        + '[Provincia: Madrid ]'
        + '[Pers. contacto: Persona Test Test ]'
        + '[Tfno. contacto: 666777888 ]'
        + '[Movil: 666666666 ]'
        + '[Usuario Caixa: U0000001]'
        + '[Oficina Caixa: 33333]'
        + '------------------------------------------------------------------'
        + '[Dispositivo: VID66159 ]'
        + '[Producto: VIDM93 P10A9 PC SOBREMESA LENOVO THINKCENTRE M93p 10A90-013SP ]'
        + '[Puesto: ]'
        + '[Num. Serie: PC07M7XT ]'
        + '[Ubicación dispositivo:'
        + ']'
        + '------------------------------------------------------------------'
        + '[Cod. Problema: ]'
        + '[Descrip. Cod. Problema:'
        + 'Sintoma/Mensaje: Arranque noos error ]'
        + '[Descrip. Incidencia: '+ descripcionIncidencia +' Usuaria, A147773, VID66159, nos llama indicando que no puede escribir, porque no se abre, en'
        + 'la lupa'
        + 'Error: "la aplicación genero una excepcion que no se pudo controlar. Id de proceso= 0x224c(8780) ide de'
        + 'subproceso= 0x2cf8(11512)"'
        + 'Ha reiniciado y forzado el apagado tres veces Escalo para su revision Tf 666999888 ] [Tipo de caso: Hardware ]'
        + '[Categoría: Puesto ]'
        + '[Area problema: HDD ]'
        + '[Detalle problema: Sobremesa ]'
        + '------------------------------------------------------------------'
        + '[Automatico]:12487398 |01/12/2020 09:18 | |Oficina BMN | |0900 ,2476 ,916585040 ,PLAZA DE LA MORALEJA'
        + '9 ,28109 ,ALCOBENDAS ,Madrid ,ROCIO TEST TEST ,666777888 |VID66159 ,VIDM93 P10A9 , ,PC07M7XT , |'
        + '| |Arranque noos error |Usuaria, A147773, VID66159, nos llama indicando que no puede escribir, porque no se'
        + 'abre, en la lupa'
        + 'Error: "la aplicación genero una excepcion que no se pudo controlar. Id de proceso= 0x224c(8780) ide de'
        + 'subproceso= 0x2cf8(11512)"'
        + 'Ha reiniciado y forzado el apagado tres veces Escalo para su revision Tf 666777999 |Hardware |Puesto | HDD'
        + '|Sobremesa | |'
        + 'Para acceder al caso:'
        + '- Si se trata de un técnico de Bankia, el acceso es'
        + '- Si se trata de un proveedor externo a Bankia, el acceso es'
        + '- Si se trata de un agente del centro de atencion que quiere acceder como tecnico, el acceso es'
        + '- Si se trata de un agente del centro de atencion que quiere acceder como agente, el acceso es';

        

        return emailPlainText;
    }
}