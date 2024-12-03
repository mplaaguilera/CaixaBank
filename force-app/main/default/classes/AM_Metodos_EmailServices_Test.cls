@isTest
public class AM_Metodos_EmailServices_Test {
    
    @isTest
    public static void referenciaCorreo() {
     // create a new email and envelope object
        Messaging.InboundEmail email2 = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env2 = new Messaging.InboundEnvelope();
        env2.fromAddress = 'ac@email.com';
        env2.toAddress = 'ac@email.com';
        
        // setup the data for the email
        email2.subject = 'Create Contact';
        email2.fromAddress = 'ac@email.com';
        email2.plainTextBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email2.htmlBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        
        
        AM_Metodos_EmailServices.referenciaCorreo(email2);

            
    }

    @isTest
    public static void respuestaTrasladoColaborador() {
        Account cuenta2 = new Account();
        cuenta2.Name = 'Cuenta02';
        cuenta2.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        insert cuenta2;        
        
        Id accountId2 = cuenta2.Id;
        
        Id RecordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        
        Contact contacto2 = new Contact();
        contacto2.FirstName = 'Contacto';
        contacto2.LastName = '02';
        contacto2.CC_NumPerso__c = '12345569';
        contacto2.AccountId = cuenta2.Id;
        contacto2.CC_Idioma__c = 'Es';
        contacto2.RecordTypeId = RecordTypeEmpleado;
        insert contacto2;        
        
        Case oCaso2 = new Case();
        oCaso2.Subject = 'Test Incidencia2';
        oCaso2.Origin = 'Email';
        oCaso2.Status = 'Pendiente Colaborador';
        oCaso2.ContactId = contacto2.Id;
        oCaso2.CC_NotIncidencia__c = '1';
        oCaso2.CC_MailTelfNotif__c = 'test@test.es';
        oCaso2.CC_CanalNotifCli__c = 'Email';
        oCaso2.CC_Idioma__c = 'es';
        oCaso2.CC_Cola_Procedencia__c = 'AM_Buzon_International_Support';
        oCaso2.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso2.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso2.RecordTypeId  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Empleado').getRecordTypeId();
        insert oCaso2;
        
        //Actividad de Traslado Colaborador
        Task actividadResponderCliente2 = new Task();
        actividadResponderCliente2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task');
        actividadResponderCliente2.WhatId = oCaso2.Id;
        actividadResponderCliente2.Type = 'Traslado Colaborador';
        actividadResponderCliente2.Subject = 'Remitir Colaborador 2';
        actividadResponderCliente2.Status = 'Completed';
        actividadResponderCliente2.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadResponderCliente2;
        
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'AM_%' LIMIT 1];
        String headerValueCAM = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        
        // create a new email and envelope object
        Messaging.InboundEmail email2 = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env2 = new Messaging.InboundEnvelope();
        env2.fromAddress = 'ac@email.com';
        env2.toAddress = 'ac@email.com';
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueCAM;
        header.name = 'X-SFDC-Original-RCPT';
        
        // setup the data for the email
        email2.subject = 'Create Contact';
        email2.fromAddress = 'ac@email.com';
        email2.plainTextBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email2.htmlBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email2.headers = new List<Messaging.InboundEmail.Header>{header};

        
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment2 = new Messaging.InboundEmail.BinaryAttachment();
        attachment2.body = blob.valueOf('my attachment text');
        attachment2.fileName = 'textfileone.txt';
        attachment2.mimeTypeSubType = 'text/plain';
        email2.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment2 };
        
		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment attachmenttext2 = new Messaging.InboundEmail.TextAttachment();
        attachmenttext2.body = 'my attachment text';
        attachmenttext2.fileName = 'textfiletwo3.txt';
        attachmenttext2.mimeTypeSubType = 'texttwo/plain';
        email2.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext2 };
           
		// call the email service class and test it with the data in the testMethod
        AM_Metodos_EmailServices.respuestaTrasladoColaborador(email2, actividadResponderCliente2.WhatId,'','');
               
    }
    
    @isTest
    public static void solicitudInfoTest() {
        Account cuenta2 = new Account();
        cuenta2.Name = 'Cuenta02';
        cuenta2.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        insert cuenta2;        
        
        Id accountId2 = cuenta2.Id;
        
        Id RecordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        
        Contact contacto2 = new Contact();
        contacto2.FirstName = 'Contacto';
        contacto2.LastName = '02';
        contacto2.CC_NumPerso__c = '12345569';
        contacto2.AccountId = cuenta2.Id;
        contacto2.CC_Idioma__c = 'Es';
        contacto2.RecordTypeId = RecordTypeEmpleado;
        insert contacto2;        
        
        Case oCaso2 = new Case();
        oCaso2.Subject = 'Test Incidencia2';
        oCaso2.Origin = 'Email';
        oCaso2.Status = 'Pendiente Cliente';
        oCaso2.ContactId = contacto2.Id;
        oCaso2.CC_NotIncidencia__c = '1';
        oCaso2.CC_MailTelfNotif__c = 'test@test.es';
        oCaso2.CC_CanalNotifCli__c = 'Email';
        oCaso2.CC_Idioma__c = 'es';
        oCaso2.CC_Cola_Procedencia__c = 'AM_Buzon_International_Support';
        oCaso2.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso2.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso2.RecordTypeId  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Empleado').getRecordTypeId();
        insert oCaso2;
        
        
        update oCaso2;
        
        //Actividad de solicitud de información
        Task actividadResponderCliente2 = new Task();
        actividadResponderCliente2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task');
        actividadResponderCliente2.WhatId = oCaso2.Id;
        actividadResponderCliente2.Type = 'Solicitud Información';
        actividadResponderCliente2.Subject = 'Solicitud Información';
        actividadResponderCliente2.Status = 'Completed';
        actividadResponderCliente2.CC_Referencia_Correo_Saliente__c = 'refSolicitudInfo';
        insert actividadResponderCliente2;
        
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'AM_%' LIMIT 1];
        String headerValueCAM = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        
        // create a new email and envelope object
        Messaging.InboundEmail email2 = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env2 = new Messaging.InboundEnvelope();
        env2.fromAddress = 'ac@email.com';
        env2.toAddress = 'ac@email.com';
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueCAM;
        header.name = 'X-SFDC-Original-RCPT';
        
        // setup the data for the email
        email2.subject = 'Create Contact';
        email2.fromAddress = 'ac@email.com';
        email2.plainTextBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email2.htmlBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email2.headers = new List<Messaging.InboundEmail.Header>{header};
        
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment2 = new Messaging.InboundEmail.BinaryAttachment();
        attachment2.body = blob.valueOf('my attachment text');
        attachment2.fileName = 'textfileone.txt';
        attachment2.mimeTypeSubType = 'text/plain';
        email2.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment2 };
        
		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment attachmenttext2 = new Messaging.InboundEmail.TextAttachment();
        attachmenttext2.body = 'my attachment text';
        attachmenttext2.fileName = 'textfiletwo3.txt';
        attachmenttext2.mimeTypeSubType = 'texttwo/plain';
        email2.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext2 };
           
		// call the email service class and test it with the data in the testMethod
        AM_Metodos_EmailServices.respuestaSolicitudInfo(email2, actividadResponderCliente2.WhatId,'','');               
    }
}