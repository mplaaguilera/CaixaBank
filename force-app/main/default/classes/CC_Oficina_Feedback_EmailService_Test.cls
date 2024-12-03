@isTest
public with sharing class CC_Oficina_Feedback_EmailService_Test {

    @TestSetup
    static void makeData()
    {
        Test.startTest();
        Id profileGenerico = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        PermissionSet psOperadorCliente = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];
        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
        List<User> userList = new List<User>();
        User usuarioAdmin = new User();
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = roleCC;
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser00000@amamama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';        
        userList.add(usuarioAdmin);		
        insert userList;

        System.runAs(usuarioAdmin) {
            User operador = new User();        
            operador.profileId = profileGenerico;
            operador.UserRoleId = roleCC;
            operador.FirstName = '';
            operador.LastName = 'Operador Cliente';
            operador.Email = 'tuser000@amamama.com';
            operador.Username = 'tuser0000000@amamama.com' + System.currentTimeMillis();
            operador.CompanyName = 'MST';
            operador.Title = 'title';
            operador.Alias = 'alias';
            operador.TimeZoneSidKey = 'Europe/Paris';
            operador.EmailEncodingKey = 'UTF-8';
            operador.LanguageLocaleKey = 'es';
            operador.LocaleSidKey = 'es_ES';        
            insert operador;
            insert new PermissionSetAssignment(AssigneeId = operador.Id, PermissionSetId = psOperadorCliente.Id);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCorreoEntranteCastellano() {

        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        List<String> lstCcAdd = new List<String>();
        String buzonOficinaFeedback = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Feedback_Empleados_CAT' LIMIT 1].CC_Direccion_Correo__c;
		List<String> lstToAdd = new List<String>();
        lstToAdd.add('email1@test.com');
        lstToAdd.add(buzonOficinaFeedback);
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_Oficina_Feedback') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';

		/*header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';*/
        envelope.fromAddress = 'correo@prueba.com';
        envelope.toAddress = buzonOficinaFeedback;
        correo.subject = 'asunto';
        correo.fromAddress = 'correo@prueba.com';
        correo.toAddresses = lstToAdd;
        correo.ccAddresses = lstCcAdd;
        //correo.plainTextBody = 'email test';
        correo.htmlBody = 'Lunes 27/12/2021 09:30:00<br><br>nU01: U0152396<br><br>Hora: 27/12/2021 09:30:00<br><br>E-mail Empleado: nerea.sanchez-bermejo.esteban@ibm.com<br><br>ID FAQ: https://www.google.es/<br><br>Dinos que error has encontrado: Intentamos meter en seguro MyBox Hogar perros de la clienta e imprimir certificados, no nos deja.DNI. X5959318H<br><br>Captura de pantalla:';
        correo.headers = new List<Messaging.InboundEmail.Header>{header};

        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
		//Adjunto de texto
		Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id)) {
            CC_Oficina_Feedback_EmailService emailServiceOficinaFeedback = new CC_Oficina_Feedback_EmailService();
            emailServiceOficinaFeedback.handleInboundEmail(correo, envelope);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCorreoEntranteCatalan() {

        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        List<String> lstCcAdd = new List<String>();
        String buzonOficinaFeedback = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Feedback_Empleados_CAT' LIMIT 1].CC_Direccion_Correo__c;
		List<String> lstToAdd = new List<String>();
        lstToAdd.add('email1@test.com');
        lstToAdd.add(buzonOficinaFeedback);
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_Oficina_Feedback') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';

		/*header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';*/
        correo.headers = new List<Messaging.InboundEmail.Header>{header};
        envelope.fromAddress = 'correo@prueba.com';
        envelope.toAddress = buzonOficinaFeedback;
        correo.subject = 'asunto';
        correo.fromAddress = 'correo@prueba.com';
        correo.toAddresses = lstToAdd;
        correo.ccAddresses = lstCcAdd;
        //correo.plainTextBody = 'email test';
        correo.htmlBody = 'Dilluns 27/12/2021 09:30:00<br><br>U01: U0144839 Hora: 09/12/2021 10:19:10<br><br>E-mail Empleat: mdmorera@caixabank.com<br><br>ID FAQ: https://www.google.es/<br><br>quin error has trobat a la FAQ: no es genera cap tipus de contracte (ingressos, alta caixabanknow, sua de prestec....)';        //Adjuntos binarios

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
		//Adjunto de texto
		Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

        Test.startTest();

        CC_Oficina_Feedback_EmailService emailServiceOficinaFeedback = new CC_Oficina_Feedback_EmailService();
        emailServiceOficinaFeedback.handleInboundEmail(correo, envelope);     
        Test.stopTest();

    }
    /*
    @isTest
    public static void semillaSolicitudInfo() {
        
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso OS_EmailService_Test'];
        caso.Status = 'Pendiente Cliente';
        update caso;

        //Actividad de solicitud de información
        Task tareaSolicitudInfo = new Task();
        tareaSolicitudInfo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        tareaSolicitudInfo.WhatId = caso.Id;
        tareaSolicitudInfo.Type = 'Solicitud Información';
        tareaSolicitudInfo.Subject = 'Solicitud Información';
        tareaSolicitudInfo.Status = 'Completed';
        tareaSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refSolicitudInfo';
        insert tareaSolicitudInfo;

        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
		header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';
        envelope.fromAddress = 'correo@prueba.com';
        envelope.toAddress = [SELECT OS_Email__c FROM OS_Correo__mdt WHERE DeveloperName LIKE '%Holabank%' LIMIT 1].OS_Email__c;
        correo.subject = 'asunto';
        correo.fromAddress = 'correo@prueba.com';
        correo.plainTextBody = 'hola\n#@refSolicitudInfo#\nadios';
		
        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
		//Adjunto de texto
		Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

        Test.startTest();
        
        OS_EmailService testInbound = new OS_EmailService();
        testInbound.handleInboundEmail(correo, envelope);
        
        Test.stopTest();

        System.assertEquals(
            1, [SELECT Count() FROM EmailMessage WHERE ParentId = :caso.Id],
            'El correo de respuesta a la solicitud de información debe quedar vinculado al caso'
        );
    }
    
    @isTest
    public static void semillaTrasladoColaborador() {

        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso OS_EmailService_Test'];
        caso.Status = 'Pendiente Colaborador';
        update caso;
        
        //Actividad de solicitud de información
        Task tareaTrasladoColab = new Task();
        tareaTrasladoColab.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        tareaTrasladoColab.WhatId = caso.Id;
        tareaTrasladoColab.Type = 'Traslado Colaborador';
        tareaTrasladoColab.Subject = 'Traslado Colaborador';
        tareaTrasladoColab.Status = 'Completed';
        tareaTrasladoColab.CC_Referencia_Correo_Saliente__c = 'refTrasladoColab';
        insert tareaTrasladoColab;
        
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
		header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';
        envelope.fromAddress = 'correo@prueba.com';
        envelope.toAddress = [SELECT OS_Email__c FROM OS_Correo__mdt WHERE DeveloperName LIKE '%Holabank%' LIMIT 1].OS_Email__c;
        correo.subject = 'asunto';
        correo.fromAddress = 'correo@prueba.com';
        correo.plainTextBody = 'hola\n#@refTrasladoColab#\nadios';
		
        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
		//Adjunto de texto
		Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

		Test.startTest();
        
        OS_EmailService testInbound = new OS_EmailService();
        testInbound.handleInboundEmail(correo, envelope);
        
        Test.stopTest();

        System.assertEquals(
            1, [SELECT Count() FROM EmailMessage WHERE ParentId = :caso.Id],
            'El correo de respuesta al traslado a colaborador debe quedar vinculado al caso'
        );
    }
    
    @isTest
    public static void semillaRemitirColaborador() {
        
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso OS_EmailService_Test'];

        //Actividad de solicitud de información
        Task tareaRemitirColab = new Task();
        tareaRemitirColab.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        tareaRemitirColab.WhatId = caso.Id;
        tareaRemitirColab.Type = 'Remitir Colaborador';
        tareaRemitirColab.Subject = 'Remitir Colaborador';
        tareaRemitirColab.Status = 'Completed';
        tareaRemitirColab.CC_Referencia_Correo_Saliente__c = 'refRemitirColab';
        insert tareaRemitirColab;
        
        ///Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
		header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';
        envelope.fromAddress = 'correo@prueba.com';
        envelope.toAddress = [SELECT OS_Email__c FROM OS_Correo__mdt WHERE DeveloperName LIKE '%Holabank%' LIMIT 1].OS_Email__c;
        correo.subject = 'asunto';
        correo.fromAddress = 'correo@prueba.com';
        correo.plainTextBody = 'hola\n#@refRemitirColab#\nadios';
		
        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
		//Adjunto de texto
		Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

		Test.startTest();
        
        OS_EmailService testInbound = new OS_EmailService();
        testInbound.handleInboundEmail(correo, envelope);
        
        Test.stopTest();

        System.assertEquals(
            1, [SELECT Count() FROM EmailMessage WHERE ParentId = :caso.Id],
            'El correo de respuesta al remitir a colaborador debe quedar vinculado al caso'
        );
    }*/
}