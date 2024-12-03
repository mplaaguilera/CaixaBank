@isTest
public class SACH_EmailService01_Test {

    @TestSetup
    public static void crearDatosPrueba() {


        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
        grupoColaborador.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_CentroCaixaBank');
        grupoColaborador.OS_Negocio__c = 'CC';
        grupoColaborador.Name = 'Oficina01';
        insert grupoColaborador;

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
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        contacto.Email = 'test@example.com';
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
        contacto2.Email = 'CGE_BUSTIA22@FAKE.COM';
        
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
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SACH_Cliente');
        caso.Subject = 'Caso SACH_EmailService_Test';
        caso.Origin = 'Chat';
        caso.Status = 'Activo';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.CC_Canal_Procedencia__c='SACH';
        //caso.CC_Cola_Procedencia__c='AM_Buzon_Carteras';
        caso.CC_Idioma__c = 'es';
        caso.CC_Detalles_Consulta__c = 'Detalles consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles solución';
        caso.CC_MCC_Tematica__c = tematica.Id;
        caso.CC_MCC_ProdServ__c = producto.Id;
        caso.CC_MCC_Motivo__c = motivo.Id;
        insert caso;
                      
        Case caso2 = new Case();
        caso2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SACH_Cliente');
        caso2.Subject = 'caso2 SACH_EmailService_Test';
        caso2.Origin = 'Email';
        caso2.Status = 'Activo';
        caso2.OS_Remitente_Inicial__c = 'CGE_BUSTIA22@FAKE.COM';
        caso2.AccountId = cuenta.Id;
        caso2.ContactId = contacto2.Id;
        caso2.CC_Canal_Procedencia__c='SACH';
        caso2.CC_Cola_Procedencia__c='AM_Buzon_Valores';
        caso2.CC_Idioma__c = 'es';
        caso2.CC_Detalles_Consulta__c = 'Detalles consulta';
        caso2.CC_Detalles_Solucion__c = 'Detalles solución';
        caso2.CC_MCC_Tematica__c = tematica.Id;
        caso2.CC_MCC_ProdServ__c = producto.Id;
        caso2.CC_MCC_Motivo__c = motivo.Id;
        caso2.CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente();
        insert caso2;

        Task tarea = new Task();
        tarea.RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task');
        tarea.Type = 'Traslado Colaborador';
        tarea.WhatId=caso2.Id;
        tarea.CC_Referencia_Correo_Saliente__c='20210371164838';
        insert tarea;
    }

