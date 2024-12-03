@isTest
public with sharing class GRR_EmailMessageTriggerHelper_Test {
    
    private static Case crearCaso() {
        Case caso = new Case (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente'),
            Subject = 'Caso Test',
            CC_Referencia_Correo_Saliente__c = 'refCorreo'
        );
        insert caso;
        return caso;
    }

    @isTest
    public static void testFilterEmailsHandlers() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            List<EmailMessage> lstCorreo = new List<EmailMessage> ();
            EmailMessage correo = new EmailMessage();
            correo.Incoming = true;
            correo.FromAddress = 'buzonpruebasgrr@gmail.com';
            correo.ToAddress = 'to@test.com';
            lstCorreo.add(correo);
            CC_TriggerParameters tp = new CC_TriggerParameters();
            tp.newList = lstCorreo;

            Test.startTest();
            list<SObject> result = GRR_EmailMessageTriggerHelper.filterEmailsHandlers(tp, 'beforeInsert', 'GRR_EmailMessage_BI_TRHan');
            Test.stopTest();

            System.assertNotEquals(null, result);
        }
    }    

    @isTest
    public static void testFiltrarCorreosGRR() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Case caso = crearCaso();
            List<EmailMessage> emailMessageInsert = new List<EmailMessage>();
            EmailMessage correo = new EmailMessage();
            correo.RelatedToId = caso.Id;
            emailMessageInsert.add(correo);

            Test.startTest();
            list<SObject> result = GRR_EmailMessageTriggerHelper.filtrarCorreosGRR(emailMessageInsert);
            Test.stopTest();

            System.assertNotEquals(null, result);
        }
    }  

    @isTest
    public static void testInformarOperativaTraslado() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Case caso = crearCaso();
            List<Task> taskInsert = new List<Task>();
            List<EmailMessage> emailMessageInsert = new List<EmailMessage>();
            Task actividadTrasladoColaborador = new Task();
            actividadTrasladoColaborador.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            actividadTrasladoColaborador.WhatId = caso.Id;
            actividadTrasladoColaborador.Type = 'Traslado Colaborador';
            actividadTrasladoColaborador.Subject = 'Traslado Colaborador';
            actividadTrasladoColaborador.Status = 'Completed';
            actividadTrasladoColaborador.CC_Referencia_Correo_Saliente__c = 'refTrasladar';
            taskInsert.add(actividadTrasladoColaborador);
            Task actividadCorreoEntranteTrasladoColaborador = new Task();
            actividadCorreoEntranteTrasladoColaborador.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            actividadCorreoEntranteTrasladoColaborador.WhatId = caso.Id;
            taskInsert.add(actividadCorreoEntranteTrasladoColaborador);
            EmailMessage correoEntranteTrasladoColaborador = new EmailMessage();
            correoEntranteTrasladoColaborador.ParentId = caso.Id;
            correoEntranteTrasladoColaborador.ActivityId = actividadCorreoEntranteTrasladoColaborador.Id;
            correoEntranteTrasladoColaborador.Incoming = true;
            correoEntranteTrasladoColaborador.MessageDate = System.now();
            correoEntranteTrasladoColaborador.FromAddress = 'buzonpruebasgrr@gmail.com';
            correoEntranteTrasladoColaborador.ToAddress = 'to@test.com';
            correoEntranteTrasladoColaborador.Subject = 'Correo entrante Traslado Colaborador';
            correoEntranteTrasladoColaborador.HtmlBody = 'Respuesta\nHola\n#@refTrasladar#\nAdios\n';
            emailMessageInsert.add(correoEntranteTrasladoColaborador);
            Task actividadCorreoSalienteTrasladoColaborador = new Task();
            actividadCorreoSalienteTrasladoColaborador.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            actividadCorreoSalienteTrasladoColaborador.WhatId = caso.Id;
            taskInsert.add(actividadCorreoSalienteTrasladoColaborador);
            EmailMessage correoSalienteTrasladoColaborador = new EmailMessage();
            correoSalienteTrasladoColaborador.ParentId = caso.Id;
            correoSalienteTrasladoColaborador.ActivityId = actividadCorreoSalienteTrasladoColaborador.Id;
            correoSalienteTrasladoColaborador.Incoming = false;
            correoSalienteTrasladoColaborador.CC_Interno__c = true;
            correoSalienteTrasladoColaborador.MessageDate = System.now();
            correoSalienteTrasladoColaborador.FromAddress = 'buzonpruebasgrr@gmail.com';
            correoSalienteTrasladoColaborador.ToAddress = 'to@test.com';
            correoSalienteTrasladoColaborador.Subject = 'Correo saliente Traslado Colaborador';
            correoSalienteTrasladoColaborador.HtmlBody = 'Hola\n#@refTrasladar#\nAdios\n#@refRemitir#';
            emailMessageInsert.add(correoSalienteTrasladoColaborador);
            insert taskInsert;

            Test.startTest();
            GRR_EmailMessageTriggerHelper.informarOperativa(emailMessageInsert);
            Test.stopTest();
            
            System.assertEquals('Traslado Colaborador', correoEntranteTrasladoColaborador.CC_Procedencia__c);
        }
    }

    @isTest
    public static void testInformarOperativaRemitir() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Case caso = crearCaso();
            List<Task> taskInsert = new List<Task>();
            List<EmailMessage> emailMessageInsert = new List<EmailMessage>();
            Task actividadRemitirColaborador = new Task();
            actividadRemitirColaborador.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            actividadRemitirColaborador.WhatId = caso.Id;
            actividadRemitirColaborador.Type = 'Remitir Colaborador';
            actividadRemitirColaborador.Subject = 'Remitir Colaborador';
            actividadRemitirColaborador.Status = 'Completed';
            actividadRemitirColaborador.CC_Referencia_Correo_Saliente__c = 'refRemitirColaborador';
            taskInsert.add(actividadRemitirColaborador);
            Task actividadCorreoSalienteRemitirColaborador = new Task();
            actividadCorreoSalienteRemitirColaborador.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            actividadCorreoSalienteRemitirColaborador.WhatId = caso.Id;
            taskInsert.add(actividadCorreoSalienteRemitirColaborador);
            EmailMessage correoSalienteRemitirColaborador = new EmailMessage();
            correoSalienteRemitirColaborador.ParentId = caso.Id;
            correoSalienteRemitirColaborador.ActivityId = actividadCorreoSalienteRemitirColaborador.Id;
            correoSalienteRemitirColaborador.Incoming = false;
            correoSalienteRemitirColaborador.CC_Interno__c = true;
            correoSalienteRemitirColaborador.MessageDate = System.now();
            correoSalienteRemitirColaborador.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
            correoSalienteRemitirColaborador.ToAddress = 'to@test.com';
            correoSalienteRemitirColaborador.Subject = 'Correo saliente Traslado Colaborador';
            correoSalienteRemitirColaborador.HtmlBody = 'Hola\n#@refTrasladar#\nAdios\n#@refRemitirColaborador#';
            emailMessageInsert.add(correoSalienteRemitirColaborador);
            Task actividadCorreoEntranteRemitirColaborador = new Task();
            actividadCorreoEntranteRemitirColaborador.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
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
            emailMessageInsert.add(correoEntranteRemitirColaborador);
            insert taskInsert;    

            Test.startTest();
            GRR_EmailMessageTriggerHelper.informarOperativa(emailMessageInsert);
            Test.stopTest();
            
            System.assertEquals('Remitir Colaborador', correoEntranteRemitirColaborador.CC_Procedencia__c);
        }
    }

    @isTest
    public static void testInformarOperativaSolicitud() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Case caso = crearCaso();
            List<Task> taskInsert = new List<Task>();
            List<EmailMessage> emailMessageInsert = new List<EmailMessage>();
            Task actividadSolInfo = new Task();
            actividadSolInfo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            actividadSolInfo.WhatId = caso.Id;
            actividadSolInfo.Type = 'Solicitud Información';
            actividadSolInfo.Subject = 'Solicitud Información';
            actividadSolInfo.Status = 'Completed';
            actividadSolInfo.CC_Referencia_Correo_Saliente__c = 'refSolInfo';
            taskInsert.add(actividadSolInfo);
            Task actividadCorreoSalienteSolInfo = new Task();
            actividadCorreoSalienteSolInfo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            actividadCorreoSalienteSolInfo.WhatId = caso.Id;
            taskInsert.add(actividadCorreoSalienteSolInfo);
            EmailMessage correoSalienteSolInfo = new EmailMessage();
            correoSalienteSolInfo.ParentId = caso.Id;
            correoSalienteSolInfo.ActivityId = actividadCorreoSalienteSolInfo.Id;
            correoSalienteSolInfo.Incoming = false;
            correoSalienteSolInfo.CC_Interno__c = true;
            correoSalienteSolInfo.MessageDate = System.now();
            correoSalienteSolInfo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
            correoSalienteSolInfo.ToAddress = 'to@test.com';
            correoSalienteSolInfo.Subject = 'Correo saliente Traslado Colaborador';
            correoSalienteSolInfo.HtmlBody = 'Hola\n#@refTrasladar#\nAdios\n#@refRemitir#';
            emailMessageInsert.add(correoSalienteSolInfo);
            Task actividadCorreoEntranteSolInfo = new Task();
            actividadCorreoEntranteSolInfo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
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
            emailMessageInsert.add(correoEntranteSolInfo);
            insert taskInsert;

            Test.startTest();
            GRR_EmailMessageTriggerHelper.informarOperativa(emailMessageInsert);
            Test.stopTest();
            
            System.assertEquals('Solicitud Información', correoEntranteSolInfo.CC_Procedencia__c);
        }
    }

    @isTest
    public static void testEnvioTrasladoColaborador() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Case caso = crearCaso();
            List<Task> lstTareas = new List<Task>();
            EmailMessage correo = new EmailMessage();
            correo.ParentId = caso.Id;
            correo.CC_Grupo_Colab__c = 'Grupo colaborador';
            correo.TextBody = 'CORREO ENTRANTE';
            Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, CC_Referencia_Correo_Saliente__c FROM Case]);

            Test.startTest();
            GRR_EmailMessageTriggerHelper.envioTrasladoColaborador(correo, null, mapaCasos, lstTareas, null);
            Test.stopTest();
            
            System.assertEquals('Grupo colaborador', correo.CC_Grupo_Colab__c);
        }
    }

    @isTest
    public static void testEnvioRemitirColaborador() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Case caso = crearCaso();
            List<Task> lstTareas = new List<Task>();
            EmailMessage correo = new EmailMessage();
            correo.ParentId = caso.Id;
            correo.CC_Grupo_Colab__c = 'Grupo colaborador';
            correo.TextBody = 'CORREO ENTRANTE';
            correo.CC_Procedencia__c = 'Remitir Colaborador';
            Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, CC_Referencia_Correo_Saliente__c FROM Case]);

            Test.startTest();
            GRR_EmailMessageTriggerHelper.envioRemitirColaborador(correo, null, mapaCasos, lstTareas);
            Test.stopTest();
            
            System.assertEquals('Grupo colaborador', correo.CC_Grupo_Colab__c);
        }
    }

    @isTest
    public static void testEnvioResponderCliente() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Case caso = crearCaso();
            caso.OS_Cerrado_Operativa__c = true;
            update caso;
            List<Task> lstTareas = new List<Task>();
            EmailMessage correo = new EmailMessage();
            correo.ParentId = caso.Id;
            correo.TextBody = 'CORREO ENTRANTE';
            Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, CC_Referencia_Correo_Saliente__c, OS_Cerrado_Operativa__c, Status FROM Case]);

            Test.startTest();
            GRR_EmailMessageTriggerHelper.envioResponderCliente(correo, mapaCasos, lstTareas);
            Test.stopTest();
            
            System.assertEquals('CORREO ENTRANTE', correo.TextBody);
        }
    }

    @isTest
    public static void testEnvioSolicitudInfo() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Case caso = crearCaso();
            List<Task> lstTareas = new List<Task>();
            EmailMessage correo = new EmailMessage();
            correo.ParentId = caso.Id;
            correo.TextBody = 'CORREO ENTRANTE';
            Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, CC_Referencia_Correo_Saliente__c, OS_Cerrado_Operativa__c FROM Case]);

            Test.startTest();
            GRR_EmailMessageTriggerHelper.envioSolicitudInfo(correo, mapaCasos, lstTareas);
            Test.stopTest();
            
            System.assertEquals('CORREO ENTRANTE', correo.TextBody);
        }
    }

}