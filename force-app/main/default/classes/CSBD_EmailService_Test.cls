@isTest
public class CSBD_EmailService_Test {

    @TestSetup
    private static void testSetup() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

        //Alta de las parametrizaciones que necesitan el triggers de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valor.CC_Lista__c = listaValores.Id;
        valor.Name = 'Préstamo';
        valor.CC_Valor__c = '1';
        listaValores.CC_Activa__c = true;
        insert valor;

        Pricebook2 listaPreciosCsbd = new Pricebook2();
        listaPreciosCsbd.Name = 'CSBD Price Book';
        listaPreciosCsbd.Description = 'CSBD Price Book';
        listaPreciosCsbd.IsActive = true;
        insert listaPreciosCsbd;
    }

    @isTest
    public static void test() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo');

        OpportunityShare oppshare = new OpportunityShare();
        oppshare.UserOrGroupId = usuarioGestor.Id;
        oppshare.OpportunityId = oportunidad.Id;
        oppshare.OpportunityAccessLevel = 'Edit';
        insert oppshare;

        Task tarea = new Task();
        tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CSBD_Task');
        tarea.WhatId = oportunidad.Id;
        tarea.TaskSubtype = 'Email';
        tarea.CC_Referencia_Correo_Saliente__c = '123456789012345';
        tarea.OwnerId = usuarioGestor.Id;
        insert tarea;

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'direccioRemitente@de.correo';
        env.toAddress = 'direccionPara@de.correo';
        email.subject = 'Correo Test';
        email.fromAddress = 'direccioRemitente@de.correo';
        email.toAddresses = new List<String>{'direccionPara@de.correo'};
        email.ccAddresses = new List<String>{'direccionCc@de.correo'};
        email.plainTextBody = '<b>Cuerpo</b> <i>correo</i>\nreferencia: #@123456789012345#';

        Messaging.InboundEmail.Header adjuntoBinarioHeader = new Messaging.InboundEmail.Header();
        adjuntoBinarioHeader.name = 'Content-Id';
        adjuntoBinarioHeader.value = 'contentIdTest';
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario.body = Blob.valueOf('my attachment text');
        adjuntoBinario.fileName = 'textfileone.txt';
        adjuntoBinario.mimeTypeSubType = 'text/plain';
        adjuntoBinario.headers = new List<Messaging.InboundEmail.Header>{adjuntoBinarioHeader};
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>{adjuntoBinario};

		Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'text/plain';
        email.textAttachments = new List<Messaging.InboundEmail.TextAttachment>{adjuntoTexto};

        //Ejecución de la prueba
        System.runAs(usuarioGestor) {
            Test.startTest();
            CSBD_EmailService emailservice = new CSBD_EmailService();
            Messaging.InboundEmailResult resultado = emailservice.handleInboundEmail(email, env);
            Test.stopTest();

            System.assertEquals(true, resultado.success, 'Error procesando el correo entrante en CSBD_EmailService');
            EmailMessage mailCreado = [SELECT Id FROM EmailMessage WHERE CSBD_Oportunidad_Id__c = :oportunidad.Id];

            CBK_Log__c respuestaLogBuena = [SELECT Log_Level__c, CBK_sfdcType__c, CBK_sfdcCaseId__c, CBK_sfdcEmailMessageId__c, CBK_sfdcMessageId__c, CBK_sfdcResultDetail__c from CBK_Log__c WHERE CBK_sfdcResultStatus__c = 'OK' AND OwnerId = :usuarioGestor.Id];
            System.assertEquals(oportunidad.Id, respuestaLogBuena.CBK_sfdcCaseId__c, 'Comprobamos que la oportunidad esta relacionada con la creada.');
            System.assertEquals(mailCreado.Id, respuestaLogBuena.CBK_sfdcMessageId__c, 'Comprobamos que el emailmessage id no es null.');
            System.assertEquals('Resultado', respuestaLogBuena.CBK_sfdcType__c, 'Comprobamos que el tipo es resultado.');
            System.assertEquals('Envio correcto', respuestaLogBuena.CBK_sfdcResultDetail__c, 'Comprobamos que el detail es envio correcto.');
            System.assertEquals('INFO', respuestaLogBuena.Log_Level__c, 'Comprobamos que el nivel es info.');
            // System.assertNotEquals(null, respuestaLogBuena.CBK_sfdcEmailMessageId__c, 'El campo CBK_sfdcEmailMessageId__c no debería ser nulo');
        }
    }
}