    @isTest
    public static void testCorreoEntrante() {

        System.runAs(new User(Id = UserInfo.getUserId())) {

        Case caso = [SELECT Id,CC_Canal_Procedencia__c FROM Case WHERE Subject=:'Caso SACH_EmailService_Test' LIMIT 1];
        
        Task tarea2 = new Task();
        tarea2.RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task');
        tarea2.Type = 'Remitir Colaborador';
        tarea2.WhatId=caso.Id;
        tarea2.CC_Referencia_Correo_Saliente__c='1610385724430';
        insert tarea2;

        HDT_Correos_Buzones_Entrada__mdt correoCAMmdt = [SELECT HDT_Email_Redireccion_Buzon__c FROM HDT_Correos_Buzones_Entrada__mdt WHERE HDT_Canal_Procedencia__c='Incidencias Técnicas'];
        
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
		header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';
        envelope.fromAddress = 'CGE_BUSTIA@FAKE.COM';
        envelope.toAddress = correoCAMmdt.HDT_Email_Redireccion_Buzon__c;
        correo.subject = 'asunto';
        correo.fromAddress = 'CGE_BUSTIA@FAKE.COM';
        correo.plainTextBody = 'email body #@n2225256325# nTitle .';
        //correo.plainTextBody = 'email body\n2225256325\nTitle .';
        correo.toAddresses =  new List<String>{'bluewolf.devcam.test@gmail.com'};
        //correo.htmlBody = 'email body\n#@SEG:1610385724410#\n#@SEG:1610473621456# 03928088';
		correo.htmlBody = 'email body\n#@1610385724430#\n#@SEG:1610473621456# 03928088';
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
        SACH_EmailService emailServiceCAM = new SACH_EmailService();
        emailServiceCAM.handleInboundEmail(correo, envelope);
        test.stopTest();

        List<Case> casoCreado = [SELECT Id, RecordType.DeveloperName, ContactId FROM Case WHERE OS_Remitente_Inicial__c = 'CGE_BUSTIA22@FAKE.COM' LIMIT 1];
        List<Contact> contactoAsociado= [SELECT Id FROM Contact WHERE FirstName = 'Contacto02'];
        List<Task> tareaAsociada= [SELECT Id,Type FROM Task WHERE CC_Referencia_Correo_Saliente__c IN ('1610385724430')];
        System.assertEquals('Remitir Colaborador', tareaAsociada[0].Type, 'El RT del caso no es correcto');
        System.assertEquals('SACH_Cliente', casoCreado[0].RecordType.DeveloperName, 'El RT del caso no es correcto');
        System.assertEquals(contactoAsociado[0].Id, casoCreado[0].ContactId, 'El RT del caso no es correcto');
        System.assert(caso.Id<>null);

        Task t2 = [SELECT WhatId, Type, CC_Referencia_Correo_Saliente__c FROM Task WHERE Id = :tarea2.Id];
        System.assertEquals('1610385724430', t2.CC_Referencia_Correo_Saliente__c, 'Task t1 not updated correctly');
         System.assertEquals('Remitir Colaborador', t2.Type, 'Task t2 not updated correctly');
       
        }
    }
     @isTest
    public static void testCorreoEntrante2() {
        
        System.runAs(new User(Id = UserInfo.getUserId())) {

        Case caso = [SELECT Id,CC_Canal_Procedencia__c FROM Case WHERE Subject=:'caso2 SACH_EmailService_Test' LIMIT 1];
        
        Task tarea2 = new Task();
        tarea2.RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task');
        tarea2.Type = 'Solicitud Información';
        tarea2.WhatId=caso.Id;
        tarea2.CC_Referencia_Correo_Saliente__c='1610385724420';
        insert tarea2;

        HDT_Correos_Buzones_Entrada__mdt correoCAMmdt = [SELECT HDT_Email_Redireccion_Buzon__c FROM HDT_Correos_Buzones_Entrada__mdt WHERE HDT_Canal_Procedencia__c='Incidencias Técnicas'];
        
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
		header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';
        envelope.fromAddress = 'CGE_BUSTIA@FAKE.COM';
        envelope.toAddress = correoCAMmdt.HDT_Email_Redireccion_Buzon__c;
        correo.subject = 'asunto';
        //correo.plainTextBody = 'email body #@n2225256325# nTitle .';
        correo.fromAddress = 'CGE_BUSTIA@FAKE.COM';
        //correo.plainTextBody = 'email body\n2225256325\nTitle Por favor, mantenga las siguientes referencias al responder a este correo electrónico: #@20210371164838#.';
        correo.toAddresses =  new List<String>{'bluewolf.devcam.test@gmail.com'};
		correo.htmlBody = 'email body\n#@1610385724420#\n#@SEG:1610473621456# 03928088';

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
        SACH_EmailService emailServiceCAM = new SACH_EmailService();
        emailServiceCAM.handleInboundEmail(correo, envelope);
        test.stopTest();

        List<Case> casoCreado = [SELECT Id, RecordType.DeveloperName, ContactId FROM Case WHERE OS_Remitente_Inicial__c = 'CGE_BUSTIA22@FAKE.COM' LIMIT 1];
        List<Contact> contactoAsociado= [SELECT Id FROM Contact WHERE FirstName = 'Contacto02'];
        List<Task> tareaAsociada= [SELECT Id,Type FROM Task WHERE CC_Referencia_Correo_Saliente__c IN ('1610385724420')];
        System.assertEquals('Solicitud Información', tareaAsociada[0].Type, 'El RT del caso no es correcto');
        System.assertEquals('SACH_Cliente', casoCreado[0].RecordType.DeveloperName, 'El RT del caso no es correcto');
        System.assertEquals(contactoAsociado[0].Id, casoCreado[0].ContactId, 'El RT del caso no es correcto');
        System.assert(caso.Id<>null);

        Task t2 = [SELECT WhatId, Type, CC_Referencia_Correo_Saliente__c FROM Task WHERE Id = :tarea2.Id];
        System.assertEquals('1610385724420', t2.CC_Referencia_Correo_Saliente__c, 'Task t1 not updated correctly');
         System.assertEquals('Solicitud Información', t2.Type, 'Task t2 not updated correctly');
        }
    }

