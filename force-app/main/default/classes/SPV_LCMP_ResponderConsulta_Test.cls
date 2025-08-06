/*****************************************************************
 * Name: SPV_LCMP_ResponderConsulta_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de la clase SPV_LCMP_ResponderConsulta
 * 
****************************************************************/ 
@isTest
public with sharing class SPV_LCMP_ResponderConsulta_Test {
    
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
        grupo2.SAC_DeveloperName__c = 'OFICINA';
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
        camposObj2.put('SAC_Respuesta__c', 'ConsultaTestSPV2');
        camposObj2.put('SAC_GrupoColaborador__c', grupo2.Id);
        SAC_Interaccion__c consulta2 = SPV_TestDataFactory.crearInteraccion('Consulta', camposObj2);
        listConsultas.add(consulta2);

        Map<String, Object> camposObj3 = new Map<String, Object>();
        camposObj3.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposObj3.put('SAC_Titulo__c', 'ConsultaTestSPV3');
        camposObj3.put('SAC_GrupoColaborador__c', grupo2.Id);
        SAC_Interaccion__c consulta3 = SPV_TestDataFactory.crearInteraccion('Consulta', camposObj3);
        listConsultas.add(consulta3);
        Database.insert(listConsultas);
    }

    @istest 
    static void responderConsultaTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c consulta = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV' LIMIT 1];

        test.startTest();
        System.runAs(usuario) {
            SPV_LCMP_ResponderConsulta.responderConsulta(consulta.id, 'Esta es la respuesta', 'SAC_FaltaInformacion');
        }
        test.stopTest();

        SAC_Interaccion__c consultaFinal = [SELECT Id, SAC_Respuesta__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV' LIMIT 1];
        Assert.areEqual('Esta es la respuesta', consultaFinal.SAC_Respuesta__c, 'No se ha respondido la consulta correctamente');
    }

    @istest 
    static void responderConsultaTest2() {
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c consultaOficina = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV3' LIMIT 1];

        test.startTest();
        System.runAs(usuario) {
            SPV_LCMP_ResponderConsulta.responderConsulta(consultaOficina.id, 'Esta es la respuesta', 'SAC_FaltaInformacion');
        }
        test.stopTest();

        SAC_Interaccion__c consultaFinal = [SELECT Id, SAC_Respuesta__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV3' LIMIT 1];
        Assert.areNotEqual('', consultaFinal.SAC_Respuesta__c, 'No se ha respondido la consulta correctamente');
    }

    @istest 
    static void guardarConsultaTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c consulta = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV' LIMIT 1];

        test.startTest();
        System.runAs(usuario) {
            SPV_LCMP_ResponderConsulta.guardarConsulta(consulta.id, 'Esta es la respuesta', 'SAC_FaltaInformacion');
        }
        test.stopTest();

        SAC_Interaccion__c consultaFinal = [SELECT Id, SAC_Respuesta__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV' LIMIT 1];
        Assert.areEqual('Esta es la respuesta', consultaFinal.SAC_Respuesta__c, 'No se ha guardado la respuesta correctamente');
    }

    @istest 
    static void guardarConsultaTest2() {
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c consultaOficina = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV3' LIMIT 1];

        test.startTest();
        System.runAs(usuario) {
            SPV_LCMP_ResponderConsulta.guardarConsulta(consultaOficina.id, 'Esta es la respuesta', 'SAC_FaltaInformacion');
        }
        test.stopTest();
        SAC_Interaccion__c consultaFinal = [SELECT Id, SAC_Respuesta__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV3' LIMIT 1];
        Assert.areNotEqual('', consultaFinal.SAC_Respuesta__c, 'No se ha guardado la respuesta correctamente');
    }
    
    @istest 
    static void getRespuestaConsultaTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c consulta = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV2' LIMIT 1];

        String comprobacion;
        test.startTest();
        System.runAs(usuario) {
            comprobacion = SPV_LCMP_ResponderConsulta.getRespuestaConsulta(consulta.id);
        }
        test.stopTest();
        Assert.areEqual('ConsultaTestSPV2', comprobacion, 'No se ha obtenido la respuesta correctamente');
    }

    @isTest
    static void insertarAdjuntoCasoTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c consulta = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV2' LIMIT 1];

        Test.startTest();
        System.runAs(usuario) {
            //Archivo adjunto
            ContentVersion newcont = new ContentVersion();
            newcont.Title = 'prueba';
            newcont.PathOnClient = 'caixatestexample.jpeg';
            Blob b=Blob.valueOf('This is version data');
            newcont.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
            newcont.FirstPublishLocationId  = consulta.id;
            Database.insert(newcont); 

            SPV_LCMP_ResponderConsulta.insertarAdjuntoCaso(consulta.Id, 1);
        }
        Test.stopTest();
		
        Assert.areNotEqual(null, 'adjuntado', 'no se ha podido insertar adjunto');
    }
}