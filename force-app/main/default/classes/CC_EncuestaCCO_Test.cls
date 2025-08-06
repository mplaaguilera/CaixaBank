@isTest
private class CC_EncuestaCCO_Test {
    @TestSetup
    static void makeData() {
        User usuarioAdmin = CC_TestDataFactory.insertUserAdmin();
        //insertar cola
        Group groupTransfer = new Group(Name='TestColaChat', DeveloperName='TestColaChat', Type='Queue');
        insert groupTransfer;
        
        QueuesObject queueTransfer = new QueueSObject(QueueID = groupTransfer.id, SObjectType = 'Case');
        insert queueTransfer;

        System.runAs(usuarioAdmin) {
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
            
            List<Case> lstCasos = new List<Case>();

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
            lstCasos.add(oCaso1);

            Case oCaso2 = new Case();
            oCaso2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            oCaso2.Subject = 'Test FCO Chat';
            oCaso2.Origin = 'Phone';
            oCaso2.Status = 'Cerrado';
            oCaso2.ContactId = contacto1.Id;
            oCaso2.CC_Canal_Procedencia__c = 'Activo';
            oCaso2.CC_NotIncidencia__c = '1';
            oCaso2.CC_MailTelfNotif__c = 'test@test.es';
            oCaso2.CC_CanalNotifCli__c = 'Email';
            oCaso2.CC_Idioma__c = 'ca';
            oCaso2.CC_Detalles_Consulta__c = 'Detalles Consulta';
            oCaso2.CC_Detalles_Solucion__c = 'Detalles Solución';
            oCaso2.CC_Canal_Operativo__c = 'Cajero';
            oCaso2.CC_MCC_Tematica__c = mccTematica.Id;
            oCaso2.CC_MCC_ProdServ__c = mccProducto.Id;
            oCaso2.CC_MCC_Motivo__c = mccMotivo.Id;
            lstCasos.add(oCaso2);
            
            Case oCaso3 = new Case();
            oCaso3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            oCaso3.Subject = 'Test FCO 3';
            oCaso3.Origin = 'Email';
            oCaso3.Status = 'Pendiente Colaborador';
            oCaso3.ContactId = contacto1.Id;
            oCaso3.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            oCaso3.CC_NotIncidencia__c = '1';
            oCaso3.CC_MailTelfNotif__c = 'test@test.es';
            oCaso3.CC_CanalNotifCli__c = 'Email';
            oCaso3.CC_Idioma__c = 'es';
            oCaso3.CC_Detalles_Consulta__c = 'Detalles Consulta';
            oCaso3.CC_Detalles_Solucion__c = 'Detalles Solución';
            oCaso3.CC_Canal_Operativo__c = 'Cajero';
            oCaso3.CC_MCC_Tematica__c = mccTematica.Id;
            oCaso3.CC_MCC_ProdServ__c = mccProducto.Id;
            oCaso3.CC_MCC_Motivo__c = mccMotivo.Id;
            oCaso3.CC_En_Tercer_Nivel__c = true;
            oCaso3.CC_Grupo_3N__c = '3N AC NEGOCIO';
            lstCasos.add(oCaso3);

            Case oCaso4 = new Case();
            oCaso4.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            oCaso4.Subject = 'Test FCO 4';
            oCaso4.Origin = 'Email';
            oCaso4.Status = 'Pendiente Colaborador';
            oCaso4.ContactId = contacto1.Id;
            oCaso4.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            oCaso4.CC_NotIncidencia__c = '1';
            oCaso4.CC_MailTelfNotif__c = 'test@test.es';
            oCaso4.CC_CanalNotifCli__c = 'Email';
            oCaso4.CC_Idioma__c = 'es';
            oCaso4.CC_Detalles_Consulta__c = 'Detalles Consulta';
            oCaso4.CC_Detalles_Solucion__c = 'Detalles Solución';
            oCaso4.CC_Canal_Operativo__c = 'Cajero';
            oCaso4.CC_MCC_Tematica__c = mccTematica.Id;
            oCaso4.CC_MCC_ProdServ__c = mccProducto.Id;
            oCaso4.CC_MCC_Motivo__c = mccMotivo.Id;
            oCaso4.CC_En_Tercer_Nivel__c = false;
            oCaso4.CC_Grupo_3N__c = '3N AC NEGOCIO';
            oCaso4.CC_Cola_Procedencia__c = 'TestColaChat';
            lstCasos.add(oCaso4);

            insert lstCasos;

            List<Task> lstTasks = new List<Task>();

            //Actividad de solicitud de información
            Task actividadSolicitudInfo = new Task();
            actividadSolicitudInfo.WhatId = oCaso1.Id;
            actividadSolicitudInfo.Type = 'Responder a cliente';
            actividadSolicitudInfo.Subject = 'TestFCO';
            actividadSolicitudInfo.Status = 'Completed';
            actividadSolicitudInfo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refRemitir';
            lstTasks.add(actividadSolicitudInfo);

            //Actividad de solicitud de información
            Task actividadSolicitudInfo2 = new Task();
            actividadSolicitudInfo2.WhatId = oCaso2.Id;
            actividadSolicitudInfo2.Type = 'Responder a cliente';
            actividadSolicitudInfo2.Subject = 'Responder a cliente';
            actividadSolicitudInfo2.Status = 'Completed';
            actividadSolicitudInfo2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            actividadSolicitudInfo2.CC_Referencia_Correo_Saliente__c = 'refRemitir';
            lstTasks.add(actividadSolicitudInfo2);
            
            //Actividad de solicitud de información
            Task actividadTrasladoColaborador = new Task();
            actividadTrasladoColaborador.WhatId = oCaso3.Id;
            actividadTrasladoColaborador.Type = 'Traslado Colaborador';
            actividadTrasladoColaborador.Subject = 'Traslado Colaborador';
            actividadTrasladoColaborador.Status = 'Completed';
            actividadTrasladoColaborador.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            actividadTrasladoColaborador.CC_Referencia_Correo_Saliente__c = 'refRemitir';
            lstTasks.add(actividadTrasladoColaborador);

            insert lstTasks;
        }
    }
    @isTest
    public static void testFCOEncuesta() {
        List<Case> casoFCO = [SELECT Id FROM Case WHERE Subject = 'Test FCO' ORDER BY CreatedDate DESC LIMIT 1];
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
        String plainText = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email1.subject = 'Create Contact';
        email1.fromAddress = 'promocaixa_empleados@email.com';
        email1.plainTextBody = plainText;
        email1.htmlBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email1.headers = new List<Messaging.InboundEmail.Header>{header};

        
        CC_Settings__c setting = new CC_Settings__c();
        setting.Name = 'CC_FormularioConsultasOperativas';
        setting.CC_Configuracion_2__c = '0';
        insert setting;

        System.runAs(CC_TestDataFactory.getUserAdmin()) {	
            Test.startTest();
                CC_Encuesta_CCO.respuestaCorreo(email1, casoFCO[0].Id, plainText , 'promocaixa_empleados@email.com');
                List<EmailMessage> emailId = new List<EmailMessage>();
                emailId = [SELECT Id FROM EmailMessage WHERE subject = 'Create Contact' AND fromAddress = 'promocaixa_empleados@email.com' LIMIT 1];
                System.assertEquals(emailId != null, true);
            Test.stopTest();
        }
    }

