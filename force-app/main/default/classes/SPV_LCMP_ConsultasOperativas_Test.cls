/*****************************************************************
 * Name: SPV_LCMP_ConsultasOperativas_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de la clase SPV_LCMP_ConsultasOperativas
 * 
****************************************************************/ 
@isTest
public with sharing class SPV_LCMP_ConsultasOperativas_Test {
    
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

        Database.insert(listGrupos);

        //Colaboradores
        List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact1 = SPV_TestDataFactory.crearColaboradorContact(usuarioAdmin.Id, grupo.Id);
        grupoColaboradorContact1.SAC_Administrador__c = true;
        listaColaboradores.add(grupoColaboradorContact1);

        System.runAs(usuarioAdmin){
            Database.insert(listaColaboradores);
        }

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
        camposObj.put('SAC_Estado__c', 'SAC_Resuelta');
        camposObj.put('SAC_GrupoColaborador__c', grupo.Id);
        SAC_Interaccion__c consulta = SPV_TestDataFactory.crearInteraccion('Consulta', camposObj);
        listConsultas.add(consulta);

        Database.insert(listConsultas);
    }

    @isTest
    static void marcarPendienteRespuestaDefinitivaTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c consulta = [SELECT Id, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV' LIMIT 1];
        
        System.runAs(usuario){
            SPV_LCMP_ConsultasOperativas.marcarPendienteRespuestaDefinitiva(consulta.Id);
        }

        SAC_Interaccion__c consultaFinal = [SELECT Id, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV' LIMIT 1];
        
        Assert.areNotEqual(consulta.SAC_Estado__c, consultaFinal.SAC_Estado__c, 'No se ha podidomarcar como respuesta no definitiva la consulta');
        Test.stopTest();
    }

    @isTest
    static void tomarPropiedadConsultaTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c consulta = [SELECT Id, OwnerId FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV' LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'grupotest' LIMIT 1];
        
        System.runAs(usuario){
            SPV_LCMP_ConsultasOperativas.tomarPropiedadConsulta(consulta.Id, grupo.Id, usuario.Id);
        }

        SAC_Interaccion__c consultaFinal = [SELECT Id, OwnerId FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV' LIMIT 1];
        
        Assert.areNotEqual(consulta.OwnerId, consultaFinal.OwnerId, 'No se ha podido tomar en propiedad la consulta');
        Test.stopTest();
    }

    @isTest
    static void tomarPropiedadConsultaFailTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'grupotest' LIMIT 1];
        SAC_Interaccion__c consulta = [SELECT Id, OwnerId FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV' LIMIT 1];

        consulta.SAC_GrupoColaborador__c = null;
        Database.update(consulta);

        Test.startTest();
        System.runAs(usuario) {
            try {
                SPV_LCMP_ConsultasOperativas.tomarPropiedadConsulta(consulta.Id, consulta.SAC_GrupoColaborador__c, usuario.Id);    
            } catch (Exception e) {
                SAC_Interaccion__c consultaresult = [SELECT Id, OwnerId FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV' LIMIT 1];
                System.assertNotEquals(usuario.Id, consultaresult.OwnerId, 'No se ha podido tomar en propiedad la consulta');        
            }
        }
        Test.stopTest();
    }

    @isTest
    static void devolverConsultaAlGrupoTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c consulta = [SELECT Id, OwnerId FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV' LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'grupotest' LIMIT 1];
        
        System.runAs(usuario){
            SPV_LCMP_ConsultasOperativas.devolverConsultaAlGrupo(consulta.Id);
        }

        List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];   

        Assert.areNotEqual(consulta.OwnerId, cola[0].Id, 'No se ha podido devolver la consulta al grupo');
        Test.stopTest();
    }
}