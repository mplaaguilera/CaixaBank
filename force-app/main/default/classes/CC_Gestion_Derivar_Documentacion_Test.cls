@isTest
public class CC_Gestion_Derivar_Documentacion_Test {

    @testSetup
    static void setup() {

        User admin = CC_TestDataFactory.insertUserAdmin();
        User operador = CC_TestDataFactory.insertUserOperadorCliente('000001');

        System.runAs(admin){
            Case testCase = new Case(
                Subject='Test Case',
                recordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente'),
                Origin = 'Email',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Tipo_Contacto__c = 'Consulta',
                OwnerId = operador.Id,
                Status = 'Activo'
            );
            insert testCase;
    
            // Crear una tarea de prueba
            Task testTask = new Task(
                Subject = 'Test Task',
                Status = 'Not Started',
                Priority = 'Normal',
                WhatId = testCase.Id
            );
            insert testTask;
    
            Group testQueue = [SELECT Id FROM Group WHERE DeveloperName = 'CC_Inbound_Email_AC' LIMIT 1];
            if (testQueue == null) {
                testQueue = new Group(
                    Name = 'CC Inbound Email AC',
                    DeveloperName = 'CC_Inbound_Email_AC',
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
        }
    }

    @isTest
    static void testCrearNuevoCasoDocumentacion() {

        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
            Test.startTest();
            CC_Gestion_Derivar_Documentacion.crearNuevoCasoDocumentacion(testCase.Id);
            Test.stopTest();
    
            Case nuevoCaso = [SELECT Id, CC_CasoRelacionado__c FROM Case WHERE CC_CasoRelacionado__c = :testCase.Id LIMIT 1];
            System.assertNotEquals(null, nuevoCaso, 'El nuevo caso debe ser creado');
            System.assertEquals(testCase.Id, nuevoCaso.CC_CasoRelacionado__c, 'El nuevo caso debe estar relacionado con el caso original');
        }
    }
}