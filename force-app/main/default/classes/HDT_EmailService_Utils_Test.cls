@isTest
public with sharing class HDT_EmailService_Utils_Test {


    @testSetup
    static void data(){

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();

        Contact contacto = new Contact(LastName = 'Test', CC_Numero_Documento__c = '36592162J', CC_Sexo__c = 'V');
        insert contacto;

        //Preparación de los datos
        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.ContactId = contacto.Id;
        caso.RecordTypeId = rtCaso;
        insert caso;

        //Preparación de los datos
        Case caso2 = new Case();
        caso2.Subject = 'Caso Test Closed';
        caso2.ContactId = contacto.Id;
        caso2.RecordTypeId = rtCaso;
        insert caso2;


        List <String> owaEmails = new List<String>{('Atención Empleados Contact Center IT Grupo CaixaBank')};

        List <OrgWideEmailAddress> owa = new List <OrgWideEmailAddress>([SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName IN : owaEmails]);

        HDT_Parametros__c params = new HDT_Parametros__c();
        params.Name = 'HDT_Email_Respuesta_Empleados_New';
        params.HDT_Configuracion_1__c = owa[0].Address;
        params.HDT_Configuracion_2__c = owa[0].Address;
        insert params;
    }

    /**
     * Comprobación de la referencia en el plainTextBody.
    */
    @isTest
    private static void testReferencia() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        String referencia = '';

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
            referencia = HDT_EmailService_Utils.referenciaCorreo(email);
        Test.stopTest();
        //Comprobar la referencia
        System.assertEquals('n2225256325', referencia, 'Referencia correcta.');
        }
    }

    /**
     * Comprobación de creación del emailMessage, el documento y la tarea.
    */
    @isTest
    private static void testGestionAdjuntos() {
        
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
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
        HDT_EmailService_Utils.gestionAdjuntos(email, caso, 'test@test.com');
        HDT_EmailService_Utils.gestionAdjuntosNew(email, caso, 'test@test.com');
    
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

    

     /**
     * Comprobación de la actualización del caso con la respuesta del colaborador.
    */
    @isTest
    private static void testTareaColaborador() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
        
        Case caso = [Select ContactId from Case where Subject = 'Caso Test' limit 1];
        caso.Status = 'Pendiente Colaborador';
        update caso;

        Task tarea = new Task(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task'),
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
            HDT_EmailService_Utils.respuestaTrasladoColaborador(email, tarea.WhatId, 'test@test.com');    
        Test.stopTest();

        System.assertEquals('Activo', [SELECT Status FROM Case WHERE Id = :caso.Id].Status, 'No se ha reactivado el caso');

        }
    }

     /**
     * Comprobación de la tarea con la respuesta del remitir colaborador.
    */
    @isTest
    private static void testTareaRemitirColaborador() {
       
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
        Case caso = [Select id, ContactId from Case where Subject = 'Caso Test' limit 1];
        caso.Status = 'Pendiente Colaborador';
        update caso;

        Task tarea = new Task(
                            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task'),
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
        HDT_EmailService_Utils.respuestaRemitirColaborador(email, tarea.WhatId, 'test@test.com');
        Test.stopTest();

        Task tareaUpdate = [Select id, Status from Task where id = :tarea.Id limit 1];

        System.assertEquals('Completed', tareaUpdate.Status, 'Estado de la tarea correcta.');

        }
    }

    static testMethod void testRespuestaTrasladoColaborador() {
       
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
        // Create test data
        Contact c = new Contact(LastName = 'Doe');
        insert c;
        Case caso = new Case(Status = 'Pendiente Colaborador', ContactId = c.Id);
        insert caso;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Test Subject';
        email.plainTextBody = 'Test Body';

        Test.startTest();       
        // Call the method being tested
        
            HDT_EmailService_Utils.respuestaTrasladoColaborador(email, caso.Id, 'test@test.com');        


        
        Test.stopTest();

        // Verify the expected changes to the Case record
        caso = [SELECT Id, Status, CC_Fecha_Ultima_Interaccion__c, CC_Ultima_Interaccion__c FROM Case WHERE Id = :caso.Id];
        System.assertNotEquals('Pendiente Colaborador', caso.Status);
        System.assertEquals(System.now().date(), caso.CC_Fecha_Ultima_Interaccion__c.date());
        System.assertEquals('Respuesta de colaborador', caso.CC_Ultima_Interaccion__c);
        
        }
    }


    @isTest
    static void testRespuestaSolicitudInfo() {
       
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();

        // Crear contacto y caso de prueba
        Contact contact = new Contact(LastName = 'Doe', Email = 'johndoe@example.com');
        insert contact;

        Case caso = new Case(RecordTypeId = rtCaso, Subject = 'Test Subject', CC_Idioma__c = 'ca' , ContactId = contact.Id, Status = 'Pendiente Cliente', CC_Ultima_Interaccion__c = 'Respuesta de solicitud de información');
        insert caso;
        
        /*
        Case caso2 = new Case(RecordTypeId = rtCaso, Subject = 'Test Subject', CC_Idioma__c = 'en' , ContactId = contact.Id, Status = 'Cerrado', CC_Ultima_Interaccion__c = 'Respuesta de solicitud de información');
        insert caso2;
        
        Case caso3 = new Case(RecordTypeId = rtCaso, Subject = 'Test Subject', CC_Idioma__c = 'es' , ContactId = contact.Id, Status = 'Cerrado', CC_Ultima_Interaccion__c = 'Respuesta de solicitud de información');
        insert caso3;*/

        // Crear email de prueba
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Test Subject';
        email.plainTextBody = 'Test plain text body';
        email.fromAddress = 'johndoe@example.com';
        //email.toAddress = 'test@test.com';

       

        Test.startTest(); 
        // Llamar al método respuestaSolicitudInfo
            HDT_EmailService_Utils.respuestaSolicitudInfo(email, caso.Id, 'Test plain text body', 'test@test.com');
            //HDT_EmailService_Utils.respuestaSolicitudInfo(email, caso2.Id, 'Test plain text body', 'test@test.com');
            HDT_EmailService_Utils.envioCorreoNoReaperturaCaso(caso);
            //HDT_EmailService_Utils.envioCorreoNoReaperturaCaso(caso2);
            //HDT_EmailService_Utils.envioCorreoNoReaperturaCaso(caso3);

        Test.stopTest();

        // Recuperar caso actualizado
        caso = [SELECT Id, CC_Ultima_Interaccion__c, Status, ContactId, CC_Autoasignado_Coordinador__c, CC_Cola_Procedencia__c, CC_Situacion_Caso__c FROM Case WHERE Id = :caso.Id];

        // Comprobar que el caso se actualizó correctamente
        System.assertEquals('Activo', caso.Status);
        System.assertEquals('Respuesta de solicitud de información', caso.CC_Ultima_Interaccion__c);
        System.assertEquals('Respuesta cliente', caso.CC_Situacion_Caso__c);
        }
    }

    @isTest
    static void testRespuestaGenerica_caso1() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

         // Crear contacto y caso de prueba
         Contact contact = new Contact(LastName = 'Doe', Email = 'johndoe@example.com');
         insert contact;
 
         Case caso = new Case(Subject = 'Test Subject', CC_Idioma__c = 'ca' , ContactId = contact.Id, Status = 'Cerrado', CC_Ultima_Interaccion__c = 'Respuesta de solicitud de información');
         insert caso;

         Case caso2 = new Case(Subject = 'Test Subject', CC_Idioma__c = 'ca' , ContactId = contact.Id, Status = 'Pendiente Colaborador', CC_Ultima_Interaccion__c = 'Respuesta de solicitud de información');
         insert caso2;
        
         Task tarea = new Task(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task'),
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
        
        Test.startTest(); 
            HDT_EmailService_Utils.respuestaGenerica(email, caso.Id, email.fromAddress, tarea);
            HDT_EmailService_Utils.respuestaGenerica(email, caso2.Id, email.fromAddress, tarea);
        Test.stopTest();

        // Verifica que el caso se haya reabierto si cumplía con las condiciones para la reapertura
        System.assertEquals('Activo', [SELECT Status FROM Case WHERE Id = :caso.Id].Status, 'El caso no se ha reabierto correctamente');

        // Verifica que las actividades relacionadas con el caso se hayan cerrado correctamente
        System.assertEquals(0, [SELECT COUNT() FROM Task WHERE WhatId = :tarea.Id AND IsClosed = false], 'Existen actividades abiertas relacionadas con el caso');
        
        }
    }

    @isTest static void testCrearContentDocumentLink() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Case caso = new Case();
            caso.RecordTypeId = recordTypeCaso;
            caso.Subject = 'Caso temporal';
            caso.Status = 'New';
            caso.CC_Referencia_Correo_Saliente__c = '#@1234567890#';
            insert caso;

            Task actividadCorreo = new Task();
            actividadCorreo.Type = 'Traslado Colaborador';
            actividadCorreo.WhatId = caso.Id;
            actividadCorreo.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            actividadCorreo.CC_Referencia_Correo_Saliente__c = '1234567890';
            insert actividadCorreo;

            Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
           
            CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
            grupoColab.Name = 'Grupo Colaborador Temporal';
            grupoColab.RecordTypeId = recordTypeGrupoColaborador;
            grupoColab.CC_External__c = 'GC-00001';
            insert grupoColab;


        /*
        List <String> owaEmails = new List<String>{('Atención Empleados Contact Center IT Grupo CaixaBank')};
        List <OrgWideEmailAddress> owa = new List <OrgWideEmailAddress>([SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName IN : owaEmails]);
        String direccionEmail = owa[0].Address;


        // Crear un mensaje de correo electrónico de prueba
        EmailMessage emailTest = new EmailMessage(
            Subject = 'Correo de Prueba',
            FromAddress = direccionEmail,
            Status = '0', // Estado que represente un correo enviado
            ToAddress = 'test@example.com',
            RelatedToId = casoTest.Id
        );
        insert emailTest;*/

        EmailMessage emailTest = new EmailMessage();
        emailTest.Subject = 'Prueba de envío de correo';
        emailTest.ActivityId = actividadCorreo.Id;
        emailTest.Status = '0';
        emailTest.CC_Grupo_Colab__c = grupoColab.Name;
        emailTest.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'HDT_Buzon'].CC_Direccion_Correo__c;
        emailTest.ToAddress = 'prueba@ibm.com';
        emailTest.Incoming = false;
        emailTest.ParentId = caso.Id;
        emailTest.RelatedToId = caso.Id;
        insert emailTest;

        // Crear una versión de contenido de prueba
        ContentVersion cvTest = new ContentVersion(
            Title = 'Documento de Prueba',
            PathOnClient = 'TestDocument.txt',
            VersionData = Blob.valueOf('Contenido de prueba'),
            IsMajorVersion = true
        );
        insert cvTest;

        // Recuperar el ID de ContentVersion insertado
        Id cvId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Documento de Prueba'].Id;

        // Llamar al método a probar
        Set<Id> listaContentVersionId = new Set<Id>{cvId};
        HDT_EmailService_Utils.crearContentDocumentLink(listaContentVersionId, emailTest, caso);

        
        // Verificar resultados
        List <ContentDocumentLink> links = [Select id, ShareType from ContentDocumentLink where LinkedEntityId = :caso.Id limit 1]; 
        System.assertEquals(1, links.size(), 'Debería haber dos enlaces de documentos de contenido creados.');
        }
    }

}