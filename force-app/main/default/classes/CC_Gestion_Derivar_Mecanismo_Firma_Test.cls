@isTest
public class CC_Gestion_Derivar_Mecanismo_Firma_Test {

    @testSetup
    static void setup() {

        User admin = CC_TestDataFactory.insertUserAdmin();
        User operador = CC_TestDataFactory.insertUserOperadorCliente('000001');

        System.runAs(admin){       
            Id rtClientePA = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
            Id rtCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');     
            
            List<AccountShare> totalPermisosAccount = new List<AccountShare>();
            List<ContactShare> totalPermisosContact = new List<ContactShare>();

            List<Account> accounts = new List<Account>();

            Account cuenta = new Account(
                Name = 'Cuenta02'
            );
            accounts.add(cuenta);
            insert accounts;

            for(Account a : accounts){
                AccountShare acshare = new AccountShare();
                acshare.AccountId = a.Id;
                acshare.UserOrGroupId = operador.Id;
                acshare.AccountAccessLevel = 'Edit';
                acshare.OpportunityAccessLevel = 'Edit';
                acshare.CaseAccessLevel = 'Edit';
                totalPermisosAccount.add(acshare);
            }

            insert totalPermisosAccount;

            //Contactos

            List <Contact> insertContact = new List <Contact>();

            Contact oContacto = new Contact( 
                FirstName = 'Contacto',
                LastName = '02',
                CC_NumPerso__c = '12345568',
                AccountId = cuenta.Id,
                CC_Idioma__c = 'Es',
                RecordTypeId = rtCliente
            );

            insertContact.add(oContacto);

            insert insertContact;

            ContactShare contactShare = new ContactShare();
            contactShare.ContactId = oContacto.Id;
            contactShare.UserOrGroupId = CC_TestDataFactory.getUserOperadorCliente().Id;
            contactShare.ContactAccessLevel = 'Edit';
            totalPermisosContact.add(contactShare);

            Boolean excepcion = false;
            
            try {
                //Database.insert(totalPermisosAccount, true);
                insert totalPermisosAccount;
            } catch(Exception e) {
                excepcion = true;
            }

            try {
                //Database.insert(totalPermisosContact, true);
                insert totalPermisosContact;
            } catch(Exception e) {
                excepcion = true;
            }

            Case testCase = new Case(
                Subject='Circuito cliente envío código de firma',
                recordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente'),
                Origin = 'Email',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Tipo_Contacto__c = 'Consulta',
                OwnerId = operador.Id,
                ContactId = oContacto.Id,
                AccountId = cuenta.Id,
                Status = 'Activo'
            );
            insert testCase;
    
            CBK_Case_Extension__c extension = new CBK_Case_Extension__c(
                Case_Id__c = testCase.Id,
                CC_Risk_Denied__c = true,
                CC_Risk_Restricted__C = false
            );

            insert extension;

            testCase.CBK_Case_Extension_Id__c = extension.Id;

            update testCase;
            
            // Crear una tarea de prueba
            Task tareaArgos = new Task(
                Subject = 'Tarea creada al llamar a Argos',
                Status = 'Completed',
                Priority = 'Normal',
                Type = 'Argos',
                CC_Solicitud_Informacion__c = true,
                CC_Detalles_Solucion__c = testCase.AccountId + ' - ' + testCase.ContactId,
                WhatId = testCase.Id
            );
            insert tareaArgos;
    
            Group testQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Videollamada_Enrollment_Caixabank_Sign' LIMIT 1];
            if (testQueue == null) {
                testQueue = new Group(
                    Name = 'Videollamada Enrollment Caixabank Sign',
                    DeveloperName = 'Videollamada_Enrollment_Caixabank_Sign',
                    Type = 'Queue'
                );
                insert testQueue;
            }

            Map <String,OrgWideEmailAddress> owasMap = new Map<String,OrgWideEmailAddress>();
            for (OrgWideEmailAddress owa : [SELECT Id, Address FROM OrgWideEmailAddress]) {
                owasMap.put(String.valueOf(owa.Address), owa);
            }

            List<CC_Buzones_Por_Defecto__mdt> owaPorDefecto = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = true LIMIT 1];
            String emailCorreoEntrante = owaPorDefecto[0].CC_Direccion_Correo__c;
            String plantilla = [SELECT HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_ConsultasOperativasCanalFormulario_Gestionado_CAS_BOT' LIMIT 1].HtmlValue;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{'test@test.com','test2@test.com'});
            email.setSubject('test');
            email.setPlainTextBody('referenciaCaso');
            email.setWhatId(testCase.Id);
            email.setOrgWideEmailAddressId(owasMap.get(emailCorreoEntrante)?.Id);
            email.setHtmlBody(plantilla);
            Messaging.sendEmail(new List<Messaging.Email>{email});	

            EmailMessage emailMsg = new EmailMessage();
                emailMsg.FromName = 'Test Sender';
                emailMsg.ToAddress = 'test@test.com;test2@test.com';
                emailMsg.FromAddress = owaPorDefecto[0].CC_Direccion_Correo__c;
                emailMsg.Subject = 'Test Email Subject';
                emailMsg.HtmlBody = '<h1>This is a test email body.</h1>';
                emailMsg.TextBody = 'This is the plain text email body.';
                emailMsg.MessageDate = DateTime.now();
                emailMsg.Status = '3'; 
                emailMsg.Incoming = false; 
                emailMsg.ParentId = testCase.Id; 
                emailMsg.CC_Plantilla__c = 'TestPlantilla'; 
            insert emailMsg;  
            
            CC_Settings__c configuracion = new CC_Settings__c(
                Name = 'CC_MecanismoFirmaCircuitoCaso',
                CC_Activa__c = true
            );
            insert configuracion;

            CC_Settings__c configuracion2 = new CC_Settings__c(
                Name = 'CC_MecanismoFirmaCola',
                CC_Activa__c = true,
                CC_Configuracion_1__c = 'Videollamada_Enrollment_Caixabank_Sign'
            );
            insert configuracion2;

        }
    }

