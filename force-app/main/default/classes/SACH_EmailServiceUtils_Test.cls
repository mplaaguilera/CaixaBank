@isTest
public with sharing class SACH_EmailServiceUtils_Test {


    @testSetup
    static void data(){

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();

        Contact contacto = new Contact(LastName = 'Test', CC_Numero_Documento__c = '36592162J', CC_Sexo__c = 'V');
        insert contacto;

        //Preparación de los datos
        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.ContactId = contacto.Id;
        caso.RecordTypeId = rtCaso;
        insert caso;

    }

    /**
     * Comprobación de la referencia en el plainTextBody.
    */
    @isTest
    private static void testReferencia() {

        Case caso = [Select id, ContactId from Case where Subject = 'Caso Test' limit 1];
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

        Test.startTest();
        //Ejecución de la prueba
        String referencia = SACH_EmailService_Utils.referenciaCorreo(email);
        Test.stopTest();

        //Comprobar la referencia
        System.assertEquals('n2225256325', referencia, 'Referencia correcta.');
    }

    /**
     * Comprobación de creación del emailMessage, el documento y la tarea.
    */
    @isTest
    private static void testGestionAdjuntos() {

        Case caso = [Select id, ContactId from Case where Subject = 'Caso Test' limit 1];
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

        Test.startTest();
        //Ejecución de la prueba
        SACH_EmailService_Utils.gestionAdjuntos(email, caso, 'test@test.com');
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

     /**
     * Comprobación de la actualización del caso con la respuesta del colaborador.
    */
    @isTest
    private static void testTareaColaborador() {

        Case caso = [Select ContactId from Case where Subject = 'Caso Test' limit 1];
        caso.Status = 'Pendiente Colaborador';
        update caso;

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

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Create Contact';
        email.fromAddress = 'someaddress@email.com';
        email.plainTextBody = 'email body #@n2225256325# Title';

        Test.startTest();
        //Ejecución de la prueba
        SACH_EmailService_Utils.respuestaTrasladoColaborador(email, tarea.WhatId, 'test@test.com');
        Test.stopTest();

        System.assertEquals('Activo', [SELECT Status FROM Case WHERE Id = :caso.Id].Status, 'No se ha reactivado el caso');
    }

    /**
     * Comprobación de la tarea con la respuesta del remitir colaborador.
    */
    @isTest
    private static void testTareaRemitirColaborador() {

        Case caso = [Select id, ContactId from Case where Subject = 'Caso Test' limit 1];
        caso.Status = 'Pendiente Colaborador';
        update caso;

        Task tarea = new Task(
                            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task'),
                            WhatId = caso.Id,
                            Type = 'Remitir Colaborador',
                            Status = 'Open',
                            Subject = 'Remitir Colaborador',
                            Description = 'Remitir Colaborador',
                            ActivityDate = System.today()
                        );

        insert tarea;

        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // setup the data for the email
        email.subject = 'Create Contact';
        email.fromAddress = 'someaddress@email.com';
        email.plainTextBody = 'email body #@n2225256325# Title';

        Test.startTest();
        //Ejecución de la prueba
        SACH_EmailService_Utils.respuestaRemitirColaborador(email, tarea.WhatId, 'test@test.com');
        Test.stopTest();

        Task tareaUpdate = [Select id, Status from Task where id = :tarea.Id limit 1];

        System.assertEquals('Completed', tareaUpdate.Status, 'Estado de la tarea correcta.');
    }
}