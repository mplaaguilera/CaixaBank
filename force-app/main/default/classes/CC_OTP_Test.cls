@isTest
public with sharing class CC_OTP_Test {

    @testSetup static void setup()
    {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        UserRole rolCC = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
        PermissionSet psOperador = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];
        PermissionSet psSupervisor = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Supervisor_PS'];
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        PermissionSet psAutenticacion = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Autenticacion'];
        List<Account> lstAccounts = new List<Account>();
        List<Contact> lstContacts = new List<Contact>();

        User usuarioAdmin = new User();        
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = rolCC.Id;
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';
        insert usuarioAdmin;


        System.runAs(usuarioAdmin)
        {
            User supervisor = new User();
            supervisor.ProfileId = profileId;
            supervisor.FirstName = 'Supervisor';
            supervisor.LastName = 'last11';
            supervisor.Email = 'tuser000@amamama.com';
            supervisor.Phone = '+34 123456789';
            supervisor.Username = 'tuser000@supervisor.com' + System.currentTimeMillis();
            supervisor.CompanyName = 'MST';
            supervisor.Title = 'title';
            supervisor.Alias = 'alias';
            supervisor.TimeZoneSidKey = 'Europe/Paris';
            supervisor.EmailEncodingKey = 'UTF-8';
            supervisor.LanguageLocaleKey = 'es';
            supervisor.LocaleSidKey = 'es_ES';
            supervisor.UserRoleId = rolCC.Id;
            
            User operador = new User();
            operador.ProfileId = profileId;
            operador.FirstName = 'Operador';
            operador.LastName = 'last11';
            operador.Email = 'tuser000@amamama.com';
            operador.Phone = '+34 123456789';
            operador.Username = 'tuser000@operador.com' + System.currentTimeMillis();
            operador.CompanyName = 'MST';
            operador.Title = 'title';
            operador.Alias = 'alias';
            operador.TimeZoneSidKey = 'Europe/Paris';
            operador.EmailEncodingKey = 'UTF-8';
            operador.LanguageLocaleKey = 'es';
            operador.LocaleSidKey = 'es_ES';
            operador.UserRoleId = rolCC.Id;
            insert new List<User>{operador, supervisor};

            insert new List<PermissionSetAssignment> {
                new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psOperador.Id),
                new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psClasses.Id),
                new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psSupervisor.Id),
                new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psAutenticacion.Id),
                new PermissionSetAssignment(AssigneeId = operador.id, PermissionSetId = psOperador.Id),
                new PermissionSetAssignment(AssigneeId = operador.id, PermissionSetId = psClasses.Id)
            };

        
            Account cuenta = new Account(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA'),
            FirstName = 'Cuenta',
            LastName = 'Test',
            CC_Email__c = 'cuenta@test.com',
            PersonMobilePhone = '+34 123456789',
            PersonBirthdate = Date.newInstance(2000, 05, 22),
            CC_NumPerso__c = '206'
            );
            lstAccounts.add(cuenta);
            //insert cuenta;

            Account cuentaSinTelefono = new Account(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA'),
            FirstName = 'Cuenta',
            LastName = 'Sin Datos',
            CC_Email__c = 'cuenta2@test.com',
            PersonBirthdate = Date.newInstance(2000, 05, 22)
            );
            lstAccounts.add(cuentaSinTelefono);

            Account cuentaSinDatos = new Account(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA'),
            FirstName = 'Cuenta',
            LastName = 'Sin Datos',
            CC_Email__c = 'cuenta2@test.com'
            );
            lstAccounts.add(cuentaSinDatos);
            
            Account cuentaMenor = new Account(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA'),
                FirstName = 'Cuenta',
                LastName = 'Menor',
                PersonBirthdate = Date.newInstance(2014, 10, 22),
                PersonMobilePhone = '+34 123 123 123'
            );

            Account cuentaJuridica = new Account(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente'),
                Name = 'Cuenta Juridica'
            );
            lstAccounts.add(cuentaJuridica);

            insert lstAccounts;

            Contact contacto = new Contact(
                //RecordTypeId = recordTypeContacto,
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(),
                FirstName = 'Contacto',
                LastName = 'Test',
                CC_Idioma__c = 'es',
                Email = 'contacto@test.com'
            );
            lstContacts.add(contacto);

            Contact apoderado = new Contact(
                //RecordTypeId = recordTypeContacto,
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CIBE_Apoderado').getRecordTypeId(),
                FirstName = 'Apoderado',
                LastName = 'Test',
                CC_Idioma__c = 'es',
                Email = 'contacto@test.com',
                accountId = cuentaJuridica.Id
            );
            lstContacts.add(apoderado);

            insert lstContacts;

            CC_Representante_Contrato__c representante = new CC_Representante_Contrato__c(
                RecordTypeId = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId(),
                CC_Nombre__c = 'Representante',
                CC_Apellido1__c = 'Test',
                CC_ClienteRepresentante__c = cuentaMenor.Id,
                CC_Representante__c = cuenta.Id
            );
            insert representante;
            

            List<Case> caseInsertLst = new List<Case>();

            Case caso1 = new Case();
            caso1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso1.Subject = 'Caso Test 1';
            caso1.Status = 'Activo';
            caso1.CC_Canal_Procedencia__c= 'Formulario web';
            caso1.CC_Canal_Respuesta__c = 'Email';
            caso1.CC_Idioma__c = 'es';
            caso1.Origin = 'Email';
            caso1.OwnerId = supervisor.Id;
            caso1.AccountId = cuenta.Id;
            caso1.ContactId = contacto.Id;
            caso1.CC_MailTelfNotif__c  = 'contacto@test.com';
            caseInsertLst.add(caso1);
            
            Case caso2 = new Case();
            caso2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso2.Subject = 'Caso Test 2';
            caso2.Status = 'Activo';
            caso2.CC_Canal_Procedencia__c= 'ImaginBank';
            //caso.CC_Canal_Respuesta__c = 'Email';
            caso2.CC_Idioma__c = 'es';
            caso2.Origin = 'Phone';
            caso2.OwnerId = supervisor.Id;
            caso2.AccountId = cuentaSinDatos.Id;
            caso2.ContactId = contacto.Id;
            caso2.CC_MailTelfNotif__c  = 'contacto@test.com';
            caseInsertLst.add(caso2);

            Case caso3 = new Case();
            caso3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso3.Subject = 'Caso Test 3';
            caso3.CC_Canal_Procedencia__c= 'Formulario web';
            caso3.CC_Representante__c = representante.Id;
            caso3.CC_Canal_Respuesta__c = 'Email';
            caso3.CC_Idioma__c = 'es';
            caso3.Origin = 'Email';
            caso3.AccountId = cuentaMenor.Id;
            caso3.ContactId = contacto.Id;
            caso3.CC_MailTelfNotif__c  = 'contacto@test.com';
            caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            caseInsertLst.add(caso3);

            Case caso4 = new Case();
            caso4.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso4.Subject = 'Caso Test 4';
            caso4.CC_Canal_Procedencia__c = 'Formulario web';
            caso4.CC_Canal_Respuesta__c = 'Email';
            caso4.CC_Idioma__c = 'es';
            caso4.Origin = 'Email';
            caso4.AccountId = cuentaJuridica.Id;
            caso4.ContactId = apoderado.Id;
            caso4.CC_MailTelfNotif__c  = 'contacto@test.com';
            caso4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            caseInsertLst.add(caso4);

            Case caso5 = new Case();
            caso5.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso5.Subject = 'Caso Test 5';
            caso5.Status = 'Activo';
            caso5.CC_Canal_Procedencia__c= 'Formulario web';
            caso5.CC_Canal_Respuesta__c = 'Email';
            caso5.CC_Idioma__c = 'es';
            caso5.Origin = 'Email';
            caso5.OwnerId = supervisor.Id;
            caso5.AccountId = cuentaSinTelefono.Id;
            caso5.ContactId = contacto.Id;
            caso5.CC_MailTelfNotif__c  = 'contacto@test.com';
            caseInsertLst.add(caso5);

            Case casoOperador = new Case();
            casoOperador.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            casoOperador.Subject = 'Caso Test Operador';
            casoOperador.OwnerId = operador.Id;
            casoOperador.CC_Canal_Procedencia__c = 'Formulario web';
            casoOperador.CC_Canal_Respuesta__c = 'Email';
            casoOperador.CC_Idioma__c = 'es';
            casoOperador.Origin = 'Email';
            casoOperador.AccountId = cuentaJuridica.Id;
            casoOperador.ContactId = apoderado.Id;
            casoOperador.CC_MailTelfNotif__c  = 'contacto@test.com';
            casoOperador.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            caseInsertLst.add(casoOperador);

            insert caseInsertLst;
            
            caseInsertLst[1].CC_Canal_Respuesta__c = 'Email';
            update caseInsertLst[1];

            // Inicialización de datos.        
            Id recorTypeLista = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();        
            Id recorTypeValor = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();        
            
            CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
            lista.Name = 'Preguntas Básicas OTPSMS';
            lista.CC_Activa__c = true;
            lista.RecordTypeId = recorTypeLista;
            insert lista;
            
            CC_Lista_Valores__c valor1 = new CC_Lista_Valores__c();
            valor1.Name = 'Nombre completo';
            valor1.CC_Activa__c = true;
            valor1.RecordTypeId = recorTypeValor;
            valor1.CC_Lista__c = lista.Id;
            valor1.CC_Valor__c = 'Nombre completo';
            insert valor1;
            
            CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c();
            valor2.Name = 'Número de identificación';
            valor2.CC_Activa__c = true;
            valor2.RecordTypeId = recorTypeValor;
            valor2.CC_Lista__c = lista.Id;
            valor2.CC_Valor__c = 'Número de identificación (DNI, NIE, pasaporte,…)';
            insert valor2;

            List<CC_Comunicaciones__c> comInsertLst = new List<CC_Comunicaciones__c>();
            Id recordTypeIdOTP = Schema.SObjectType.CC_Comunicaciones__c.getRecordTypeInfosByDeveloperName().get('CC_OTPSMS').getRecordTypeId();
            CC_Comunicaciones__c comunicacion1 =  new CC_Comunicaciones__c();
            comunicacion1.CC_Case__c = caseInsertLst[0].Id;
            comunicacion1.CC_Estado__c = 'Pdte. Validar';
            comunicacion1.RecordTypeId = recordTypeIdOTP;
            comunicacion1.CC_Nivel__c = 'Nivel 2';
            comunicacion1.CC_Cliente__c = cuenta.Id;
            comunicacion1.CC_Ticket__c = '123456789';
            comInsertLst.add(comunicacion1);
            CC_Comunicaciones__c comunicacion2 =  new CC_Comunicaciones__c();
            comunicacion2.CC_Case__c = caseInsertLst[1].Id;
            comunicacion2.CC_Estado__c = 'Pdte. Validar';
            comunicacion2.RecordTypeId = recordTypeIdOTP;
            comunicacion2.CC_Cliente__c = cuenta.Id;
            comunicacion1.CC_Ticket__c = '123456789';
            comInsertLst.add(comunicacion2);
            CC_Comunicaciones__c comunicacion3 =  new CC_Comunicaciones__c();
            comunicacion3.CC_Case__c = caseInsertLst[2].Id;
            comunicacion3.CC_Estado__c = 'Pdte. Validar';
            comunicacion3.RecordTypeId = recordTypeIdOTP;
            comunicacion3.CC_Cliente__c = cuenta.Id;
            comunicacion1.CC_Ticket__c = '123456789';
            comInsertLst.add(comunicacion3);
            insert comInsertLst;

            // Id recorTypeLista = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
            // Id recorTypeValor = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();

            List<CC_Lista_Valores__c> lstValores = new List<CC_Lista_Valores__c>();
            CC_Lista_Valores__c preguntas2Nivel = new CC_Lista_Valores__c();
            preguntas2Nivel.RecordTypeId = recorTypeLista;
            preguntas2Nivel.Name = 'Preguntas OTPSMS 2 Nivel';
            preguntas2Nivel.CC_Activa__c = true;
            insert preguntas2Nivel;

            CC_Lista_Valores__c pregunta1 = new CC_Lista_Valores__c();
            pregunta1.RecordTypeId = recorTypeValor;
            pregunta1.Name = 'Edad del cliente';
            pregunta1.CC_Activa__c = true;
            pregunta1.CC_Valor__c = 'Edad del cliente';
            pregunta1.CC_Lista__c = preguntas2Nivel.Id;
            pregunta1.CC_Servicio__c = 'Pregunta 1';
            pregunta1.CC_Valor_SFDC__c = 'Salesforce';
            pregunta1.CC_Orden__c = 5;
            lstValores.add(pregunta1);

            CC_Lista_Valores__c pregunta2 = new CC_Lista_Valores__c();
            pregunta2.RecordTypeId = recorTypeValor;
            pregunta2.Name = 'Teléfono asociado';
            pregunta2.CC_Activa__c = true;
            pregunta2.CC_Valor__c = 'Teléfono asociado a CaixaBank del cliente';
            pregunta2.CC_Lista__c = preguntas2Nivel.Id;
            pregunta2.CC_Servicio__c = 'Pregunta 2';
            pregunta2.CC_Valor_SFDC__c = 'Salesforce';
            pregunta2.CC_Orden__c = 5;
            lstValores.add(pregunta2);


            CC_Lista_Valores__c validacionesToast = new CC_Lista_Valores__c();
            validacionesToast.RecordTypeId = recorTypeLista;
            validacionesToast.Name = 'Validaciones preguntas 2 Nivel';
            validacionesToast.CC_Activa__c = true;
            insert validacionesToast;

            CC_Lista_Valores__c validacion1 = new CC_Lista_Valores__c();
            validacion1.RecordTypeId = recorTypeValor;
            validacion1.Name = 'CORRECTO';
            validacion1.CC_Activa__c = true;
            validacion1.CC_Valor__c = 'Las respuestas de las preguntas son correctas';
            validacion1.CC_Valor2__c = 'OK';
            validacion1.CC_Lista__c = validacionesToast.Id;
            lstValores.add(validacion1);

            insert lstValores;

            List<CC_Llamada__c> listadoLlamadas = new List<CC_Llamada__c>();
            CC_Llamada__c llamadaEntranteNOKAccount = new CC_Llamada__c(
                CC_Tipo__c = 'Entrante',
                CC_DNIS__c = '679610728',
                CC_Asunto__c = 'llamadaEntranteNOKAccount'
            );
            listadoLlamadas.add(llamadaEntranteNOKAccount);
            CC_Llamada__c llamadaSalienteNOKAccount = new CC_Llamada__c(
                CC_Tipo__c = 'Saliente',
                CC_DNIS__c = '679610728',
                CC_Asunto__c = 'llamadaSalienteNOKAccount'
            );
            listadoLlamadas.add(llamadaSalienteNOKAccount);
            CC_Llamada__c llamadaEntranteOKAccount = new CC_Llamada__c(
                CC_Tipo__c = 'Entrante',
                CC_DNIS__c = '+34 123456789',
                CC_Asunto__c = 'llamadaEntranteOKAccount'
            );            
            listadoLlamadas.add(llamadaEntranteOKAccount);
            CC_Llamada__c llamadaSalienteOKAccount = new CC_Llamada__c(
                CC_Tipo__c = 'Saliente',
                CC_DNIS__c = '+34 123456789',
                CC_Asunto__c = 'llamadaSalienteOKAccount'
            );
            listadoLlamadas.add(llamadaSalienteOKAccount);
            insert listadoLlamadas;

            List<Task> taskList = new List<Task>();
            Id recordTypeIdTask = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            Task task = new Task();
            task.Status = 'Open';
            task.WhatId = caso1.id;
            task.RecordTypeId = recordTypeIdTask;
            task.CC_Llamada_Id__c = llamadaSalienteOKAccount.Id;
            taskList.add(task);

            Task task2 = new Task();
            task2.Status = 'Open';
            task2.WhatId = caso2.id;
            task2.RecordTypeId = recordTypeIdTask;
            task2.CC_Llamada_Id__c = llamadaSalienteNOKAccount.Id;
            taskList.add(task2);

            Task task3 = new Task();
            task3.Status = 'Open';
            task3.WhatId = caso3.id;
            task3.RecordTypeId = recordTypeIdTask;
            task3.CC_Llamada_Id__c =  llamadaEntranteNOKAccount.Id;
            taskList.add(task3);

            Task task4 = new Task();
            task4.Status = 'Open';
            task4.WhatId = caso4.id;
            task4.RecordTypeId = recordTypeIdTask;
            task4.CC_Llamada_Id__c = llamadaEntranteOKAccount.Id;
            taskList.add(task4);

            Task task5 = new Task();
            task5.Status = 'Open';
            task5.WhatId = caso5.id;
            task5.RecordTypeId = recordTypeIdTask;
            taskList.add(task5);
            insert taskList;

                            
            List<CC_Settings__c> settings = new List<CC_Settings__c>();
            CC_Settings__c parametrosIntegracion = new CC_Settings__c(
                Name = 'CC_Integracion_Autenticacion',
                CC_Activa__c = true,
                CC_Configuracion_1__c = 'walletle',
                CC_Configuracion_2__c = 'true',
                CC_Configuracion_3__c = 'false',
                CC_Configuracion_4__c = 'N',
                CC_Configuracion_5__c = 1,
                CC_Configuracion_6__c = '10',
                CC_Configuracion_7__c = ''
            );
            settings.add(parametrosIntegracion);
            
            CC_Settings__c parametrosPerfiles = new CC_Settings__c(
                Name = 'CC_PerfilesAutentication',
                CC_Activa__c = true,
                CC_Configuracion_1__c = 'CC',
                CC_Configuracion_2__c = 'CSBD',
                CC_Configuracion_3__c = 'HDT'

            );
            settings.add(parametrosPerfiles);

            CC_Settings__c parametrosBloqueos = new CC_Settings__c(
                Name = 'CC_Autenticacion_Bloqueos',
                CC_Activa__c = true,
                CC_Configuracion_1__c = '2',
                CC_Configuracion_2__c = '24'

            );
            settings.add(parametrosBloqueos);

            CC_Settings__c recuperarTarjetasDatos = new CC_Settings__c(
                Name = 'recuperarTarjetasDatos',
                CC_Activa__c = true,
                CC_Configuracion_1__c = 'CARD_MASKEDPAN',
                CC_Configuracion_2__c = 'CARD_STATUSMAINCARD'

            );
            settings.add(recuperarTarjetasDatos);

            CC_Settings__c recuperarTarjetasFiltro = new CC_Settings__c(
                Name = 'recuperarTarjetasFiltro',
                CC_Activa__c = true,
                CC_Configuracion_1__c = 'ACTIVE_CARD'

            );
            settings.add(recuperarTarjetasFiltro);
            CC_Settings__c autenticacion = new CC_Settings__c(
                Name = 'autenticacion',
                CC_Activa__c = true
            );
            settings.add(autenticacion);

            CC_Settings__c  customSettingAut = new CC_Settings__c ();
            customSettingAut.Name = 'CC_Autenticacion';
            customSettingAut.CC_Activa__c = true;
            settings.add(customSettingAut);
            insert settings;

            CBK_IntegrationSetting__c customSetting = new CBK_IntegrationSetting__c();
            customSetting.Name = 'CC_Recuperar_Tarjetas';
            customSetting.NamedCredential__c = 'callout:API_GWT_PRO_CCSF/cards/creditCard/bis/cards/customers/id/request';
            customSetting.RegistroTrazaIntegracion__c = true;
            insert customSetting;

            
            // AccountShare acshare = new AccountShare();
            // acshare.AccountId = cuenta.Id;
            // acshare.UserOrGroupId = supervisor.Id;
            // acshare.AccountAccessLevel = 'Edit';
            // acshare.OpportunityAccessLevel = 'Edit';
            // acshare.ContactAccessLevel = 'Edit';
            // acshare.CaseAccessLevel = 'Edit';
            // insert acshare;

            // // AccountShare acshare3 = new AccountShare();
            // // acshare3.AccountId = cuentaMenor.Id;
            // // acshare3.UserOrGroupId = supervisor.Id;
            // // acshare3.AccountAccessLevel = 'Edit';
            // // acshare3.OpportunityAccessLevel = 'Edit';
            // // acshare3.CaseAccessLevel = 'Edit';
            // // insert acshare3;

            // ContactShare contactShare = new ContactShare();
            // contactShare.ContactId = contacto.Id;
            // contactShare.UserOrGroupId = supervisor.Id;
            // contactShare.ContactAccessLevel = 'Edit';
            // insert contactShare;

            // CaseShare conshare = new CaseShare();
            // conshare.CaseAccessLevel = 'Read';
            // conshare.CaseId = caso1.Id;
            // conshare.UserOrGroupId = supervisor.Id; 
            // insert conshare;

            // CaseShare conshare3 = new CaseShare();
            // conshare3.CaseId = caso3.Id;
            // conshare3.UserOrGroupId = supervisor.Id;
            // conshare3.CaseAccessLevel = 'All';
            // insert conshare3;
        }

    }

    @isTest
    public static void testOTP()
    {
        Test.startTest();

        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        List<Case> casesLst = [SELECT Id, Origin, Status, CC_Idioma__c, CC_Canal_Respuesta__c, OwnerId, AccountId FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        Case caso = new Case();
        if (!casesLst.isEmpty()) {
            caso = casesLst[0];
        }

        /*Account cuenta = new Account(
            Name = 'Cuenta Test',
            CC_Email__c = 'cuenta@test.com'
        );
        insert cuenta;*/

        //Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        /*List<Account> acctLst = [SELECT Id, Name, CC_Email__c FROM Account WHERE Name = 'Cuenta Test' AND CC_Email__c = 'cuenta@test.com' LIMIT 1];
        Account cuenta = new Account();
        if (!acctLst.isEmpty()) {
            cuenta = acctLst[0];
        }
        
        Contact contacto = new Contact(
        //RecordTypeId = recordTypeContacto,
        RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(),
        FirstName = 'Contacto',
        LastName = 'Test',      
        AccountId = cuenta.Id,
        CC_Idioma__c = 'es',
        Email = 'contacto@test.com'   
        );
        insert contacto;
        */
        /*Case caso = new Case();
        caso.Subject = 'Caso Test ';
        caso.CC_Canal_Procedencia__c= 'Formulario web';
        caso.CC_Canal_Respuesta__c = 'Email';
        caso.CC_Idioma__c = 'es';
        caso.Origin = 'Email';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.CC_MailTelfNotif__c  = 'contacto@test.com';
        insert caso;*/


        //Obtenemos los datos del caso 
        //List<Case> datosCaso = CC_OTP.datosCaso(caso.Id);

        //System.assertEquals(caso.Id, datosCaso[0].Id);
        //System.assertEquals('Email', datosCaso[0].Origin);
        //System.assertEquals('Activo', datosCaso[0].Status);
        //System.assertEquals('es', datosCaso[0].CC_Idioma__c);
        //System.assertEquals('Email', datosCaso[0].CC_Canal_Respuesta__c);
        //System.assertEquals(caso.AccountId, datosCaso[0].AccountId);
        
        //Funcionalidades de OTP - ¿existe OTP?
        
        //Boolean resultado = CC_OTP.existeOTPCaso(caso.Id);
        //System.assertEquals(false, resultado);
        //Map<String,Object>  resultadoNuevo = CC_OTP.existeBloqueoNuevo(caso.Id);
        //System.assertEquals(true,  !resultadoNuevo.isEmpty());
        
        /* SELECT Id FROM CC_Comunicaciones__c
        
        CC_Comunicaciones__c comunicacion = new CC_Comunicaciones__c();
        comunicacion.*/
        
        //Obtenemos valores de una picklist
        //List<String> valoresPickList = CC_OTP.getPicklistValues('CC_Comunicaciones__c','CC_Nivel__c');
        
        // Inicialización de datos.        
        /*Id recorTypeLista = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();        
        Id recorTypeValor = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();        
        
        CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
        lista.Name = 'Preguntas Básicas OTPSMS';
        lista.CC_Activa__c = true;
        lista.RecordTypeId = recorTypeLista;
        insert lista;
        
        CC_Lista_Valores__c valor1 = new CC_Lista_Valores__c();
        valor1.Name = 'Nombre completo';
        valor1.CC_Activa__c = true;
        valor1.RecordTypeId = recorTypeValor;
        valor1.CC_Lista__c = lista.Id;
        valor1.CC_Valor__c = 'Nombre completo';
        insert valor1;
        
        CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c();
        valor2.Name = 'Número de identificación';
        valor2.CC_Activa__c = true;
        valor2.RecordTypeId = recorTypeValor;
        valor2.CC_Lista__c = lista.Id;
        valor2.CC_Valor__c = 'Número de identificación (DNI, NIE, pasaporte,…)';
        insert valor2;*/
        
        //Devuelve las preguntas que se le hacen al cliente

            List<CC_Lista_Valores__c> preguntas = CC_OTP.preguntasOTP('Preguntas Básicas OTPSMS');    
            System.assert(preguntas.size() >=2 );
        
        
        // List<CC_OTP.OTPWrapper> wrapperOTP = new List<CC_OTP.OTPWrapper>();

        
        /*Id recordTypeIdOTP = Schema.getGlobalDescribe().get('CC_Comunicaciones__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_OTPSMS').getRecordTypeId();
        CC_Comunicaciones__c comunicacion =  new CC_Comunicaciones__c();
        comunicacion.CC_Case__c = caso.Id;
        comunicacion.CC_Estado__c = 'Pdte. Validar';
        comunicacion.RecordTypeId = recordTypeIdOTP;
        comunicacion.CC_Cliente__c = cuenta.Id;
        insert comunicacion;*/
        List<CC_Comunicaciones__c> comLst = [SELECT Id FROM CC_Comunicaciones__c WHERE CC_Case__c=:caso.Id LIMIT 1];
        CC_Comunicaciones__c comunicacion = new CC_Comunicaciones__c();
        if (!comLst.isEmpty()) {
            comunicacion = comLst[0];
        }
        String  clienteId = caso.AccountId;   
        List<CC_OTP.OTPWrapper> wrapperOTP = CC_OTP.obtenerOTPCliente(caso.Id, clienteId);
        //system.assert(wrapperOTP.size()>1);  
        //
        //
        String resultadoOTPValido = CC_OTP.gestionesSegunNivel(caso.Id, true, 'Nivel 1');
        String resultadoOTPKO = CC_OTP.gestionesSegunNivel(caso.Id, false, 'Nivel 1');
        System.runAs(supervisor){
            Map<string, string> resultadoSegundoNivelOK = CC_OTP.segundoNivel(caso.Id, true, 'Nivel 2',  'Edad del cliente', 'Teléfono asociado a CaixaBank del cliente', '20', '123456789', 'OK', 'OK', true, true);
            Map<string, string> resultadoSegundoNivelKO = CC_OTP.segundoNivel(caso.Id, false, 'Nivel 2', 'Edad del cliente', 'Teléfono asociado a CaixaBank del cliente', '20', '123456789', 'OK', 'OK', true, true);
        }
        List<CC_OTP.OTPWrapper> wrapperOTPHistorico = CC_OTP.obtenerHistoricoOTPCliente(caso.Id, clienteId);
        system.assert(wrapperOTPHistorico.size()>1);  
                    
        string resultadoIntentos = CC_OTP.comprobarIntentos(caso.Id, clienteId);
        system.assertEquals('OK', resultadoIntentos);
        
        String resultadoValidacion = CC_OTP.validarRegistro(caso.Id, comunicacion.Id, '1234');
        CC_OTP.enviarRegistro(comunicacion.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testOTP2()
    {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        
        List<Case> casesLst = [SELECT Id, Origin, Status, CC_Idioma__c, CC_Canal_Respuesta__c, OwnerId, AccountId FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        Case caso = new Case();
        if (!casesLst.isEmpty()) {
            caso = casesLst[0];
        }
        //String casoId, Boolean valido, String nivel, String pregunta1, String pregunta2, String respuesta1, String respuesta2, String validacion1, String validacion2, Boolean enviarSMS
        Test.startTest();
        Map<String, String> resultadoSegundoNivelClienteDigital = CC_OTP.segundoNivel(caso.Id, false, 'Cliente Digital', caso.AccountId, caso.CC_Idioma__c, caso.OwnerId, null, null, null, false, false);
        //Devuelve las preguntas que se le hacen al cliente
        System.runAs(supervisor) {
            List<CC_Lista_Valores__c> preguntas = CC_OTP.preguntasOTP('Preguntas Básicas OTPSMS');    
            System.assert(preguntas.size() >=2 );
        }
        
        List<CC_Comunicaciones__c> comLst = [SELECT Id FROM CC_Comunicaciones__c WHERE CC_Case__c=:caso.Id LIMIT 1];
        CC_Comunicaciones__c comunicacion = new CC_Comunicaciones__c();
        if (!comLst.isEmpty()) {
            comunicacion = comLst[0];
        }
            
        List<CC_OTP.OTPWrapper> wrapperOTP = CC_OTP.obtenerOTPCliente(caso.Id, caso.AccountId);
        String resultadoOTPValido = CC_OTP.gestionesSegunNivel(caso.Id, true, 'Nivel 1');
        System.runAs(supervisor){
          Map<string, string> resultadoSegundoNivelOK = CC_OTP.segundoNivel(caso.Id, true, 'Nivel 2',  'Edad del cliente', 'Teléfono asociado a CaixaBank del cliente', '20', '123456789', 'OK', 'OK', true, true);
        }
        List<CC_OTP.OTPWrapper> wrapperOTPHistorico = CC_OTP.obtenerHistoricoOTPCliente(caso.Id, caso.AccountId);
        system.assert(wrapperOTPHistorico.size()>1);

        string resultadoIntentos = CC_OTP.comprobarIntentos(caso.Id, caso.AccountId);
        system.assertEquals('OK', resultadoIntentos);

        String resultadoValidacion = CC_OTP.validarRegistro(caso.Id, comunicacion.Id, '1234');
        CC_OTP.enviarRegistro(comunicacion.Id);

        String resultadoValidacionPruebaNull = CC_OTP.validarRegistro(caso.Id, null, '1234');
        CC_OTP.enviarRegistro(comunicacion.Id);

        Test.stopTest();
    }

    @isTest
    public static void testOTP4()
    {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];

        List<Case> casesLst = [SELECT Id, Origin, Status, CC_Idioma__c, CC_Canal_Respuesta__c, OwnerId, AccountId FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        Case caso = new Case();
        if (!casesLst.isEmpty()) {
            caso = casesLst[0];
        }
        Test.startTest();
        Map<String, String> resultadoSegundoNivelClienteDigital = CC_OTP.segundoNivel(caso.Id, false, 'Cliente Digital', caso.AccountId, caso.CC_Idioma__c, caso.OwnerId, null, null, null, false, false);
        System.runAs(supervisor) {
            List<CC_Lista_Valores__c> preguntas = CC_OTP.preguntasOTP('Preguntas Básicas OTPSMS');
            System.assert(preguntas.size() >=2 );
        }

        List<CC_Comunicaciones__c> comLst = [SELECT Id FROM CC_Comunicaciones__c WHERE CC_Case__c=:caso.Id LIMIT 1];
        CC_Comunicaciones__c comunicacion = new CC_Comunicaciones__c();
        if (!comLst.isEmpty()) {
            comunicacion = comLst[0];
        }

        String resultadoOTPKO = CC_OTP.gestionesSegunNivel(caso.Id, false, 'Nivel 1');
        System.runAs(supervisor){
            Map<string, string> resultadoSegundoNivelKO = CC_OTP.segundoNivel(caso.Id, false, 'Nivel 2', 'Edad del cliente', 'Teléfono asociado a CaixaBank del cliente', '20', '123456789', 'OK', 'OK', true, true);
        }
        List<CC_OTP.OTPWrapper> wrapperOTPHistorico = CC_OTP.obtenerHistoricoOTPCliente(caso.Id, caso.AccountId);
        system.assert(wrapperOTPHistorico.size()>1);
                    
        string resultadoIntentos = CC_OTP.comprobarIntentos(caso.Id, caso.AccountId);
        system.assertEquals('OK', resultadoIntentos);
        
        String resultadoValidacion = CC_OTP.validarRegistro(caso.Id, comunicacion.Id, '1234');
        CC_OTP.enviarRegistro(comunicacion.Id);

        String resultadoValidacionPruebaNull = CC_OTP.validarRegistro(caso.Id, null, '1234');
        CC_OTP.enviarRegistro(comunicacion.Id);
        
        Test.stopTest();
    }
    
    @isTest
    public static void noRecibidoTest(){
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        /*Account cuenta = new Account(
            Name = 'Cuenta Test',
            CC_Email__c = 'cuenta@test.com'
        );
        insert cuenta;
        
        Case caso = new Case();
        caso.Subject = 'Caso Test ';
        caso.CC_Canal_Procedencia__c= 'Formulario web';
        caso.CC_Canal_Respuesta__c = 'Email';
        caso.CC_Idioma__c = 'es';
        caso.Origin = 'Email';
        caso.AccountId = cuenta.Id;
        caso.CC_MailTelfNotif__c  = 'contacto@test.com';
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        insert caso;*/
        List<Case> casesLst = [SELECT Id, Origin, Status, CC_Idioma__c, CC_Canal_Respuesta__c, OwnerId FROM Case WHERE Subject = 'Caso Test 3' LIMIT 1];
        Case caso = new Case();
        if (!casesLst.isEmpty()) {
            caso = casesLst[0];
        }
        
        /*Id recordTypeIdOTP = Schema.getGlobalDescribe().get('CC_Comunicaciones__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_OTPSMS').getRecordTypeId();
        CC_Comunicaciones__c comunicacion =  new CC_Comunicaciones__c();
        comunicacion.CC_Case__c = caso.Id;
        comunicacion.CC_Estado__c = 'Pdte. Validar';
        comunicacion.RecordTypeId = recordTypeIdOTP;
        comunicacion.CC_Cliente__c = cuenta.Id;
        insert comunicacion;*/
        List<CC_Comunicaciones__c> comLst = [SELECT Id FROM CC_Comunicaciones__c WHERE CC_Case__c=:caso.Id LIMIT 1];
        CC_Comunicaciones__c comunicacion = new CC_Comunicaciones__c();
        if (!comLst.isEmpty()) {
            comunicacion = comLst[0];
        }
        System.runAs(supervisor) {
            Test.startTest();
            CC_OTP.mensajeNoRecibido(comunicacion.Id, caso.Id);
            system.assertEquals('OTP No recibida', [SELECT CC_Estado__c FROM CC_Comunicaciones__c WHERE Id = :comunicacion.Id].CC_Estado__c);
            Test.stopTest();
        }
    }

    // @isTest
    // public static void testExisteBloqueo(){
    //     User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1]; 

    //     Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];

    //     //Obtenemos los datos del caso 
    //     //List<Case> datosCaso = CC_OTP.datosCaso(caso.Id);

        

    //     //Devuelve las preguntas que se le hacen al cliente
    //    /* System.runAs(supervisor)
    //     {
    //         Boolean resultado = CC_OTP.existeOTPCaso(caso.Id);
    //         System.assertEquals(false, resultado);
    //         Boolean  resultadoNuevo = CC_OTP.existeBloqueo(caso.Id);
    //         System.assertEquals(true,  resultadoNuevo);
    //     }*/
        
    // }

    @isTest
    public static void validarCanalAutenticacionTest() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];

        CC_Lista_Valores__c listaAutenticacionCliente = new CC_Lista_Valores__c();
        listaAutenticacionCliente.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        listaAutenticacionCliente.CC_Activa__c = true;
        listaAutenticacionCliente.Name = 'CC_Autenticacion_Cliente';
        insert listaAutenticacionCliente;
        
        CC_Lista_Valores__c valorTelefono = new CC_Lista_Valores__c();
        valorTelefono.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorTelefono.CC_Activa__c = true;
        valorTelefono.CC_Lista__c = listaAutenticacionCliente.Id;
        valorTelefono.Name = 'Teléfono';
        valorTelefono.CC_Valor__c = 'Teléfono';
        insert valorTelefono;
        
        /*CC_Lista_Valores__c valorDesactivado = new CC_Lista_Valores__c();
        valorDesactivado.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorDesactivado.CC_Activa__c = false;
        valorDesactivado.CC_Lista__c = listaAutenticacionCliente.Id;
        valorDesactivado.Name = 'Twitter';
        valorDesactivado.CC_Valor__c = 'Twitter';
        insert valorDesactivado;*/
        
        Case caso = new Case(
            Status = 'Activo',
            Origin = 'Phone',
            CC_Canal_Procedencia__c = 'Accionista'
        );
        insert caso;

        Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        Case casoInvalido = new Case(
            recordTypeId = recordTypeCaso,
            Status = 'Activo',
            Origin = 'Chat',
            CC_Canal_Procedencia__c = 'App'
        );
        insert casoInvalido;

        //Devuelve las preguntas que se le hacen al cliente
        System.runAs(supervisor)
        {
            Test.startTest();
            System.assertEquals(true,  CC_OTP.validarCanalAutenticacion(caso.Id));
            System.assertEquals(false,  CC_OTP.validarCanalAutenticacion(casoInvalido.Id));
            Test.stopTest();
        }   
    }

    @isTest
    public static void preguntasNivelDosTest() {
        // Id recorTypeLista = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        // Id recorTypeValor = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();

        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        Map<String,String> preguntas = CC_OTP.preguntasOTP2Nivel('Preguntas OTPSMS 2 Nivel', caso.Id);
        List<String> preguntasMapa = preguntas.values();
        //Devuelve las preguntas que se le hacen al cliente
        System.runAs(supervisor)
        {
            Test.startTest();
            System.assertEquals('Edad del cliente', preguntasMapa[0]);
            Test.stopTest();
        }
    }

    @isTest
    public static void validacionPreguntasTest() {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id rtContactClientePA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
        wsc.Name = 'CC_Autenticacion_Cuenta';
        wsc.NamedCredential__c = 'callout:API_GWT_PRO_CCSF/accountingServices/positionKeeping/accounts/request';
        insert wsc;
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        Account cuenta = [SELECT Id FROM Account WHERE CC_NumPerso__c = '206'];
        
        List<Boolean> validaciones = new List<Boolean>();
        validaciones.add(true);
        validaciones.add(true);
        validaciones.add(true);
        //Devuelve las preguntas que se le hacen al cliente
        System.runAs(supervisor)
        {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion_Validacion(200));
            List<Boolean> lista = CC_OTP.validacionPreguntas(caso.Id, 'Últimos 4 dígitos de una cuenta del cliente', 'Edad del cliente', '9491', '24');
            System.assertEquals(validaciones, lista);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void validacionPreguntasTestDos() {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id rtContactClientePA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
        wsc.Name = 'CC_Autenticacion_Cuenta';
        wsc.NamedCredential__c = 'callout:API_GWT_PRO_CCSF/accountingServices/positionKeeping/accounts/request';
        insert wsc;
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        Account cuenta = [SELECT Id FROM Account WHERE CC_NumPerso__c = '206'];
        
        List<Boolean> validaciones = new List<Boolean>();
        validaciones.add(true);
        validaciones.add(false);
        validaciones.add(true);
        //Devuelve las preguntas que se le hacen al cliente
        System.runAs(supervisor)
        {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion_Validacion(200));
            //'Últimos 4 dígitos de una cuenta del cliente' 9491
            List<Boolean> lista = CC_OTP.validacionPreguntas(caso.Id, 'teléfono del cliente', 'Últimos 4 dígitos de una tarjeta del cliente', '123456789', '9491');
            System.assertEquals(validaciones, lista);
            Test.stopTest();
        }
    }

    @isTest
    public static void validacionPreguntasTestTres() {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id rtContactClientePA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
        wsc.Name = 'CC_Autenticacion_Cuenta';
        wsc.NamedCredential__c = 'callout:API_GWT_PRO_CCSF/accountingServices/positionKeeping/accounts/request';
        insert wsc;
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 3' LIMIT 1];
        Account cuenta = [SELECT Id FROM Account WHERE CC_NumPerso__c = '206'];
        
        List<Boolean> validaciones = new List<Boolean>();
        validaciones.add(true);
        validaciones.add(true);
        validaciones.add(false);
        //Devuelve las preguntas que se le hacen al cliente
        System.runAs(supervisor)
        {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion_Validacion(200));
            List<Boolean> lista = CC_OTP.validacionPreguntas(caso.Id, 'Edad del cliente', 'teléfono del cliente', '24', '+34 123456789');
            System.assertEquals(validaciones, lista);
            Test.stopTest();
        }
    }

    @isTest
    public static void validacionPreguntasTestCuatro() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 3' LIMIT 1];
        
        List<Boolean> validaciones = new List<Boolean>();
        validaciones.add(true);
        validaciones.add(true);
        validaciones.add(false);
        //Devuelve las preguntas que se le hacen al cliente
        System.runAs(supervisor)
        {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion_Validacion(200));
            List<Boolean> lista = CC_OTP.validacionPreguntas(caso.Id, 'teléfono del cliente', 'Edad del cliente', '+34 123456789', '24');
            System.assertEquals(validaciones, lista);
            Test.stopTest();
        }
    }

    @isTest
    public static void validacionPreguntasTestCinco() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        
        List<Boolean> validaciones = new List<Boolean>();
        validaciones.add(true);
        validaciones.add(true);
        validaciones.add(true);
        //Devuelve las preguntas que se le hacen al cliente
        System.runAs(supervisor)
        {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion_Validacion(200));
            List<Boolean> lista = CC_OTP.validacionPreguntas(caso.Id, 'Edad del cliente', 'teléfono del cliente', '24', '123456789');
            System.assertEquals(validaciones, lista);
            Test.stopTest();
        }
    }

    @isTest
    public static void validacionPreguntasTestSeis() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 4' LIMIT 1];
        
        List<Boolean> validaciones = new List<Boolean>();
        validaciones.add(false);
        validaciones.add(false);
        validaciones.add(false);
        //Devuelve las preguntas que se le hacen al cliente
        System.runAs(supervisor)
        {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion_Validacion(200));
            List<Boolean> lista = CC_OTP.validacionPreguntas(caso.Id, 'teléfono del cliente', 'Edad del cliente', '123456789', '24');
            System.assertEquals(validaciones, lista);
            Test.stopTest();
        }
    }

    @isTest
    public static void clienteDigitalTest(){
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT Id, AccountId, OwnerId FROM Case WHERE Subject = 'Caso Test 2' LIMIT 1];
        CC_Settings__c aut = [SELECT Id, Name, CC_Activa__c FROM CC_Settings__c WHERE Name = 'CC_Autenticacion'];
        System.runAs(supervisor)
        {
            Test.startTest();
            String resultado = CC_OTP.clienteDigital(caso.Id.toString(), caso.AccountId.toString(), caso.OwnerId.toString());
            System.assertEquals('OK', resultado);
            aut.CC_Activa__c = false;
            update aut;
            String resultadoNoActiva = CC_OTP.clienteDigital(caso.Id.toString(), caso.AccountId.toString(), caso.OwnerId.toString());
            System.assertEquals('OK', resultado);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void autenticacionCanceladaTest(){
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT Id, AccountId, OwnerId FROM Case WHERE Subject = 'Caso Test 2' LIMIT 1];
        CC_Comunicaciones__c comunicacionId = [SELECT Id, CC_Estado__c FROM CC_Comunicaciones__c  WHERE CC_Estado__c = 'Pdte. Validar' LIMIT 1];
        System.runAs(supervisor)
        {
            Test.startTest();
            CC_OTP.autenticacionCancelada(comunicacionId.Id, caso.Id);
            Case casoResultado = [SELECT Id, CC_Status_Autorizacion__c FROM Case WHERE CC_Status_Autorizacion__c = 'UNAUTHORIZED' LIMIT 1];
            CC_Comunicaciones__c comunicacion = [SELECT Id, CC_Estado__c FROM CC_Comunicaciones__c WHERE CC_Estado__c = 'Cancelada por agente' LIMIT 1];

            System.assertEquals('UNAUTHORIZED', casoResultado.CC_Status_Autorizacion__c);
            System.assertEquals('Cancelada por agente', comunicacion.CC_Estado__c);
            Test.stopTest();
        }
    }

    @isTest
    public static void validacionMensajeToastTest() {
        CC_Lista_Valores__c listaValores = CC_OTP.mensajeValidacionPreguntas('OK');
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        System.runAs(supervisor)
        {
            Test.startTest();
            System.assertEquals('CORRECTO', listaValores.Name);
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarDatos2NivelFisico() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 2' LIMIT 1];
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];

        string error = CC_OTP.comprobarDatos2Nivel(caso.Id);
        Map<String,String> preguntasMapa = CC_OTP.preguntasOTP2Nivel('Preguntas OTPSMS 2 Nivel', caso.Id);
        List<String> lst = preguntasMapa.values();

        System.runAs(supervisor)
        {
            Test.startTest();
            System.assertEquals('SIN DATOS', error, 'Error en comprobarDatos2NivelFisico, datos no esperados');
            System.assertEquals(lst.contains('true'), true);
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarDatos2NivelFisicoDos() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 5' LIMIT 1];
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];

        string error = CC_OTP.comprobarDatos2Nivel(caso.Id);
         Map<String,String> preguntasMapa = CC_OTP.preguntasOTP2Nivel('Preguntas OTPSMS 2 Nivel', caso.Id);
        List<String> lst = preguntasMapa.values();

        System.runAs(supervisor)
        {
            Test.startTest();
            System.assertEquals('OK', error, 'Error en comprobarDatos2NivelFisicoDos, datos no esperados');
            System.assertEquals(lst.contains('true'), false);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void comprobarDatos2NivelMenor() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 3' LIMIT 1];
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];

        string error = CC_OTP.comprobarDatos2Nivel(caso.Id);
        Map<String,String> preguntasMapa = CC_OTP.preguntasOTP2Nivel('Preguntas OTPSMS 2 Nivel', caso.Id);
        List<String> lst = preguntasMapa.values();

        System.runAs(supervisor)
        {
            Test.startTest();
            System.assertEquals('OK', error, 'Error en comprobarDatos2NivelMenor, datos no esperados');
            System.assertEquals(lst.contains('true'), false);
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarDatos2NivelApoderado() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 4' LIMIT 1];
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        string error = CC_OTP.comprobarDatos2Nivel(caso.Id);
        Map<String,String> preguntasMapa = CC_OTP.preguntasOTP2Nivel('Preguntas OTPSMS 2 Nivel', caso.Id);
        List<String> lst = preguntasMapa.values();

        System.runAs(supervisor)
        {
            Test.startTest();
            System.assertEquals('SIN DATOS', error, 'Error en comprobarDatos2NivelApoderado, datos no esperados');
            System.assertEquals(lst.contains('true'), true);
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarDatosNOKTask1(){
        
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 4' LIMIT 1];
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Task task = [SELECT Id FROM Task WHERE WhatId = :caso.Id];
        task.WhatId = null;
        update task;

        string error = CC_OTP.comprobarDatos2Nivel(caso.Id);
         Map<String,String> preguntasMapa = CC_OTP.preguntasOTP2Nivel('Preguntas OTPSMS 2 Nivel', caso.Id);
        List<String> lst = preguntasMapa.values();

        System.runAs(supervisor)
        {
            Test.startTest();
            // System.assertEquals('SIN DATOS', error, 'Error en comprobarDatosNOKTask, datos no esperados');
            System.assertEquals(lst.contains('true'), true);
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarDatosNOKTask2() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test Operador' LIMIT 1];

        User operador = [SELECT Id FROM User WHERE FirstName = 'Operador' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        System.runAs(operador) {
            Test.startTest();
            string error = CC_OTP.comprobarDatos2Nivel(caso.Id);
            Map<String,String> preguntasMapa = CC_OTP.preguntasOTP2Nivel('Preguntas OTPSMS 2 Nivel', caso.Id);
            List<String> lst = preguntasMapa.values();
            Test.stopTest();

            System.assertEquals('SIN LLAMADAS', error, 'Error en comprobarDatosNOKTask, datos no esperados');
            System.assertEquals(lst.contains('true'), true);
        }
    }

    @isTest
    public static void existeBloqueoNuevoTest(){
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 3' LIMIT 1];
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        System.runAs(supervisor)
        {
            Test.startTest();
            Map<String,Object> resultado = CC_OTP.existeBloqueoNuevo(caso.Id);
            System.assertEquals(false, resultado.get('Resultado'));
            Test.stopTest(); 
        }
    }

}