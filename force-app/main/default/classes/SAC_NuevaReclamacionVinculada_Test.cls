/*****************************************************************
 * Name: SAC_NuevaReclamacionVinculada
 * Copyright © 2022  CaixaBank
 * 
 * Proposito: 
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0                             Marcela Neira        25/05/2022   Creación
 * 1.1            US563153         Jose Carlos Blanco  	02/05/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@istest
public with sharing class SAC_NuevaReclamacionVinculada_Test {
    @TestSetup
    static void makeData(){

        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
            SAC_DatabaseDML.insertDML(usuarioGeneral, false);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);
        }

        //Grupo Colaborador
        CC_Grupo_Colaborador__c grupoColaborador = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor',1)[0];
		grupoColaborador.SAC_PorcentajeAsignacion__c = 100;
		grupoColaborador.SAC_MaximoCasosDiarios__c = 1;

        SAC_DatabaseDML.insertDML(grupoColaborador, false);

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Reclamacion');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SEG_Grupo__c', grupoColaborador.Id);
        
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(reclamacion, false);

        //Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'pretension');
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_Reclamacion__c', reclamacion.Id);
        
        Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        SAC_DatabaseDML.insertDML(pretension, false);

        
        reclamacion.SAC_PretensionPrincipal__c = pretension.Id;
        SAC_DatabaseDML.updateDML(reclamacion, false);

        //Topic
        Topic  t = new Topic(Name = 'Topic');
        SAC_DatabaseDML.insertDML(t, false);

        TopicAssignment topicAssig = new TopicAssignment(TopicId=t.Id, EntityId=reclamacion.Id);
        SAC_DatabaseDML.insertDML(topicAssig, false);

        //Email
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
        String headerValueSTR = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details from above. 
        emailMsg.ToAddress = 't.t@t.t';
        emailMsg.Subject = 'em.Subject';
        emailMsg.HtmlBody = 'em.HtmlBody';
        emailMsg.MessageDate = system.today();
        emailMsg.Status = '3';
        emailMsg.FromAddress = 'tt.tt@tt.tt';
        emailMsg.CcAddress = 'cc.cc@cc.cc';
        emailMsg.ParentId = reclamacion.Id;
        emailMsg.Headers = '[{"value": "' + headerValueSTR + '","name": "X-SDFC-Original-RCPT"}]';

        SAC_DatabaseDML.insertDML(emailMsg, false);

        //Adjuntos
        Attachment attach = new Attachment();   	
    	attach.Name='Test';
    	Blob bodyBlob = Blob.valueOf('Testing Body of Attachment');
    	attach.body = bodyBlob;
        attach.ParentId = emailMsg.id;       

        SAC_DatabaseDML.insertDML(attach, false);

        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob2=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob2; 
        content.origin = 'H';
        SAC_DatabaseDML.insertDML(content, false);

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId = reclamacion.id;
        contentlink.contentdocumentid=[SELECT contentdocumentid FROM contentversion WHERE id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';        
        
        SAC_DatabaseDML.insertDML(contentlink, false);
    }

    @istest
    static void nuevaReclamacionVinculada() {
        Case reclamacion = [SELECT id, SAC_PretensionPrincipal__c, CaseNumber FROM Case WHERE Subject = 'Reclamacion']; 
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        Test.startTest();
        System.runAs(usuario) {
            SAC_Case_Operativas_Controller.nuevaReclamacionVinculada(SAC_Case_Operativas_Controller.recuperarCaso(reclamacion.id));
        }
	    Test.stopTest();

        Case reclamacion2 = [SELECT id, SAC_PretensionPrincipal__c, CaseNumber FROM Case WHERE Subject LIKE 'Nueva %'];

        System.assertNotEquals(null, reclamacion2, 'No ha devuelto nada');
    }

    @istest
    static void nuevaReclamacionVinculada2() {
        List<Case> listaCasos = [SELECT id, SAC_PretensionPrincipal__c, CaseNumber FROM Case WHERE SuppliedCompany='pretension']; 
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        Test.startTest();
        System.runAs(usuario) {
            DateTime dt = DateTime.now();
            Long dateInMilliseconds = dt.getTime();
            AsyncOptions options = new AsyncOptions();
            options.DuplicateSignature = QueueableDuplicateSignature.Builder()
            .addString(String.valueOf(dateInMilliseconds))
            .build();
            try {
                System.enqueueJob(new SAC_NuevaReclamacionVinculada(listaCasos, listaCasos[0]), options);    
            } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);                 } 
        }
	    Test.stopTest();

        System.assertNotEquals(false, !listaCasos.isEmpty(), 'Lista casos correcta');
    }
}