    @isTest
    public static void testFCOEncuestaTiempoMayor() {
       
        List<Case> casoFCO = [SELECT Id FROM Case WHERE Subject = 'Test FCO' ORDER BY CreatedDate DESC LIMIT 1];
        
        CC_Settings__c setting = new CC_Settings__c();
        setting.Name = 'CC_FormularioConsultasOperativas';
        setting.CC_Configuracion_2__c = '10';
        insert setting;

        CBK_Resultado_Encuesta__c resultadoEncuesta = new CBK_Resultado_Encuesta__c();
        resultadoEncuesta.CBK_Respuesta__c = '5';
        resultadoEncuesta.CBK_Case__c = casoFCO[0].Id;
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
        String plainText = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email1.subject = 'Create Contact';
        email1.fromAddress = 'promocaixa_empleados@email.com';
        email1.plainTextBody = plainText;
        email1.htmlBody = plainText;
        email1.headers = new List<Messaging.InboundEmail.Header>{header};
       
        System.runAs(CC_TestDataFactory.getUserAdmin()) {	
            Test.startTest();
                CC_Encuesta_CCO.respuestaCorreo(email1, casoFCO[0].Id, plainText , 'promocaixa_empleados@email.com');
                List<EmailMessage> emailId = new List<EmailMessage>();
                emailId = [SELECT Id FROM EmailMessage WHERE subject = 'Create Contact' AND fromAddress = 'promocaixa_empleados@email.com' LIMIT 1];
                System.assertEquals(emailId != null, true);
            Test.stopTest();
        }
   
    }

