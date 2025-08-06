@isTest
public with sharing class GRR_EmailService_Utils_Test {

    private static Contact crearContacto() {
        Contact contacto = new Contact (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente'),
            LastName = 'Test',
            CC_Numero_Documento__c = '36592162J'
        );
        insert contacto;
        return contacto;
    }

    private static Case crearCasoConContacto(String idcont) {
        Contact contacto = [SELECT Id FROM Contact WHERE Id = :idcont];
        CC_MCC__c mccTematica = new CC_MCC__c(
            Name = 'MCC Tematica',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'TEGR-000001',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica')
        );
        insert mccTematica;
        CC_MCC__c mccProducto = new CC_MCC__c(
            Name = 'MCC Producto',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio'),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'PRGR-000001',
            CC_Tematica__c = mccTematica.Id
        );
        insert mccProducto;
        CC_MCC__c mccMotivo = new CC_MCC__c(
            Name = 'MCC Motivo',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo'),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'MOGR-000001',
            CC_Producto_Servicio__c = mccProducto.Id
        );
        insert mccMotivo;
        Case caso = new Case (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente'),
            Subject = 'Caso Test',
            ContactId = contacto.Id,
            CC_MCC_Tematica__c = mccTematica.Id,
            CC_MCC_ProdServ__c = mccProducto.Id,
            CC_MCC_Motivo__c = mccMotivo.Id
        );           
        insert caso;
        return caso;
    }

    @isTest
    public static void testReferenciaCorreo() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();

            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            email.subject = 'Create Contact';
            email.fromAddress = 'someaddress@email.com';
            email.plainTextBody = 'email body #@n2225256325# Title';
            Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
            attachment.body = blob.valueOf('my attachment text');
            attachment.fileName = 'textfileone.txt';
            attachment.mimeTypeSubType = 'text/plain';
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
            attachmenttext.body = 'my attachment text';
            attachmenttext.fileName = 'textfiletwo3.txt';
            attachmenttext.mimeTypeSubType = 'texttwo/plain';
            email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
    
            String referencia = GRR_EmailService_Utils.referenciaCorreo(email);
            System.assertEquals('n2225256325', referencia);                

            Test.stopTest();
        }
    }

    @isTest
    public static void testGestionAdjuntos() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();

            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            email.subject = 'Create Contact';
            email.fromAddress = 'someaddress@email.com';
            email.plainTextBody = 'email body #@n2225256325# Title';
            Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
            attachment.body = blob.valueOf('my attachment text');
            attachment.fileName = 'textfileone.txt';
            attachment.mimeTypeSubType = 'text/plain';
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
            attachmenttext.body = 'my attachment text';
            attachmenttext.fileName = 'textfiletwo3.txt';
            attachmenttext.mimeTypeSubType = 'texttwo/plain';
            email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
            
            
            GRR_EmailService_Utils.gestionAdjuntos(email, caso, 'test@test.com');
            ContentDocumentLink contentDocument = [SELECT Id, ShareType FROM ContentDocumentLink WHERE LinkedEntityId = :caso.Id LIMIT 1];
            System.assert(contentDocument.Id != null, 'Content document creado.');
            System.assertEquals('I', contentDocument.ShareType);
            EmailMessage emailGenerado = [SELECT Id FROM EmailMessage WHERE ParentId = :caso.Id LIMIT 1];
            System.assert(emailGenerado.Id != null,'Email generado.');
            Task tarea = [SELECT Id, Type FROM Task WHERE WhatId = :caso.Id LIMIT 1];
            System.assert(tarea.Id != null, 'Tarea creada.');
            System.assertEquals('Correo - Entrada', tarea.Type);
            
            Test.stopTest();
        }
    }

    @isTest
    public static void testRespuestaTrasladoColaborador() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();
            
            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            caso.Status = 'Pendiente Colaborador';
            update caso;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            Messaging.InboundEmail email = new Messaging.InboundEmail();
            email.subject = 'Create Contact';
            email.fromAddress = 'someaddress@email.com';
            email.plainTextBody = 'email body #@n2225256325# Title';
    
            GRR_EmailService_Utils.respuestaTrasladoColaborador(email, caso.Id, 'test@test.com');
            System.assertEquals('Activo', [SELECT Status FROM Case WHERE Id = :caso.Id].Status);    

            Test.stopTest();
        }
    }

    @isTest
    public static void testRespuestaRemitirColaborador() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();
            
            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            caso.CC_No_Identificado__c = true;
            caso.Status = 'Cerrado';
            update caso;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            Messaging.InboundEmail email = new Messaging.InboundEmail();
            email.subject = 'Create Contact';
            email.fromAddress = 'someaddress@email.com';
            email.plainTextBody = 'email body #@n2225256325# Title';
    
            GRR_EmailService_Utils.respuestaRemitirColaborador(email, caso.Id, 'test@test.com');
            System.assertEquals('Activo', [SELECT Status FROM Case WHERE Id = :caso.Id].Status);    

            Test.stopTest();
        }
    }

    @isTest
    public static void testRespuestaResponderCliente() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            caso.CC_No_Identificado__c = true;
            caso.Status = 'Cerrado';
            update caso;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            Messaging.InboundEmail email = new Messaging.InboundEmail();
            email.subject = 'Create Contact';
            email.fromAddress = 'someaddress@email.com';
            email.plainTextBody = 'email body #@n2225256325# Title';

            Test.startTest();
            GRR_EmailService_Utils.respuestaResponderCliente(email, caso.Id, 'test@test.com');
            System.assertEquals('Activo', [SELECT Status FROM Case WHERE Id = :caso.Id].Status);
            
            caso.Status = 'Pendiente Cliente';
            update caso;

            GRR_EmailService_Utils.respuestaResponderCliente(email, caso.Id, 'test@test.com');
            System.assertEquals('Activo', [SELECT Status FROM Case WHERE Id = :caso.Id].Status);
            Test.stopTest();
        }
    }

    @isTest
    public static void testRespuestaSolicitudInfo() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            caso.CC_No_Identificado__c = true;
            caso.Status = 'Cerrado';
            update caso;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            Messaging.InboundEmail email = new Messaging.InboundEmail();
            email.subject = 'Create Contact';
            email.fromAddress = 'someaddress@email.com';
            email.plainTextBody = 'email body #@n2225256325# Title';
    
            Test.startTest();
            GRR_EmailService_Utils.respuestaSolicitudInfo(email, caso.Id, 'test@test.com');
            System.assertEquals('Activo', [SELECT Status FROM Case WHERE Id = :caso.Id].Status);

            caso.Status = 'Pendiente Colaborador';
            update caso;

            GRR_EmailService_Utils.respuestaSolicitudInfo(email, caso.Id, 'test@test.com');
            System.assertEquals('Activo', [SELECT Status FROM Case WHERE Id = :caso.Id].Status);
            Test.stopTest();
        }
    }

    @isTest
    public static void testRespuestaGenerica() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();
            
            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            Task tarea = new Task(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task'),
                WhatId = caso.Id,
                Type = 'Traslado Colaborador',
                Status = 'Pending',
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
    
            GRR_EmailService_Utils.respuestaGenerica(email, caso.Id, 'test@test.com', tarea);
            System.assertEquals('Completed', [SELECT Status FROM Task WHERE Id = :tarea.Id].Status);    

            Test.stopTest();
        }
    }

}