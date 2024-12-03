@isTest
public with sharing class GRR_EmailService_Test {

    private static Contact crearContacto() {
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'Cuenta01';
        insert cuenta;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'Contacto01';
        contacto.LastName = 'Contacto01';
        contacto.CC_Numero_Documento__c = '36592162J';
        contacto.CC_NumPerso__c = '25345561';
        contacto.CC_Idioma__c = 'Es';
        contacto.CC_Sexo__c = 'V';
        contacto.Email = 'testGRR@test.COM';
        insert contacto;
        return contacto;
    }

    private static Case crearCasoConContacto(String idcont) {
        Contact contacto = [SELECT Id, AccountId FROM Contact WHERE Id = :idcont];
        Case caso = new Case (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente'),
            Subject = 'Caso Test',
            ContactId = contacto.Id,
            AccountId = contacto.AccountId,
            Origin = 'Manual'
        );           
        insert caso;
        EmailMessage correo = new EmailMessage (
            CC_Interno__c = true,
            FromAddress = 'barcelona@reputacional.caixabank.com',
            ParentId = caso.Id
        );
        insert correo;
        correo.TextBody = 'Esto es una prueba para la operativa de Traslado a Colaborador\n\n';
        correo.TextBody += 'CORREO INICIAL DESDE SF a COLABORADOR\n\n';
        correo.TextBody += 'Por favor, mantén las siguientes referencias al responder a este correo electrónico: #@20240104084844#.';
        correo.TextBody += 'ref:!00D7Z058vP.!5007Z0Q2hal:ref';
        update correo;
        return caso;
    }

    @isTest
    public static void testCrearCaso() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) { 
            Test.startTest();
            
            Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
            header.value = 'hello';
            header.name = 'HEADER DE PRUEBA';
            Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
            adjuntoBinario1.body = Blob.valueOf('my attachment text');
            adjuntoBinario1.fileName = 'textfileone.txt';
            adjuntoBinario1.mimeTypeSubType = 'text/plain';
            adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};
            Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
            adjuntoBinario2.body = Blob.valueOf('my attachment text 2');
            adjuntoBinario2.fileName = 'text2fileone.txt';
            adjuntoBinario2.mimeTypeSubType = 'text/plain';
            Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
            adjuntoTexto.body = 'my attachment text';
            adjuntoTexto.fileName = 'textfiletwo3.txt';
            adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            envelope.fromAddress = 'and-occidental@reputacional.caixabank.com';
            envelope.toAddress = 'and-occidental@33epnk7uzkor6qavbd35qyzn6q9ugn46j238ita19woz7fxana.1t-x4n6eaa.eu33.apex.salesforce.com';
            Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
            correo.subject = 'asunto';
            correo.fromAddress = 'testGRR@test.COM';
            correo.plainTextBody = 'email body\n2225256325\nTitle .';
            correo.toAddresses =  new List<String>{'and-occidental@reputacional.caixabank.com'};
            correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
            correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};        
            
            
            GRR_EmailService emailService = new GRR_EmailService();
            Messaging.InboundEmailResult result = emailService.handleInboundEmail(correo, envelope);
            System.assert(result.success, 'Resultado incorrecto');    
            Test.stopTest();
        }
    }

    @isTest
    public static void testConTareaTrasladoColab() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();
            
            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            Task tarea = new Task();
            tarea.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            tarea.Type = 'Traslado Colaborador';
            tarea.Subject = 'Traslado Colaborador';
            tarea.WhatId = caso.Id;
            tarea.Status = 'Open';
            tarea.CC_Referencia_Correo_Saliente__c = 'n2225256325';
            tarea.ActivityDate = System.today();
            insert tarea;
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            envelope.fromAddress = 'barcelona@reputacional.caixabank.com';
            envelope.toAddress = 'and-occidental@33epnk7uzkor6qavbd35qyzn6q9ugn46j238ita19woz7fxana.1t-x4n6eaa.eu33.apex.salesforce.com';
            Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
            correo.subject = 'asunto';
            correo.fromAddress = 'barcelona@reputacional.caixabank.com';
            correo.plainTextBody = 'email body #@n2225256325# nTitle .';
            correo.toAddresses =  new List<String>{'and-occident@reputacional.caixabank.com'};

            GRR_EmailService emailService = new GRR_EmailService();
            Messaging.InboundEmailResult result = emailService.handleInboundEmail(correo, envelope);
            System.assert(result.success, 'Resultado incorrecto');

            Test.stopTest();
        }
    }

    @isTest
    public static void testConTareaRemitirColab() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();
            
            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            Task tarea = new Task();
            tarea.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            tarea.Type = 'Remitir Colaborador';
            tarea.Subject = 'Remitir Colaborador';
            tarea.WhatId = caso.Id;
            tarea.Status = 'Open';
            tarea.CC_Referencia_Correo_Saliente__c = 'n2225256325';
            tarea.ActivityDate = System.today();
            insert tarea;
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            envelope.fromAddress = 'direccionFromGRR@test.com';
            envelope.toAddress = 'and-occidental@33epnk7uzkor6qavbd35qyzn6q9ugn46j238ita19woz7fxana.1t-x4n6eaa.eu33.apex.salesforce.com';
            Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
            correo.subject = 'asunto';
            correo.fromAddress = 'testGRR@test.COM';
            correo.plainTextBody = 'email body #@n2225256325# nTitle .';
            correo.toAddresses =  new List<String>{'devgrr.test@gmail.com'};

            GRR_EmailService emailService = new GRR_EmailService();
            Messaging.InboundEmailResult result = emailService.handleInboundEmail(correo, envelope);
            System.assert(result.success, 'Resultado incorrecto');

            Test.stopTest();
        }
    }

    @isTest
    public static void testConTareaResponderCliente() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();
            
            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            Task tarea = new Task();
            tarea.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            tarea.Type = 'Responder a Cliente';
            tarea.Subject = 'Responder a Cliente';
            tarea.WhatId = caso.Id;
            tarea.Status = 'Open';
            tarea.CC_Referencia_Correo_Saliente__c = 'n2225256325';
            tarea.ActivityDate = System.today();
            insert tarea;
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            envelope.fromAddress = 'direccionFromGRR@test.com';
            envelope.toAddress = 'and-occidental@33epnk7uzkor6qavbd35qyzn6q9ugn46j238ita19woz7fxana.1t-x4n6eaa.eu33.apex.salesforce.com';
            Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
            correo.subject = 'asunto';
            correo.fromAddress = 'testGRR@test.COM';
            correo.plainTextBody = 'email body #@n2225256325# nTitle .';
            correo.toAddresses =  new List<String>{'devgrr.test@gmail.com'};

            GRR_EmailService emailService = new GRR_EmailService();
            Messaging.InboundEmailResult result = emailService.handleInboundEmail(correo, envelope);
            System.assert(result.success, 'Resultado incorrecto');

            Test.stopTest();
        }
    }

    @isTest
    public static void testConTareaSolicitarInfo() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();
            
            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            Task tarea = new Task();
            tarea.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            tarea.Type = 'Solicitud Información';
            tarea.Subject = 'Solicitud Información';
            tarea.WhatId = caso.Id;
            tarea.Status = 'Open';
            tarea.CC_Referencia_Correo_Saliente__c = 'n2225256325';
            tarea.ActivityDate = System.today();
            insert tarea;
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            envelope.fromAddress = 'direccionFromGRR@test.com';
            envelope.toAddress = 'and-occidental@33epnk7uzkor6qavbd35qyzn6q9ugn46j238ita19woz7fxana.1t-x4n6eaa.eu33.apex.salesforce.com';
            Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
            correo.subject = 'asunto';
            correo.fromAddress = 'testGRR@test.COM';
            correo.plainTextBody = 'email body #@n2225256325# nTitle .';
            correo.toAddresses =  new List<String>{'devgrr.test@gmail.com'};

            GRR_EmailService emailService = new GRR_EmailService();
            Messaging.InboundEmailResult result = emailService.handleInboundEmail(correo, envelope);
            System.assert(result.success, 'Resultado incorrecto');

            Test.stopTest();
        }
    }

    @isTest
    public static void testConTareaActividadManual() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();
            
            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            Task tarea = new Task();
            tarea.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            tarea.Type = 'Actividad manual';
            tarea.Subject = 'Actividad manual';
            tarea.WhatId = caso.Id;
            tarea.Status = 'Open';
            tarea.CC_Referencia_Correo_Saliente__c = 'n2225256325';
            tarea.ActivityDate = System.today();
            insert tarea;
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            envelope.fromAddress = 'direccionFromGRR@test.com';
            envelope.toAddress = 'and-occidental@33epnk7uzkor6qavbd35qyzn6q9ugn46j238ita19woz7fxana.1t-x4n6eaa.eu33.apex.salesforce.com';
            Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
            correo.subject = 'asunto';
            correo.fromAddress = 'testGRR@test.COM';
            correo.plainTextBody = 'email body #@n2225256325# nTitle .';
            correo.toAddresses =  new List<String>{'devgrr.test@gmail.com'};

            GRR_EmailService emailService = new GRR_EmailService();
            Messaging.InboundEmailResult result = emailService.handleInboundEmail(correo, envelope);
            System.assert(result.success, 'Resultado incorrecto');

            Test.stopTest();
        }
    }

}