    @isTest
    public static void testChatEncuesta() {
        List<Case> casoFCOChat = [SELECT Id, Origin FROM Case WHERE Subject = 'Test FCO Chat' ORDER BY CreatedDate DESC LIMIT 1];

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
        String plainText = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email1.subject = 'Create Contact';
        email1.fromAddress = 'promocaixa_empleados@email.com';
        email1.plainTextBody = plainText;
        email1.htmlBody = plainText;
        email1.headers = new List<Messaging.InboundEmail.Header>{header};

        CC_Settings__c setting2 = new CC_Settings__c();
        setting2.Name = 'CC_Encuesta_CCO';
        setting2.CC_Configuracion_2__c = '5';
        insert setting2;
        

        System.runAs(CC_TestDataFactory.getUserAdmin()) {	
            Test.startTest();
                CC_Encuesta_CCO.respuestaCorreo(email1, casoFCOChat[0].Id, plainText , 'promocaixa_empleados@email.com');
                List<EmailMessage> emailId = new List<EmailMessage>();
                emailId = [SELECT Id FROM EmailMessage WHERE subject = 'Create Contact' AND fromAddress = 'promocaixa_empleados@email.com' LIMIT 1];
                System.assertEquals(emailId != null, true);
            Test.stopTest();
        }
 
    }

    @isTest
    public static void testExtraerReferencia() {
        String textWithReference = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        EmailMessage createEmail = new EmailMessage();   
        createEmail.TextBody = 'SinReferencia';
        createEmail.HtmlBody = textWithReference;     
   
        System.runAs(CC_TestDataFactory.getUserAdmin()) {	
            Test.startTest();
               String referencia = CC_Metodos_EmailServices.referenciaCorreo(createEmail);
               System.assertEquals(String.isNotBlank(referencia), true, 'NO se obtuvo referencia');
            Test.stopTest();
        }
    }

    @isTest
    public static void testTraslado() {
        // Task tarea = [SELECT WhatId FROM Task WHERE Subject = 'Traslado Colaborador' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Test FCO 3' LIMIT 1];
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'preventiva@email.com';
        env.toAddress = 'preventiva@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_Preventiva') LIMIT 1];
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
        email.plainTextBody = 'Hola\n#@refRemitir#\nAdios';
        email.htmlBody = 'Hola\n#@refRemitir#\nAdios';
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
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            Test.startTest();
                CC_Metodos_EmailServices.respuestaTrasladoColaborador(email, caso.Id, '', '');
                Case casoUpd = [SELECT Status FROM Case WHERE Id = :caso.Id LIMIT 1];
                System.assertEquals('Pendiente Interno', casoUpd.Status);
            Test.stopTest();
        }
        
    }

    @isTest
    public static void testTraslado2() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Test FCO 3' LIMIT 1];
        caso.CC_Cola_Procedencia__c = 'Prueba';
        update caso;
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'preventiva@email.com';
        env.toAddress = 'preventiva@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_Preventiva') LIMIT 1];
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
        email.plainTextBody = 'Hola\n#@refRemitir#\nAdios';
        email.htmlBody = 'Hola\n#@refRemitir#\nAdios';
        email.headers = new List<Messaging.InboundEmail.Header>{header};

		// call the email service class and test it with the data in the testMethod
		CC_Preventiva_EmailService testInbound = new CC_Preventiva_EmailService();
        testInbound.handleInboundEmail(email, env);

        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            Test.startTest();
                CC_Metodos_EmailServices.respuestaTrasladoColaborador(email, caso.Id, '', '');
                Case casoUpd = [SELECT Status FROM Case WHERE Id = :caso.Id LIMIT 1];
                System.assertEquals('Pendiente Interno', casoUpd.Status);
            Test.stopTest();
        }
    }

    @isTest
    public static void testTraslado3() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Test FCO 4' LIMIT 1];
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'preventiva@email.com';
        env.toAddress = 'preventiva@email.com';
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_Preventiva') LIMIT 1];
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
        email.plainTextBody = 'Hola\n#@refRemitir#\nAdios';
        email.htmlBody = 'Hola\n#@refRemitir#\nAdios';
        email.headers = new List<Messaging.InboundEmail.Header>{header};

		// call the email service class and test it with the data in the testMethod
		CC_Preventiva_EmailService testInbound = new CC_Preventiva_EmailService();
        testInbound.handleInboundEmail(email, env);

        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            Test.startTest();
                CC_Metodos_EmailServices.respuestaTrasladoColaborador(email, caso.Id, '', '');
                Case casoUpd = [SELECT Status FROM Case WHERE Id = :caso.Id LIMIT 1];
                System.assertEquals('Activo', casoUpd.Status);
            Test.stopTest();
        }
    }

}