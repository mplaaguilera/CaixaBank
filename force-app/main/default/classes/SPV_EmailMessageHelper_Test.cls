/*****************************************************************
 * Name: SPV_EmailMessageHelper_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de la clase SPV_EmailMessageHelper
 * 
****************************************************************/ 
@isTest
public with sharing class SPV_EmailMessageHelper_Test {
    
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
        grupo.SAC_Externo__c = true;
        grupo.SAC_PeriodoConsulta__c = 12;
        grupo.OS_Negocio__c = 'SPV';
        listGrupos.add(grupo);
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
        // camposObj.put('SAC_Titulo__c', 'ConsultaTestSPV');
        camposObj.put('SAC_GrupoColaborador__c', grupo.Id);
        SAC_Interaccion__c consulta = SPV_TestDataFactory.crearInteraccion('Consulta', camposObj);
        listConsultas.add(consulta);
        Database.insert(listConsultas);
    }

    @isTest
    static void pegarInteraccionMessageTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];
        SAC_Interaccion__c consulta = [SELECT id, SAC_Pregunta__c FROM SAC_Interaccion__c WHERE SAC_Reclamacion__c = :reclamacion.Id LIMIT 1];

        Test.startTest();
        System.runAs(usuario) {
            EmailMessage em  = new EmailMessage();
            em.relatedtoId = consulta.Id;
            em.Subject = 'emTest Consulta externa';
            em.ToAddress = 'test@test.cominvalidspv';
            em.MessageDate = System.now();
            Database.insert(em);
        }
        Test.stopTest();
		
        SAC_Interaccion__c consultaFinal = [SELECT id, SAC_Titulo__c FROM SAC_Interaccion__c WHERE SAC_Reclamacion__c = :reclamacion.Id LIMIT 1];
        
        Assert.areNotEqual('' ,consultaFinal.SAC_Titulo__c, 'no se ha podido actualizar');
    }
}