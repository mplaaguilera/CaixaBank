@isTest
public class AM_EmailService_Test {

    @TestSetup
    public static void crearDatosPrueba() {

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente'); 
        
        insert cuenta;

        Account cuenta2 = new Account();
        cuenta2.Name = 'Cuenta02';
        cuenta2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank'); 
        
        insert cuenta2;

        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto01';
        contacto.LastName = 'Contacto01';
        contacto.CC_NumPerso__c = '25345561';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'CGE_BUSTIA@FAKE.COM';
        insert contacto;

        Contact contacto3 = new Contact();
        contacto3.FirstName = 'Contacto03';
        contacto3.LastName = 'Contacto03';
        contacto3.CC_NumPerso__c = '25345563';
        contacto3.AccountId = cuenta.Id;
        contacto3.CC_Idioma__c = 'Es';
        contacto3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto3.Email = 'CGE_BUSTIA2@FAKE.COM';
        insert contacto3;

        Contact contacto2 = new Contact();
        contacto2.FirstName = 'Contacto02';
        contacto2.LastName = 'Contacto02';
        contacto2.CC_NumPerso__c = '25345562';
        contacto2.AccountId = cuenta2.Id;
        contacto2.CC_Idioma__c = 'Es';
        contacto2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        contacto2.Email = 'CGE_BUSTIA2@FAKE.COM';
        insert contacto2;
        
        Group grp = new Group();
        grp.Name = 'Buzón Valores';
        insert grp;
        
        CC_MCC__c tematica = new CC_MCC__c();
		tematica.Name = 'tematica cops test';
        tematica.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        tematica.CC_Fecha_Vigencia_Inicio__c = System.now();
        tematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.CC_Codigo_Externo__c = 'TEC-000001';
        insert tematica;

        CC_MCC__c producto = new CC_MCC__c();
        producto.Name = 'producto cops test';
        producto.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        producto.CC_Fecha_Vigencia_Inicio__c = System.now();
        producto.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        producto.CC_Tematica__c = tematica.Id;
        producto.CC_Codigo_Externo__c = 'PRC-000001'; 
        insert producto;
        
        CC_MCC__c motivo = new CC_MCC__c();
        motivo.Name = 'motivo cops test';
        motivo.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        motivo.CC_Fecha_Vigencia_Inicio__c = System.now();
        motivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tematica__c = tematica.Id;
        motivo.CC_Producto_Servicio__c = producto.Id;
        motivo.CC_Codigo_Externo__c = 'MOC-000001';
        insert motivo;

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'AM_Cliente');
        caso.Subject = 'Caso AM_EmailService_Test';
        caso.Origin = 'Email';
        caso.Status = 'Activo';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.CC_Canal_Procedencia__c='Buzón Carteras';
        caso.CC_Cola_Procedencia__c='AM_Buzon_Carteras';
        caso.CC_Idioma__c = 'es';
        caso.CC_Detalles_Consulta__c = 'Detalles consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles solución';
        caso.CC_MCC_Tematica__c = tematica.Id;
        caso.CC_MCC_ProdServ__c = producto.Id;
        caso.CC_MCC_Motivo__c = motivo.Id;
        insert caso;
                      
