@isTest
public class TMS_EmailService_Test {
    
    @TestSetup
    public static void crearDatosPrueba() {
        

        User admin = TMS_Usuarios.usuarioAdmin();
        User adminTMS = TMS_Usuarios.usuarioAdminTMS();
		System.runAs(admin) {
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
            
            EmailTemplate template1 = new EmailTemplate();
            template1.FolderId = admin.Id;
            template1.Name = 'Plantilla TMS';
            template1.Subject = 'esto es una prueba';
            template1.HtmlValue = 'Test';
            template1.DeveloperName = 'TMS_Plantilla_Prueba';
            template1.TemplateType = 'Text';
            insert template1;
    
            List<Case> lstCasos = new List<Case>();
            Id recordTypeCasoTMS = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('TMS_Expediente').getRecordTypeId();
    
            Case caso = new Case();
            caso.Subject = 'Caso de prueba TMS';
            caso.recordtypeId= recordTypeCasoTMS;
            caso.Origin = 'SAC_Manual';
            caso.Status = 'TMS_001';
            caso.CC_Canal_Procedencia__c = 'Testamentarias';
            caso.CC_Buzon_Salida__c = [SELECT TMS_Correo__c FROM TMS_Correo__mdt LIMIT 1].TMS_Correo__c;
            caso.TMS_Numexp__c='87458569878';
            caso.SuppliedEmail='test2@test.com';
            caso.OwnerId= adminTMS.Id;
            insert caso;
            
            
        }

        
    }

    @isTest
    public static void testCorreo1(){

        List<EmailServicesAddress> emailServiceAddress = [SELECT Id, LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName = 'TMS_EmailService'];
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'TMS_%' LIMIT 1];
        String direccionBuzonTMS = emailServiceAddress[0].LocalPart + '@' + emailServiceAddress[0].EmailDomainName;

        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
		header.value = direccionBuzonTMS;        
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'CGE_BUSTIA@FAKE.COM';
        envelope.toAddress = 'direccionBuzonTMS@test.com';
        correo.subject = 'asunto';
        correo.fromAddress = 'CGE_BUSTIA@FAKE.COM';
        correo.plainTextBody = 'email body\n2225256325\nTitle Por favor, mantenga las siguientes referencias al responder a este correo electrónico: #@20240371164838#.';
        correo.toAddresses =  new List<String>{'bluewolf.tms.test@test.com'};
        correo.headers = new List<Messaging.InboundEmail.Header>{header};

        User superv = [SELECT Id FROM User WHERE Alias = 'AdminTMS'];
        System.runAs(superv){
            Test.startTest();
            TMS_EmailService emailServiceTMS = new TMS_EmailService();
            emailServiceTMS.handleInboundEmail(correo, envelope);  
            Test.stopTest();

            System.assertEquals('asunto', correo.subject, 'Comprobamos el asunto.');
        }
        
        
    }

    @isTest
    public static void testCorreo2(){
        
        Case casoTMS = [SELECT Id, CC_Buzon_Salida__c FROM Case WHERE CC_Canal_Procedencia__c = 'Testamentarias' LIMIT 1];

        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();

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
        
        List<EmailServicesAddress> emailServiceAddress = [SELECT Id, LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName = 'TMS_EmailService'];
        String direccionBuzonTMS = emailServiceAddress[0].LocalPart + '@' + emailServiceAddress[0].EmailDomainName;

        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
		header.value = direccionBuzonTMS;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'CGE_BUSTIA@FAKE.COM';
        envelope.toAddress = 'direccionBuzonTMS@test.com';
        correo.subject = 'asunto';
        correo.fromAddress = 'CGE_BUSTIA@FAKE.COM';
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        correo.plainTextBody = 'email body\n2225256325\nTitle Por favor, mantenga las siguientes referencias al responder a este correo electrónico: #@20240371164838#.';
        correo.toAddresses =  new List<String>{'bluewolf.devcam.test@gmail.com'};
        correo.headers = new List<Messaging.InboundEmail.Header>{header};
            
        Task tarea = new Task();
        tarea.CC_Referencia_Correo_Saliente__c = '20240371164838';
        tarea.WhatId= casoTMS.Id;
        tarea.RecordTypeId=Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('TMS_Tarea').getRecordTypeId();
        tarea.Type='Envio correo';
        tarea.Status='Pendiente';
        insert tarea;

        User superv = [SELECT Id FROM User WHERE Alias = 'AdminTMS'];
        System.runAs(superv){
                Test.startTest();
                TMS_EmailService emailServiceTMS = new TMS_EmailService();
    			emailServiceTMS.handleInboundEmail(correo, envelope);  
                Test.stopTest();
                List<EmailMessage> mensaje = [SELECT Id FROM EmailMessage WHERE ParentId = :casoTMS.Id ];
                System.AssertNotEquals(0, mensaje.size());
                
            } 
        
        
    }
    @isTest
    public static void testCorreo3(){
        
        Case casoTMS = [SELECT Id, CC_Buzon_Salida__c FROM Case WHERE CC_Canal_Procedencia__c = 'Testamentarias' LIMIT 1];

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
        
        List<EmailServicesAddress> emailServiceAddress = [SELECT Id, LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName = 'TMS_EmailService'];
        String direccionBuzonTMS = emailServiceAddress[0].LocalPart + '@' + emailServiceAddress[0].EmailDomainName;

        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
		header.value = direccionBuzonTMS;        
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'CGE_BUSTIA@FAKE.COM';
        envelope.toAddress = 'direccionBuzonTMS@test.com';
        correo.subject = 'asunto';
        correo.fromAddress = 'CGE_BUSTIA@FAKE.COM';
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        correo.textAttachments = new List<Messaging.InboundEmail.TextAttachment>{adjuntoTexto};
        correo.plainTextBody = 'email body\n2225256325\nTitle Por favor, mantenga las siguientes referencias al responder a este correo electrónico: #@20240371164838#.';
        correo.toAddresses =  new List<String>{'bluewolf.devcam.test@gmail.com'};
            
        Task tarea = new Task();
        tarea.CC_Referencia_Correo_Saliente__c = '20240371164838';
        tarea.WhatId= casoTMS.Id;
        tarea.RecordTypeId=Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('TMS_Tarea').getRecordTypeId();
        tarea.Type='Actividad manual';
        insert tarea;

        User superv = [SELECT Id FROM User WHERE Alias = 'AdminTMS'];
        System.runAs(superv){
                Test.startTest();
                TMS_EmailService emailServiceTMS = new TMS_EmailService();
    			emailServiceTMS.handleInboundEmail(correo, envelope);  
                Test.stopTest();
                List<EmailMessage> mensaje = [SELECT Id FROM EmailMessage WHERE ParentId = :casoTMS.Id ];
                System.AssertNotEquals(0, mensaje.size());
                
            } 
        
        
    }
}