    @isTest
    static void crearNuevoCasoMecanismoFirmaTest() {

        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            Case testCase = [SELECT Id FROM Case WHERE Subject = 'Circuito cliente envío código de firma' LIMIT 1];
            Test.startTest();
            CC_Gestion_Derivar_Mecanismo_Firma.crearCasoMecanismoFirma(testCase.Id);
            Test.stopTest();
    
            Case nuevoCaso = [SELECT Id, CC_CasoRelacionado__c FROM Case WHERE CC_CasoRelacionado__c = :testCase.Id LIMIT 1];
            System.assertNotEquals(null, nuevoCaso, 'El nuevo caso debe ser creado');
            System.assertEquals(testCase.Id, nuevoCaso.CC_CasoRelacionado__c, 'El nuevo caso debe estar relacionado con el caso original');
        }
    }

        @isTest
    static void actualizarCasoMecanismoFirmaTest() {

        CC_Settings__c conf = [SELECT Id, CC_Activa__c FROM CC_Settings__c WHERE Name ='CC_MecanismoFirmaCircuitoCaso'];
        conf.CC_Activa__c = false;
        update conf;

        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            Case testCase = [SELECT Id FROM Case WHERE Subject = 'Circuito cliente envío código de firma' LIMIT 1];
            Test.startTest();
            CC_Gestion_Derivar_Mecanismo_Firma.crearCasoMecanismoFirma(testCase.Id);
            Test.stopTest();
    
            List<Case> nuevoCaso = [SELECT Id, CC_CasoRelacionado__c FROM Case WHERE CC_CasoRelacionado__c = :testCase.Id LIMIT 1];
            System.assertEquals(true, nuevoCaso.isEmpty(), 'El nuevo caso no debe ser creado');
        }
    }

    @isTest
    static void comprobarCasoCreadoMecanismoFirmaTest() {

        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            Case testCase = [SELECT Id FROM Case WHERE Subject = 'Circuito cliente envío código de firma' LIMIT 1];
            Boolean eleccion;

            Test.startTest();
            eleccion = CC_Gestion_Derivar_Mecanismo_Firma.comprobarCasoCreadoMecanismoFirma(testCase.Id);
            Test.stopTest();
    
            System.assertEquals(eleccion, false, 'No tiene caso relacionado');

        }
    }

    @isTest
    static void recuperarArgosTest() {

        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            Case testCase = [SELECT Id, AccountId, ContactId FROM Case WHERE Subject = 'Circuito cliente envío código de firma' LIMIT 1];
            Boolean argos;

            Test.startTest();
            argos = CC_Gestion_Derivar_Mecanismo_Firma.recuperarArgos(testCase.Id);
            Test.stopTest();
    
            System.assertEquals(argos, true, 'Argos tiene que ser true');

        }
    }
    
}