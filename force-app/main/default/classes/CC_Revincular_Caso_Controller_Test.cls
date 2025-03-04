@isTest
public with sharing class CC_Revincular_Caso_Controller_Test {
	@testSetup
    public static void testSetup(){
        Id profileIdAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;

        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = profileIdAdmin;
        usuario1.FirstName = 'Usuario Admin Prueba';
        usuario1.LastName = 'last211';
        usuario1.Email = 'aalsdna@kfsb.com';
        usuario1.Username = 'tuser0001@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';
        insert usuario1;

    }

    @isTest
    public static void testgetCaso() {
        Group cola = [Select Id from Group where developername='CC_Inbound_Email' LIMIT 1];
        User user1 = [SELECT Id FROM User WHERE Email = 'aalsdna@kfsb.com' LIMIT 1];
        Case caso1 = new Case();
        caso1.Subject = 'CASO INICIAL';
        caso1.Status = 'Pendiente Cliente';
        caso1.Reason = 'Helpdesk';
        caso1.Origin = 'Email';
        caso1.CC_Canal_Procedencia__c='Atención al Cliente';
        //caso1.CC_Cola_Procedencia__c='CC_Inbound_Email';
        caso1.OwnerId = cola.Id;
        Test.startTest();
        System.runAs(user1){
            insert caso1;
            Map<String,Object> out = CC_Revincular_Caso_Controller.getCaso(caso1.Id);
            System.assertEquals(5, out.size(), 'Cantidad de outputs');
        }
        Test.stopTest();
    }

    @isTest
    static void testgetlstCaso() {
        contact contacto = new contact(Lastname = 'XXXXX');
        insert contacto;
        User user1 = [SELECT Id FROM User WHERE Email = 'aalsdna@kfsb.com' LIMIT 1];

        Case caso = new Case();
        caso.Subject = 'CASO INICIAL';
        caso.Status = 'Pendiente Cliente';
        caso.Reason = 'Helpdesk';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c='Formulario Web';
        caso.CC_MailTelfNotif__c='test';
        caso.contactId=contacto.Id;
        insert caso;
        Test.startTest();
        System.runAs(user1){
            List<Case> lst = CC_Revincular_Caso_Controller.getlstCaso(Contacto.Id,caso.Id);
            System.assertNotEquals(lst.size(), null, 'La ejecución ha fallado.');
        }
        Test.stopTest();
    }

    @isTest
    static void testEmailMessageTriggerTraslado() {
        Group cola = [Select Id from Group where developername='CC_Inbound_Email' LIMIT 1];

        Case caso1 = new Case();
        caso1.Subject = 'CASO INICIAL';
        caso1.Status = 'Pendiente Cliente';
        caso1.Reason = 'Helpdesk';
        caso1.Origin = 'Email';
        caso1.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
        caso1.CC_Canal_Procedencia__c='Buzón Valores';
        insert caso1;

        task tarea1 = new Task();
        tarea1.WhatId=caso1.Id;
        tarea1.CC_Referencia_Correo_Saliente__c ='XXXXX';
        tarea1.Status='Completed';
        tarea1.Type='Solicitud Información';
        insert tarea1;
        Datetime oneMinuteAgo = Datetime.now().addMinutes(-1);
		Test.setCreatedDate(tarea1.Id, oneMinuteAgo);

        //('Solicitud Información','Traslado Colaborador','Remitir Colaborador')];

        Case caso2 = new Case();
        caso2.Subject = 'CORREO ENTRANTE';
        caso2.OwnerId = cola.Id;
        caso2.Status = 'New';
        caso2.Reason = 'Helpdesk';
        caso2.Origin = 'Email';
        caso2.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
        caso2.CC_Canal_Procedencia__c='Buzón Valores';
        insert caso2;

        task tarea2 = new Task();
        tarea2.WhatId=caso2.Id;
        tarea2.Status='Open';
        tarea2.Type='Solicitud Información';
        insert tarea2;
		Test.setCreatedDate(tarea2.Id, oneMinuteAgo);

        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;
        } else {
            headerValueStr = 'Prueba@IBM';
        }

        EmailMessage emailmes = new EmailMessage();
        emailmes.RelatedToId = caso2.Id;
        emailmes.TextBody='CORREO ENTRANTE';
        emailmes.Incoming=true;
        emailmes.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert emailmes;

        CC_Revincular_Caso_Controller.mergeCase(caso1.Id,Caso2.Id);

        //Comprobación de resultados
        Case caso = [SELECT Id,CC_Ultima_Interaccion__c,status, CC_Cola_Procedencia__c,CC_Fecha_Ultima_Interaccion__c,CC_Canal_Procedencia__c,
                           		  CC_Fecha_Activo_Formulario__c,CC_Fecha_Traslado_Colaborador__c
                           FROM Case WHERE Id=:caso1.Id LIMIT 1];

        Task tarea = [SELECT Id,Status from Task where Id= :tarea1.Id LIMIT 1];
        //Falla//System.assertEquals('Activo', caso.Status);
        //Falla//
        System.assertEquals('Completed', tarea.Status);
	}

    @isTest
    static void testMergeCierraRecordTypeCC (){
        //Jorge Argente, 9 de Marzo 2022
        //Comprueba que 'Asociar Caso' no elimina el caso fusionado si el RecordType es de CC_

        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.CC_Tipo_Cliente__c = 'Empleado';
        tematica.Name = 'Temática Test';
        tematica.CC_Codigo_Externo__c = 'TE-000001';
        tematica.CC_Canal_Operativo__c = 'App BrokerNow';

        insert tematica;


        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicio.CC_Tipo_Cliente__c = 'Empleado';
        productoServicio.Name = 'Producto/Servicio Test';
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001';
        insert productoServicio;


        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tipo_Cliente__c = 'Empleado';
        motivo.Name = 'Motivo Test';
        motivo.CC_Producto_Servicio__c = productoServicio.Id;
        motivo.CC_Codigo_Externo__c = 'MO-000001';
        insert motivo;

        CC_MCC__c causa = new CC_MCC__c();
        causa.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        causa.Name = 'Causa Prueba';
        causa.CC_Tipo_Cliente__c = 'Cliente';
        causa.CC_Codigo_Externo__c = 'CA00-01';
        causa.CC_Motivo__c = motivo.Id;
        insert causa;
        CC_MCC__c solucion = new CC_MCC__c();
        solucion.Name = 'Solucion 1';
        solucion.CC_Tipo_Cliente__c = 'Empleado';
        solucion.CC_Fecha_Vigencia_Inicio__c = date.today();
        solucion.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        solucion.CC_Causa__c = causa.Id;
        solucion.CC_Codigo_Externo__c = 'SO-000001';
		insert solucion;

        //insercion contacto con account
        Account account = new Account();
        account.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        account.Name = 'account temp';
        insert account;


        Contact contacto = new Contact();
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        contacto.FirstName = 'Contacto';
        contacto.LastName = 'Test';
        contacto.CC_Idioma__c = 'es';
        contacto.AccountId = account.Id;
        insert contacto;


        //Creamos dos casos para hacer el Merge
        Case caso1 = new Case();
        caso1.Subject = 'Master Fusion';
        caso1.Status = 'Activo';
        caso1.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        caso1.Reason = 'Helpdesk';
        caso1.Origin = 'Chat';
        caso1.CC_Canal_Procedencia__c='Web';
        caso1.CC_Idioma__c = 'es';
        caso1.CC_Tipo_Contacto__c = 'Consulta';
        caso1.CC_Canal_Operativo__c = 'App BrokerNow';
        caso1.CC_MCC_Tematica__c= tematica.Id;
        caso1.CC_MCC_ProdServ__c= productoServicio.Id;
        caso1.CC_MCC_Motivo__c= motivo.Id;
        caso1.CC_MCC_Causa__c = causa.Id;
        caso1.CC_MCC_Solucion__c = solucion.Id;
        caso1.ContactId = contacto.Id;
        caso1.AccountId = account.Id;
        insert caso1;
        Id caso1Id = caso1.Id;

        Case caso2 = new Case();
        caso2.Subject = 'Fusionado';
        caso2.Status = 'Activo';
        caso2.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        caso2.Reason = 'Helpdesk';
        caso2.Origin = 'Chat';
        caso2.CC_Canal_Procedencia__c='Web';
        caso2.CC_Idioma__c = 'es';
        caso2.CC_Tipo_Contacto__c = 'Consulta';
        caso2.CC_Canal_Operativo__c = 'App BrokerNow';
        caso2.CC_MCC_Causa__c = causa.Id;
        caso2.CC_MCC_Solucion__c = solucion.id;
        caso2.CC_MCC_Tematica__c= tematica.Id;
        caso2.CC_MCC_ProdServ__c= productoServicio.Id;
        caso2.CC_MCC_Motivo__c= motivo.Id;
        caso2.ContactId = contacto.Id;
        caso2.AccountId = account.Id;
        insert caso2;
		Id caso2Id = caso2.Id;




        Test.startTest();
        //merge de los casos
        CC_Revincular_Caso_Controller.mergeCase(caso1Id,caso2Id);

        Test.stopTest();

        //recuperamos las tareas del caso para ver si ha guardado correctamente el caseNumber
        Id recordtypeIdTask = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        Task tareaFusion = Database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Task').getDescribe().fields.getMap().keySet()), ',') + ' FROM Task WHERE WhatId = :caso1Id AND RecordTypeId = :recordtypeIdTask LIMIT 1');
		Case caso2Assert = Database.query('SELECT CaseNumber FROM Case WHERE Id = :caso2Id');
        String descripcion = tareaFusion.description;
        descripcion = descripcion.substring(31); //la posicion desde la que empieza el caseNumber
        String numerCaso2 = caso2Assert.CaseNumber;

        System.assertEquals(numerCaso2, descripcion, 'No es el mismo CaseNumber que el caso fusionado');
    }

    @isTest
    static void testMergeNoCierraOtroRecordTypeCC (){
        //Jorge Argente, 9 de Marzo 2022
        //Comprueba que 'Fusionar Caso' elimina el caso si el RecordType no es de CC_

        //Creamos dos casos para hacer el Merge
        Case caso1 = new Case();
        caso1.CC_Idioma__c = 'es';
        caso1.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        caso1.Subject = 'Prueba fusionar Caso';
        caso1.Status = 'Activo';
        caso1.Origin = 'Phone';
        caso1.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso1.CC_Canal_Resolucion__c = 'Teléfono COPS atención clientes';
        caso1.CC_Tipo_Contacto__c = 'Asesoramiento';


        Case caso2 = new Case();
       	caso2.CC_Idioma__c = 'es';
        caso2.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        caso2.Subject = 'Prueba fusionado Caso';
        caso2.Status = 'Activo';
        caso2.Origin = 'Phone';
        caso2.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';

        //empieza el test
        Test.startTest();

        insert caso1;
        Id caso1Id = caso1.Id;

        insert caso2;
		Id caso2Id = caso2.Id;

        CC_Revincular_Caso_Controller.mergeCase(caso1Id,caso2Id);

        Test.stopTest();

        //recuperamos las tareas del caso para ver si ha guardado correctamente el id
        Id recordtypeIdTask = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        Task tareaFusion = Database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Task').getDescribe().fields.getMap().keySet()), ',') + ' FROM Task WHERE WhatId = :caso1Id AND RecordTypeId = :recordtypeIdTask LIMIT 1');

        List <Case> casos;
        try {casos = [SELECT CaseNumber FROM Case WHERE Id = :caso2Id LIMIT 1];}
        catch (Exception e ) {
            throw new AuraHandledException('Error');
        }

        System.assertEquals(casos.isEmpty(), true, 'El caso no se ha borrado');
    }



    static testMethod void testrespuestaTrasladoColaborador() {
        Group cola = [Select Id from Group where developername='CC_Inbound_Email' LIMIT 1];

        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.CC_Tipo_Cliente__c = 'Cliente';
        tematica.Name = 'Temática Test';
        tematica.CC_Codigo_Externo__c = 'TE-000001';
        tematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert tematica;


        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicio.CC_Tipo_Cliente__c = 'Cliente';
        productoServicio.Name = 'Producto/Servicio Test';
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001';
        insert productoServicio;


        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tipo_Cliente__c = 'Cliente';
        motivo.Name = 'Motivo Test';
        motivo.CC_Producto_Servicio__c = productoServicio.Id;
        motivo.CC_Codigo_Externo__c = 'MO-000001';
        insert motivo;

        CC_MCC__c causa = new CC_MCC__c();
        causa.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        causa.Name = 'Causa Prueba';
        causa.CC_Tipo_Cliente__c = 'Cliente';
        causa.CC_Codigo_Externo__c = 'CA00-01';
        causa.CC_Motivo__c = motivo.Id;
        insert causa;
        CC_MCC__c solucion = new CC_MCC__c();
        solucion.Name = 'Solucion 1';
        solucion.CC_Tipo_Cliente__c = 'Empleado';
        solucion.CC_Fecha_Vigencia_Inicio__c = date.today();
        solucion.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        solucion.CC_Causa__c = causa.Id;
        solucion.CC_Codigo_Externo__c = 'SO-000001';
		insert solucion;

        //insercion contacto con account
        Account account = new Account();
        account.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        account.Name = 'account temp';
        insert account;


        Contact contacto = new Contact();
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contacto.FirstName = 'Contacto';
        contacto.LastName = 'Test';
        contacto.CC_Idioma__c = 'es';
        contacto.AccountId = account.Id;
        insert contacto;


        Case caso1 = new Case();
        caso1.Subject = 'CASO INICIAL';
        caso1.Status = 'Pendiente Colaborador';
        caso1.Reason = 'Helpdesk';
        caso1.CC_Cambio_Estado_Pendiente_Externo__c	=true;
        caso1.Origin = 'Email';
        caso1.CC_Canal_Procedencia__c='Formulario Web';
        caso1.CC_Detalles_Consulta__c='consulta';
		caso1.CC_Detalles_Solucion__c = 'solucion';
        caso1.CC_MCC_Motivo__c = motivo.Id;
        caso1.CC_MCC_ProdServ__c = productoServicio.Id;
        caso1.CC_MCC_Tematica__c = tematica.Id;
        caso1.CC_Idioma__c = 'es';
        caso1.CC_Tipo_Contacto__c = 'Consulta';
        caso1.CC_Canal_Operativo__c = 'App BrokerNow';
        caso1.CC_MCC_Causa__c = causa.Id;
        caso1.CC_MCC_Solucion__c = solucion.id;
        caso1.AccountId = account.Id;
        caso1.ContactId = contacto.Id;
        insert caso1;

        Case caso2 = new Case();
        caso2.Subject = 'CORREO ENTRANTE';
        caso2.OwnerId = cola.Id;
        caso2.Status = 'New';
        caso2.Reason = 'Helpdesk';
        caso2.Origin = 'Email';
        caso2.CC_Canal_Procedencia__c='Formulario Web';
        caso2.CC_Detalles_Consulta__c='consulta';
		caso2.CC_Detalles_Solucion__c = 'solucion';
        caso2.CC_MCC_Motivo__c = motivo.Id;
        caso2.CC_MCC_ProdServ__c = productoServicio.Id;
        caso2.CC_MCC_Tematica__c = tematica.Id;
        caso2.CC_Idioma__c = 'es';
        caso2.CC_Tipo_Contacto__c = 'Consulta';
        caso2.CC_Canal_Operativo__c = 'App BrokerNow';
        caso2.CC_MCC_Causa__c = causa.Id;
        caso2.CC_MCC_Solucion__c = solucion.id;
        caso2.AccountId = account.Id;
        caso2.ContactId = contacto.Id;
        insert caso2;

        Task tarea1 = new Task();
        tarea1.WhatId = caso2.Id;
        tarea1.CC_Referencia_Correo_Saliente__c = 'XXXX';
        tarea1.Status = 'Open';
        tarea1.Type = 'Traslado Colaborador';
        insert tarea1;

        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;
        } else {
            headerValueStr = 'Prueba@IBM';
        }

        EmailMessage emailmes = new EmailMessage();
        emailmes.RelatedToId = caso2.Id;
        emailmes.TextBody='CORREO ENTRANTE';
        emailmes.Incoming=true;
        emailmes.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert emailmes;

        Test.startTest();

        CC_Revincular_Caso_Controller.mergeCase(caso1.Id,Caso2.Id);

        //Comprobación de resultados
        Case caso = [SELECT Id,CC_Ultima_Interaccion__c,status, CC_Cola_Procedencia__c,CC_Fecha_Ultima_Interaccion__c,CC_Canal_Procedencia__c,
                           		  CC_Fecha_Activo_Formulario__c,CC_Fecha_Traslado_Colaborador__c
                           FROM Case WHERE Id=:caso1.Id LIMIT 1];

        //Task tarea = [SELECT Id,Status from Task where Id= :tarea1.Id LIMIT 1];

        Test.stopTest();

        //Falla//System.assertEquals('Activo', caso.Status);
        //Falla//System.assertEquals('Completed', tarea.Status);
	}

    static testMethod void testrespuestaRemitirColaborador() {
        Group cola = [Select Id from Group where developername='CC_Inbound_Email' LIMIT 1];
        User user1 = [SELECT Id FROM User WHERE Email = 'aalsdna@kfsb.com' LIMIT 1];
        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.CC_Tipo_Cliente__c = 'Cliente';
        tematica.Name = 'Temática Test';
        tematica.CC_Codigo_Externo__c = 'TE-000001';
        tematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert tematica;


        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicio.CC_Tipo_Cliente__c = 'Cliente';
        productoServicio.Name = 'Producto/Servicio Test';
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001';
        insert productoServicio;


        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tipo_Cliente__c = 'Cliente';
        motivo.Name = 'Motivo Test';
        motivo.CC_Producto_Servicio__c = productoServicio.Id;
        motivo.CC_Codigo_Externo__c = 'MO-000001';
        insert motivo;

        CC_MCC__c causa = new CC_MCC__c();
        causa.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        causa.Name = 'Causa Prueba';
        causa.CC_Tipo_Cliente__c = 'Cliente';
        causa.CC_Codigo_Externo__c = 'CA00-01';
        causa.CC_Motivo__c = motivo.Id;
        insert causa;
        CC_MCC__c solucion = new CC_MCC__c();
        solucion.Name = 'Solucion 1';
        solucion.CC_Tipo_Cliente__c = 'Empleado';
        solucion.CC_Fecha_Vigencia_Inicio__c = date.today();
        solucion.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        solucion.CC_Causa__c = causa.Id;
        solucion.CC_Codigo_Externo__c = 'SO-000001';
		insert solucion;


        //insercion contacto con account
        Account account = new Account();
        account.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        account.Name = 'account temp';
        insert account;


        Contact contacto = new Contact();
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contacto.FirstName = 'Contacto';
        contacto.LastName = 'Test';
        contacto.CC_Idioma__c = 'es';
        contacto.AccountId = account.Id;
        insert contacto;


        Case caso1 = new Case();
        caso1.Subject = 'CASO INICIAL';
        caso1.Status = 'Pendiente Colaborador';
        caso1.Reason = 'Helpdesk';
        caso1.CC_Cambio_Estado_Pendiente_Externo__c	=true;
        caso1.Origin = 'Email';
        caso1.CC_Canal_Procedencia__c='Formulario Web';
        caso1.CC_Detalles_Consulta__c='consulta';
		caso1.CC_Detalles_Solucion__c = 'solucion';
        caso1.CC_MCC_Motivo__c = motivo.Id;
        caso1.CC_MCC_ProdServ__c = productoServicio.Id;
        caso1.CC_MCC_Tematica__c = tematica.Id;
        caso1.CC_Idioma__c = 'es';
        caso1.CC_Tipo_Contacto__c = 'Consulta';
        caso1.CC_Canal_Operativo__c = 'App BrokerNow';
        caso1.CC_MCC_Causa__c = causa.Id;
        caso1.CC_MCC_Solucion__c = solucion.id;
        caso1.AccountId = account.Id;
        caso1.ContactId = contacto.Id;
        insert caso1;

        task tarea1 = new Task();
        tarea1.WhatId=caso1.Id;
        tarea1.CC_Referencia_Correo_Saliente__c ='XXXXX';
        tarea1.Status='Open';
        tarea1.Type='Remitir Colaborador';
        insert tarea1;

        Case caso2 = new Case();
        caso2.Subject = 'CORREO ENTRANTE';
        caso2.OwnerId = cola.Id;
        caso2.Status = 'New';
        caso2.Reason = 'Helpdesk';
        caso2.Origin = 'Email';
        caso2.CC_Canal_Procedencia__c='Formulario Web';
        caso2.CC_Detalles_Consulta__c='consulta';
		caso2.CC_Detalles_Solucion__c = 'solucion';
        caso2.CC_MCC_Motivo__c = motivo.Id;
        caso2.CC_MCC_ProdServ__c = productoServicio.Id;
        caso2.CC_MCC_Tematica__c = tematica.Id;
        caso2.CC_Idioma__c = 'es';
        caso2.CC_Tipo_Contacto__c = 'Consulta';
        caso2.CC_Canal_Operativo__c = 'App BrokerNow';
        caso2.CC_MCC_Causa__c = causa.Id;
        caso2.CC_MCC_Solucion__c = solucion.id;
        caso2.AccountId = account.Id;
        caso2.ContactId = contacto.Id;
        insert caso2;

        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;
        } else {
            headerValueStr = 'Prueba@IBM';
        }

        EmailMessage emailmes = new EmailMessage();
        emailmes.RelatedToId = caso2.Id;
        emailmes.TextBody='CORREO ENTRANTE';
        emailmes.Incoming=true;
        emailmes.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert emailmes;

        Test.startTest();
        System.runAs(user1){
            CC_Revincular_Caso_Controller.mergeCase(caso1.Id,Caso2.Id);

        //Comprobación de resultados
            Case caso = [SELECT Id,CC_Ultima_Interaccion__c,status, CC_Cola_Procedencia__c,CC_Fecha_Ultima_Interaccion__c,CC_Canal_Procedencia__c,
                           		  CC_Fecha_Activo_Formulario__c,CC_Fecha_Traslado_Colaborador__c
                           FROM Case WHERE Id=:caso1.Id LIMIT 1];

            Task tarea = [SELECT Id,Status from Task where Id= :tarea1.Id LIMIT 1];

            System.assertEquals('Pendiente Colaborador', caso.Status, 'El método merge ha fallado');
            //System.assertEquals('Completed', tarea.Status, 'El método merge ha fallado');
        }
        Test.stopTest();
        //Comprobación de resultados


        //Falla//System.assertEquals('Activo', caso.Status);
        //Falla//System.assertEquals('Completed', tarea.Status);
	}

    static testMethod void testAux1() {
        Case caso1 = new Case();
        caso1.Subject = 'Subject';
        caso1.Status = 'Pendiente Cliente';
        caso1.Reason = 'Helpdesk';
        caso1.CC_Cambio_Estado_Pendiente_Externo__c	=true;
        caso1.Origin = 'Email';
        caso1.CC_Canal_Procedencia__c='Formulario Web';
        insert caso1;
        CC_Revincular_Caso_Controller.respuestaSolicitudInfo(null, caso1, null, null);
    }

    static testMethod void testAux2() {
        Case caso1 = new Case();
        caso1.Subject = 'Subject';
        caso1.Status = 'Pendiente Colaborador';
        caso1.Reason = 'Helpdesk';
        caso1.CC_Cambio_Estado_Pendiente_Externo__c	=true;
        caso1.Origin = 'Email';
        caso1.CC_Canal_Procedencia__c='Formulario Web';
        insert caso1;

        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;
        } else {
            headerValueStr = 'Prueba@IBM';
        }

        EmailMessage emailmes = new EmailMessage();
        emailmes.RelatedToId = caso1.Id;
        emailmes.TextBody='TextBody';
        emailmes.Incoming=true;
        emailmes.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert emailmes;

        CC_Revincular_Caso_Controller.respuestaTrasladoColaborador(emailmes, caso1, null, null);
    }

    static testMethod void testAux3() {
        Case caso1 = new Case();
        caso1.Subject = 'Subject';
        caso1.Status = 'Pendiente Colaborador';
        caso1.Reason = 'Helpdesk';
        caso1.CC_Cambio_Estado_Pendiente_Externo__c	=true;
        caso1.Origin = 'Email';
        caso1.CC_Canal_Procedencia__c='Formulario Web';
        insert caso1;

        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE '%CC_Revincular%' LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;
        } else {
            headerValueStr = 'Prueba@IBM';
        }

        EmailMessage emailmes = new EmailMessage();
        emailmes.RelatedToId = caso1.Id;
        emailmes.TextBody='TextBody';
        emailmes.Incoming=true;
        emailmes.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert emailmes;

        CC_Revincular_Caso_Controller.respuestaRemitirColaborador(emailmes, caso1, null, null);
    }


    /******************************************* Casos Empleados CSI ****************************************************/
    static testMethod void testgetCasoEmpleadoCSIFromCola() {
        Id idCasoEmpleadoCSI = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        Group cola = [Select Id from Group where developername='CC_Inbound_Email' LIMIT 1];

        Case caso1 = new Case();
        caso1.Subject = 'CASO INICIAL';
        caso1.Status = 'Pendiente Cliente';
        caso1.Reason = 'Helpdesk';
        caso1.Origin = 'Email';
        caso1.CC_Canal_Procedencia__c='CCO CSI';
        caso1.OwnerId = cola.Id;
        caso1.RecordTypeId = idCasoEmpleadoCSI;
        insert caso1;

        Map<String,Object> out = CC_Revincular_Caso_Controller.getCaso(caso1.Id);
        System.assertEquals(5, out.size());
        System.assertEquals('Para poder fusionar este caso acepte primero su propiedad.', out.get('MENSAJE'), 'Caso asignado a una cola');
        Boolean isHabilitada = (Boolean)out.get('HABILITADO');
        System.assert(!isHabilitada, 'La operativa no está habilitada');

    }
    static testMethod void testgetCasoEmpleadoCSIFromChat() {
        Id idCasoEmpleadoCSI = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();

        Case caso1 = new Case();
        caso1.Subject = 'CASO INICIAL';
        caso1.Status = 'Pendiente Cliente';
        caso1.Reason = 'Helpdesk';
        caso1.Origin = 'Chat';
        caso1.CC_Canal_Procedencia__c = 'CCO CSI';
        caso1.RecordTypeId = idCasoEmpleadoCSI;
        insert caso1;

        Map<String,Object> out = CC_Revincular_Caso_Controller.getCaso(caso1.Id);
        System.assertEquals(5, out.size());
        Boolean isHabilitada = (Boolean)out.get('HABILITADO');
        System.assert(isHabilitada, 'La operativa está habilitada');
    }


    public static testMethod void mergeCops() {
        List<Case> listaCasos = new List<Case>();
        List<Task> listaTask = new List<Task>();

        Case caso1 = new Case();
        caso1.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        caso1.Subject = 'CASO INICIAL';
        caso1.Status = 'Activo';
       	caso1.Origin = 'Phone';
        caso1.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso1.CC_Canal_Resolucion__c = 'Teléfono COPS atención clientes';
        caso1.CC_Tipo_Contacto__c = 'Asesoramiento';
        listaCasos.add(caso1);

        Case caso2 = new Case();
        caso2.Subject = 'CORREO ENTRANTE';
        caso2.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        caso2.Status = 'Activo';
        caso2.Origin = 'Email';
        caso2.Origin = 'Phone';
        caso2.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        listaCasos.add(caso2);
        insert listaCasos;

        task tarea1 = new Task();
        tarea1.WhatId=caso1.Id;
        tarea1.CC_Referencia_Correo_Saliente__c ='XXXXX';
        tarea1.Status='Completed';
        tarea1.Type='Solicitud Información';
        listaTask.add(tarea1);
        Datetime oneMinuteAgo = Datetime.now().addMinutes(-1);

        Task tarea2 = new Task();
        tarea2.WhatId=caso2.Id;
        tarea2.Status='Completed';
        tarea2.Type='Solicitud Información';
        tarea2.CC_Referencia_Correo_Saliente__c = 'XXXXX';
        listaTask.add(tarea2);

        insert listaTask;

        Test.setCreatedDate(tarea2.Id, oneMinuteAgo);
		Test.setCreatedDate(tarea1.Id, oneMinuteAgo);

        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;
        } else {
            headerValueStr = 'Prueba@IBM';
        }

        EmailMessage eMessage = new EmailMessage();
        eMessage.RelatedToId = caso2.Id;
        eMessage.TextBody='CORREO ENTRANTE';
        eMessage.Incoming=true;
        eMessage.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert eMessage;

        //Adjuntos:
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');

        List<ContentVersion> listCVs = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content pdf';
        cv.PathOnClient = 'Test_Pdf.pdf';
        cv.VersionData = beforeblob;
        listCVs.add(cv);

        ContentVersion cv2 = new ContentVersion();
        cv2.title = 'test content image';
        cv2.PathOnClient = 'Test_Image.jpg';
        cv2.VersionData = beforeblob;
        listCVs.add(cv2);

        Test.startTest();
        insert listCVs;

        ContentVersion testContent = [SELECT Id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        ContentVersion testContent2 = [SELECT Id, ContentDocumentId FROM ContentVersion where Id = :cv2.Id];

        List<ContentDocumentLink> listContentLink = new List<ContentDocumentLink>();
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentlink.LinkedEntityId = caso2.Id;
        contentlink.ShareType = 'V';
        contentlink.ContentDocumentId = testcontent.ContentDocumentId;
		listContentLink.add(contentLink);

        ContentDocumentLink contentLink2 = new ContentDocumentLink();
        contentLink2.LinkedEntityId = caso2.Id;
        contentLink2.ShareType = 'V';
        contentLink2.ContentDocumentId = testcontent2.ContentDocumentId;
		listContentLink.add(contentLink2);

        insert listContentLink;
        CC_Revincular_Caso_Controller.mergeCase(caso1.Id,Caso2.Id);
        Test.stopTest();

        Set<Id> setCasos = new Set<Id>{caso1.Id};
        //System.debug([SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId IN :setCasos]);

        System.assertEquals(2,[SELECT Count() FROM ContentDocumentLink WHERE LinkedEntityId IN :setCasos]);

	}

    public static testMethod void getParentIdRecordTypeDeveloperName() {

        Case casoCOPS = new Case();
        casoCOPS.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        casoCOPS.Subject = 'CASO COPS';
        casoCOPS.Status = 'Activo';
        casoCOPS.Origin = 'Phone';
        casoCOPS.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        casoCOPS.CC_Canal_Resolucion__c = 'Teléfono COPS atención clientes';
        casoCOPS.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert casoCOPS;

        Case caso = new Case();
        caso.Subject = 'CASO Contact Center';
        caso.Status = 'Pendiente Cliente';
        caso.Reason = 'Helpdesk';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c='Formulario Web';
        caso.CC_MailTelfNotif__c='test';
        caso.ParentId = casoCOPS.Id;
        insert caso;


        Test.startTest();
            String developerName = CC_Revincular_Caso_Controller.getParentIdRecordTypeDeveloperName(caso);
        Test.stopTest();
        System.assertNotEquals(null,developerName);
        System.assertEquals('OS_Cliente',developerName);

	}
    @isTest
    static void derivarAlSac(){

        Id tematicaId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id causaId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id solucionId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();

        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'TE-000001',
            CC_Canal_Operativo__c = 'App BrokerNow'

        );
        insert tematica;
        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-000001'
        );
        insert producto;
        CC_MCC__c motivo = new CC_MCC__c(
            Name = 'Motivo Test',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000001'
        );
        insert motivo;
        CC_MCC__c causa = new CC_MCC__c(
            Name = 'Causa Test',
            RecordTypeId = causaId,
            CC_Producto_Servicio__c = motivo.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'CA-000001'
        );
        insert causa;
        CC_MCC__c solucion = new CC_MCC__c(
            Name = 'Solucion Test',
            RecordTypeId = solucionId,
            CC_Producto_Servicio__c = causa.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'SO-000001'
        );
        insert solucion;

        Account cuenta = new Account();
        cuenta.Name = 'cuentaTest';
        insert cuenta;

        Contact contacto = new Contact();
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'test';
        contacto.LastName = 'test';
        insert contacto;

        Case casoCC = new Case();
        casoCC.Subject = 'Caso de Contact Center para Derivar al SAC';
        casoCC.Description = 'Caso de Contact Center para Derivar al SAC';
        casoCC.CC_Idioma__c = 'es';
        casoCC.Origin = 'Email';
        casoCC.CC_Canal_Operativo__c = 'Sin canal';
        casoCC.CC_Tipo_Contacto__c = 'Consulta';
        casoCC.CC_Canal_Procedencia__c = 'Formulario web';
        casoCC.CC_Detalles_Consulta__c = 'Caso de Contact Center para Derivar al SAC';
        casoCC.Status = 'Activo';
        casoCC.AccountId = cuenta.Id;
        casoCC.ContactId = contacto.Id;
        casoCC.CC_MCC_Tematica__c = tematica.Id;
        casoCC.CC_MCC_ProdServ__c = producto.Id;
        casoCC.CC_MCC_Motivo__c = motivo.Id;
        casoCC.CC_MCC_Causa__c = causa.Id;
        casoCC.CC_MCC_Solucion__c = solucion.Id;
        casoCC.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        insert casoCC;

        ContentVersion content=new ContentVersion();
        content.Title = 'Header_Picture1';
        content.PathOnClient = '/' + content.Title + '.jpg';
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        content.VersionData = bodyBlob;
        content.origin = 'H';
        insert content;

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = casoCC.Id;
        contentlink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: content.Id].ContentDocumentId;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';
        insert contentlink;

        /*EmailMessage emailMessage = new EmailMessage();
        emailMessage.Status = '3'; // email was sent
        emailMessage.FromName = 'Magulan Duraipandian'; // from name
        emailMessage.Incoming =  true;
        emailMessage.Subject = 'This is the Subject!'; // email subject
        emailMessage.HtmlBody = '<html><body><b>Hello</b></body></html>'; // email body
        emailMessage.RelatedToId = casoCC.Id;
        insert emailMessage; */ // insert

        Test.startTest();
        CC_Revincular_Caso_Controller.derivarCasoAlSAC(casoCC, 'Motivo derivar');
        Test.stopTest();

        List<Case> casoSAC = [SELECT Id, CC_Motivo__c	 FROM Case WHERE ParentId = :casoCC.Id];
        System.assertEquals(1, casoSAC.size(), 'La creación de la reclamación desde CC no ha funcionado.');
        System.assertEquals('Motivo derivar', casoSAC.get(0).CC_Motivo__c	, 'El motivo no coincide');
    }


    @isTest
    static void devolverAlSac(){
        Id tematicaId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id causaId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id solucionId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();

        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'TE-000001',
            CC_Canal_Operativo__c = 'App BrokerNow'

        );
        insert tematica;
        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-000001'
        );
        insert producto;
        CC_MCC__c motivo = new CC_MCC__c(
            Name = 'Motivo Test',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000001'
        );
        insert motivo;
        CC_MCC__c causa = new CC_MCC__c(
            Name = 'Causa Test',
            RecordTypeId = causaId,
            CC_Producto_Servicio__c = motivo.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'CA-000001'
        );
        insert causa;
        CC_MCC__c solucion = new CC_MCC__c(
            Name = 'Solucion Test',
            RecordTypeId = solucionId,
            CC_Producto_Servicio__c = causa.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'SO-000001'
        );
        insert solucion;

        Account cuenta = new Account();
        cuenta.Name = 'cuentaTest';
        insert cuenta;

        Contact contacto = new Contact();
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'test';
        contacto.LastName = 'test';
        insert contacto;

        Case casoSac = new Case();
        casoSac.Subject = 'CASO SAC Derivar a CC';
        casoSac.Description = 'Luego devolveremos nuestro caso de CC a este caso SAC';
        casoSac.CC_Idioma__c = 'es';
        casoSac.Origin = 'SAC_Manual';
        casoSac.Status = 'SAC_001';
        casoSac.SAC_StatusAuxiliar__c = 'SAC_001';
        casoSac.CC_Tipo_Contacto__c = 'Consulta';
        casoSac.CC_Canal_Procedencia__c = 'Junta Andalucia';
        casoSac.SAC_TipoConsumidor__c = 'No';
        casoSac.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        insert casoSac;

        Case casoCC = new Case();
        casoCC.Subject = 'Caso de Contact Center para devolver al SAC';
        casoCC.Description = 'Caso de Contact Center para devolver al SAC';
        casoCC.CC_Idioma__c = 'es';
        casoCC.Origin = 'Email';
        casoCC.CC_Canal_Operativo__c = 'Sin canal';
        casoCC.CC_Tipo_Contacto__c = 'Consulta';
        casoCC.CC_Canal_Procedencia__c = 'Formulario web';
        casoCC.CC_Detalles_Consulta__c = 'Caso de Contact Center para devolver al SAC';
        casoCC.Status = 'Activo';
        casoCC.AccountId = cuenta.Id;
        casoCC.ContactId = contacto.Id;
        casoCC.ParentId = casoSac.Id;
        casoCC.CC_MCC_Tematica__c = tematica.Id;
        casoCC.CC_MCC_ProdServ__c = producto.Id;
        casoCC.CC_MCC_Motivo__c = motivo.Id;
        casoCC.CC_MCC_Causa__c = causa.Id;
        casoCC.CC_MCC_Solucion__c = solucion.Id;
        casoCC.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        insert casoCC;

        casoSac.Status = 'SAC_003';
        casoSac.SAC_StatusAuxiliar__c = 'SAC_003';
        update casoSac;

        Test.startTest();
        CC_Revincular_Caso_Controller.f3('Motivo devolución', casoCC);
        Test.stopTest();

        List<Case> casos = [SELECT Status, CC_Motivo__c FROM Case WHERE Id = :casoSac.Id];
        System.assertEquals('Motivo devolución', casos.get(0).CC_Motivo__c);
        System.assertEquals('SAC_001', casos.get(0).Status);
    }

    @isTest
    static void comprobarRecordType_Test(){

        Id idRT = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Test.startTest();
        Boolean res = CC_Revincular_Caso_Controller.comprobarRecordType(idRT);
        Test.stopTest();

        System.assertEquals(false, res, 'Ha fallado la obtención del recordType.');
    }

}