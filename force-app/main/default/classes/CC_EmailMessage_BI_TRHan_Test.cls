@isTest
public with sharing class CC_EmailMessage_BI_TRHan_Test {
    
    @TestSetup
    static void makeData(){
        
        List<Account> cuentas = new List<Account>();
        Account cuenta = new Account();
        cuenta.Name = 'cuentaTest';
        cuenta.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuentas.add(cuenta);

        Account cuentaCentroCaixabank = new Account();
        cuentaCentroCaixabank.Name = 'cuentaTest';
        cuentaCentroCaixabank.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        cuentas.add(cuentaCentroCaixabank);
        insert cuentas;

        List<Contact> contactos = new List<Contact>();
        Contact contactoCliente = new Contact();
        contactoCliente.AccountId = cuenta.Id;
        contactoCliente.FirstName = 'test';
        contactoCliente.LastName = 'test';
        contactoCliente.Email = 'to@test.com';
        contactoCliente.RecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactos.add(contactoCliente);

        
        Contact contactoEmpleado = new Contact();
        contactoEmpleado.AccountId = cuenta.Id;
        contactoEmpleado.FirstName = 'Contacto Empleado';
        contactoEmpleado.LastName = 'Contacto Empleado';
        contactoEmpleado.Email = 'to@test.com';
        contactoEmpleado.CC_Inactivo__c = true;
        contactoEmpleado.RecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        contactos.add(contactoEmpleado);

        Contact contactoEmpleado2 = new Contact();
        contactoEmpleado2.AccountId = cuenta.Id;
        contactoEmpleado2.FirstName = 'Contacto Empleado 2';
        contactoEmpleado2.LastName = 'Contacto Empleado 2';
        contactoEmpleado2.Email = 'to@test.com';
        contactoEmpleado2.CC_Inactivo__c = true;
        contactoEmpleado2.RecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        contactos.add(contactoEmpleado2);
        insert contactos;
        
    }  
    /**
    @isTest
    private static void test() {
		
		// Trasladar a Colaborador
        
        Case caso = new Case();
		caso.Origin = 'Chat';
        caso.CC_Canal_Procedencia__c = 'App';
        insert caso;
        
        Task actividad = new Task();
        actividad.WhatId = caso.Id;
        insert actividad;
        
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Marc';
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;
        
        EmailMessage correo = new EmailMessage();
        correo.ParentId = caso.Id;
        correo.RelatedToId = caso.Id;
        correo.ActivityId = actividad.Id;
        correo.Subject = 'prueba';
        correo.Incoming = false;
        correo.TextBody = 'cuerpo';
        correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correo.toAddress = 'test@test.com';
        correo.CC_Procedencia__c = 'Traslado Colaborador';
        correo.CC_Grupo_Colab__c = 'Grupo Colaborador Marc';
        insert correo;
        
        //system.assert(correo.CC_Interno__c == true);
            
        // Remitir a Colaborador
             
        caso = new Case();
        caso.Origin = 'Chat';
        caso.CC_Canal_Procedencia__c = 'Web';
        insert caso;
        
        actividad = new Task();
        actividad.WhatId = caso.Id;
        insert actividad;
        
        correo = new EmailMessage();
        correo.ParentId = caso.Id;
        correo.RelatedToId = caso.Id;
        correo.ActivityId = actividad.Id;
        correo.Subject = 'prueba';
        correo.Incoming = false;
        correo.TextBody = 'cuerpo';
        correo.toAddress = 'test@test.com';
        correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correo.CC_Procedencia__c = 'Remitir Colaborador';
        correo.CC_Grupo_Colab__c = 'Grupo Colaborador Marc';
        insert correo;
        
        //system.assert(correo.CC_Interno__c == true);
        
        
    }*/
    @isTest
    private static void informarOperativaTraslado() {
		
		//Preparación de los datos
        Case caso = new Case();
        caso.Subject = 'Caso Test';
        insert caso;

        List<Task> taskInsert = new List<Task>();
        List<EmailMessage> emailMessageInsert = new List<EmailMessage>();

        //Actividad de traslado a colaborador
        Task actividadTrasladoColaborador = new Task();
        actividadTrasladoColaborador.WhatId = caso.Id;
        actividadTrasladoColaborador.Type = 'Traslado Colaborador';
        actividadTrasladoColaborador.Subject = 'Traslado Colaborador';
        actividadTrasladoColaborador.Status = 'Completed';
        actividadTrasladoColaborador.CC_Referencia_Correo_Saliente__c = 'refTrasladar';
        taskInsert.add(actividadTrasladoColaborador);

        //Correo saliente de traslado a colaborador
        Task actividadCorreoSalienteTrasladoColaborador = new Task();
        actividadCorreoSalienteTrasladoColaborador.WhatId = caso.Id;
        taskInsert.add(actividadCorreoSalienteTrasladoColaborador);

        //Preparación del header para el email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }

        EmailMessage correoSalienteTrasladoColaborador = new EmailMessage();
        correoSalienteTrasladoColaborador.ParentId = caso.Id;
        correoSalienteTrasladoColaborador.ActivityId = actividadCorreoSalienteTrasladoColaborador.Id;
        correoSalienteTrasladoColaborador.Incoming = false;
        correoSalienteTrasladoColaborador.CC_Interno__c = true;
        correoSalienteTrasladoColaborador.MessageDate = System.now();
        correoSalienteTrasladoColaborador.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correoSalienteTrasladoColaborador.ToAddress = 'to@test.com';
        correoSalienteTrasladoColaborador.Subject = 'Correo saliente Traslado Colaborador';
        //Se añaden referencias a otras operativas detrás de la correcta para
        //simular las referencias que entran en la parte histórica de correos
        correoSalienteTrasladoColaborador.HtmlBody = 'Hola\n#@refTrasladar#\nAdios\n#@refRemitir#';
        emailMessageInsert.add(correoSalienteTrasladoColaborador);



        //CORREOS ENTRANTES (deben identificar la operativa mediante el método informarOperativa)
        //Correo entrante de traslado a colaborador
        Task actividadCorreoEntranteTrasladoColaborador = new Task();
        actividadCorreoEntranteTrasladoColaborador.WhatId = caso.Id;
        taskInsert.add(actividadCorreoEntranteTrasladoColaborador);

        EmailMessage correoEntranteTrasladoColaborador = new EmailMessage();
        correoEntranteTrasladoColaborador.ParentId = caso.Id;
        correoEntranteTrasladoColaborador.ActivityId = actividadCorreoEntranteTrasladoColaborador.Id;
        correoEntranteTrasladoColaborador.Incoming = true;
        correoEntranteTrasladoColaborador.MessageDate = System.now();
        correoEntranteTrasladoColaborador.FromAddress = 'from@test.com';
        correoEntranteTrasladoColaborador.ToAddress = 'to@test.com';
        correoEntranteTrasladoColaborador.Subject = 'Correo entrante Traslado Colaborador';
        correoEntranteTrasladoColaborador.HtmlBody = 'Respuesta\nHola\n#@refTrasladar#\nAdios\n';
        //Se añade el header del email
        correoEntranteTrasladoColaborador.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        emailMessageInsert.add(correoEntranteTrasladoColaborador);

        insert taskInsert;

        Test.startTest();
        insert emailMessageInsert;
        Test.stopTest();      
        
    }

    @isTest
    private static void informarOperativaSolicitud() {
		
		//Preparación de los datos
        Case caso = new Case();
        caso.Subject = 'Caso Test';
        insert caso;

        List<Task> taskInsert = new List<Task>();
        List<EmailMessage> emailMessageInsert = new List<EmailMessage>();

        //Actividad de traslado a colaborador
        Task actividadSolInfo = new Task();
        actividadSolInfo.WhatId = caso.Id;
        actividadSolInfo.Type = 'Solicitud Información';
        actividadSolInfo.Subject = 'Solicitud Información';
        actividadSolInfo.Status = 'Completed';
        actividadSolInfo.CC_Referencia_Correo_Saliente__c = 'refSolInfo';
        taskInsert.add(actividadSolInfo);

        //Correo saliente de traslado a colaborador
        Task actividadCorreoSalienteSolInfo = new Task();
        actividadCorreoSalienteSolInfo.WhatId = caso.Id;
        taskInsert.add(actividadCorreoSalienteSolInfo);

        //Preparación del header para el email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }

        EmailMessage correoSalienteSolInfo = new EmailMessage();
        correoSalienteSolInfo.ParentId = caso.Id;
        correoSalienteSolInfo.ActivityId = actividadCorreoSalienteSolInfo.Id;
        correoSalienteSolInfo.Incoming = false;
        correoSalienteSolInfo.CC_Interno__c = true;
        correoSalienteSolInfo.MessageDate = System.now();
        correoSalienteSolInfo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correoSalienteSolInfo.ToAddress = 'to@test.com';
        correoSalienteSolInfo.Subject = 'Correo saliente Traslado Colaborador';
        //Se añaden referencias a otras operativas detrás de la correcta para
        //simular las referencias que entran en la parte histórica de correos
        correoSalienteSolInfo.HtmlBody = 'Hola\n#@refTrasladar#\nAdios\n#@refRemitir#';

        emailMessageInsert.add(correoSalienteSolInfo);



        //CORREOS ENTRANTES (deben identificar la operativa mediante el método informarOperativa)
        //Correo entrante de traslado a colaborador
        Task actividadCorreoEntranteSolInfo = new Task();
        actividadCorreoEntranteSolInfo.WhatId = caso.Id;
        taskInsert.add(actividadCorreoEntranteSolInfo);

        EmailMessage correoEntranteSolInfo = new EmailMessage();
        correoEntranteSolInfo.ParentId = caso.Id;
        correoEntranteSolInfo.ActivityId = actividadCorreoEntranteSolInfo.Id;
        correoEntranteSolInfo.Incoming = true;
        correoEntranteSolInfo.MessageDate = System.now();
        correoEntranteSolInfo.FromAddress = 'from@test.com';
        correoEntranteSolInfo.ToAddress = 'to@test.com';
        correoEntranteSolInfo.Subject = 'Correo entrante Sol Info';
        correoEntranteSolInfo.HtmlBody = 'Respuesta\nHola\n#@refSolInfo#\nAdios\n';
        //Se añade el header del email
        correoEntranteSolInfo.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        emailMessageInsert.add(correoEntranteSolInfo);

        insert taskInsert;

        Test.startTest();
        insert emailMessageInsert;

        Test.stopTest();
       
        
    }

    @isTest
    private static void informarOperativaRemitido() {
		
		//Preparación de los datos
        Case caso = new Case();
        caso.Subject = 'Caso Test';
        insert caso;

        List<Task> taskInsert = new List<Task>();
        List<EmailMessage> emailMessageInsert = new List<EmailMessage>();

        //Actividad de traslado a colaborador
        Task actividadRemitirColaborador = new Task();
        actividadRemitirColaborador.WhatId = caso.Id;
        actividadRemitirColaborador.Type = 'Remitir Colaborador';
        actividadRemitirColaborador.Subject = 'Remitir Colaborador';
        actividadRemitirColaborador.Status = 'Completed';
        actividadRemitirColaborador.CC_Referencia_Correo_Saliente__c = 'refRemitirColaborador';
        taskInsert.add(actividadRemitirColaborador);

        //Correo saliente de traslado a colaborador
        Task actividadCorreoSalienteRemitirColaborador = new Task();
        actividadCorreoSalienteRemitirColaborador.WhatId = caso.Id;
        taskInsert.add(actividadCorreoSalienteRemitirColaborador);

        //Preparación del header para el email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }

        EmailMessage correoSalienteRemitirColaborador = new EmailMessage();
        correoSalienteRemitirColaborador.ParentId = caso.Id;
        correoSalienteRemitirColaborador.ActivityId = actividadCorreoSalienteRemitirColaborador.Id;
        correoSalienteRemitirColaborador.Incoming = false;
        correoSalienteRemitirColaborador.CC_Interno__c = true;
        correoSalienteRemitirColaborador.MessageDate = System.now();
        correoSalienteRemitirColaborador.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correoSalienteRemitirColaborador.ToAddress = 'to@test.com';
        correoSalienteRemitirColaborador.Subject = 'Correo saliente Traslado Colaborador';
        //Se añaden referencias a otras operativas detrás de la correcta para
        //simular las referencias que entran en la parte histórica de correos
        correoSalienteRemitirColaborador.HtmlBody = 'Hola\n#@refTrasladar#\nAdios\n#@refRemitirColaborador#';
        emailMessageInsert.add(correoSalienteRemitirColaborador);



        //CORREOS ENTRANTES (deben identificar la operativa mediante el método informarOperativa)
        //Correo entrante de traslado a colaborador
        Task actividadCorreoEntranteRemitirColaborador = new Task();
        actividadCorreoEntranteRemitirColaborador.WhatId = caso.Id;
        taskInsert.add(actividadCorreoEntranteRemitirColaborador);

        EmailMessage correoEntranteRemitirColaborador = new EmailMessage();
        correoEntranteRemitirColaborador.ParentId = caso.Id;
        correoEntranteRemitirColaborador.ActivityId = actividadCorreoEntranteRemitirColaborador.Id;
        correoEntranteRemitirColaborador.Incoming = true;
        correoEntranteRemitirColaborador.MessageDate = System.now();
        correoEntranteRemitirColaborador.FromAddress = 'from@test.com';
        correoEntranteRemitirColaborador.ToAddress = 'to@test.com';
        correoEntranteRemitirColaborador.Subject = 'Correo entrante Sol Info';
        correoEntranteRemitirColaborador.HtmlBody = 'Respuesta\nHola\n#@refRemitirColaborador#\nAdios\n';
        //Se añade el header del email
        correoEntranteRemitirColaborador.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        emailMessageInsert.add(correoEntranteRemitirColaborador);

        insert taskInsert;

        Test.startTest();
        insert emailMessageInsert;

        Test.stopTest();
       
        
    }

    @isTest
    private static void comprobarContactos() {

        Id rtCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id rtCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [Select id from Account where Name = 'cuentaTest' and RecordtypeId = :rtCliente limit 1];
        Account cuentaCentroCaixabank = [Select id from Account where Name = 'cuentaTest' and RecordtypeId = :rtCentro limit 1];

        Id rtCOntactoCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id rtEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Contact contactoCliente = [Select id from Contact where FirstName = 'test' and RecordtypeId = :rtCOntactoCliente limit 1];
        Contact contactoEmpleado = [Select id from Contact where FirstName = 'Contacto Empleado' and RecordtypeId = :rtEmpleado limit 1];
        Contact contactoEmpleado2 = [Select id from Contact where FirstName = 'Contacto Empleado' and RecordtypeId = :rtEmpleado limit 1];

        Case casoComprobarContactosToAddress = new Case();
        casoComprobarContactosToAddress.RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        casoComprobarContactosToAddress.Subject = 'Caso Traslado a colaborador no contempla clientes en el toaddress';
        casoComprobarContactosToAddress.Description = 'Caso Traslado a colaborador no contempla clientes en el toaddress';
        casoComprobarContactosToAddress.Origin = 'Email';
        casoComprobarContactosToAddress.CC_Idioma__c = 'es';
        casoComprobarContactosToAddress.CC_Tipo_Contacto__c = 'Consulta';
        casoComprobarContactosToAddress.CC_Canal_Procedencia__c = 'Formulario web';
        casoComprobarContactosToAddress.CC_Detalles_Consulta__c = 'Caso Traslado a colaborador no contempla clientes en el toaddress';
        casoComprobarContactosToAddress.Status = 'Activo';
        casoComprobarContactosToAddress.AccountId = cuenta.Id;
        casoComprobarContactosToAddress.ContactId = contactoCliente.Id;
        casoComprobarContactosToAddress.Subject = 'Caso Test';
        casoComprobarContactosToAddress.Subject = 'Caso Test';
        insert casoComprobarContactosToAddress;

        //Correo saliente de traslado a colaborador
        Task actividadCorreoSalienteTrasladoColaborador = new Task();
        actividadCorreoSalienteTrasladoColaborador.WhatId = casoComprobarContactosToAddress.Id;
        insert actividadCorreoSalienteTrasladoColaborador;


        EmailMessage correoSalienteTrasladoColaborador = new EmailMessage();
        correoSalienteTrasladoColaborador.ParentId = casoComprobarContactosToAddress.Id;
        correoSalienteTrasladoColaborador.ActivityId = actividadCorreoSalienteTrasladoColaborador.Id;
        correoSalienteTrasladoColaborador.Incoming = false;
        correoSalienteTrasladoColaborador.CC_Interno__c = true;
        correoSalienteTrasladoColaborador.MessageDate = System.now();
        correoSalienteTrasladoColaborador.CC_Procedencia__c = 'Traslado Colaborador';
        correoSalienteTrasladoColaborador.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correoSalienteTrasladoColaborador.ToAddress = 'to@test.com';
        correoSalienteTrasladoColaborador.ccAddress = 'to@test.com';
        correoSalienteTrasladoColaborador.Subject = 'Correo saliente Traslado Colaborador';
        //Se añaden referencias a otras operativas detrás de la correcta para
        //simular las referencias que entran en la parte histórica de correos
        correoSalienteTrasladoColaborador.HtmlBody = 'Hola\n#@refTrasladar#\nAdios\n#@refRemitir#';
        

        try {
            Test.startTest();
            insert correoSalienteTrasladoColaborador;
            Test.stopTest();
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('No se puede enviar un correo de traslado/remitido con direcciones de cliente en el Para o en Copia') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }

    }
    
    @isTest
    private static void comprobarContactosSucces() {

        Id rtCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id rtCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [Select id from Account where Name = 'cuentaTest' and RecordtypeId = :rtCliente limit 1];
        Account cuentaCentroCaixabank = [Select id from Account where Name = 'cuentaTest' and RecordtypeId = :rtCentro limit 1];

        Id rtCOntactoCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id rtEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Contact contactoCliente = [Select id from Contact where FirstName = 'test' and RecordtypeId = :rtCOntactoCliente limit 1];
        Contact contactoEmpleado = [Select id from Contact where FirstName = 'Contacto Empleado' and RecordtypeId = :rtEmpleado limit 1];
        Contact contactoEmpleado2 = [Select id from Contact where FirstName = 'Contacto Empleado' and RecordtypeId = :rtEmpleado limit 1];


        Case casoComprobarContactosToAddress = new Case();
        casoComprobarContactosToAddress.RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        casoComprobarContactosToAddress.Subject = 'Caso Traslado a colaborador no contempla clientes en el toaddress';
        casoComprobarContactosToAddress.Description = 'Caso Traslado a colaborador no contempla clientes en el toaddress';
        casoComprobarContactosToAddress.Origin = 'Email';
        casoComprobarContactosToAddress.CC_Idioma__c = 'es';
        casoComprobarContactosToAddress.CC_Tipo_Contacto__c = 'Consulta';
        casoComprobarContactosToAddress.CC_Canal_Procedencia__c = 'Formulario web';
        casoComprobarContactosToAddress.CC_Detalles_Consulta__c = 'Caso Traslado a colaborador no contempla clientes en el toaddress';
        casoComprobarContactosToAddress.Status = 'Activo';
        casoComprobarContactosToAddress.AccountId = cuenta.Id;
        casoComprobarContactosToAddress.ContactId = contactoCliente.Id;
        casoComprobarContactosToAddress.Subject = 'Caso Test';
        casoComprobarContactosToAddress.Subject = 'Caso Test';
        insert casoComprobarContactosToAddress;

        //Correo saliente de traslado a colaborador
        Task actividadCorreoSalienteTrasladoColaborador = new Task();
        actividadCorreoSalienteTrasladoColaborador.WhatId = casoComprobarContactosToAddress.Id;
        insert actividadCorreoSalienteTrasladoColaborador;

        
        EmailMessage correoSalienteTrasladoColaborador = new EmailMessage();
        correoSalienteTrasladoColaborador.ParentId = casoComprobarContactosToAddress.Id;
        correoSalienteTrasladoColaborador.ActivityId = actividadCorreoSalienteTrasladoColaborador.Id;
        correoSalienteTrasladoColaborador.Incoming = false;
        correoSalienteTrasladoColaborador.CC_Interno__c = true;
        correoSalienteTrasladoColaborador.MessageDate = System.now();
        correoSalienteTrasladoColaborador.CC_Procedencia__c = 'Traslado Colaborador';
        correoSalienteTrasladoColaborador.ccAddress = 'to@test.com';
        correoSalienteTrasladoColaborador.Subject = 'Correo saliente Traslado Colaborador';
        //Se añaden referencias a otras operativas detrás de la correcta para
        //simular las referencias que entran en la parte histórica de correos
        correoSalienteTrasladoColaborador.HtmlBody = 'Hola\n#@refTrasladar#\nAdios\n#@refRemitir#';
    

        try {
            Test.startTest();
            insert correoSalienteTrasladoColaborador;
            Test.stopTest();
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('No se puede enviar un correo de traslado/remitido con direcciones de cliente en el Para o en Copia') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }


    }
}