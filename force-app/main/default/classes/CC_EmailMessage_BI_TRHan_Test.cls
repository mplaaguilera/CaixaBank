@isTest
            public with sharing class CC_EmailMessage_BI_TRHan_Test {
                
                @TestSetup
                static void makeData(){
                    User usuarioAdmin = CC_TestDataFactory.insertUserAdmin();
                    System.runAs(usuarioAdmin) {

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
                        contactoEmpleado.CC_Matricula__c = 'Invalid';
                        contactoEmpleado.RecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
                        contactos.add(contactoEmpleado);
                        
                        insert contactos;
                        
                        List<ContactShare> totalPermisosContact = new List<ContactShare>();
                        for(Contact c : [SELECT Id FROM Contact]) {
                            ContactShare contactShare = new ContactShare();
                            contactShare.ContactId = c.Id;
                            contactShare.UserOrGroupId = usuarioAdmin.Id;
                            contactShare.ContactAccessLevel = 'Edit';
                            totalPermisosContact.add(contactShare);
                        }
                        Database.insert(totalPermisosContact, false);
                        
                        List<AccountShare> totalPermisosAccount = new List<AccountShare>();
                        for(Account a : [SELECT Id FROM Account]) {
                            AccountShare acshare = new AccountShare();
                            acshare.AccountId = a.Id;
                            acshare.UserOrGroupId = usuarioAdmin.Id;
                            acshare.AccountAccessLevel = 'Edit';
                            acshare.OpportunityAccessLevel = 'Edit';
                            acshare.CaseAccessLevel = 'Edit';
                            totalPermisosAccount.add(acshare);
                        }
                        Database.insert(totalPermisosAccount, false);
                    }
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
        User admin = CC_TestDataFactory.getUserAdmin();
        System.runAs(admin) {
            Id rtCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            Id rtCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Account cuenta = [Select id from Account where Name = 'cuentaTest' and RecordtypeId = :rtCliente limit 1];
            Account cuentaCentroCaixabank = [Select id from Account where Name = 'cuentaTest' and RecordtypeId = :rtCentro limit 1];
            
            Id rtCOntactoCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Id rtEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            Contact contactoCliente = [Select id from Contact where FirstName = 'test' and RecordtypeId = :rtCOntactoCliente limit 1];
            Contact contactoEmpleado = [Select id from Contact where FirstName = 'Contacto Empleado' and RecordtypeId = :rtEmpleado limit 1];
            contactoEmpleado.CC_Inactivo__c = true;    
            contactoEmpleado.CC_Matricula__c = 'Invalid';
            update contactoEmpleado;

            
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
            correoSalienteTrasladoColaborador.ToAddress = 'accionista@test.com';
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
/*
    @isTest
    static void testEsAccionista() {
        User admin = CC_TestDataFactory.getUserAdmin();
        System.runAs(admin) {
            Id rtCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Account cuenta = [Select id from Account where Name = 'cuentaTest' and RecordtypeId = :rtCliente limit 1];
            Id rtContactoCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Contact contactoCliente = [Select id from Contact where FirstName = 'test' and RecordtypeId = :rtContactoCliente limit 1];

            // Crear caso de prueba con RecordType CC_Cliente
            Case caso = new Case();
            caso.RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            caso.Subject = 'Test Accionista';
            caso.Description = 'Test Accionista';
            caso.Origin = 'Email';
            caso.CC_Idioma__c = 'es';
            caso.CC_Tipo_Contacto__c = 'Incidencia';
            caso.CC_Canal_Operativo__c = 'Oficina';
            caso.CC_Canal_Procedencia__c = 'Atención al Cliente';
            caso.CC_Detalles_Consulta__c = 'Test Accionista';
            caso.CC_Canal_Resolucion__c = 'Atención al Cliente';
            caso.CC_Tipo_Cliente__c = 'Cliente';
            caso.Status = 'Activo';
            caso.AccountId = cuenta.Id;
            caso.ContactId = contactoCliente.Id;
            insert caso;
            
            System.debug('### INICIO TEST ACCIONISTA ###');
            System.debug('Caso creado con ID: ' + caso.Id);
            System.debug('RecordType del caso: ' + caso.RecordtypeId);
            
            // Verificar estado inicial del caso
            Case casoInicial = [SELECT Id, CC_Canal_Procedencia__c, CC_Tipo_Contacto__c 
                              FROM Case 
                              WHERE Id = :caso.Id];
            System.debug('Estado inicial del caso - Canal procedencia: ' + casoInicial.CC_Canal_Procedencia__c);
            System.debug('Estado inicial del caso - Tipo contacto: ' + casoInicial.CC_Tipo_Contacto__c);
            
            // Crear correo de prueba
            EmailMessage correoAccionista = new EmailMessage();
            correoAccionista.ParentId = caso.Id;
            correoAccionista.Incoming = true; // Cambiado a true para probar como correo entrante
            correoAccionista.CC_Aplicacion__c = 'CC Clientes';
            correoAccionista.MessageDate = System.now();
            correoAccionista.ToAddress = 'accionista@test.com';
            correoAccionista.FromAddress = 'test@example.com';
            correoAccionista.Subject = 'Correo Accionista';
            correoAccionista.HtmlBody = 'Test correo accionista';
           
            Test.startTest();
            try {	
                System.debug('Intentando insertar correo con ToAddress: ' + correoAccionista.ToAddress);
                insert correoAccionista;
                System.debug('Correo insertado exitosamente con ID: ' + correoAccionista.Id);
                
                // Verificar el correo después de la inserción
                EmailMessage correoVerificacion = [SELECT Id, ToAddress, ParentId, Incoming, CC_Interno__c
                                                 FROM EmailMessage 
                                                 WHERE Id = :correoAccionista.Id];
                System.debug('Correo después de inserción - ToAddress: ' + correoVerificacion.ToAddress);
                System.debug('Correo después de inserción - ParentId: ' + correoVerificacion.ParentId);
                System.debug('Correo después de inserción - Incoming: ' + correoVerificacion.Incoming);
                
            } catch (Exception e) {
                System.debug('Error al insertar el correo: ' + e.getMessage());
                System.debug('Stack trace: ' + e.getStackTraceString());
            }
            Test.stopTest(); 

            // Verificar que el caso se actualizó correctamente
            Case casoActualizado = [SELECT Id, CC_Canal_Procedencia__c, CC_Tipo_Contacto__c, RecordTypeId 
                                   FROM Case 
                                   WHERE Id = :caso.Id];
            
            System.debug('Canal de procedencia después de la actualización: ' + casoActualizado.CC_Canal_Procedencia__c);
            System.debug('Tipo de contacto después de la actualización: ' + casoActualizado.CC_Tipo_Contacto__c);
            System.debug('### FIN TEST ACCIONISTA ###');
            
            System.assertEquals('Accionista', casoActualizado.CC_Canal_Procedencia__c, 
                              'El canal de procedencia no se actualizó correctamente');
            System.assertEquals('Consulta', casoActualizado.CC_Tipo_Contacto__c, 
                              'El tipo de contacto no se actualizó correctamente');
        }
    }*/
    /*
    @isTest
    static void testMultiplesCorreos() {
        User admin = CC_TestDataFactory.getUserAdmin();
        System.runAs(admin) {
            String defaultFromAddressAttCliente = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Atencion_Cliente_ESP'].CC_Direccion_Correo__c;
            
            Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
            CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
            grupoColab.Name = 'Grupo Colaborador Temporal';
            grupoColab.RecordTypeId = recordTypeGrupoColaborador;
            grupoColab.CC_External__c = 'GC-00001';
            insert grupoColab; 
            
            List<Case> casosIdioma = new List<Case>();

            Case casoIngles = new Case();
            casoIngles.RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            casoIngles.Subject = 'Inglés';
            casoIngles.Description = 'Test Caso Inglés';
            casoIngles.Origin = 'Email';
            casosIdioma.add(casoIngles);

            Case casoCastellano = new Case();
            casoCastellano.RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            casoCastellano.Subject = 'Castellano';
            casoCastellano.Description = 'Test Caso Castellano';
            casoCastellano.Origin = 'Email';
            casosIdioma.add(casoCastellano);

            Case casoCatalan = new Case();
            casoCatalan.RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            casoCatalan.Subject = 'Català';
            casoCatalan.Description = 'Test Caso Catalan';
            casoCatalan.Origin = 'Email';
            casosIdioma.add(casoCatalan);

            insert casosIdioma;

            List <Task> tareas = new List<Task>();

            Task actividadCorreoIngles = new Task();
            actividadCorreoIngles.Type = 'Traslado Colaborador';
            actividadCorreoIngles.WhatId = casoIngles.Id;
            actividadCorreoIngles.CC_Referencia_Correo_Saliente__c = '1234567890';
            actividadCorreoIngles.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
            tareas.add(actividadCorreoIngles);
            
            Task actividadCorreoCastellano = new Task();
            actividadCorreoCastellano.Type = 'Traslado Colaborador';
            actividadCorreoCastellano.CC_Referencia_Correo_Saliente__c = '1234567890';
            actividadCorreoCastellano.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
            actividadCorreoCastellano.WhatId = casoCastellano.Id;
            tareas.add(actividadCorreoCastellano);
            
            Task actividadCorreoCatalan = new Task();
            actividadCorreoCatalan.Type = 'Traslado Colaborador';
            actividadCorreoCatalan.WhatId = casoCatalan.Id;
            actividadCorreoCatalan.CC_Referencia_Correo_Saliente__c = '1234567890';
            actividadCorreoCatalan.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
            tareas.add(actividadCorreoCatalan);
            
            insert tareas;

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

            List<EmailMessage> correos = new List<EmailMessage>();
            EmailMessage correoIngles = new EmailMessage();
            correoIngles.Subject = 'Prueba de envío de correo Ingles';
            correoIngles.ActivityId = actividadCorreoIngles.Id;
            correoIngles.CC_Grupo_Colab__c = grupoColab.Name;
            correoIngles.CC_Procedencia__c = 'Traslado Colaborador';
            correoIngles.FromAddress = defaultFromAddressAttCliente;
            correoIngles.ToAddress = 'shareholders@company.com';
            correoIngles.Incoming = true;
            correoIngles.Status = '0';
            correoIngles.ParentId = casoIngles.Id;
            correoIngles.RelatedToId = casoIngles.Id;
            correoIngles.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
            correos.add(correoIngles);  

            EmailMessage correoCastellano = new EmailMessage();
            correoCastellano.Subject = 'Prueba de envío de correo Castellano';
            correoCastellano.ActivityId = actividadCorreoCastellano.Id;
            correoCastellano.CC_Grupo_Colab__c = grupoColab.Name;
            correoCastellano.CC_Procedencia__c = 'Traslado Colaborador';
            correoCastellano.FromAddress = defaultFromAddressAttCliente;
            correoCastellano.ToAddress = 'atencion.clientes@company.com';
            correoCastellano.Incoming = true;
            correoCastellano.Status = '0';
            correoCastellano.ParentId = casoCastellano.Id;
            correoCastellano.RelatedToId = casoCastellano.Id;
            correoCastellano.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
            correos.add(correoCastellano);

            EmailMessage correoCatalan = new EmailMessage();
            correoCatalan.Subject = 'Prueba de envío de correo Catalan';
            correoCatalan.ActivityId = actividadCorreoCatalan.Id;
            correoCatalan.CC_Grupo_Colab__c = grupoColab.Name;
            correoCatalan.CC_Procedencia__c = 'Traslado Colaborador';
            correoCatalan.FromAddress = defaultFromAddressAttCliente;
            correoCatalan.ToAddress = 'atencio.clients@company.com';
            correoCatalan.Incoming = true;
            correoCatalan.ParentId = casoCatalan.Id;
            correoCatalan.RelatedToId = casoCatalan.Id;
            correoCatalan.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
            correoCatalan.Status = '0';
            correos.add(correoCatalan);
            
            
            Test.startTest();
            insert correos;
            Test.stopTest();
           
            
            System.assertEquals('Inglés', casoIngles.CC_Idioma__c, 'El idioma del caso en inglés no es correcto');
            System.assertEquals('Castellano', casoCastellano.CC_Idioma__c, 'El idioma del caso en español no es correcto');
            System.assertEquals('Català', casoCatalan.CC_Idioma__c, 'El idioma del caso en catalán no es correcto');
            
        }
    }*/
}