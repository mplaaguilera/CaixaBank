/*****************************************************************
 * Name: SPV_LCMP_NuevaConsulta_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de la clase SPV_LCMP_NuevaConsulta
 * 
****************************************************************/ 
@isTest
public with sharing class SPV_LCMP_NuevaConsulta_Test {
    
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
        grupo.SAC_TienePropietario__c = true;
        grupo.SAC_PeriodoConsulta__c = 12;
        grupo.OS_Negocio__c = 'SPV';
        listGrupos.add(grupo);

        Database.insert(listGrupos);

        //Colaboradores
        List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact1 = SPV_TestDataFactory.crearColaboradorContact(usuarioAdmin.Id, grupo.Id);
        grupoColaboradorContact1.SAC_Administrador__c = true;
        listaColaboradores.add(grupoColaboradorContact1);
        Database.insert(listaColaboradores);

        //Reclamacion
        List<Case> listaReclamaciones = new List<Case>();
        Map<String, Object> camposReclamacion = new Map<String, Object>();
        camposReclamacion.put('Subject', 'TestRecCrearRec1');
        // camposReclamacion.put('SPV_Organismo__c', 'SPV_CNMV');
        camposReclamacion.put('Status', 'SAC_001');
        camposReclamacion.put('OwnerId', listUsuarios[0].Id);
        camposReclamacion.put('SAC_StatusAuxiliar__c', 'SAC_001');

        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion);
        listaReclamaciones.add(casoReclamacion);

        Map<String, Object> camposReclamacion2 = new Map<String, Object>();
        camposReclamacion2.put('Subject', 'TestRecCrearRec2');
        // camposReclamacion2.put('SPV_Organismo__c', 'SPV_CNMV');
        camposReclamacion2.put('Status', 'SAC_001');
        camposReclamacion2.put('OwnerId', usuarioAdmin.Id);
        camposReclamacion2.put('SAC_StatusAuxiliar__c', 'SAC_001');

        Case casoReclamacion2 = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion2);
        listaReclamaciones.add(casoReclamacion2);
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
        camposObj2.put('SAC_Reclamacion__c', casoReclamacion2.Id);
        camposObj2.put('SAC_Titulo__c', 'ConsultaTestSPV2');
        camposObj2.put('SAC_GrupoColaborador__c', grupo.Id);
        SAC_Interaccion__c consulta2 = SPV_TestDataFactory.crearInteraccion('Consulta', camposObj2);
        listConsultas.add(consulta2);

        Database.insert(listConsultas);
    }

    @isTest
    static void insertarConsultaTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        Case caso = [SELECT Id,Subject FROM Case WHERE subject = 'TestRecCrearRec1' LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'grupotest' LIMIT 1];


        String idRec = caso.Id; 
        String idConsultaInsertada;

        Test.startTest();
        System.runAs(usuario) {
            idConsultaInsertada = SPV_LCMP_NuevaConsulta.insertarConsulta(idRec, grupo.Id);
        }
        Test.stopTest();

        Assert.areNotEqual(null, idConsultaInsertada, 'La ejecucion ha fallado a la hora de insertar la Consulta');
    }

    @isTest
    static void tienePermisosTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case caso = [SELECT Id,Subject FROM Case WHERE subject = 'TestRecCrearRec1' LIMIT 1];

        String idRec = caso.Id; 
        Boolean tienePermisos;

        Test.startTest();
        System.runAs(usuario) {
            tienePermisos = SPV_LCMP_NuevaConsulta.tienePermisos(idRec);
        }
        Test.stopTest();

        Assert.areNotEqual(false, tienePermisos, 'La ejecucion ha fallado al comprobar los permisos');
    }

    @istest 
    static void getConsultasCasoTest() {
        Case caso = [SELECT Id, Status, OwnerId  FROM Case WHERE Subject = 'TestRecCrearRec2' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        List<SAC_Interaccion__c> consultasPendientes;

        Test.startTest();
        System.runAs(usuario) {
            Map<String, Object> camposObj2 = new Map<String, Object>();
            camposObj2.put('SAC_Reclamacion__c', caso.Id);
            camposObj2.put('SAC_Titulo__c', 'ConsultaTestSPV3');
            // camposObj2.put('SAC_GrupoColaborador__c', grupo.Id);
            SAC_Interaccion__c consulta = SPV_TestDataFactory.crearInteraccion('Consulta', camposObj2);
            Database.insert(consulta);

            consultasPendientes = SPV_LCMP_NuevaConsulta.getConsultasCaso(caso.id, true, caso.OwnerId);
        }
        Test.stopTest();

        Assert.areNotEqual(null, consultasPendientes, 'No se han obtenido las consultas');
    }

    @istest 
    static void finalizarConsultasCasoTest() {
        Case caso = [SELECT Id, Status, OwnerId  FROM Case WHERE Subject = 'TestRecCrearRec2' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        List<SAC_Interaccion__c> listaConsultasAFinalizar = [SELECT id FROM SAC_Interaccion__c  WHERE SAC_Reclamacion__c =: caso.id AND RecordType.DeveloperName = 'SPV_Consulta'];
        List<String> consultasIds = new List<String>();

        for (SAC_Interaccion__c consulta: listaConsultasAFinalizar) {
            consultasIds.add(consulta.id);
        }
        String motivoFinalizado = 'SAC_CanceladaAltaErronea';

        Test.startTest();
        System.runAs(usuario) {
            SPV_LCMP_NuevaConsulta.finalizarConsultasCaso(consultasIds, motivoFinalizado);
        }
        Test.stopTest();

        List<SAC_Interaccion__c> listaConsultasFinalizadas = [SELECT id, SAC_Estado__c, SAC_MotivoDeFinalizado__c FROM SAC_Interaccion__c  WHERE SAC_Reclamacion__c =: caso.id AND RecordType.DeveloperName = 'SPV_Consulta'];
        Assert.areEqual(motivoFinalizado, listaConsultasFinalizadas[0].SAC_MotivoDeFinalizado__c, 'No se han finalizado correctamente las consultas');
    }
}