@isTest
public with sharing class CC_OTP_Test {

    @testSetup static void setup() {
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
        //insert usuarioAdmin;
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
        insert new List<User>{operador, supervisor, usuarioAdmin};

            insert new List<PermissionSetAssignment> {
                new PermissionSetAssignment(AssigneeId = supervisor.Id, PermissionSetId = psOperador.Id),
                new PermissionSetAssignment(AssigneeId = supervisor.Id, PermissionSetId = psClasses.Id),
                new PermissionSetAssignment(AssigneeId = supervisor.Id, PermissionSetId = psSupervisor.Id),
                new PermissionSetAssignment(AssigneeId = supervisor.Id, PermissionSetId = psAutenticacion.Id),
                new PermissionSetAssignment(AssigneeId = operador.Id, PermissionSetId = psOperador.Id),
                new PermissionSetAssignment(AssigneeId = operador.Id, PermissionSetId = psClasses.Id)
            };

        System.runAs(usuarioAdmin) {
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
            
            Account cuentaMenor = new Account(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA'),
                FirstName = 'Cuenta',
                LastName = 'Menor',
                PersonBirthdate = Date.newInstance(2014, 10, 22),
                PersonMobilePhone = '+34 123 123 123'
            );
            lstAccounts.add(cuentaMenor);

            Account cuentaJuridica = new Account(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente'),
                Name = 'Cuenta Juridica'
            );
            lstAccounts.add(cuentaJuridica);

            insert lstAccounts;

            Contact contacto = new Contact(
                //RecordTypeId = recordTypeContacto,
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente'),
                FirstName = 'Contacto',
                LastName = 'Test',
                CC_Idioma__c = 'es',
                Email = 'contacto@test.com'
            );
            lstContacts.add(contacto);

            Contact apoderado = new Contact(
                //RecordTypeId = recordTypeContacto,
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CIBE_Apoderado'),
                FirstName = 'Apoderado',
                LastName = 'Test',
                CC_Idioma__c = 'es',
                Email = 'contacto@test.com',
                accountId = cuentaJuridica.Id
            );
            lstContacts.add(apoderado);

            insert lstContacts;

            CC_Representante_Contrato__c representante = new CC_Representante_Contrato__c(
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Representante_Contrato__c', 'CC_Representante'),
                CC_Nombre__c = 'Representante',
                CC_Apellido1__c = 'Test',
                CC_ClienteRepresentante__c = cuentaMenor.Id,
                CC_Representante__c = cuenta.Id
            );
            insert representante;
            
            Id recordTem = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            Id recordProd = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
            Id recordMot = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');

            CC_MCC__c mcc = new CC_MCC__c();
            mcc.RecordTypeId = recordTem;
            mcc.Name = 'App\'s';
            mcc.CC_Tipo_Cliente__c = 'Cliente';
            mcc.CC_Codigo_Externo__c = 'TE-000001';
            mcc.CC_Canal_Operativo__c = 'App BrokerNow';
            insert mcc;
            CC_MCC__c mcc1 = new CC_MCC__c();
            mcc1.RecordTypeId = recordProd;
            mcc1.Name = 'APP CaixaBank';
            mcc1.CC_Detalle__c = 'CaixaBank';
            mcc1.CC_Tipo_Cliente__c = 'Cliente';
            mcc1.CC_Tematica__c = mcc.Id;
            mcc1.CC_Codigo_Externo__c = 'PR-000001';
            insert mcc1;
            CC_MCC__c mcc2 = new CC_MCC__c();
            mcc2.RecordTypeId = recordMot;
            mcc2.Name = 'Valoración positiva';
            mcc2.CC_Tipo_Cliente__c = 'Cliente';
            mcc2.CC_Producto_Servicio__c = mcc1.Id;
            mcc2.CC_Codigo_Externo__c = 'MO-000001';
            mcc2.CC_ImpedirNivel2__c = true;
            mcc2.CC_ImpedirClienteDigital__c = false;
            insert mcc2;

            CC_MCC__c mcc3 = new CC_MCC__c();
            mcc3.Name = 'Solicita reversión';
            mcc3.CC_Tipo_Cliente__c = 'Cliente';
            mcc3.CC_Fecha_Vigencia_Inicio__c = date.today();
            mcc3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
            mcc3.CC_Motivo__c = mcc2.Id;
            mcc3.CC_Codigo_Externo__c = 'CA-000001';
            mcc3.CC_Omitir_preguntas_Nivel_2__c = false;
            insert mcc3;
            CC_MCC__c mcc4 = new CC_MCC__c();
            mcc4.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
            mcc4.Name = 'Actualizar Sistema';
            mcc4.CC_Tipo_Cliente__c = 'Cliente';
            mcc4.CC_Causa__c = mcc3.Id;
            mcc4.CC_Codigo_Externo__c = 'CA-000002';
            insert mcc4;
            
            List<Case> caseInsertLst = new List<Case>();

            //Caso Generico
            Case caso1 = new Case();
            caso1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso1.Subject = 'Caso Test 1';
            caso1.Status = 'Activo';
            caso1.CC_Canal_Procedencia__c = 'Accionista';
            caso1.CC_Canal_Respuesta__c = 'Email';
            caso1.CC_Idioma__c = 'es';
            caso1.Origin = 'Phone';
            caso1.OwnerId = supervisor.Id;
            caso1.AccountId = cuenta.Id;
            caso1.ContactId = contacto.Id;
            caso1.CC_MailTelfNotif__c  = 'contacto@test.com';
            caso1.CC_MCC_Tematica__c = mcc.Id;
            caso1.CC_MCC_ProdServ__c = mcc1.Id;
            caso1.CC_MCC_Motivo__c = mcc2.Id;
            caso1.CC_MCC_Causa__c = mcc3.Id;
            caso1.CC_MCC_Solucion__c = mcc4.Id;
            caseInsertLst.add(caso1);
            
            //Caso cuenta menor
            Case caso3 = new Case();
            caso3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso3.Subject = 'Caso Test 3';
            caso3.CC_Canal_Procedencia__c= 'Accionista';
            caso3.CC_Representante__c = representante.Id;
            caso3.CC_Canal_Respuesta__c = 'Phone';
            caso3.CC_Idioma__c = 'es';
            caso3.Origin = 'Phone';
            caso3.AccountId = cuentaMenor.Id;
            caso3.ContactId = contacto.Id;
            caso3.CC_MailTelfNotif__c  = 'contacto@test.com';
            caso3.CC_MCC_Causa__c = mcc3.Id;
            caso3.CC_MCC_Solucion__c = mcc4.Id;
            caseInsertLst.add(caso3);

            //Caso juridico
            Case caso4 = new Case();
            caso4.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso4.Subject = 'Caso Test 4';
            caso4.OwnerId = operador.Id;
            caso4.CC_Canal_Procedencia__c = 'Accionista';
            caso4.CC_Canal_Respuesta__c = 'Phone';
            caso4.CC_Idioma__c = 'es';
            caso4.Origin = 'Phone';
            caso4.AccountId = cuentaJuridica.Id;
            caso4.ContactId = apoderado.Id;
            caso4.CC_MailTelfNotif__c  = 'contacto@test.com';
            caso4.CC_MCC_Causa__c = mcc3.Id;
            caso4.CC_MCC_Solucion__c = mcc4.Id;
            caseInsertLst.add(caso4);

            insert caseInsertLst;
            
            // Inicialización de datos.        
            Id recorTypeLista =CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');       
            
            List<CC_Lista_Valores__c> lstListas = new List<CC_Lista_Valores__c>();
            
            CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
            lista.Name = 'Preguntas Básicas OTPSMS';
            lista.CC_Activa__c = true;
            lista.RecordTypeId = recorTypeLista;
            lstListas.add(lista);

            CC_Lista_Valores__c preguntas2Nivel = new CC_Lista_Valores__c();
            preguntas2Nivel.RecordTypeId = recorTypeLista;
            preguntas2Nivel.Name = 'Preguntas OTPSMS 2 Nivel';
            preguntas2Nivel.CC_Activa__c = true;
            lstListas.add(preguntas2Nivel);

            CC_Lista_Valores__c validacionesToast = new CC_Lista_Valores__c();
            validacionesToast.RecordTypeId = recorTypeLista;
            validacionesToast.Name = 'Validaciones preguntas 2 Nivel';
            validacionesToast.CC_Activa__c = true;
            lstListas.add(validacionesToast);

            CC_Lista_Valores__c listaAutenticacionCliente = new CC_Lista_Valores__c();
            listaAutenticacionCliente.RecordTypeId = recorTypeLista;
            listaAutenticacionCliente.CC_Activa__c = true;
            listaAutenticacionCliente.Name = 'CC_Autenticacion_Cliente';
            lstListas.add(listaAutenticacionCliente);


            insert lstListas;

            Id recorTypeValor = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');  
            
            List<CC_Lista_Valores__c> lstValores = new List<CC_Lista_Valores__c>();     
            
            CC_Lista_Valores__c valor1 = new CC_Lista_Valores__c();
            valor1.Name = 'Nombre completo';
            valor1.CC_Activa__c = true;
            valor1.RecordTypeId = recorTypeValor;
            valor1.CC_Lista__c = lista.Id;
            valor1.CC_Valor__c = 'Nombre completo';
            lstValores.add(valor1);
            
            CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c();
            valor2.Name = 'Número de identificación';
            valor2.CC_Activa__c = true;
            valor2.RecordTypeId = recorTypeValor;
            valor2.CC_Lista__c = lista.Id;
            valor2.CC_Valor__c = 'Número de identificación (DNI, NIE, pasaporte,…)';
            lstValores.add(valor2);

            CC_Lista_Valores__c pregunta1 = new CC_Lista_Valores__c();
            pregunta1.RecordTypeId = recorTypeValor;
            pregunta1.Name = 'Edad del cliente';
            pregunta1.CC_Activa__c = true;
            pregunta1.CC_Valor__c = 'Edad del cliente';
            pregunta1.CC_Lista__c = preguntas2Nivel.Id;
            pregunta1.CC_Servicio__c = 'Pregunta 1';
            pregunta1.CC_Orden__c = 5;
            pregunta1.CC_Mensajes_Mostrar__c = 'Test';
            lstValores.add(pregunta1);

            CC_Lista_Valores__c pregunta2 = new CC_Lista_Valores__c();
            pregunta2.RecordTypeId = recorTypeValor;
            pregunta2.Name = 'Teléfono asociado';
            pregunta2.CC_Activa__c = true;
            pregunta2.CC_Valor__c = 'Teléfono asociado a CaixaBank del cliente';
            pregunta2.CC_Lista__c = preguntas2Nivel.Id;
            pregunta2.CC_Servicio__c = 'Pregunta 2';
            pregunta2.CC_Orden__c = 5;
            pregunta2.CC_Mensajes_Mostrar__c = 'Test';
            lstValores.add(pregunta2);

            CC_Lista_Valores__c validacion1 = new CC_Lista_Valores__c();
            validacion1.RecordTypeId = recorTypeValor;
            validacion1.Name = 'CORRECTO';
            validacion1.CC_Activa__c = true;
            validacion1.CC_Valor__c = 'Las respuestas de las preguntas son correctas';
            validacion1.CC_Valor2__c = 'OK';
            validacion1.CC_Lista__c = validacionesToast.Id;
            lstValores.add(validacion1);

            CC_Lista_Valores__c valorTelefono = new CC_Lista_Valores__c();
            valorTelefono.RecordTypeId = recorTypeValor;
            valorTelefono.CC_Activa__c = true;
            valorTelefono.CC_Lista__c = listaAutenticacionCliente.Id;
            valorTelefono.Name = 'Teléfono';
            valorTelefono.CC_Valor__c = 'Teléfono';
            lstValores.add(valorTelefono);

            insert lstValores;

            List<CC_Comunicaciones__c> comInsertLst = new List<CC_Comunicaciones__c>();
            Id recordTypeIdOTP = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS'); 
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
            comunicacion3.CC_Nivel__c = 'Nivel 2';
            comunicacion3.CC_Estado__c = 'Pdte. Validar';
            comunicacion3.RecordTypeId = recordTypeIdOTP;
            comunicacion3.CC_Cliente__c = cuenta.Id;
            comunicacion1.CC_Ticket__c = '123456789';
            comInsertLst.add(comunicacion3);
            insert comInsertLst;

            List<CC_Comunicaciones__Share> share = new List<CC_Comunicaciones__Share>();
            for(CC_Comunicaciones__c a : [SELECT Id FROM CC_Comunicaciones__c]) {
                CC_Comunicaciones__Share acshare = new CC_Comunicaciones__Share(
                    ParentId = a.Id,
                    UserOrGroupId = supervisor.Id, // Dar acceso al usuario actual
                    AccessLevel = 'Edit' // o 'Read'
                );
                share.add(acshare);
            }

            Boolean excepcion = false;
            // try {
            Database.insert(share, false);
            // insert share;
            // } catch(Exception e) {
            //     excepcion = true;
            // }

            List<CC_MCC__Share> totalPermisosMCC = new List<CC_MCC__Share>();
            for(CC_MCC__c record : [SELECT Id FROM CC_MCC__c]) {
                CC_MCC__Share mccShare = new CC_MCC__Share();
                mccShare.ParentId = record.Id;
                mccShare.UserOrGroupId = supervisor.Id;
                mccShare.AccessLevel = 'Edit';
                totalPermisosMCC.add(mccShare);
            }
            insert totalPermisosMCC;

            List<AccountShare> totalPermisosAccount = new List<AccountShare>();
            for(Account a : [SELECT Id FROM Account]) {
                AccountShare acshare = new AccountShare();
                acshare.AccountId = a.Id;
                acshare.UserOrGroupId = supervisor.Id;
                acshare.AccountAccessLevel = 'Edit';
                acshare.OpportunityAccessLevel = 'Edit';
                acshare.CaseAccessLevel = 'Edit';
                totalPermisosAccount.add(acshare);
            }

            
            Boolean excepcion2 = false;
            
            // try {
            Database.insert(totalPermisosAccount, false);
            // insert totalPermisosAccount;
            // } catch(Exception e) {
            //     excepcion2 = true;
            // }
            
            List<ContactShare> totalPermisosContact = new List<ContactShare>();
            for(Contact c : [SELECT Id FROM Contact]) {
            ContactShare contactShare = new ContactShare();
            contactShare.ContactId = c.Id;
            contactShare.UserOrGroupId = supervisor.Id;
            contactShare.ContactAccessLevel = 'Edit';
            totalPermisosContact.add(contactShare);
            }
            Boolean excepcion3 = false;

            // try {
            Database.insert(totalPermisosContact, false);
            // insert totalPermisosContact;
            // } catch(Exception e) {
            //     excepcion3 = true;
            // }


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
            task.WhatId = caso1.Id;
            task.RecordTypeId = recordTypeIdTask;
            task.CC_Llamada_Id__c = llamadaSalienteOKAccount.Id;
            taskList.add(task);


            Task task3 = new Task();
            task3.Status = 'Open';
            task3.WhatId = caso3.Id;
            task3.RecordTypeId = recordTypeIdTask;
            task3.CC_Llamada_Id__c =  llamadaEntranteNOKAccount.Id;
            taskList.add(task3);

            Task task4 = new Task();
            task4.Status = 'Open';
            task4.WhatId = caso4.Id;
            task4.RecordTypeId = recordTypeIdTask;
            task4.CC_Llamada_Id__c = llamadaEntranteOKAccount.Id;
            taskList.add(task4);

            insert taskList;

            CC_Caracteristica__c caracteristicaCuenta = new CC_Caracteristica__c();
            caracteristicaCuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Caracteristica__c', 'CC_Cliente_Cuenta');
            caracteristicaCuenta.Name = 'Característica Cuenta';
            caracteristicaCuenta.CC_Descripcion__c = 'descripcion';
            caracteristicaCuenta.OS_Negocio__c = 'FRA';
            caracteristicaCuenta.CC_RestriccionTotal__c = true;
            insert caracteristicaCuenta;

            CC_MCC_Caracteristica__c mccCaracteristica = new CC_MCC_Caracteristica__c();
            mccCaracteristica.CC_MCC__c = mcc2.Id;
            mccCaracteristica.CC_Caracteristica__c = caracteristicaCuenta.Id;
            insert mccCaracteristica;

            
                            
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

            CC_Settings__c  circuitoAutenticacion = new CC_Settings__c ();
            circuitoAutenticacion.Name = 'CC_CircuitoAutenticacion';
            circuitoAutenticacion.CC_Activa__c = true;
            settings.add(circuitoAutenticacion);
            
            CC_Settings__c  visibilidadBotonEmergenciaAut = new CC_Settings__c ();
            visibilidadBotonEmergenciaAut.Name = 'CC_VisibilidadBotonEmergenciaAut';
            visibilidadBotonEmergenciaAut.CC_Activa__c = true;
            settings.add(visibilidadBotonEmergenciaAut);
            
            CC_Settings__c  preguntaMenores65 = new CC_Settings__c ();
            preguntaMenores65.Name = 'CC_PreguntaMenores65';
            preguntaMenores65.CC_Activa__c = true;
            settings.add(preguntaMenores65);

            CC_Settings__c  edadLimite = new CC_Settings__c ();
            edadLimite.Name = 'CC_EdadAutenticacion';
            edadLimite.CC_Activa__c = true;
            edadLimite.CC_Configuracion_1__c = '65';
            settings.add(edadLimite);
            

            insert settings;

            List<CBK_IntegrationSetting__c> lstCS = new List<CBK_IntegrationSetting__c>();
            CBK_IntegrationSetting__c integracionTarjetas = new CBK_IntegrationSetting__c();
            integracionTarjetas.Name = 'CC_Recuperar_Tarjetas';
            integracionTarjetas.NamedCredential__c = 'callout:API_GWT_PRO_CCSF/cards/creditCard/bis/cards/customers/Id/request';
            integracionTarjetas.RegistroTrazaIntegracion__c = true;
            lstCS.add(integracionTarjetas);

            CBK_IntegrationSetting__c integracionCuentas = new CBK_IntegrationSetting__c();
            integracionCuentas.Name = 'CC_Autenticacion_Cuenta';
            integracionCuentas.NamedCredential__c = 'callout:API_GWT_PRO_CCSF/accountingServices/positionKeeping/accounts/request';
            lstCS.add(integracionCuentas);

            insert lstCS;
        }

    }

    @isTest
    public static void testOTP() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT Origin, Status, CC_Idioma__c, CC_Canal_Respuesta__c, OwnerId, AccountId FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        CC_Comunicaciones__c comunicacion = [SELECT Id FROM CC_Comunicaciones__c WHERE CC_Case__c = :caso.Id LIMIT 1];
        
        System.runAs(supervisor){
            Test.startTest();
                CC_OTP.reiniciarDerivar(caso.Id);
                List<CC_Lista_Valores__c> preguntas = CC_OTP.preguntasOTP('Preguntas Básicas OTPSMS');    
                System.assert(preguntas.size() > = 2, '');
                String clienteId = caso.AccountId;   
        List<CC_OTP.OTPWrapper> wrapperOTP = CC_OTP.obtenerOTPCliente(caso.Id, clienteId);

        String resultadoOTPValido = CC_OTP.gestionesSegunNivel(caso.Id, true, 'Nivel 1');
        String resultadoOTPKO = CC_OTP.gestionesSegunNivel(caso.Id, false, 'Nivel 1');

                Map<string, string> resultadoSegundoNivelOK = CC_OTP.segundoNivel(caso.Id, true, 'Nivel 2',  'Edad del cliente', 'Teléfono asociado a CaixaBank del cliente', '20', '123456789', 'OK', 'OK', true, true, false);
                Map<string, string> resultadoSegundoNivelKO = CC_OTP.segundoNivel(caso.Id, false, 'Nivel 2', 'Edad del cliente', 'Teléfono asociado a CaixaBank del cliente', '20', '123456789', 'OK', 'OK', true, true, false);

                List<CC_OTP.OTPWrapper> wrapperOTPHistorico = CC_OTP.obtenerHistoricoOTPCliente(caso.Id, clienteId);
                System.assert(wrapperOTPHistorico.size() > 1, '');  
                            
                string resultadoIntentos = CC_OTP.comprobarIntentos(caso.Id, clienteId);
                System.assertEquals('OK', resultadoIntentos, '');
        
        String resultadoValidacion = CC_OTP.validarRegistro(caso.Id, comunicacion.Id, '1234');
        CC_OTP.enviarRegistro(comunicacion.Id);
        Test.stopTest();
    }
    }

    @isTest
    public static void testGetOTP() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT Origin, Status, CC_Idioma__c, CC_Canal_Respuesta__c, OwnerId, AccountId FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        
        CC_Comunicaciones__c comunicacion = new CC_Comunicaciones__c(
            CC_Case__c = caso.Id,
            CC_Estado__c = 'Pendiente',
            CC_Nivel__c = 'Nivel 1',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS')
        );
        insert comunicacion;
        
        System.runAs(supervisor){
            Test.startTest();
                Id otpId = CC_OTP.getOTP(caso.Id, 'Nivel 1', 'Pendiente');
                System.assert(otpId != null, 'No se obtuvo el ID del OTP');
            Test.stopTest();
        }
    }

    @isTest
    public static void testSegundoNivelElse() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        
        System.runAs(supervisor) {
            Test.startTest();
                Map<String, String> resultado = CC_OTP.segundoNivel(caso.Id, false, 'Nivel 2', 'Edad del cliente', 'Teléfono asociado a CaixaBank del cliente', '20', '123456789', 'OK', 'OK', false, false, false);
                System.assertEquals('Para realizar la operación que nos solicita es necesario identificar al titular del contrato. Una mera conversación telefónica no sirve para realizar dicha identificación y usted no ha superado las preguntas de seguridad que le hemos realizado por lo que no es posible hacer dicha operación. Estamos seguros que comprenderá nuestro compromiso con la seguridad de nuestros clientes.', resultado.get('Resultado'), '');
            Test.stopTest();
    }
    }
    
    @isTest
    public static void noRecibidoTest(){
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT Id, Origin, Status, CC_Idioma__c, CC_Canal_Respuesta__c, OwnerId FROM Case WHERE Subject = 'Caso Test 3' LIMIT 1];
        CC_Comunicaciones__c comunicacion = [SELECT Id, RecordType.DeveloperName, CC_Estado__c, CC_Nivel__c FROM CC_Comunicaciones__c WHERE CC_Case__c=:caso.Id LIMIT 1];

        System.runAs(supervisor) {
            Test.startTest();
                CC_OTP.mensajeNoRecibido(comunicacion.Id, caso.Id);
                System.assertEquals('OTP No recibida', [SELECT CC_Estado__c FROM CC_Comunicaciones__c WHERE Id = :comunicacion.Id].CC_Estado__c, '');
            Test.stopTest();
        }
    }

    @isTest
    public static void validarCanalAutenticacionTest() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];

        Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        Case casoInvalido = new Case(
            recordTypeId = recordTypeCaso,
            Status = 'Activo',
            Origin = 'Chat',
            CC_Canal_Procedencia__c = 'App'
        );
        insert casoInvalido;

        //Devuelve las preguntas que se le hacen al cliente
        System.runAs(supervisor) {
            Test.startTest();
            System.assertEquals(true,  CC_OTP.validarCanalAutenticacion(caso.Id), '');
            System.assertEquals(false,  CC_OTP.validarCanalAutenticacion(casoInvalido.Id), '');
            Test.stopTest();
        }   
    }

    // @isTest
    // public static void preguntasNivelDosTest() {
    //     User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
    //     Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        
    //     //Devuelve las preguntas que se le hacen al cliente
    //     System.runAs(supervisor) {
    //         Test.startTest();
    //         Map<String,String> preguntas = CC_OTP.preguntasOTP2Nivel('Preguntas OTPSMS 2 Nivel', caso.Id);
    //         System.assertEquals(4, preguntas.size(), '');
    //         Test.stopTest();
    //     }
    // }

    @isTest
    public static void validacionPreguntasTest() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        List<Boolean> validaciones = new List<Boolean>();
        validaciones.add(true);
        validaciones.add(true);
        validaciones.add(true);
        //Devuelve las preguntas que se le hacen al cliente
        System.runAs(supervisor) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion_Validacion(200));
            List<Boolean> lista = CC_OTP.validacionPreguntas(caso.Id, 'Últimos 4 dígitos de una cuenta del cliente', 'Edad del cliente', '9491', '24', '[9491, 2222]', null);
            System.assertEquals(validaciones, lista, '');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void validacionPreguntasTestDos() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        
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
            List<Boolean> lista = CC_OTP.validacionPreguntas(caso.Id, 'teléfono del cliente', 'Últimos 4 dígitos de una tarjeta del cliente', '123456789', '9491',null, '[9492, 2222]');
            System.assertEquals(validaciones, lista, '');
            Test.stopTest();
        }
    }

    @isTest
    public static void validacionPreguntasTestTres() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 3' LIMIT 1];
        
        List<Boolean> validaciones = new List<Boolean>();
        validaciones.add(true);
        validaciones.add(true);
        validaciones.add(false);
        //Devuelve las preguntas que se le hacen al cliente
        System.runAs(supervisor) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion_Validacion(200));
            List<Boolean> lista = CC_OTP.validacionPreguntas(caso.Id, 'Edad del cliente', 'teléfono del cliente', '24', '+34 123456789', null, null);
            System.assertEquals(validaciones, lista, '');
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
        System.runAs(supervisor) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion_Validacion(200));
            List<Boolean> lista = CC_OTP.validacionPreguntas(caso.Id, 'teléfono del cliente', 'Edad del cliente', '+34 123456789', '24', null, null);
            System.assertEquals(validaciones, lista, '');
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
        System.runAs(supervisor) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion_Validacion(200));
            List<Boolean> lista = CC_OTP.validacionPreguntas(caso.Id, 'Edad del cliente', 'teléfono del cliente', '24', '123456789', null, null);
            System.assertEquals(validaciones, lista, '');
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
        System.runAs(supervisor) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion_Validacion(200));
            List<Boolean> lista = CC_OTP.validacionPreguntas(caso.Id, 'teléfono del cliente', 'Edad del cliente', '123456789', '24', null, null);
            System.assertEquals(validaciones, lista, '');
            Test.stopTest();
        }
    }

    @isTest
    public static void clienteDigitalTest(){
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT AccountId, OwnerId FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        CC_Settings__c aut = [SELECT Name, CC_Activa__c FROM CC_Settings__c WHERE Name = 'CC_Autenticacion'];
        System.runAs(supervisor)
        {
            Test.startTest();
            String resultado = CC_OTP.clienteDigital(caso.Id.toString(), caso.AccountId.toString(), caso.OwnerId.toString());
            System.assertEquals('OK', resultado, '');
            aut.CC_Activa__c = false;
            update aut;
            String resultadoNoActiva = CC_OTP.clienteDigital(caso.Id.toString(), caso.AccountId.toString(), caso.OwnerId.toString());
            System.assertEquals('OK', resultado, '');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void autenticacionCanceladaTest(){
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Case caso = [SELECT AccountId, OwnerId FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        CC_Comunicaciones__c comunicacionId = [SELECT Id, CC_Estado__c FROM CC_Comunicaciones__c  WHERE CC_Estado__c = 'Pdte. Validar' LIMIT 1];
        System.runAs(supervisor) {
            Test.startTest();
            CC_OTP.autenticacionCancelada(comunicacionId.Id, caso.Id);
            Case casoResultado = [SELECT Id, CC_Status_Autorizacion__c FROM Case WHERE CC_Status_Autorizacion__c = 'UNAUTHORIZED' LIMIT 1];
            CC_Comunicaciones__c comunicacion = [SELECT Id, CC_Estado__c FROM CC_Comunicaciones__c WHERE CC_Estado__c = 'Cancelada por agente' LIMIT 1];

            System.assertEquals('UNAUTHORIZED', casoResultado.CC_Status_Autorizacion__c, '');
            System.assertEquals('Cancelada por agente', comunicacion.CC_Estado__c, '');
            Test.stopTest();
        }
    }

    @isTest
    public static void validacionMensajeToastTest() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        System.runAs(supervisor) {
            Test.startTest();
            CC_Lista_Valores__c listaValores = CC_OTP.mensajeValidacionPreguntas('OK');
            System.assertEquals('CORRECTO', listaValores.Name, '');
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarDatos2NivelFisicoSinDatos() {
        Case caso = [SELECT Id, AccountId FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Account cuenta = [SELECT Id FROM Account WHERE Id = :caso.AccountId];
        cuenta.PersonMobilePhone = null;
        cuenta.PersonBirthdate = null;
        update cuenta;
        System.runAs(supervisor) {
            Test.startTest();
            Map<String,String> error = CC_OTP.comprobarDatos2Nivel(caso.Id, 'Preguntas OTPSMS 2 Nivel');
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
                List<String> lst = error.values();
                System.assertEquals('SIN DATOS', error.get('error'), 'Error en comprobarDatos2NivelFisico, datos no esperados');
                //System.assertEquals(lst.contains('true'), true, '');
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarDatos2NivelFisico() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];

        System.runAs(supervisor) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
            Map<String,String> error = CC_OTP.comprobarDatos2Nivel(caso.Id, 'Preguntas OTPSMS 2 Nivel');
            List<String> lst = error.values();
                System.assertEquals('OK', error.get('error'), 'Error en comprobarDatos2NivelFisicoDos, datos no esperados');
                System.assertEquals(lst.contains('true'), false, '');
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarDatos2NivelFisicoCuenta() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        CC_Lista_Valores__c preguntasNivel2 = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'Preguntas OTPSMS 2 Nivel' LIMIT 1];

        CC_Lista_Valores__c preguntaEdad = [SELECT CC_Activa__c FROM CC_Lista_Valores__c WHERE CC_Lista__c = :preguntasNivel2.Id AND Name = 'Edad del cliente' LIMIT 1];
        CC_Lista_Valores__c preguntaTelefono = [SELECT CC_Activa__c FROM CC_Lista_Valores__c WHERE CC_Lista__c = :preguntasNivel2.Id AND Name = 'Teléfono asociado' LIMIT 1];
        
        List<CC_Lista_Valores__c> preguntasUpd = new List<CC_Lista_Valores__c>();
        preguntaEdad.CC_Activa__c = false;
        preguntasUpd.add(preguntaEdad);
        preguntaTelefono.CC_Activa__c = false;
        preguntasUpd.add(preguntaTelefono);
        update preguntasUpd;

        
        List<CC_Lista_Valores__c> preguntasInsert = new List<CC_Lista_Valores__c>();
        CC_Lista_Valores__c pregunta1Cuenta = new CC_Lista_Valores__c();
        pregunta1Cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        pregunta1Cuenta.Name = 'Cuenta';
        pregunta1Cuenta.CC_Activa__c = true;
        pregunta1Cuenta.CC_Valor__c = 'Últimos 4 dígitos de una cuenta del cliente';
        pregunta1Cuenta.CC_Lista__c = preguntasNivel2.Id;
        pregunta1Cuenta.CC_Servicio__c = 'Pregunta 1';
        pregunta1Cuenta.CC_Orden__c = 5;
        pregunta1Cuenta.CC_Mensajes_Mostrar__c = 'Test';
        preguntasInsert.add(pregunta1Cuenta);

        CC_Lista_Valores__c pregunta2Cuenta = new CC_Lista_Valores__c();
        pregunta2Cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        pregunta2Cuenta.Name = 'Cuenta';
        pregunta2Cuenta.CC_Activa__c = true;
        pregunta2Cuenta.CC_Valor__c = 'Últimos 4 dígitos de una cuenta del cliente';
        pregunta2Cuenta.CC_Lista__c = preguntasNivel2.Id;
        pregunta2Cuenta.CC_Servicio__c = 'Pregunta 2';
        pregunta2Cuenta.CC_Orden__c = 5;
        pregunta2Cuenta.CC_Mensajes_Mostrar__c = 'Test';
        preguntasInsert.add(pregunta2Cuenta);

        insert preguntasInsert;

        System.runAs(supervisor) {
            Test.startTest();
            Map<String,String> error = CC_OTP.comprobarDatos2Nivel(caso.Id, 'Preguntas OTPSMS 2 Nivel');
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
            List<String> lst = error.values();
            System.assertEquals('SIN DATOS API', error.get('error'), 'Error en comprobarDatos2NivelFisicoCuenta, datos no esperados');
            //System.assertEquals(lst.contains('true'), false, '');
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarDatos2NivelFisicoPreguntaForzada() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 3' LIMIT 1];
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Account cuenta = [SELECT Id FROM Account WHERE CC_NumPerso__c = '206' LIMIT 1];
        cuenta.PersonMobilePhone = null;
        cuenta.PersonBirthdate = null;
        update cuenta;

        System.runAs(supervisor) {
            Test.startTest();
            Map<String,String> error = CC_OTP.comprobarDatos2Nivel(caso.Id, 'Preguntas OTPSMS 2 Nivel');
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
            List<String> lst = error.values();
            System.assertEquals('SIN DATOS', error.get('error'), 'Error en comprobarDatos2NivelFisicoPreguntaForzada, datos no esperados');
            //System.assertEquals(lst.contains('false'), false, '');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void comprobarDatos2NivelMenor() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 3' LIMIT 1];
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];

        System.runAs(supervisor) {
            Test.startTest();
            Map<String,String> error = CC_OTP.comprobarDatos2Nivel(caso.Id, 'Preguntas OTPSMS 2 Nivel');
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
            List<String> lst = error.values();
            System.assertEquals('OK', error.get('error'), 'Error en comprobarDatos2NivelMenor, datos no esperados');
            //System.assertEquals(lst.contains('true'), false, '');
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarDatos2NivelApoderado() {
        Case caso = [SELECT Id, Account.RecordType.DeveloperName, Contact.RecordType.DeveloperName FROM Case WHERE Subject = 'Caso Test 4' LIMIT 1];
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        System.runAs(supervisor) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
            Map<String,String> error = CC_OTP.comprobarDatos2Nivel(caso.Id, 'Preguntas OTPSMS 2 Nivel');
            List<String> lst = error.values();
            System.assertEquals('SIN DATOS', error.get('error'), 'Error en comprobarDatos2NivelApoderado, datos no esperados');
            //System.assertEquals(lst.contains('true'), true, '');
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

        System.runAs(supervisor)
        {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
            Map<String,String> error = CC_OTP.comprobarDatos2Nivel(caso.Id, 'Preguntas OTPSMS 2 Nivel');
            List<String> lst = error.values();
            System.assertEquals(lst.size() > 0, true, '');
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarDatosNOKTask2() {
        User operador = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        System.runAs(operador) {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 4' LIMIT 1];
        Task task = [SELECT Id FROM Task WHERE WhatId = :caso.Id];
        task.WhatId = null;

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
            Map<String,String> error = CC_OTP.comprobarDatos2Nivel(caso.Id, 'Preguntas OTPSMS 2 Nivel');
            List<String> lst = error.values();
            System.assertEquals('SIN DATOS', error.get('error'), 'Error en comprobarDatosNOKTask2, datos no esperados');
            //System.assertEquals(lst.contains('true'), true, '');
            Test.stopTest();
        }
    }

    @isTest
    public static void existeBloqueoNuevoTest(){
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        System.runAs(supervisor) {
            Test.startTest();
            List<Case> casos = [SELECT Id FROM Case WHERE Subject IN ('Caso Test 1','Caso Test 3') LIMIT 2];
                Map<String,Object> resultado = CC_OTP.existeBloqueoNuevo(casos[0].Id);
                System.assertEquals(false, resultado.get('Resultado'), '');
                Map<String,Object> resultado2 = CC_OTP.existeBloqueoNuevo(casos[1].Id);
                System.assertEquals(false, resultado2.get('Resultado'), '');
            Test.stopTest(); 
        }
    }

    @isTest
    public static void validarContratoSAUTest() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        System.runAs(supervisor) {
            Test.startTest();
                String testsss = CC_OTP.validarContratoSAU(caso.Id);
                System.assertEquals(true, true, '');
            Test.stopTest();
        }
    }

    @isTest
    public static void validarNacimientoTest() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        System.runAs(supervisor) {
            Test.startTest();
                List<Boolean> lstValidaciones = CC_OTP.validacionPreguntas(caso.Id, 'año', 'edad', '2000', '20', null, null);
                System.assertEquals(true, lstValidaciones[0], '');
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarCaracteristicasClienteTest() {
        Case caso = [SELECT AccountId FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];

        CC_Caracteristica__c caracteristicaCuenta = [SELECT Id FROM CC_Caracteristica__c WHERE Name = 'Característica Cuenta' LIMIT 1];
        CC_Caracteristica_Detalle__c caracteristicaDetalle = new CC_Caracteristica_Detalle__c();
        caracteristicaDetalle.CC_Cuenta__c = caso.AccountId;
        caracteristicaDetalle.CC_Caracteristica__c = caracteristicaCuenta.Id;
        insert caracteristicaDetalle;
        
        System.runAs(supervisor) {
            Test.startTest();
                String resultado = CC_OTP.comprobarCaracteristicasCliente(caso.Id);
                System.assertEquals('restriccion_total', resultado, '');
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarCaracteristicasClienteDosTest() {
        Case caso = [SELECT CC_MCC_Motivo__c FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        
        System.runAs(supervisor) {
            Test.startTest();
                String resultado = CC_OTP.comprobarCaracteristicasCliente(caso.Id);
                System.assertEquals('autenticar', resultado, '');
            Test.stopTest();
        }
    }

    private class MockHttpResponseExito implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) { 
            String bodyClienteDigital = '{"totalCards":1,"hasExcluded":false,"CardList":[{"maskedPan":"403051******9035","statusMainCard":"ACTIVE_CARD"}]}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(bodyClienteDigital);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    public static void testAsignarPregunta() {
        Case caso = [SELECT Account.RecordType.DeveloperName,Account.PersonBirthdate, Account.AV_Age__c,Account.PersonMobilePhone,CC_Representante__c,CC_Representante__r.CC_Representante__r.PersonMobilePhone,CC_Representante__r.CC_Representante__r.AV_Age__c, CC_Representante__r.CC_Representante__r.PersonBirthdate, CC_Representante__r.CC_Representante__r.AV_NumPerso__c,CC_Representante__r.CC_Representante__r.CC_NumPerso__c,Contact.RecordType.DeveloperName,Contact.CIBE_Telefono1__c,Contact.AV_NumPerso__c,Contact.CIBE_NumPerso__c, Contact.CC_NumPerso__c, Account.AV_NumPerso__c,Account.CC_NumPerso__c,CC_MCC_Causa__r.CC_Omitir_preguntas_Nivel_2__c, CC_MCC_Motivo__r.CC_Motivo_OmitirSMSNivel2__c FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        
        System.runAs(supervisor) {
            Test.startTest();
        // Prepare data for the method
        Map<String, String> preguntas = new Map<String, String>();
        Map<String, String> preguntas1 = new Map<String, String>();
        Map<String, String> preguntas2 = new Map<String, String>();
        preguntas1.put('Edad del cliente', '¿Cuál es la edad del cliente?');
        preguntas1.put('Número de cuenta', '¿Cuál es el número de cuenta del cliente?');
        preguntas2.put('Teléfono asociado', '¿Cuál es el teléfono asociado al cliente?');
        preguntas2.put('Número de tarjeta', '¿Cuál es el número de tarjeta del cliente?');

        // Call the method with different scenarios
        CC_OTP.asignarPregunta(preguntas, 'Pregunta1', preguntas1, caso, null, null);
        CC_OTP.asignarPregunta(preguntas, 'Pregunta2', preguntas2, caso, null, null);

        // Verify the results
        System.assert(preguntas.containsKey('Pregunta1'));
        System.assert(preguntas.containsKey('TextoAyudaPregunta1'));
        System.assert(preguntas.containsKey('Pregunta2'));
        System.assert(preguntas.containsKey('TextoAyudaPregunta2'));

        // Test with forced question
        preguntas.clear();
        CC_OTP.asignarPregunta(preguntas, 'Pregunta1', preguntas1, caso, 'edad', null);
        CC_OTP.asignarPregunta(preguntas, 'Pregunta2', preguntas2, caso, 'telefono', null);

        // Verify the results
        System.assertEquals('Edad del cliente', preguntas.get('Pregunta1'));
        System.assertEquals('¿Cuál es la edad del cliente?', preguntas.get('TextoAyudaPregunta1'));
        System.assertEquals('Teléfono asociado', preguntas.get('Pregunta2'));
        System.assertEquals('¿Cuál es el teléfono asociado al cliente?', preguntas.get('TextoAyudaPregunta2'));

        // Test with forced API question
        preguntas.clear();
        CC_OTP.asignarPregunta(preguntas, 'Pregunta1', preguntas1, caso, null, 'cuenta');
        CC_OTP.asignarPregunta(preguntas, 'Pregunta2', preguntas2, caso, null, 'tarjeta');

        // Verify the results
        System.assertEquals('Número de cuenta', preguntas.get('Pregunta1'));
        System.assertEquals('¿Cuál es el número de cuenta del cliente?', preguntas.get('TextoAyudaPregunta1'));
        System.assertEquals('Número de tarjeta', preguntas.get('Pregunta2'));
        System.assertEquals('¿Cuál es el número de tarjeta del cliente?', preguntas.get('TextoAyudaPregunta2'));
        Test.stopTest();
    }
    }

    @isTest
    public static void testValidarRegistro() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        System.runAs(supervisor) {
            Case caso = [SELECT Id, AccountId FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
            
            
            CC_Comunicaciones__c testOTP = new CC_Comunicaciones__c(
                CC_Case__c = caso.Id,
                CC_Cliente__c = caso.AccountId,
                CC_Nivel__c = 'Nivel 2',
                CC_Estado__c = 'Pdte. Validar',
                CC_Ticket__c = 'sagklj12312kj',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS')
                );
                insert testOTP;
                
                // Mock the response from CC_WS_Validacion_OTP
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseExitoOTP());
                
                Test.startTest();
        // Call the method
        String resultado = CC_OTP.validarRegistro(caso.Id, testOTP.Id, '12345');
        Test.stopTest();
        // Verify the results
        System.assertEquals('OK', resultado);

        // Verify the case was updated correctly
        Case updatedCase = [SELECT CC_OTP_Intentos__c, CC_Status_Autorizacion__c, CC_OTP_Valido__c, CC_OTP_Fecha_Ultima_Validacion__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(1, updatedCase.CC_OTP_Intentos__c);
        System.assertEquals('APPROVED', updatedCase.CC_Status_Autorizacion__c);
        System.assertEquals(true, updatedCase.CC_OTP_Valido__c);
        System.assertNotEquals(null, updatedCase.CC_OTP_Fecha_Ultima_Validacion__c);

        
    }
}
@isTest
public static void testValidarRegistroKO() {
    User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
    System.runAs(supervisor) {
        Case caso = [SELECT Id, AccountId FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        
        
        CC_Comunicaciones__c testOTP = new CC_Comunicaciones__c(
            CC_Case__c = caso.Id,
            CC_Cliente__c = caso.AccountId,
            CC_Nivel__c = 'Nivel 2',
            CC_Estado__c = 'Pdte. Validar',
            CC_Ticket__c = 'sagklj12312kj',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Comunicaciones__c', 'CC_OTPSMS')
            );
            insert testOTP;
        // Test invalid OTP
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseError());
        Test.startTest();
        // Call the method with invalid OTP
        String resultado = CC_OTP.validarRegistro(caso.Id, testOTP.Id, '654321');
        Test.stopTest();
        // Verify the results
        System.assertEquals('OTP errónea', resultado);
        
        // Verify the case was updated correctly
        Case updatedCase = [SELECT CC_OTP_Intentos__c, CC_Status_Autorizacion__c, CC_OTP_Valido__c, CC_OTP_Fecha_Ultima_Validacion__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(1, updatedCase.CC_OTP_Intentos__c);
        System.assertEquals('ERROR', updatedCase.CC_Status_Autorizacion__c);
        System.assertEquals(false, updatedCase.CC_OTP_Valido__c);
        System.assertNotEquals(null, updatedCase.CC_OTP_Fecha_Ultima_Validacion__c);

    }
}


    public class MockHttpResponseExitoOTP implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"CC_Resultado_Validacion__c": "OTP validada correctamente"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class MockHttpResponseError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"CC_Resultado_Validacion__c": "OTP errónea"}');
            res.setStatusCode(400);
            return res;
        }
    }

}