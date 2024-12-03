/*****************************************************************
 * Name: SPV_LCMP_GestionEmails_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de la clase SPV_LCMP_GestionEmails
 * 
****************************************************************/ 
@isTest
public with sharing class SPV_LCMP_GestionEmails_Test {

    @TestSetup
    static void makeData(){
    
        Test.startTest();

        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);

        List<User> listUsuarios ;

        System.runAs(usuarioAdmin){
            listUsuarios  = SPV_TestDataFactory.crearUsuarioSPVGeneral(2);
            Database.insert(listUsuarios );
        }

        Test.stopTest();

        //Grupo
        List<CC_Grupo_Colaborador__c> listGrupos = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();
        grupo.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoDeTareas').getRecordTypeId();
        grupo.Name = 'grupotest';
        grupo.SAC_PermiteEscalado__c = true;
        grupo.SAC_PermiteConsultas__c = true;
        grupo.SAC_PermiteTareas__c = true;
        grupo.SAC_PeriodoConsulta__c = 12;
        grupo.OS_Negocio__c = 'SPV';
        listGrupos.add(grupo);

        CC_Grupo_Colaborador__c grupo2 = new CC_Grupo_Colaborador__c();
        grupo2.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoDeTareas').getRecordTypeId();
        grupo2.Name = 'grupotest2';
        grupo2.SAC_PermiteEscalado__c = true;
        grupo2.SAC_PermiteConsultas__c = true;
        grupo2.SAC_PermiteTareas__c = true;
        grupo2.SAC_Externo__c = true;
        grupo2.SAC_PeriodoConsulta__c = 12;
        grupo2.OS_Negocio__c = 'SPV';
        listGrupos.add(grupo2);

        Database.insert(listGrupos);

        //Reclamacion
        List<Case> listaReclamaciones = new List<Case>();
        Map<String, Object> camposReclamacion = new Map<String, Object>();
        camposReclamacion.put('Subject', 'TestRecCrearRec1');
        // camposReclamacion.put('SPV_Organismo__c', 'SPV_CNMV');
        camposReclamacion.put('Status', 'SAC_003');
        camposReclamacion.put('OwnerId', listUsuarios[0].Id);
        camposReclamacion.put('SAC_StatusAuxiliar__c', 'SAC_003');

        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion);
        listaReclamaciones.add(casoReclamacion);
        Database.insert(listaReclamaciones);

        //ContentVersion
        ContentVersion cv = SPV_TestDataFactory.crearContentVersion(casoReclamacion);
        List<ContentVersion> listaCV = new List<ContentVersion>();
        listaCV.add(cv);
        Database.insert(listaCV);

        //Email Backlist
        SAC_MaestroTemas__c maestroTema = new SAC_MaestroTemas__c();
        maestroTema.Name ='emailtest@prueba.com';
        maestroTema.SAC_Activo__c = true;
        maestroTema.RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SPV_BlackListEmails').getRecordTypeId();
        Database.insert(maestroTema);

        //Consulta
        List<SAC_Interaccion__c> listConsultas = new List<SAC_Interaccion__c>();
        Map<String, Object> camposObj = new Map<String, Object>();
        camposObj.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposObj.put('SAC_Titulo__c', 'ConsultaTestSPV');
        camposObj.put('SAC_GrupoColaborador__c', grupo.Id);
        SAC_Interaccion__c consulta = SPV_TestDataFactory.crearInteraccion('Consulta', camposObj);
        listConsultas.add(consulta);

        Map<String, Object> camposObj2 = new Map<String, Object>();
        camposObj2.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposObj2.put('SAC_Titulo__c', 'ConsultaTestSPV2');
        camposObj2.put('SAC_GrupoColaborador__c', grupo2.Id);
        SAC_Interaccion__c consulta2 = SPV_TestDataFactory.crearInteraccion('Consulta', camposObj2);
        listConsultas.add(consulta2);
        Database.insert(listConsultas);

        EmailMessage em  = new EmailMessage();
        em.relatedtoId = consulta2.Id;
        em.Subject = 'emTest Consulta externa';
        em.ToAddress = 'test@test.com';
        em.MessageDate = System.now();
        Database.insert(em);
    }
    
    @isTest
    static void obtieneAdjuntosTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];
        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE Title = 'ABC Test'];
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
       
        reclamacion.OwnerId = usuario.id; 
        cv.OwnerId = usuario.id; 
        Database.update(reclamacion);
        Database.update(cv);

        System.runAs(usuario){
            ContentVersion[] resultado = SPV_LCMP_GestionEmails.obtieneAdjuntos(reclamacion.id);
            Assert.areEqual(resultado[0].Id, cv.Id, 'No ha funcionado correctamente la recuperación de archivos adjuntos.');
        }
        Test.stopTest();
    }

    @isTest
    static void comprobarEmailsEnvioTest() {
        
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        string para = 'emailtest@prueba.com';
        string copia1 ='emailtestcopia1@prueba.com';
        string copia2 ='emailtestcopia2@prueba.com';
        string result;
        Test.startTest();
        System.runAs(usuario){
           result =  SPV_LCMP_GestionEmails.comprobarEmailsEnvio(para, copia1, copia2);
        }
        Assert.areEqual('emailtest@prueba.com', result, 'No coincide');
        Test.stopTest();
    }

    @isTest
    static void enviarEmailTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];
        List<EmailMessage> listaEmailMsg = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];
        //ContentVersion y serializar
        List<ContentVersion> listaCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'ABC Test'];
        List<String> listaIds = new List<String>();
        for (ContentVersion cv : listaCV) {
            listaIds.add(cv.ContentDocumentId);
        }
        String idsAdjuntos = JSON.serialize(listaIds);
        
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            SPV_LCMP_GestionEmails.enviarEmail(reclamacion.Id, 'testemailspv@viewnext.cominvalid; testemailspv@viewnext.cominvalid2', 'testemailspv@viewnext.cominvalid3; testemailspv@viewnext.cominvalid4', 'testemailspv@viewnext.cominvalid5; testemailspv@viewnext.cominvalid6', 'cuerpo prueba', 'Asunto', idsAdjuntos, null);
        }

        List<EmailMessage> listaEmailMsgFinal  = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];        
        Assert.areNotEqual(null, listaEmailMsgFinal, 'No se ha podido efectuar el envío de email');
        Test.stopTest();
    }

    @isTest
    static void enviarEmailInteraccionTest(){
        Test.startTest();
        SAC_Interaccion__c consulta = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV' LIMIT 1];
        List<EmailMessage> listaEmailMsg = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];
        //ContentVersion y serializar
        List<ContentVersion> listaCV = [SELECT Id FROM ContentVersion WHERE Title = 'ABC Test'];
        List<String> listaIds = new List<String>();
        for (ContentVersion cv : listaCV) {
            listaIds.add(cv.Id);
        }
        String idsAdjuntos = JSON.serialize(listaIds);
        
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            SPV_LCMP_GestionEmails.enviarEmail(consulta.Id, 'testemailspv@viewnext.cominvalid; testemailspv@viewnext.cominvalid2', 'testemailspv@viewnext.cominvalid3; testemailspv@viewnext.cominvalid4', 'testemailspv@viewnext.cominvalid5; testemailspv@viewnext.cominvalid6', 'cuerpo prueba', 'Asunto', idsAdjuntos, null);
        }
        List<EmailMessage> listaEmailMsgFinal  = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];        
        Assert.areNotEqual(null, listaEmailMsgFinal, 'No se ha podido efectuar el envío de email');
        Test.stopTest();
    }

    @isTest
    static void enviarEmailInteraccionTest2(){
        Test.startTest();
        SAC_Interaccion__c consulta = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV2' LIMIT 1];
        List<EmailMessage> listaEmailMsg = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];
        //ContentVersion y serializar
        List<ContentVersion> listaCV = [SELECT Id FROM ContentVersion WHERE Title = 'ABC Test'];
        List<String> listaIds = new List<String>();
        for (ContentVersion cv : listaCV) {
            listaIds.add(cv.Id);
        }
        String idsAdjuntos = JSON.serialize(listaIds);
        
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            SPV_LCMP_GestionEmails.enviarEmail(consulta.Id, 'testemailspv@viewnext.cominvalid; testemailspv@viewnext.cominvalid2', 'testemailspv@viewnext.cominvalid3; testemailspv@viewnext.cominvalid4', 'testemailspv@viewnext.cominvalid5; testemailspv@viewnext.cominvalid6', 'cuerpo prueba', 'Asunto prueba', idsAdjuntos, null);
        }
        List<EmailMessage> listaEmailMsgFinal  = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];        
        Assert.areNotEqual(null, listaEmailMsgFinal, 'No se ha podido efectuar el envío de email');
        Test.stopTest();
    }
}