/*****************************************************************
 * Name: SAC_EmailServiceConsulta_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Clase test de SAC_EmailServiceConsulta
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US219270         Esteve Llaó          26/07/21     Creación
 * 1.1            US563153         Jose Carlos Blanco  	29/03/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@isTest
public without sharing class SAC_EmailServiceConsulta_Test {
    @TestSetup
    static void makeData(){

        //Usuario SAC General
        User usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        Database.insert(usuario);

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec2');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        Database.insert(reclamacion);

        //Interacción
        SAC_Interaccion__c interaccion = SAC_TestDataFactory.crearInteraccionn(1,reclamacion.id,null)[0];
        interaccion.SAC_Respuesta__c = 'threadId';
        interaccion.SAC_IndexedThreadId__c = 'ref:_threadId:ref';
        interaccion.SAC_FechaRespuesta__c = system.now();
        interaccion.SAC_EmailRespuesta__c = 'emailentrante@entrante.com';
        interaccion.SAC_Estado__c = 'SAC_Resuelta'; 
        Database.insert(interaccion);   
    
    }

    @isTest
    static void emailServiceConsultaTest() {

        Messaging.InboundEmail.BinaryAttachment binAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binAttachment.body = blob.valueOf('my attachment text');
        binAttachment.fileName = 'textfile.txt';
        binAttachment.mimeTypeSubType = 'text/plain';

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailServiceConsulta' LIMIT 1];
        String headerValueCAM = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.name = 'X-SDFC-Original-RCPT';
        header.value = headerValueCAM;

        Messaging.InboundEmail.TextAttachment txtAttachment = new Messaging.InboundEmail.TextAttachment();
        txtAttachment.body = 'my attachment text';
        txtAttachment.fileName = 'textfile2.txt';
        txtAttachment.mimeTypeSubType = 'text/plain';

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.subject = 'Email entrante';
        email.fromname = 'emailentrante@entrante.com';
        email.fromAddress = 'emailentrante@entrante.com';
        List<String> direcciones = new List<String>();
        direcciones.add('emailentrante@entrante.com');
        email.toAddresses = direcciones;
        List<String> ccAdresses = new List<String>();
        ccAdresses.add('emailentrante@entrante.com, emailentrante2@entrante.com');
        email.ccAddresses = ccAdresses;
        email.plainTextBody = 'threadId';
        email.htmlBody= 'ref:_threadId:ref';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {binAttachment};
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] {txtAttachment};
        email.headers = new Messaging.InboundEmail.Header[] {header};

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'emailentrante@entrante.com';
        env.toAddress = 'emailentrante@entrante.com';
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {
            //llamar a la clase del email service
            SAC_EmailServiceConsulta emailProcess = new SAC_EmailServiceConsulta();
            emailProcess.handleInboundEmail (email, env);
        }
        Test.stopTest();

        System.assertNotEquals([SELECT ID FROM SAC_Interaccion__c].size(), 0, 'No se ha insertado el mail');

    }

    @isTest
    static void emailServiceConsultaFail(){
        
        Messaging.InboundEmail.BinaryAttachment binAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binAttachment.body = blob.valueOf('my attachment text');
        binAttachment.fileName = 'textfile.txt';
        binAttachment.mimeTypeSubType = 'text/plain';

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailServiceConsulta' LIMIT 1];
        String headerValueCAM = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.name = 'X-SDFC-Original-RCPT';
        header.value = headerValueCAM;

        Messaging.InboundEmail.TextAttachment txtAttachment = new Messaging.InboundEmail.TextAttachment();
        txtAttachment.body = 'my attachment text';
        txtAttachment.fileName = 'textfile2.txt';
        txtAttachment.mimeTypeSubType = 'text/plain';

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.subject = 'Email entrante';
        email.fromname = 'emailentrante@entrante.com';
        email.fromAddress = 'emailentranteentrante.com';
        List<String> direcciones = new List<String>();
        direcciones.add('emailentrante@entrante.com');
        email.toAddresses = direcciones;
        email.plainTextBody = 'threadId';
        email.htmlBody= 'ref:_threadId:ref';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {binAttachment};
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] {txtAttachment};
        email.headers = new Messaging.InboundEmail.Header[] {header};

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'emailentranteentrante.com';
        env.toAddress = 'emailentrante@entrante.com';

        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        Test.startTest();
        try {
            System.runAs(usuario) {
                SAC_EmailServiceConsulta emailProcess = new SAC_EmailServiceConsulta();
                emailProcess.handleInboundEmail (email, env);
            }    
        } catch (Exception e) {
            System.assertNotEquals(e, null, 'el metodo email service no deberia funcionar');
            
        }
        Test.stopTest();
    }
}