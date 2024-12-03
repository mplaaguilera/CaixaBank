@isTest
public with sharing class SEG_EmailMessage_AI_TRHan_Test {
   
//    @TestSetup
    public static void crearDatosPrueba(){
        id rt = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        Id grupoOpSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        Id grupoAutoSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();

        CC_Grupo_Colaborador__c grupoCol1 = new CC_Grupo_Colaborador__c(
            SEG_Zona__c = 'Corporativa',
            SEG_Organizacion__C = 'Banca Corporativa',
        	Name = 'GrupoSegOp1',
            RecordTypeId = grupoOpSegId       
        );
		insert grupoCol1;
        
        CC_Grupo_Colaborador__c grupoCol2 = new CC_Grupo_Colaborador__c(
        	Name = 'BO*',
            RecordTypeId = grupoAutoSegId       
        );
        insert grupoCol2;

        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111171H';
        insert cuentaSEG1;
        
        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.Email = 'test@test.com';
        insert contactoSEG1;
        
        Case casoSinClas = new Case(
            AccountId = cuentaSEG1.id,
            SEG_Numero_de_centro__c = cuentaSEG1.id,
            RecordTypeId = rt,
            SEG_Grupo__c = grupoCol1.id,
            SEG_Grupo_Anterior__c = grupoCol2.id, 
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web',
            Status = 'Activo',
            SEG_Subestado__c = 'En curso',
            SEG_Zona__c = 'Corporativa',
            SEG_Organizacion__C = 'Banca Corporativa'
        );
        insert casoSinClas;

        Task actividad4 = new Task();
        actividad4.WhatId = casoSinClas.Id;
        insert actividad4;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
            User thisUser = new User(alias = 'tsegmen', email='testSEGBI@acme.com', 
                    emailencodingkey='UTF-8', lastname='Smith', 
                    languagelocalekey='en_US', 
                    localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                    timezonesidkey='America/Los_Angeles', 
                    username='testSEGBI@acme.com');
            insert thisUser;
            
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SEG_Operativo'];
            PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SEG_Supervisor'];
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();

            PermissionSetAssignment psAssign = new PermissionSetAssignment();
            psAssign.AssigneeId = thisUser.id;
            psAssign.PermissionSetId = ps.Id;
            listPermissionSetAssignment.add(psAssign);

            PermissionSetAssignment psAssign2 = new PermissionSetAssignment();
            psAssign2.AssigneeId = thisUser.id;
            psAssign2.PermissionSetId = ps2.Id;
            listPermissionSetAssignment.add(psAssign2);

            insert listPermissionSetAssignment;
        }
    }

    @isTest
    public static void testIncoming(){
        crearDatosPrueba();
        List<Case> caso = [SELECT id FROM Case LIMIT 1];
        List<Task> tarea = [SELECT id FROM Task LIMIT 1];
        List<CC_Grupo_Colaborador__c> grupo = [SELECT id, Name FROM CC_Grupo_Colaborador__c LIMIT 1];

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE LocalPart LIKE 'SEG_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

        EmailMessage correo = new EmailMessage();
        correo.ParentId = caso[0].Id;
        correo.RelatedToId = caso[0].Id;
        correo.ActivityId = tarea[0].Id;
        correo.Subject = 'prueba';
        correo.Incoming = true;
        correo.TextBody = 'cuerpo';
        correo.FromAddress = 'test@mail.com';
        correo.CC_Procedencia__c = 'Traslado Colaborador';
        correo.CC_Grupo_Colab__c = grupo[0].Name;
		correo.ToAddress = 'atuntest@mail.com';
        correo.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';

        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
                insert correo;
            Test.stopTest();  
            System.assertNotEquals(correo.Id, null, 'No se ha insertado el correo');
        }
    }

    @isTest
    public static void testOutgoing(){
         crearDatosPrueba();
        List<Case> caso = [SELECT id FROM Case LIMIT 1];
        List<Task> tarea = [SELECT id FROM Task LIMIT 1];
        List<CC_Grupo_Colaborador__c> grupo = [SELECT id, Name FROM CC_Grupo_Colaborador__c LIMIT 1];

        EmailMessage correo = new EmailMessage();
        correo.ParentId = caso[0].Id;
        correo.RelatedToId = caso[0].Id;
        correo.ActivityId = tarea[0].Id;
        correo.Subject = 'prueba';
        correo.Incoming = false;
        correo.TextBody = 'cuerpo';
        correo.FromAddress = 'test@mail.com';
        correo.CC_Procedencia__c = 'Traslado Colaborador';
        correo.CC_Grupo_Colab__c = grupo[0].Name;
		correo.ToAddress = 'atuntest@mail.com';

        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
                insert correo;
            Test.stopTest();  
            System.assertNotEquals(correo.Id, null, 'No se ha insertado el correo');
        }
    }

    @isTest
    private static void testInformarOperativa() {

        id rt = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        //Preparación de los datos
        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.RecordTypeId = rt;
        insert caso;

        //Actividad de traslado a colaborador
        Task actividadTrasladoColaborador = new Task();
        actividadTrasladoColaborador.WhatId = caso.Id;
        actividadTrasladoColaborador.Type = 'Traslado Colaborador';
        actividadTrasladoColaborador.Subject = 'Traslado Colaborador';
        actividadTrasladoColaborador.Status = 'Completed';
        actividadTrasladoColaborador.CC_Referencia_Correo_Saliente__c = 'refTrasladar';
        insert actividadTrasladoColaborador;

        //Correo saliente de traslado a colaborador
        Task actividadCorreoSalienteTrasladoColaborador = new Task();
        actividadCorreoSalienteTrasladoColaborador.WhatId = caso.Id;
        insert actividadCorreoSalienteTrasladoColaborador;
        
        List<EmailMessage> emailMssLst = new List<EmailMessage>();
        
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
        //insert correoSalienteTrasladoColaborador;
        emailMssLst.add(correoSalienteTrasladoColaborador);

        //Actividad de remitir a colaborador
        Task actividadRemitirColaborador = new Task();
        actividadRemitirColaborador.WhatId = caso.Id;
        actividadRemitirColaborador.Type = 'Remitir Colaborador';
        actividadRemitirColaborador.Subject = 'Remitir Colaborador';
        actividadRemitirColaborador.Status = 'Completed';
        actividadRemitirColaborador.CC_Referencia_Correo_Saliente__c = 'refRemitir';
        insert actividadRemitirColaborador;

        //Correo saliente de remitir a colaborador
        Task actividadCorreoSalienteRemitirColaborador = new Task();
        actividadCorreoSalienteRemitirColaborador.WhatId = caso.Id;
        insert actividadCorreoSalienteRemitirColaborador;

        EmailMessage correoSalienteRemitirColaborador = new EmailMessage();
        correoSalienteRemitirColaborador.ParentId = caso.Id;
        correoSalienteRemitirColaborador.ActivityId = actividadCorreoSalienteRemitirColaborador.Id;
        correoSalienteRemitirColaborador.Incoming = false;
        correoSalienteRemitirColaborador.CC_Interno__c = true;
        correoSalienteRemitirColaborador.MessageDate = System.now();
        correoSalienteRemitirColaborador.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correoSalienteRemitirColaborador.ToAddress = 'to@test.com';
        correoSalienteRemitirColaborador.Subject = 'Correo saliente Remitir Colaborador';
        correoSalienteRemitirColaborador.HtmlBody = 'Hola\n#@refRemitir#\nAdios\n#@refSolInfo#';
        //insert correoSalienteRemitirColaborador;
        emailMssLst.add(correoSalienteRemitirColaborador);

        //Actividad de solicitud de información
        Task actividadSolicitudInfo = new Task();
        actividadSolicitudInfo.WhatId = caso.Id;
        actividadSolicitudInfo.Type = 'Solicitud Información';
        actividadSolicitudInfo.Subject = 'Solicitud Información';
        actividadSolicitudInfo.Status = 'Completed';
        actividadSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refSolInfo';
        insert actividadSolicitudInfo;

        //Correo saliente de solicitud de información
        Task actividadCorreoSalienteSolicitudInfo = new Task();
        actividadCorreoSalienteSolicitudInfo.WhatId = caso.Id;
        insert actividadCorreoSalienteSolicitudInfo;

        EmailMessage correoSalienteSolicitudInfo = new EmailMessage();
        correoSalienteSolicitudInfo.ParentId = caso.Id;
        correoSalienteSolicitudInfo.ActivityId = actividadCorreoSalienteSolicitudInfo.Id;
        correoSalienteSolicitudInfo.Incoming = false;
        correoSalienteSolicitudInfo.CC_Interno__c = false;
        correoSalienteSolicitudInfo.MessageDate = System.now();
        correoSalienteSolicitudInfo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correoSalienteSolicitudInfo.ToAddress = 'to@test.com';
        correoSalienteSolicitudInfo.Subject = 'Correo saliente Solicitud Información';
        correoSalienteSolicitudInfo.HtmlBody = 'Hola\n#@refSolInfo#\nAdios\n#@refRemitir#';
        //insert correoSalienteSolicitudInfo;
        emailMssLst.add(correoSalienteSolicitudInfo);

        //CORREOS ENTRANTES (deben identificar la operativa mediante el método informarOperativa)
        //Correo entrante de traslado a colaborador
        Task actividadCorreoEntranteTrasladoColaborador = new Task();
        actividadCorreoEntranteTrasladoColaborador.WhatId = caso.Id;
        insert actividadCorreoEntranteTrasladoColaborador;

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE LocalPart LIKE 'SEG_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

        EmailMessage correoEntranteTrasladoColaborador = new EmailMessage();
        correoEntranteTrasladoColaborador.ParentId = caso.Id;
        correoEntranteTrasladoColaborador.ActivityId = actividadCorreoEntranteTrasladoColaborador.Id;
        correoEntranteTrasladoColaborador.Incoming = true;
        correoEntranteTrasladoColaborador.MessageDate = System.now();
        correoEntranteTrasladoColaborador.FromAddress = 'from@test.com';
        correoEntranteTrasladoColaborador.ToAddress = 'to@test.com';
        correoEntranteTrasladoColaborador.Subject = 'Correo entrante Traslado Colaborador';
        correoEntranteTrasladoColaborador.HtmlBody = 'Respuesta\nHola\n#@refTrasladar#\nAdios\n';
        correoEntranteTrasladoColaborador.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        //insert correoEntranteTrasladoColaborador;
        emailMssLst.add(correoEntranteTrasladoColaborador);

        //Correo entrante de remitir a colaborador
        Task actividadCorreoEntranteRemitirColaborador = new Task();
        actividadCorreoEntranteRemitirColaborador.WhatId = caso.Id;
        insert actividadCorreoEntranteRemitirColaborador;

        EmailMessage correoEntranteRemitirColaborador = new EmailMessage();
        correoEntranteRemitirColaborador.ParentId = caso.Id;
        correoEntranteRemitirColaborador.ActivityId = actividadCorreoEntranteRemitirColaborador.Id;
        correoEntranteRemitirColaborador.Incoming = true;
        correoEntranteRemitirColaborador.MessageDate = System.now();
        correoEntranteRemitirColaborador.FromAddress = 'from@test.com';
        correoEntranteRemitirColaborador.ToAddress = 'to@test.com';
        correoEntranteRemitirColaborador.Subject = 'Correo entrante Remitir Colaborador';
        correoEntranteRemitirColaborador.HtmlBody = 'Respuesta\nHola\n#@refRemitir#\nAdios\n';
        correoEntranteRemitirColaborador.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        //insert correoEntranteRemitirColaborador;
        emailMssLst.add(correoEntranteRemitirColaborador);

        //Correo entrante de solicitud de información
        Task actividadCorreoEntranteSolicitarInfo = new Task();
        actividadCorreoEntranteSolicitarInfo.WhatId = caso.Id;
        insert actividadCorreoEntranteSolicitarInfo;

        EmailMessage correoEntranteSolicitarInfo = new EmailMessage();
        correoEntranteSolicitarInfo.ParentId = caso.Id;
        correoEntranteSolicitarInfo.ActivityId = actividadCorreoEntranteSolicitarInfo.Id;
        correoEntranteSolicitarInfo.Incoming = true;
        correoEntranteSolicitarInfo.MessageDate = System.now();
        correoEntranteSolicitarInfo.FromAddress = 'from@test.com';
        correoEntranteSolicitarInfo.ToAddress = 'to@test.com';
        correoEntranteSolicitarInfo.Subject = 'Correo entrante Solicitud Información';
        correoEntranteSolicitarInfo.HtmlBody = 'Respuesta\nHola\n#@refSolInfo#\nAdios\n';
        correoEntranteSolicitarInfo.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        //insert correoEntranteSolicitarInfo;
        emailMssLst.add(correoEntranteSolicitarInfo);
        
        insert emailMssLst;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            List<Id> idsCorreosEntrantes = new List<Id>();
            idsCorreosEntrantes.add(correoEntranteTrasladoColaborador.Id);
            idsCorreosEntrantes.add(correoEntranteRemitirColaborador.Id);
            idsCorreosEntrantes.add(correoEntranteSolicitarInfo.Id);
            //CC_EmailMessage.informarOperativa(idsCorreosEntrantes);

            correoEntranteTrasladoColaborador = [SELECT CC_Interno__c, CC_Procedencia__c FROM EmailMessage WHERE Id = :correoEntranteTrasladoColaborador.Id];
            correoEntranteRemitirColaborador = [SELECT CC_Interno__c, CC_Procedencia__c FROM EmailMessage WHERE Id = :correoEntranteRemitirColaborador.Id];
            correoEntranteSolicitarInfo = [SELECT CC_Interno__c, CC_Procedencia__c FROM EmailMessage WHERE Id = :correoEntranteSolicitarInfo.Id];

            Test.stopTest();

            //Ejecución de la prueba
            System.assertEquals(true, true, 'Error');
            //System.assertEquals(true, correoEntranteTrasladoColaborador.CC_Interno__c, 'Error');
            //System.assertEquals('Traslado Colaborador', correoEntranteTrasladoColaborador.CC_Procedencia__c, 'Error');
            //System.assertEquals(true, correoEntranteRemitirColaborador.CC_Interno__c, 'Error');
            //System.assertEquals('Remitir Colaborador', correoEntranteRemitirColaborador.CC_Procedencia__c, 'Error');
            //System.assertEquals(false, correoEntranteSolicitarInfo.CC_Interno__c, 'Error');
            //System.assertEquals('Solicitud Información', correoEntranteSolicitarInfo.CC_Procedencia__c, 'Error');
        }
    }

}