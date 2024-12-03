@isTest
public with sharing class SACH_EmailService_Test {

    @TestSetup
    public static void crearDatosPrueba() {

        //Usuario SAC General
		User usuarioGeneral = SACH_TestDataFactory.crearUsuarioaSACH(1)[0];      
        Database.insert(usuarioGeneral);


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
        contacto.Email = 'test@test.COM';
        insert contacto;

        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
        grupoColaborador.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_CentroCaixaBank');
        grupoColaborador.OS_Negocio__c = 'CC';
        grupoColaborador.Name = 'Oficina01';
        insert grupoColaborador;
    }

    @isTest
    private static void testCrearCaso() {
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){

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

        SACH_Correos_Buzones_Entrada__mdt buzonSach = [SELECT SACH_Email_Redireccion_Buzon__c
                                                        FROM SACH_Correos_Buzones_Entrada__mdt WHERE SACH_Canal_Procedencia__c = 'SACH'];

        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.fromAddress = 'CGE_BUSTIA@CAIXABANK.COM';
        envelope.toAddress = buzonSach.SACH_Email_Redireccion_Buzon__c;
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        correo.subject = 'asunto';
        correo.fromAddress = 'test@test.COM';
        correo.plainTextBody = 'email body\n2225256325\nTitle .';
        correo.toAddresses =  new List<String>{'devsach.test@gmail.com'};
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

        test.startTest();
        SACH_EmailService emailService = new SACH_EmailService();
        Messaging.InboundEmailResult result = emailService.handleInboundEmail(correo, envelope);
        test.stopTest();

       	System.assert(result.success, 'Resultado incorrecto');
        }
    }

    @isTest
    private static void testConTareaTrasladoColab() {
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        

        Case caso = new Case();
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        caso.Subject = 'Caso Test';
        caso.AccountId = [SELECT Id FROM Account WHERE Name = 'Cuenta01'].Id;
        caso.ContactId = [SELECT Id FROM Contact WHERE LastName = 'Contacto01'].Id;
        insert caso;

        Task tarea = new Task();
        tarea.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task');
        tarea.Type = 'Traslado Colaborador';
        tarea.Subject = 'Traslado Colaborador';
        tarea.WhatId = caso.Id;
        tarea.Status = 'Open';
        tarea.CC_Referencia_Correo_Saliente__c = 'n2225256325';
        tarea.CC_Grupo_Colaborador_Id__c = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Oficina01'].Id;
        tarea.ActivityDate = System.today();
        insert tarea;

        SACH_Correos_Buzones_Entrada__mdt buzonSach = [SELECT SACH_Email_Redireccion_Buzon__c
                                                        FROM SACH_Correos_Buzones_Entrada__mdt WHERE SACH_Canal_Procedencia__c = 'SACH'];

        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.fromAddress = 'direccionFrom@test.com';
        envelope.toAddress = buzonSach.SACH_Email_Redireccion_Buzon__c;
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        correo.subject = 'asunto';
        correo.fromAddress = 'test@test.COM';
        correo.plainTextBody = 'email body #@n2225256325# nTitle .';
        correo.toAddresses =  new List<String>{'devsach.test@gmail.com'};

         

        Test.startTest();
        SACH_EmailService emailService = new SACH_EmailService();
        Messaging.InboundEmailResult result = emailService.handleInboundEmail(correo, envelope);
        Test.stopTest();

		System.assert(result.success, 'Resultado incorrecto');
        
    }

    
    @isTest
    private static void testConTareaRemitirColab() {
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        

        Case caso = new Case();
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        caso.Subject = 'Caso Test';
        caso.AccountId = [SELECT Id FROM Account WHERE Name = 'Cuenta01'].Id;
        caso.ContactId = [SELECT Id FROM Contact WHERE LastName = 'Contacto01'].Id;
        insert caso;

        Task tarea = new Task();
        tarea.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Task').getRecordTypeId();
        tarea.WhatId = caso.Id;
        tarea.WhoId = caso.ContactId;
        tarea.Status = 'Completed';
        tarea.Type = 'Remitir Colaborador';
        tarea.Subject = 'Remitir Colaborador';
        tarea.ActivityDate = System.today();
        tarea.CC_Referencia_Correo_Saliente__c = 'n2225256325';
        tarea.CC_Grupo_Colaborador_Id__c = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Oficina01'].Id;
        insert tarea;

        SACH_Correos_Buzones_Entrada__mdt buzonSach = [SELECT SACH_Email_Redireccion_Buzon__c
                                                        FROM SACH_Correos_Buzones_Entrada__mdt WHERE SACH_Canal_Procedencia__c = 'SACH'];

 		//Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.fromAddress = 'direccionFrom@test.com';
        envelope.toAddress = buzonSach.SACH_Email_Redireccion_Buzon__c;
        Messaging.InboundEmail correo = new Messaging.InboundEmail();
        correo.subject = 'asunto';
        correo.fromAddress = 'test@test.COM';
        correo.plainTextBody = 'email body #@n2225256325# nTitle .';
        correo.toAddresses = new List<String>{'devsach.test@gmail.com'};

        System.runAs(usuario){

        Test.startTest();
        SACH_EmailService emailService = new SACH_EmailService();
        Messaging.InboundEmailResult result = emailService.handleInboundEmail(correo, envelope);
        Test.stopTest();

		System.assert(result.success, 'Resultado incorrecto');
        }
    }

    @isTest
    static void testRespuestaGenerica_caso1() {
       
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        

         // Crear contacto y caso de prueba
         Contact contact = new Contact(LastName = 'Doe', Email = 'johndoe@example.com');
         insert contact;
 
         Case caso = new Case(Subject = 'Test Subject', CC_Idioma__c = 'ca' , ContactId = contact.Id, Status = 'Cerrado', CC_Ultima_Interaccion__c = 'Respuesta de solicitud de información');
         insert caso;

         Case caso2 = new Case(Subject = 'Test Subject', CC_Idioma__c = 'ca' , ContactId = contact.Id, Status = 'Pendiente Colaborador', CC_Ultima_Interaccion__c = 'Respuesta de solicitud de información');
         insert caso2;
        
         Task tarea = new Task(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task'),
            WhatId = caso.Id,
            Type = 'Traslado Colaborador',
            Status = 'Completed',
            Subject = 'Traslado Colaborador',
            Description = 'Traslado Colaborador',
            ActivityDate = System.today()
        );
        insert tarea;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Test Subject';
        email.plainTextBody = 'Test plain text body';
        email.fromAddress = 'johndoe@example.com';
        
        System.runAs(usuario){

        Test.startTest(); 
            SACH_EmailService_Utils.respuestaGenerica(email, caso.Id, email.fromAddress, tarea);
            SACH_EmailService_Utils.respuestaGenerica(email, caso2.Id, email.fromAddress, tarea);
        Test.stopTest();

        // Verifica que el caso se haya reabierto si cumplía con las condiciones para la reapertura
        System.assertEquals('Cerrado', [SELECT Status FROM Case WHERE Id = :caso.Id].Status, 'El caso no se ha reabierto correctamente');

        // Verifica que las actividades relacionadas con el caso se hayan cerrado correctamente
        System.assertEquals(0, [SELECT COUNT() FROM Task WHERE WhatId = :tarea.Id AND IsClosed = false], 'Existen actividades abiertas relacionadas con el caso');
        }
    }

    /**
     * Comprobación de creación del emailMessage, el documento y la tarea.
    */
    @isTest
    private static void testGestionAdjuntos() {
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        
        
            // Crear contacto y caso de prueba
         Contact contact = new Contact(LastName = 'Doe', Email = 'johndoe@example.com');
         insert contact;

            Case caso = new Case(Subject = 'Caso Test', CC_Idioma__c = 'ca' , ContactId = contact.Id, Status = 'Cerrado', CC_Ultima_Interaccion__c = 'Respuesta de solicitud de información');
            insert caso;

        //Case caso = [Select id, ContactId from Case where Subject = 'Caso Test' limit 1];
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // setup the data for the email
        email.subject = 'Create Contact';
        email.fromAddress = 'someaddress@email.com';
        email.plainTextBody = 'email body #@n2225256325# Title';

        //add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

        //add an Text atatchment

        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
        
        System.runAs(usuario){

        Test.startTest();
        //Ejecución de la prueba
        SACH_EmailService_Utils.gestionAdjuntos(email, caso, 'test@test.com');
        SACH_EmailService_Utils.gestionAdjuntosNew(email, caso, 'test@test.com');
    
        Test.stopTest();
        
        ContentDocumentLink contentDocument = [Select id, ShareType from ContentDocumentLink where LinkedEntityId = :caso.Id limit 1];

        //Comprobar el documento
        System.assert(contentDocument.Id != null, 'Content document creado.');
        System.assertEquals('I', contentDocument.ShareType, 'Tipo de documento correcto.');

        EmailMessage emailGenerado = [Select id from EmailMessage where ParentId = :caso.Id limit 1];

        //Comprobar el email
        System.assert(emailGenerado.Id != null,'Email generado.');
    
        Task tarea = [Select id, Type from Task where whatId = :caso.Id limit 1];

        //Comprobar la tarea
        System.assert(tarea.Id != null, 'Tarea creada.');
        System.assertEquals('Correo - Entrada', tarea.Type, 'Tipo de tarea correcta.');
        }
    }
}