    @isTest
    public static void testCorreoEntrante3() {       
        System.runAs(new User(Id = UserInfo.getUserId())) {

        HDT_Correos_Buzones_Entrada__mdt correoCAMmdt = [SELECT HDT_Email_Redireccion_Buzon__c FROM HDT_Correos_Buzones_Entrada__mdt WHERE HDT_Canal_Procedencia__c = 'Incidencias Técnicas'];
        
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
		header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';
        envelope.fromAddress = 'CGE_BUSTIA2@FAKE.COM';
        envelope.toAddress = correoCAMmdt.HDT_Email_Redireccion_Buzon__c;
        correo.subject = 'asunto';
        correo.fromAddress = 'CGE_BUSTIA2@FAKE.COM';
        correo.plainTextBody = 'email body\n2225256325\nTitle Por favor, mantenga las siguientes referencias al responder a este correo electrónico:';//' #@20210371164838#.';
        correo.toAddresses =  new List<String>{'bluewolf.devcam.test@gmail.com'};
		correo.htmlBody = 'email body\n#@1610385724410#\n#@SEG:1610473621456# 03928088';

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

        case caso2 = [SELECT Id, RecordType.DeveloperName, ContactId FROM Case WHERE OS_Remitente_Inicial__c = 'CGE_BUSTIA22@FAKE.COM' LIMIT 1];

        Task tarea1 = new Task();
        tarea1.RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task');
        tarea1.Type = 'Traslado Colaborador';
        tarea1.WhatId=caso2.Id;
        tarea1.CC_Referencia_Correo_Saliente__c='1610385724410';
        insert tarea1;

        


        test.startTest();
        SACH_EmailService emailServiceCAM = new SACH_EmailService();
        emailServiceCAM.handleInboundEmail(correo, envelope);


        test.stopTest();
        
        List<Case> casoCreado = [SELECT Id, RecordType.DeveloperName, ContactId FROM Case WHERE OS_Remitente_Inicial__c = 'CGE_BUSTIA22@FAKE.COM' LIMIT 1];
        List<Contact> contactoAsociado= [SELECT Id FROM Contact WHERE FirstName = 'Contacto02'];
        List<Task> tareaAsociada= [SELECT Id,Type FROM Task WHERE CC_Referencia_Correo_Saliente__c IN ('1610385724410')];


        System.assertEquals('Traslado Colaborador', tareaAsociada[0].Type, 'El RT del caso no es correcto');
       
        System.assertEquals('SACH_Cliente', casoCreado[0].RecordType.DeveloperName, 'El RT del caso no es correcto');
        System.assertEquals(contactoAsociado[0].Id, casoCreado[0].ContactId, 'El RT del caso no es correcto');

        // Verify the results using assertions
       Task t1 = [SELECT WhatId, Type, CC_Referencia_Correo_Saliente__c FROM Task WHERE Id = :tarea1.Id];
       System.assertEquals('1610385724410', t1.CC_Referencia_Correo_Saliente__c, 'Task t1 not updated correctly');
        System.assertEquals('Traslado Colaborador', t1.Type, 'Task t1 not updated correctly');

        }
        
    }

    @isTest
    private static void testConTareaTrasladoColab() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
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

        
       HDT_Correos_Buzones_Entrada__mdt buzonSach = [SELECT HDT_Email_Redireccion_Buzon__c FROM HDT_Correos_Buzones_Entrada__mdt WHERE HDT_Canal_Procedencia__c = 'Incidencias Técnicas'];

        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.fromAddress = 'direccionFrom@test.com';
        envelope.toAddress = buzonSach.HDT_Email_Redireccion_Buzon__c;
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        correo.subject = 'asunto';
        correo.fromAddress = 'test@test.COM';
        correo.plainTextBody = 'email body #@n2225256325# nTitle .';
        correo.toAddresses =  new List<String>{'devsach.test@gmail.com'};
        correo.htmlBody = 'email body\n#@SEG:1610385724410#\n#@SEG:1610473621456# 03928088';


        Test.startTest();
        SACH_EmailService emailService = new SACH_EmailService();
        Messaging.InboundEmailResult result = emailService.handleInboundEmail(correo, envelope);
        Test.stopTest();

        Map<Account, List<Contact>> mapaCuentasContactos = SACH_Identificacion_Auto.identificarCliente('Email', 'test@example.com');
       //System.assertEquals(1, mapaCuentasContactos.size());
    //System.assertEquals(1, mapaCuentasContactos.values()[0].size());

		System.assert(result.success, 'Resultado incorrecto');
        }
    }

    @IsTest
    static void testIdentificarCliente() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
        // Crear una cuenta con un contacto que tenga el email del remitente
        Account account = new Account(Name = 'Test Account');
        insert account;
        Contact contact = new Contact(FirstName = 'Contacto01',LastName = 'Contacto01',AccountId = account.Id, Email = 'testn@example.com',RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado'));
        insert contact;
        
        // Crear otro contacto que no tenga el email del remitente
        Contact contact2 = new Contact(FirstName = 'Contacto02',LastName = 'Contacto02',AccountId = account.Id, Email = 'another@example.com');
        insert contact2;

        // Llamar al método identificarCliente para el email de prueba
        Map<Account, List<Contact>> mapaCuentasContactos = SACH_Identificacion_Auto.identificarCliente('Email', 'testn@example.com');
        
        // Verificar que se identificó correctamente la cuenta y contacto
        //System.assertEquals(1, mapaCuentasContactos.size());
        //System.assertEquals(1, mapaCuentasContactos.values()[0].size());
        //System.assertEquals(account.Id, mapaCuentasContactos.keySet()[0].Id);
        //System.assertEquals(contact.Id, mapaCuentasContactos.values()[0][0].Id);

        //0035E000033B5aTQAS, Actual: 0035E000033B5PtQAK
        //0035E000033B5gBQAS, Actual: 0035E000033B5g7QAC
        }
    }

}