        Case caso2 = new Case();
        caso2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'AM_Cliente');
        caso2.Subject = 'caso2 AM_EmailService_Test';
        caso2.Origin = 'Email';
        caso2.Status = 'Activo';
        caso2.AccountId = cuenta.Id;
        caso2.ContactId = contacto.Id;
        caso2.CC_Canal_Procedencia__c='Buzón Valores';
        caso2.CC_Cola_Procedencia__c='AM_Buzon_Valores';
        caso2.CC_Idioma__c = 'es';
        caso2.CC_Detalles_Consulta__c = 'Detalles consulta';
        caso2.CC_Detalles_Solucion__c = 'Detalles solución';
        caso2.CC_MCC_Tematica__c = tematica.Id;
        caso2.CC_MCC_ProdServ__c = producto.Id;
        caso2.CC_MCC_Motivo__c = motivo.Id;
        insert caso2;

        Task tarea = new Task();
        tarea.RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task');
        tarea.Type = 'Responder a cliente';
        tarea.WhatId=caso2.Id;
        tarea.CC_Referencia_Correo_Saliente__c='20210371164838';
        insert tarea;

    
    }

    @isTest
    public static void testCorreoEntrante() {
            
        Case caso = [SELECT Id,CC_Canal_Procedencia__c FROM Case WHERE Subject=:'Caso AM_EmailService_Test' LIMIT 1];
        
        AM_Correos_Buzones_Entrada__mdt correoCAMmdt = [SELECT AM_Email_Redireccion_Buzon__c FROM AM_Correos_Buzones_Entrada__mdt WHERE AM_Canal_Procedencia__c=:caso.CC_Canal_Procedencia__c];
        
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
		header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';
        envelope.fromAddress = 'CGE_BUSTIA@FAKE.COM';
        envelope.toAddress = correoCAMmdt.AM_Email_Redireccion_Buzon__c;
        correo.subject = 'asunto';
        correo.fromAddress = 'CGE_BUSTIA@FAKE.COM';
        correo.plainTextBody = 'email body\n2225256325\nTitle .';
        correo.toAddresses =  new List<String>{'bluewolf.devcam.test@gmail.com'};
		
        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
		//Adjunto de texto
		Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

        test.startTest();
        AM_EmailService emailServiceCAM = new AM_EmailService();
        emailServiceCAM.handleInboundEmail(correo, envelope);
        test.stopTest();


       System.assert(caso.Id<>null);
              
    }
     @isTest
    public static void testCorreoEntrante2() {
            
        Case caso = [SELECT Id,CC_Canal_Procedencia__c FROM Case WHERE Subject=:'caso2 AM_EmailService_Test' LIMIT 1];
        
        AM_Correos_Buzones_Entrada__mdt correoCAMmdt = [SELECT AM_Email_Redireccion_Buzon__c FROM AM_Correos_Buzones_Entrada__mdt WHERE AM_Canal_Procedencia__c=:caso.CC_Canal_Procedencia__c];
        
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
		header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';
        envelope.fromAddress = 'CGE_BUSTIA@FAKE.COM';
        envelope.toAddress = correoCAMmdt.AM_Email_Redireccion_Buzon__c;
        correo.subject = 'asunto';
        correo.fromAddress = 'CGE_BUSTIA@FAKE.COM';
        correo.plainTextBody = 'email body\n2225256325\nTitle Por favor, mantenga las siguientes referencias al responder a este correo electrónico: #@20210371164838#.';
        correo.toAddresses =  new List<String>{'bluewolf.devcam.test@gmail.com'};
		
        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
		//Adjunto de texto
		Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

        test.startTest();
        AM_EmailService emailServiceCAM = new AM_EmailService();
        emailServiceCAM.handleInboundEmail(correo, envelope);
        test.stopTest();


       System.assert(caso.Id<>null);
              
    }

    @isTest
    public static void testCorreoEntrante3() {       
        
        AM_Correos_Buzones_Entrada__mdt correoCAMmdt = [SELECT AM_Email_Redireccion_Buzon__c FROM AM_Correos_Buzones_Entrada__mdt WHERE AM_Canal_Procedencia__c = 'Buzón Carteras'];
        
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
		header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';
        envelope.fromAddress = 'CGE_BUSTIA2@FAKE.COM';
        envelope.toAddress = correoCAMmdt.AM_Email_Redireccion_Buzon__c;
        correo.subject = 'asunto';
        correo.fromAddress = 'CGE_BUSTIA2@FAKE.COM';
        correo.plainTextBody = 'email body\n2225256325\nTitle Por favor, mantenga las siguientes referencias al responder a este correo electrónico:';//' #@20210371164838#.';
        correo.toAddresses =  new List<String>{'bluewolf.devcam.test@gmail.com'};
		
        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
		//Adjunto de texto
		Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

        test.startTest();
        AM_EmailService emailServiceCAM = new AM_EmailService();
        emailServiceCAM.handleInboundEmail(correo, envelope);
        test.stopTest();
        
        List<Case> casoCreado = [SELECT Id, RecordType.DeveloperName, ContactId FROM Case WHERE OS_Remitente_Inicial__c = 'CGE_BUSTIA2@FAKE.COM'];
        List<Contact> contactoAsociado= [SELECT Id FROM Contact WHERE FirstName = 'Contacto02'];

        System.assertEquals('AM_Empleado', casoCreado[0].RecordType.DeveloperName, 'El RT del caso no es correcto');
        System.assertEquals(contactoAsociado[0].Id, casoCreado[0].ContactId, 'El RT del caso no es correcto');
              
    }
}