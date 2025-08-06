@isTest
public with sharing class OS_CorreosElectronicos_Controller_Test {

    @TestSetup
    static void makeData(){
        User usuarioOperador = OS_Usuarios.usuarioOperador();

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'account temp';
        insert cuenta;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;
                
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        insert contacto; 
    }
    
    @isTest
    public static void recuperarCampos() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;       

        List<BusinessHours> bhs = [select id from BusinessHours where IsDefault=true];
        
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (COPS)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica.CC_Codigo_Externo__c = 'TEC-000001';
		//mccTematica.OS_Buzon_Salida__c = [SELECT DISPLAYNAME FROM OrgWideEmailAddress WHERE DISPLAYNAME LIKE 'Buzón %' LIMIT 1].DISPLAYNAME;
        mccTematica.OS_Buzon_Salida__c = 'Buzón UAFE';
        mccTematica.OS_Departamento__c = 'UAC';
        mccTematica.OS_Horario__c = bhs.get(0).Id;
        insert mccTematica;
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (COPS)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccProducto.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PRC-000001'; 
        insert mccProducto; 
        
        CC_MCC__c motivo = new CC_MCC__c();
        motivo.Name = 'Apertura sin autorización';
        motivo.CC_Tipo_Cliente__c = 'Cliente (COPS)';
        motivo.CC_Fecha_Vigencia_Inicio__c = Date.today();
        motivo.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tematica__c = mccTematica.Id;
        motivo.CC_Producto_Servicio__c = mccProducto.Id;
        motivo.CC_Codigo_Externo__c = 'MOC-000001';
        insert motivo;
      
        Account cuenta = [SELECT Id FROM Account WHERE Name = 'account temp'];
        Contact contacto = [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id AND CC_NumPerso__c = '12345569'];

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        caso.Subject = 'Caso listview Correos electronicos';
        caso.Origin = 'Email';
        caso.Status = 'Activo';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.CC_Idioma__c = 'es';
        caso.CC_Detalles_Consulta__c = 'Detalles consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles solución';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = motivo.Id;
        caso.CC_Canal_Procedencia__c = 'Buzón International Operations';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso;
        
        //Actividades correo
        List<Task> listaActividades = new List<Task>();
        Task actividadCorreo1 = new Task();

        Id taskOSTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('OS_Task').getRecordTypeId();

        actividadCorreo1.RecordTypeId = taskOSTaskRecordTypeId;
        actividadCorreo1.Type = 'Traslado Colaborador';
        actividadCorreo1.WhatId = caso.Id;
        actividadCorreo1.CC_Referencia_Correo_Saliente__c = '1234567890';
        listaActividades.add(actividadCorreo1);
        
        Task actividadCorreo2 = new Task();
        actividadCorreo2.RecordTypeId = taskOSTaskRecordTypeId;
        actividadCorreo2.Type = 'Traslado Colaborador';
        actividadCorreo2.WhatId = caso.Id;
        actividadCorreo2.CC_Referencia_Correo_Saliente__c = '1234567890';
        listaActividades.add(actividadCorreo2);
        insert listaActividades;
        
        String fromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'OS_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

        List<EmailMessage> listaCorreos = new List<EmailMessage>();
        EmailMessage correo1 = new EmailMessage();
        correo1.Subject = 'Prueba de correo 1';
        correo1.status = '3'; // email was sent 
        correo1.ActivityId = listaActividades[0].Id;
        correo1.CC_Grupo_Colab__c = 'Grupo';
        correo1.CC_Procedencia__c = 'Traslado Colaborador';
        correo1.FromAddress = fromAddress;
        correo1.ToAddress = 'prueba@ibm.com';
        correo1.Incoming = false;
        correo1.ParentId = caso.Id;
        correo1.RelatedToId = caso.Id;
        
        List<String> cuerpoCorreo1 = new List<String>();
        cuerpoCorreo1.add('<html>');
        cuerpoCorreo1.add('Cuerpo del correo');
        cuerpoCorreo1.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpoCorreo1.add('</html>');
        correo1.HtmlBody = String.join(cuerpoCorreo1, '<br/>');
        listaCorreos.add(correo1);
         
        EmailMessage correo2 = new EmailMessage();
        correo2.Subject = 'Prueba de correo 2';
        correo2.status = '2'; 
        correo2.ActivityId = listaActividades[1].Id;
        correo2.CC_Grupo_Colab__c = 'Grupo';
        correo2.CC_Procedencia__c = 'Traslado Colaborador';
        correo2.FromAddress = fromAddress;
        correo2.ToAddress = 'prueba@ibm.com';
        correo2.Incoming = true;
        correo2.ParentId = caso.Id;
        correo2.RelatedToId = caso.Id;
        correo2.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        
        List<String> cuerpoCorreo2 = new List<String>();
        cuerpoCorreo2.add('<html>');
        cuerpoCorreo2.add('Cuerpo del correo');
        cuerpoCorreo2.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpoCorreo2.add('</html>');
        correo2.HtmlBody = String.join(cuerpoCorreo2, '<br/>');
        //listaCorreos.add(correo2);
               
        
        insert listaCorreos;
        
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');

        ContentVersion cv = new ContentVersion();
        cv.title = 'test content pdf';
        cv.PathOnClient = 'Test_Pdf.pdf';
        cv.VersionData = beforeblob;
        insert cv;
        
        ContentVersion testContent = [SELECT Id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];

        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentlink.LinkedEntityId = correo1.Id;
        contentlink.ShareType = 'V';
        contentlink.ContentDocumentId = testcontent.ContentDocumentId;
        insert contentLink;
              
        System.runAs (usuarioOperador) {                
            Test.startTest();
            List<OS_CorreosElectronicos_Controller.CorreoElectronico> correosElectronicos = OS_CorreosElectronicos_Controller.recuperarCampos(caso.Id, 'fecha', 'desc');
            List<OS_CorreosElectronicos_Controller.CorreoElectronico> correosElectronicos2 = OS_CorreosElectronicos_Controller.recuperarCampos(caso.Id, 'estado', 'desc');
            List<OS_CorreosElectronicos_Controller.CorreoElectronico> correosElectronicos3 = OS_CorreosElectronicos_Controller.recuperarCampos(caso.Id, 'de', 'desc');
            List<OS_CorreosElectronicos_Controller.CorreoElectronico> correosElectronicos5 = OS_CorreosElectronicos_Controller.recuperarCampos(caso.Id, 'nameUrl', 'desc');
            List<OS_CorreosElectronicos_Controller.CorreoElectronico> correosElectronicos7 = OS_CorreosElectronicos_Controller.recuperarCampos(caso.Id, 'HasAttachment', 'desc');
            Test.stopTest();

            System.assertEquals(1, correosElectronicos.size());
            System.assertEquals('Prueba de correo 1',correosElectronicos5[0].asunto);
        }
    }
}