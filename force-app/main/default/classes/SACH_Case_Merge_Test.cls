@isTest
public class SACH_Case_Merge_Test {
    
    @TestSetup
    static void setData() {

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-00000112';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente'; 
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-00000121';
        insert mccProducto;
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today().addDays(7);
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-0000012';
        insert mccMotivo;

        Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        CC_Grupo_Colaborador__c	grupo = new CC_Grupo_Colaborador__c();
        grupo.RecordTypeId = recordTypeGrupoColaborador;
        grupo.name = 'Servicio SACH';
        grupo.OS_Negocio__c = 'CC';
        insert grupo;

        EmailTemplate template1 = new EmailTemplate();
        template1.FolderId = UserInfo.getUserId();
        template1.Name = 'Plantilla SACH';
        template1.Subject = 'esto es una prueba';
        template1.HtmlValue = '';
        template1.DeveloperName = 'SACH_Plantilla_Prueba';
        template1.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert template1;
        }

        List<Case> lstCasos = new List<Case>();
        Id recordTypeCasoCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.Subject = 'Caso de prueba mcc';
        caso.recordtypeId= recordTypeCasoCliente;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'SACH';
        caso.CC_Tipo_Contacto__c = 'Consulta de Cliente';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.Status = 'Activo';
        lstCasos.add(caso);
        
        Case caso2 = new Case();
        caso2.Subject = 'Caso de prueba mcc 2';
        caso2.recordtypeId= recordTypeCasoCliente;
        caso2.Origin = 'Email';
        caso2.CC_Canal_Procedencia__c = 'SACH';
        caso2.CC_Tipo_Contacto__c = 'Consulta de Cliente';
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;
        caso2.Status = 'Activo';
        lstCasos.add(caso2);
        
        insert lstCasos;
    }

    //Test para el método mergeCase
    @isTest
    public static void mergeCaseTest() {
        
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

            
        Date fecha = System.today();
        List<Case> casoSACH = [SELECT Id, ContactId FROM Case WHERE CC_Canal_Procedencia__c = 'SACH'];
		SACH_EmailMessage.crearEmailMessage(email, 'toaddress@email.com', casoSACH[0].Id, casoSACH[0].ContactId, 'Cuerpo del correo');
        
        Id rtTarea = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Task').getRecordTypeId();
        
        Task tarea = new Task();
        tarea.RecordTypeId = rtTarea;
        tarea.WhatId = casoSACH[0].Id;
        tarea.WhoId = casoSACH[0].ContactId;
        tarea.Status = 'Completed';
        tarea.Type = 'Traslado Colaborador';
        tarea.TaskSubtype = 'Email';
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
            LinkedEntityId = casoSACH[0].Id,
            ContentDocumentId = cVers.ContentDocumentId,
            ShareType = 'V'
        );
        insert cdl1;
        
        Test.startTest();

        String error = SACH_Case_Merge.fusionarCaso(casoSACH[0].Id, casoSACH[1].Id);

        Test.stopTest();
        System.assertEquals('Ok', error, 'Hay errores');
    }
}