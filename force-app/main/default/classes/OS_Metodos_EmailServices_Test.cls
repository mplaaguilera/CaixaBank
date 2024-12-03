@isTest
public class OS_Metodos_EmailServices_Test {
	@isTest
    public static void respuestaCliente() {
        List<Group> colasTotalesCOPS = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE DeveloperName LIKE 'OS_%'];

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        cuenta.recordtypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        insert cuenta;        
        
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = recordTypeCliente;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert contacto;
        }
        Id cId = contacto.Id;
        
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.Status = 'Pendiente Colaborador';
        oCaso.ContactId = cId;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Canal_Procedencia__c = 'Buzón Servicio Firma';
        oCaso.CC_Tipo_Contacto__c = 'Asesoramiento';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso.CC_Cola_Procedencia__c = 'OS_Servicio_Firma';
        oCaso.RecordTypeId  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        insert oCaso;

        Case oCaso2 = new Case();
        oCaso2.Subject = 'Test Incidencia Prueba2';
        oCaso2.Origin = 'Email';
        oCaso2.Status = 'Pendiente Alerta';
        oCaso2.ContactId = cId;
        oCaso2.CC_NotIncidencia__c = '1';
        oCaso2.CC_MailTelfNotif__c = 'test@test.es';
        oCaso2.CC_CanalNotifCli__c = 'Email';
        oCaso2.CC_Idioma__c = 'es';
        oCaso2.CC_Canal_Procedencia__c = 'Buzón KYC Renewal';
        oCaso2.CC_Tipo_Contacto__c = 'Asesoramiento';
        oCaso2.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso2.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso2.OS_Alerta_Fecha__c = System.now();
        oCaso2.RecordTypeId  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        insert oCaso2;
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.OS_Departamento__c = 'UAC';
        mccTematica.CC_Canal_Operativo__c = 'Sin canal';
        insert mccTematica;
        
        List<BusinessHours> bhs = [select id from BusinessHours where IsDefault=true];
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        mccProducto.OS_Horario__c = bhs.get(0).Id;
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        oCaso.CC_MCC_Tematica__c = mccTematica.Id;
        oCaso.CC_MCC_ProdServ__c = mccProducto.Id;
        oCaso.CC_MCC_Motivo__c = mccMotivo.Id;
        update oCaso;

        oCaso2.CC_MCC_Tematica__c = mccTematica.Id;
        oCaso2.CC_MCC_ProdServ__c = mccProducto.Id;
        oCaso2.CC_MCC_Motivo__c = mccMotivo.Id;
        update oCaso2;
        
        //Actividad de solicitud de información
        Task actividadResponderCliente = new Task();
        actividadResponderCliente.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        actividadResponderCliente.WhatId = oCaso.Id;
        actividadResponderCliente.Type = 'Remitir Colaborador';
        actividadResponderCliente.Subject = 'Remitir Colaborador';
        actividadResponderCliente.Status = 'Completed';
        actividadResponderCliente.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadResponderCliente;

        Task actividadResponderCliente2 = new Task();
        actividadResponderCliente2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        actividadResponderCliente2.WhatId = oCaso2.Id;
        actividadResponderCliente2.Type = 'Remitir Colaborador';
        actividadResponderCliente2.Subject = 'Remitir Colaborador';
        actividadResponderCliente2.Status = 'Completed';
        actividadResponderCliente2.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadResponderCliente2;
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'ac@email.com';
        env.toAddress = 'ac@email.com';
        
        // setup the data for the email
        email.subject = 'Create Contact';
        email.fromAddress = 'ac@email.com';
        email.plainTextBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email.htmlBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

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
        Test.startTest();
        OS_Metodos_EmailServices.respuestaCliente(email, actividadResponderCliente.WhatId,'','', colasTotalesCOPS, oCaso);
        OS_Metodos_EmailServices.respuestaCliente(email2, actividadResponderCliente2.WhatId,'','', colasTotalesCOPS, oCaso2);
        Test.stopTest();
        

        Case updatedCase = [SELECT Id,CC_Ultima_Interaccion__c FROM Case Where Id =: oCaso.Id];
        Case updatedCase2 = [SELECT Id,Status FROM Case Where Id =: oCaso2.Id];

        System.assertEquals('Respuesta de cliente', updatedCase.CC_Ultima_Interaccion__c, 'Comprobamos la última interacción ha sido una respuesta a cliente.');
        System.assertEquals('Activo', updatedCase2.Status, 'Estatus cambiado incorrectamente');        
    }
    @isTest
    public static void respuestaCliente2() {
        List<Group> colasTotalesCOPS = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE DeveloperName LIKE 'OS_%'];

        Account cuenta2 = new Account(); 
        cuenta2.Name = 'Cuenta02';
        cuenta2.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert cuenta2;
        }        
        Id accountId2 = cuenta2.Id;
        
        Id recordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        
        Contact contacto2 = new Contact();
        contacto2.FirstName = 'Contacto';
        contacto2.LastName = '02';
        contacto2.CC_NumPerso__c = '12345569';
        contacto2.AccountId = cuenta2.Id;
        contacto2.CC_Idioma__c = 'Es';
        contacto2.RecordTypeId = recordTypeEmpleado;
        insert contacto2;        
        
        Case oCaso2 = new Case();
        oCaso2.Subject = 'Test Incidencia2';
        oCaso2.Origin = 'Email';
        oCaso2.Status = 'Activo';
        oCaso2.ContactId = contacto2.Id;
        oCaso2.CC_NotIncidencia__c = '1';
        oCaso2.CC_MailTelfNotif__c = 'test@test.es';
        oCaso2.CC_CanalNotifCli__c = 'Email';
        oCaso2.CC_Idioma__c = 'es';
        oCaso2.CC_Canal_Procedencia__c = 'Buzón KYC Renewal';
        oCaso2.CC_Tipo_Contacto__c = 'Asesoramiento';
        oCaso2.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso2.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso2.RecordTypeId  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();
        insert oCaso2;
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();

        CC_MCC__c mccTematica2 = new CC_MCC__c();
		mccTematica2.Name = 'Ahorro a la vista2';
        mccTematica2.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica2.RecordTypeId = recordTypeIdTematica;
        mccTematica2.CC_Codigo_Externo__c = 'TE-000002';
        mccTematica2.CC_Canal_Operativo__c = 'Sin canal';
        insert mccTematica2;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
		CC_MCC__c mccProducto2 = new CC_MCC__c();
        mccProducto2.Name = 'Cuenta corriente2';
        mccProducto2.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto2.RecordTypeId = recordTypeIdProducto;
        mccProducto2.CC_Tematica__c = mccTematica2.Id;
        mccProducto2.CC_Codigo_Externo__c = 'PR-000002'; 
        insert mccProducto2; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo2 = new CC_MCC__c();
        mccMotivo2.Name = 'Apertura sin autorización';
        mccMotivo2.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo2.RecordTypeId = recordTypeIdMotivo;
        mccMotivo2.CC_Tematica__c = mccTematica2.Id;
        mccMotivo2.CC_Producto_Servicio__c = mccProducto2.Id;
        mccMotivo2.CC_Codigo_Externo__c = 'MO-000002';
        insert mccMotivo2;
        
        oCaso2.CC_MCC_Tematica__c = mccTematica2.Id;
        oCaso2.CC_MCC_ProdServ__c = mccProducto2.Id;
        oCaso2.CC_MCC_Motivo__c = mccMotivo2.Id;
        update oCaso2;
        
        //Actividad de solicitud de información
        Task actividadResponderCliente2 = new Task();
        actividadResponderCliente2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        actividadResponderCliente2.WhatId = oCaso2.Id;
        actividadResponderCliente2.Type = 'Remitir Colaborador';
        actividadResponderCliente2.Subject = 'Remitir Colaborador 2';
        actividadResponderCliente2.Status = 'Completed';
        actividadResponderCliente2.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadResponderCliente2;
        
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
        
        Test.startTest();
        OS_Metodos_EmailServices.respuestaCliente(email2, actividadResponderCliente2.WhatId,'','', colasTotalesCOPS, oCaso2);
        Test.stopTest();
        
        
        Case updatedCase = [SELECT Id,CC_Ultima_Interaccion__c FROM Case Where Id =: oCaso2.Id];

        system.assertEquals('Respuesta de cliente', updatedCase.CC_Ultima_Interaccion__c, 'Comprobamos la última interacción ha sido una respuesta a cliente.');
               
    }
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

        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.CC_Idioma__c = 'Es';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert contacto;
        }
        Id cId = contacto.Id;
        
        Test.startTest();
        String referencia = OS_Metodos_EmailServices.referenciaCorreo(email2);
        Test.stopTest();

        System.assertEquals(referencia, 'refRemitir', 'Comprobamos la referencia de remitir.');

            
    }
    @isTest
    public static void respuestaTrasladoColaborador() {
        List<Group> colasTotalesCOPS = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE DeveloperName LIKE 'OS_%'];

        Account cuenta2 = new Account();
        cuenta2.Name = 'Cuenta02';
        cuenta2.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        insert cuenta2;        
        
        Id accountId2 = cuenta2.Id;
        
        Id recordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        
        Contact contacto2 = new Contact();
        contacto2.FirstName = 'Contacto';
        contacto2.LastName = '02';
        contacto2.CC_NumPerso__c = '12345569';
        contacto2.AccountId = cuenta2.Id;
        contacto2.CC_Idioma__c = 'Es';
        contacto2.RecordTypeId = recordTypeEmpleado;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert contacto2;
        }

        Case oCaso2 = new Case();
        oCaso2.Subject = 'Test Incidencia2';
        oCaso2.Origin = 'Email';
        oCaso2.Status = 'Pendiente Colaborador';
        oCaso2.ContactId = contacto2.Id;
        oCaso2.CC_NotIncidencia__c = '1';
        oCaso2.CC_MailTelfNotif__c = 'test@test.es';
        oCaso2.CC_CanalNotifCli__c = 'Email';
        oCaso2.CC_Idioma__c = 'es';
        oCaso2.CC_Canal_Procedencia__c = 'Buzón KYC Renewal';
        oCaso2.CC_Tipo_Contacto__c = 'Asesoramiento';
        oCaso2.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso2.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso2.RecordTypeId  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();
        insert oCaso2;
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();

        CC_MCC__c mccTematica2 = new CC_MCC__c();
		mccTematica2.Name = 'Ahorro a la vista2';
        mccTematica2.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica2.RecordTypeId = recordTypeIdTematica;
        mccTematica2.CC_Codigo_Externo__c = 'TE-000002';
        mccTematica2.CC_Canal_Operativo__c = 'Sin canal';
        insert mccTematica2;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
		CC_MCC__c mccProducto2 = new CC_MCC__c();
        mccProducto2.Name = 'Cuenta corriente2';
        mccProducto2.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto2.RecordTypeId = recordTypeIdProducto;
        mccProducto2.CC_Tematica__c = mccTematica2.Id;
        mccProducto2.CC_Codigo_Externo__c = 'PR-000002'; 
        insert mccProducto2; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo2 = new CC_MCC__c();
        mccMotivo2.Name = 'Apertura sin autorización';
        mccMotivo2.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo2.RecordTypeId = recordTypeIdMotivo;
        mccMotivo2.CC_Tematica__c = mccTematica2.Id;
        mccMotivo2.CC_Producto_Servicio__c = mccProducto2.Id;
        mccMotivo2.CC_Codigo_Externo__c = 'MO-000002';
        insert mccMotivo2;
        
        oCaso2.CC_MCC_Tematica__c = mccTematica2.Id;
        oCaso2.CC_MCC_ProdServ__c = mccProducto2.Id;
        oCaso2.CC_MCC_Motivo__c = mccMotivo2.Id;
        update oCaso2;
        
        //Actividad de solicitud de información
        Task actividadResponderCliente2 = new Task();
        actividadResponderCliente2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        actividadResponderCliente2.WhatId = oCaso2.Id;
        actividadResponderCliente2.Type = 'Remitir Colaborador';
        actividadResponderCliente2.Subject = 'Remitir Colaborador 2';
        actividadResponderCliente2.Status = 'Completed';
        actividadResponderCliente2.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadResponderCliente2;
        
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
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        OS_Metodos_EmailServices.respuestaTrasladoColaborador(email2, actividadResponderCliente2.WhatId,'','', colasTotalesCOPS, oCaso2);
        Test.stopTest();
        }

        ContentDocumentLink cdl = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:oCaso2.Id LIMIT 1];

        System.assertEquals(oCaso2.Id, cdl.LinkedEntityId, 'Comprobamos que el caso tiene un document link asociado.');

       
    }
    
    @isTest
    public static void respuestaRimitirColaborador() {
        List<Group> colasTotalesCOPS = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE DeveloperName LIKE 'OS_%'];

        Account cuenta2 = new Account();
        cuenta2.Name = 'Cuenta02';
        cuenta2.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        insert cuenta2;        
        
        Id accountId2 = cuenta2.Id;
        
        Id recordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        
        Contact contacto2 = new Contact();
        contacto2.FirstName = 'Contacto';
        contacto2.LastName = '02';
        contacto2.CC_NumPerso__c = '12345569';
        contacto2.AccountId = cuenta2.Id;
        contacto2.CC_Idioma__c = 'Es';
        contacto2.RecordTypeId = recordTypeEmpleado;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert contacto2;
        }

        Case oCaso2 = new Case();
        oCaso2.Subject = 'Test Incidencia2';
        oCaso2.Origin = 'Email';
        oCaso2.Status = 'Pendiente Colaborador';
        oCaso2.ContactId = contacto2.Id;
        oCaso2.CC_NotIncidencia__c = '1';
        oCaso2.CC_MailTelfNotif__c = 'test@test.es';
        oCaso2.CC_CanalNotifCli__c = 'Email';
        oCaso2.CC_Idioma__c = 'es';
        oCaso2.CC_Canal_Procedencia__c = 'Buzón Servicio Firma';
        oCaso2.CC_Cola_Procedencia__c = 'OS_Servicio_Firma';
        oCaso2.CC_Tipo_Contacto__c = 'Asesoramiento';
        oCaso2.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso2.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso2.RecordTypeId  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();
        insert oCaso2;
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();

        CC_MCC__c mccTematica2 = new CC_MCC__c();
		mccTematica2.Name = 'Ahorro a la vista2';
        mccTematica2.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica2.RecordTypeId = recordTypeIdTematica;
        mccTematica2.CC_Codigo_Externo__c = 'TE-000002';
        mccTematica2.CC_Canal_Operativo__c = 'Sin canal';
        insert mccTematica2;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
		CC_MCC__c mccProducto2 = new CC_MCC__c();
        mccProducto2.Name = 'Cuenta corriente2';
        mccProducto2.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto2.RecordTypeId = recordTypeIdProducto;
        mccProducto2.CC_Tematica__c = mccTematica2.Id;
        mccProducto2.CC_Codigo_Externo__c = 'PR-000002'; 
        insert mccProducto2; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo2 = new CC_MCC__c();
        mccMotivo2.Name = 'Apertura sin autorización';
        mccMotivo2.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo2.RecordTypeId = recordTypeIdMotivo;
        mccMotivo2.CC_Tematica__c = mccTematica2.Id;
        mccMotivo2.CC_Producto_Servicio__c = mccProducto2.Id;
        mccMotivo2.CC_Codigo_Externo__c = 'MO-000002';
        insert mccMotivo2;
        
        oCaso2.CC_MCC_Tematica__c = mccTematica2.Id;
        oCaso2.CC_MCC_ProdServ__c = mccProducto2.Id;
        oCaso2.CC_MCC_Motivo__c = mccMotivo2.Id;
        update oCaso2;
        
        //Actividad de solicitud de información
        Task actividadResponderCliente2 = new Task();
        actividadResponderCliente2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        actividadResponderCliente2.WhatId = oCaso2.Id;
        actividadResponderCliente2.Type = 'Remitir Colaborador';
        actividadResponderCliente2.Subject = 'Remitir Colaborador 2';
        actividadResponderCliente2.Status = 'Completed';
        actividadResponderCliente2.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadResponderCliente2;
        
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
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        OS_Metodos_EmailServices.respuestaRemitirColaborador(email2, actividadResponderCliente2.WhatId,'','', colasTotalesCOPS, oCaso2);
        Test.stopTest();
        }

        ContentDocumentLink cdl = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:oCaso2.Id LIMIT 1];

        System.assertEquals(oCaso2.Id, cdl.LinkedEntityId, 'Comprobamos que el caso tiene un document link asociado.');
               
    }
    
    @isTest
    public static void solicitudInfoTest() {
        List<Group> colasTotalesCOPS = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE DeveloperName LIKE 'OS_%'];

        Account cuenta2 = new Account();
        cuenta2.Name = 'Cuenta02';
        cuenta2.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        insert cuenta2;        
        
        Id accountId2 = cuenta2.Id;
        
        Id recordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        
        Contact contacto2 = new Contact();
        contacto2.FirstName = 'Contacto';
        contacto2.LastName = '02';
        contacto2.CC_NumPerso__c = '12345569';
        contacto2.AccountId = cuenta2.Id;
        contacto2.CC_Idioma__c = 'Es';
        contacto2.RecordTypeId = recordTypeEmpleado;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert contacto2;
        }

        Case oCaso2 = new Case();
        oCaso2.Subject = 'Test Incidencia2';
        oCaso2.Origin = 'Email';
        oCaso2.Status = 'Pendiente Cliente';
        oCaso2.ContactId = contacto2.Id;
        oCaso2.CC_NotIncidencia__c = '1';
        oCaso2.CC_MailTelfNotif__c = 'test@test.es';
        oCaso2.CC_CanalNotifCli__c = 'Email';
        oCaso2.CC_Idioma__c = 'es';
        oCaso2.CC_Canal_Procedencia__c = 'Buzón Servicio Firma';
        oCaso2.CC_Cola_Procedencia__c = 'OS_Servicio_Firma';
        oCaso2.CC_Tipo_Contacto__c = 'Asesoramiento';
        oCaso2.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso2.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso2.RecordTypeId  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();
        insert oCaso2;
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();

        CC_MCC__c mccTematica2 = new CC_MCC__c();
		mccTematica2.Name = 'Ahorro a la vista2';
        mccTematica2.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica2.RecordTypeId = recordTypeIdTematica;
        mccTematica2.CC_Codigo_Externo__c = 'TE-000002';
        mccTematica2.CC_Canal_Operativo__c = 'Sin canal';
        insert mccTematica2;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
		CC_MCC__c mccProducto2 = new CC_MCC__c();
        mccProducto2.Name = 'Cuenta corriente2';
        mccProducto2.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto2.RecordTypeId = recordTypeIdProducto;
        mccProducto2.CC_Tematica__c = mccTematica2.Id;
        mccProducto2.CC_Codigo_Externo__c = 'PR-000002'; 
        insert mccProducto2; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo2 = new CC_MCC__c();
        mccMotivo2.Name = 'Apertura sin autorización';
        mccMotivo2.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo2.RecordTypeId = recordTypeIdMotivo;
        mccMotivo2.CC_Tematica__c = mccTematica2.Id;
        mccMotivo2.CC_Producto_Servicio__c = mccProducto2.Id;
        mccMotivo2.CC_Codigo_Externo__c = 'MO-000002';
        insert mccMotivo2;
        
        oCaso2.CC_MCC_Tematica__c = mccTematica2.Id;
        oCaso2.CC_MCC_ProdServ__c = mccProducto2.Id;
        oCaso2.CC_MCC_Motivo__c = mccMotivo2.Id;
        update oCaso2;
        
        //Actividad de solicitud de información
        Task actividadResponderCliente2 = new Task();
        actividadResponderCliente2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        actividadResponderCliente2.WhatId = oCaso2.Id;
        actividadResponderCliente2.Type = 'Solicitud Información';
        actividadResponderCliente2.Subject = 'Solicitud Información';
        actividadResponderCliente2.Status = 'Completed';
        actividadResponderCliente2.CC_Referencia_Correo_Saliente__c = 'refSolicitudInfo';
        insert actividadResponderCliente2;
        
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
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        OS_Metodos_EmailServices.respuestaSolicitudInfo(email2, actividadResponderCliente2.WhatId,'','', colasTotalesCOPS, oCaso2); 
        Test.stopTest();
        }

        ContentDocumentLink cdl = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:oCaso2.Id LIMIT 1];

        System.assertEquals(oCaso2.Id, cdl.LinkedEntityId, 'Comprobamos que el caso tiene un document link asociado.');
    }

    @isTest
    public static void testAsignarColaUsuarioInactivo() {
        
        //GRUPO COLABORADOR
        CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
        oGrupo.Name = 'COPS Sucursales';
        oGrupo.OS_GrupoTrabajo__c = 'COPS Sucursales';
        oGrupo.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('OS_GrupoTrabajo').getRecordTypeId();
        insert oGrupo;

        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.Status = 'Activo';
        oCaso.CC_Tipo_Contacto__c = 'Operativa';
        oCaso.CC_Canal_Procedencia__c = 'Buzón KYC Renewal';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.OS_GrupoTrabajo__c = oGrupo.Name;
        oCaso.RecordTypeId  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        insert oCaso;

        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.CC_Idioma__c = 'Es';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert contacto;
        }
        Id cId = contacto.Id;

        Group grupo = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE Type = 'Regular' AND Name = :oCaso.OS_GrupoTrabajo__c LIMIT 1];
        Group grupoCola = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE Type = 'Queue' AND DeveloperName = :grupo.DeveloperName LIMIT 1];
        
        List<Group> gruposCOPS = new List<Group>();
        gruposCOPS.add(grupo);
		gruposCOPS.add(grupoCola);
        // Group colas = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'COPS Sucursales'];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        OS_Metodos_EmailServices.asignarColaUsuarioInactivo(oCaso, '000', gruposCOPS);
        Test.stopTest();
        }
        
        Case oCasoAct = [SELECT OwnerID FROM Case WHERE Id = :oCaso.Id LIMIT 1];

        System.assertEquals(grupoCola.Id, oCasoAct.OwnerId, 'Comprobamos que el propietario de la cola es el grupo asociado.');
    }

    @isTest
    public static void adjuntarEmailAlCaso() {

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        cuenta.recordtypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        insert cuenta;        
        
       
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = recordTypeCliente;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert contacto;
        }
        Id cId = contacto.Id;
        
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.Status = 'Activo';
        oCaso.ContactId = cId;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Canal_Procedencia__c = 'Buzón KYC Renewal';
        oCaso.CC_Tipo_Contacto__c = 'Operativa';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso.RecordTypeId  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        insert oCaso;
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'Sin canal';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        oCaso.CC_MCC_Tematica__c = mccTematica.Id;
        oCaso.CC_MCC_ProdServ__c = mccProducto.Id;
        oCaso.CC_MCC_Motivo__c = mccMotivo.Id;
        update oCaso;
        
        //Actividad de solicitud de información
        Task actividadResponderCliente = new Task();
        actividadResponderCliente.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        actividadResponderCliente.WhatId = oCaso.Id;
        actividadResponderCliente.Type = 'Remitir Colaborador';
        actividadResponderCliente.Subject = 'Remitir Colaborador';
        actividadResponderCliente.Status = 'Completed';
        actividadResponderCliente.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadResponderCliente;
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'ac@email.com';
        env.toAddress = 'ac@email.com';
        
        // setup the data for the email
        email.subject = 'Create Contact';
        email.fromAddress = 'ac@email.com';
        email.plainTextBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        email.htmlBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
        
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
           
		// call the email service class and test it with the data in the testMethod
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        OS_Metodos_EmailServices.adjuntarEmailAlCaso(email, actividadResponderCliente.WhatId,'','', oCaso);
        Test.stopTest();
        }
        ContentDocumentLink cdl = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:oCaso.Id LIMIT 1];

        System.assertEquals(oCaso.Id, cdl.LinkedEntityId, 'Comprobamos que el caso tiene un document link asociado.');
        }

}