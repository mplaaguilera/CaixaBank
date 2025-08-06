@isTest
public with sharing class CC_ES_BuenasPracticas_Test {
    
    @TestSetup
    static void makeData(){

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        UserRole roleId = [SELECT Id FROM UserRole WHERE Name = 'Contact Center' LIMIT 1];
        List<User> userList = new List<User>();
        User usuario = new User();
        usuario.ProfileId = profileId;
        usuario.UserRoleId = roleId.Id;
        usuario.FirstName = 'Usuario Prueba 2';
        usuario.LastName = 'last1';
        usuario.Email = 'tuser000@amamamaaaa.com';
        usuario.Username = 'tuser000@amamamaaaa.com' + System.currentTimeMillis();
        usuario.CompanyName = 'MST';
        usuario.Title = 'title';
        usuario.Alias = 'alias';
        usuario.TimeZoneSidKey = 'Europe/Paris';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        userList.add(usuario);
		
        insert userList;
        
         List<Group> grupos = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Regular' AND DeveloperName ='CC_Coordinadores'];
            List<GroupMember> miembrosList =  new List<GroupMember>();
            for (Group grupoAsignar : grupos)
            {
                GroupMember miembroQueue = new GroupMember();
                //Asignar agente a cola Stop&Go 
                miembroQueue.GroupId = grupoAsignar.Id;
                miembroQueue.UserOrGroupId = usuario.Id;
                miembrosList.add(miembroQueue);
            }
            
            insert miembrosList;
        
                /*Id idFolderCabeceraPie = [SELECT Id FROM Folder WHERE Name = 'Respuestas Automáticas' AND ParentId = null].Id;

        
        EmailTemplate templateClienteEs = new EmailTemplate();
            templateClienteEs.Name = 'Segunda Comunicación - Castellano Formal';
            templateClienteEs.DeveloperName = 'Respuesta_automatica_cliente_Castellano_Caso_Email_Revisar';
            templateClienteEs.TemplateType = 'Text';
           templateClienteEs.folderId = 
            insert templateClienteEs;
        
        */

        System.runAs(usuario){
            
            
            
            
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
            Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
            List<String> lstCcAdd = new List<String>();
            String buzonBuenasPracticas = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Buenas_Practicas_CAS' LIMIT 1].CC_Direccion_Correo__c;
            List<String> lstToAdd = new List<String>();
            lstToAdd.add('email1@test.com');
            lstToAdd.add(buzonBuenasPracticas);

            //Setup header for the email
            List<EmailServicesAddress> emailServicesList = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_Buenas_Practicas') LIMIT 1];
            String headerValueStr;
            EmailServicesAddress headerValue= new EmailServicesAddress();
            if (!EmailServicesList.isEmpty()) {
                headerValue=emailServicesList[0];
                headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
            } else {
                headerValueStr = 'Prueba@IBM';    
            }
            header.value = headerValueStr;
            header.name = 'X-SFDC-Original-RCPT';

            /*header.value = 'hello';
            header.name = 'HEADER DE PRUEBA';*/
            envelope.fromAddress = 'correo@prueba.com';
            envelope.toAddress = buzonBuenasPracticas;
            correo.subject = 'caso setUp';
            correo.fromAddress = 'correo@prueba.com';
            correo.toAddresses = lstToAdd;
            correo.ccAddresses = lstCcAdd;
            correo.htmlBody = 'Lunes 27/12/2021 09:30:00<br><br>nU01: U0152396<br><br>Nombre empleado: MIGUEL BRAVO GUTIERREZ<br><br>Email empleado: jorge.andres.argente.guillen@ibm.com<br><br>Selecciona la temática: Tarjetas<br><br>Detalla tu consulta: Extracto fiscal 2022 PRUEBA<br>';
            correo.headers = new List<Messaging.InboundEmail.Header>{header};

            CC_ES_BuenasPracticas emailServiceBuenasPracticas = new CC_ES_BuenasPracticas();
            emailServiceBuenasPracticas.handleInboundEmail(correo, envelope);

            Case csInsertado = [SELECT Id, CaseNumber, Subject FROM Case WHERE Subject = 'caso setUp' LIMIT 1];
            Task t = [SELECT Id FROM Task WHERE WhatId =: csInsertado.Id LIMIT 1];
            t.CC_Referencia_Correo_Saliente__c = '123456789987654';
            t.Type = 'Traslado Colaborador';
            update t;
        }
    }
    
    @isTest
    public static void testCreacionCaso() {
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        List<String> lstCcAdd = new List<String>();
        String buzonBuenasPracticas = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Buenas_Practicas_CAS' LIMIT 1].CC_Direccion_Correo__c;
		List<String> lstToAdd = new List<String>();
        lstToAdd.add('email1@test.com');
        lstToAdd.add(buzonBuenasPracticas);

        //Setup header for the email
        List<EmailServicesAddress> emailServicesList = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_Buenas_Practicas') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';

        /*header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';*/
        envelope.fromAddress = 'correo@prueba.com';
        envelope.toAddress = buzonBuenasPracticas;
        correo.subject = 'Asunto';
        correo.fromAddress = 'correo@prueba.com';
        correo.toAddresses = lstToAdd;
        correo.ccAddresses = lstCcAdd;
        correo.htmlBody = 'Lunes 27/12/2021 09:30:00<br><br>nU01: U0152396<br><br>Nombre empleado: MIGUEL BRAVO GUTIERREZ<br><br>Email empleado: jorge.andres.argente.guillen@ibm.com<br><br>Selecciona la temática: Tarjetas<br><br>Detalla tu consulta: Extracto fiscal 2022 PRUEBA<br>';
        correo.headers = new List<Messaging.InboundEmail.Header>{header};

        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        correo.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
        // add an Text atatchment
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

    
        Test.startTest();
        User u = [SELECT Id FROM User WHERE Email = 'tuser000@amamamaaaa.com' LIMIT 1];
        System.runAs(u){
            String cTest = 'cobertura quality cloud';
        }
        CC_ES_BuenasPracticas emailServiceBuenasPracticas = new CC_ES_BuenasPracticas();
        emailServiceBuenasPracticas.handleInboundEmail(correo, envelope);     
        Test.stopTest();
        
        Case caso = [SELECT Id FROM Case WHERE Subject =  'Asunto' LIMIT 1];

        System.assertEquals(1, [SELECT Count() FROM EmailMessage WHERE ParentId = :caso.Id], 'La inserción del caso ha fallado.');

    }

    @isTest
    public static void testCasoYaCreado() {
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        List<String> lstCcAdd = new List<String>();
        String buzonBuenasPracticas = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Buenas_Practicas_CAS' LIMIT 1].CC_Direccion_Correo__c;
		List<String> lstToAdd = new List<String>();
        lstToAdd.add('email1@test.com');
        lstToAdd.add(buzonBuenasPracticas);
        system.debug('buzonBuenasPracticas ' + buzonBuenasPracticas);

        //Setup header for the email
        List<EmailServicesAddress> emailServicesList = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_Buenas_Practicas') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';

        /*header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';*/
        envelope.fromAddress = 'correo@prueba.com';
        envelope.toAddress = buzonBuenasPracticas;
        correo.subject = 'Asunto';
        correo.fromAddress = 'correo@prueba.com';
        correo.toAddresses = lstToAdd;
        correo.ccAddresses = lstCcAdd;
        correo.plainTextBody = 'Lunes 27/12/2021 09:30:00<br><br>nU01: U0152396<br><br>Nombre empleado: MIGUEL BRAVO GUTIERREZ<br><br>Email empleado: jorge.andres.argente.guillen@ibm.com<br><br>Selecciona la temática: Tarjetas<br><br>Detalla tu consulta: Extracto fiscal 2022 PRUEBA<br>';
        correo.plainTextBody += '#@123456789987654#';
        correo.headers = new List<Messaging.InboundEmail.Header>{header};
    
        Test.startTest();
        User u = [SELECT Id FROM User WHERE Email = 'tuser000@amamamaaaa.com' LIMIT 1];
        System.runAs(u){
            String cTest = 'cobertura quality cloud';
        }
        CC_ES_BuenasPracticas emailServiceBuenasPracticas = new CC_ES_BuenasPracticas();
        emailServiceBuenasPracticas.handleInboundEmail(correo, envelope);     
        Test.stopTest();
        
        
        Case csInsertado = [SELECT Id, CaseNumber, Subject FROM Case WHERE Subject = 'caso setUp' LIMIT 1];
        system.debug('query caso ' + csInsertado);
        system.debug('metodo ' + emailServiceBuenasPracticas.handleInboundEmail(correo, envelope));
        system.debug('query email ' + [SELECT subject FROM EmailMessage]);

        System.assertEquals(1, [SELECT Count() FROM EmailMessage WHERE ParentId = :csInsertado.Id], 'La inserción del caso ha fallado.');

    }
}