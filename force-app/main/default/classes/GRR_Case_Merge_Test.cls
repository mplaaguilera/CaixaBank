@isTest
public with sharing class GRR_Case_Merge_Test {
    
    private static void crearCaso() {
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
        CC_Grupo_Colaborador__c	grupocolaborador = new CC_Grupo_Colaborador__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_CentroCaixaBank'),
            Name = 'Servicio GRR',
            OS_Negocio__c = 'CC'
        );
        insert grupocolaborador;
        List<Case> lstCasos = new List<Case>();
        Case caso = new Case ();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente');
        caso.Subject = 'Caso de prueba mcc';
        caso.Origin = 'Email';
        caso.Status = 'Activo';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        lstCasos.add(caso);
        Case caso2 = new Case ();
        caso2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente');
        caso2.Subject = 'Caso de prueba mcc 2';
        caso2.Origin = 'Email';
        caso2.Status = 'Activo';
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;
        lstCasos.add(caso2);
        insert lstCasos;
    }
    
    @isTest
    public static void testCrearCaso() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();

            crearCaso();
            Messaging.InboundEmail email = new Messaging.InboundEmail();
            email.subject = 'Create Contact';
            email.fromAddress = 'someaddress@email.com';
            email.plainTextBody = 'email body\n2225256325\nTitle';
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
            
            List<Case> casoGRR = [SELECT Id, ContactId FROM Case];
            GRR_EmailMessage.crearEmailMessage(email, 'toaddress@email.com', casoGRR[0].Id, casoGRR[0].ContactId, 'Cuerpo del correo');
            GRR_Carga__c carga = new GRR_Carga__c();
            carga.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_Carga__c', 'GRR_Carga');
            carga.GRR_NombreDelFichero__c = 'Carga prueba';
            carga.GRR_TipoDeFichero__c = 'Acta de comité';
            insert carga;
            GRR_RegistroCarga__c registroCarga = new GRR_RegistroCarga__c();
            registroCarga.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_RegistroCarga__c', 'GRR_Recobro');
            registroCarga.GRR_Fichero__c = carga.Id;
            registroCarga.GRR_Caso__c = casoGRR[0].Id;
            insert registroCarga;
            Account cuenta = new Account();
            cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'GRR_NoCliente_PA');
            cuenta.LastName = 'Cliente GRR';
            insert cuenta;
            GRR_Participante__c participante = new GRR_Participante__c();
            participante.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_Participante__c', 'GRR_Participante');
            participante.GRR_Cliente_Participante__c = cuenta.Id;
            participante.GRR_Case_Participante__c = casoGRR[0].Id;
            insert participante;
            Task tarea = new Task();
            tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            tarea.WhatId = casoGRR[0].Id;
            tarea.WhoId = casoGRR[0].ContactId;
            tarea.Status = 'Completed';
            tarea.Type = 'Traslado Colaborador';
            tarea.Subject = 'Test Subject';
            tarea.ActivityDate = System.today();
            tarea.CC_Referencia_Correo_Saliente__c = 'n2225256325';
            insert tarea;
            
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S';
            contentVersion.PathOnClient = 'Test';
            contentVersion.Origin = 'H';
            contentVersion.Title = 'Test';
            contentVersion.VersionData = Blob.valueOf('Test Content');
            insert contentVersion;
            ContentVersion cVers = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
            ContentDocumentLink cdl1 = new ContentDocumentLink(
                LinkedEntityId = casoGRR[0].Id,
                ContentDocumentId = cVers.ContentDocumentId,
                ShareType = 'V'
            );
            insert cdl1;
    
            String error = GRR_Case_Merge.fusionarCaso(casoGRR[0].Id, casoGRR[1].Id);
            System.assertEquals('Ok', error);    

            Test.stopTest();
        }
    }

}