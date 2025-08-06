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
        SPV_DatabaseDML.insertDML(usuarioADmin, true);

        List<User> listUsuarios ;

        System.runAs(usuarioAdmin){
            listUsuarios  = SPV_TestDataFactory.crearUsuarioSPVGeneral(2);
            SPV_DatabaseDML.insertListDML(listUsuarios, true);
        }

        Test.stopTest();

        List<Account> listaCuentas = new List<Account>();
        //Cuentas
        listaCuentas = SPV_TestDataFactory.crearCuentas(1);
        listaCuentas[0].Name = 'Cuenta A - Test SPV';
        listaCuentas[0].CC_Tipo_Centro__c = 'OF';
        listaCuentas[0].Phone = '123456789';
        listaCuentas[0].CC_Email__c = 'cuenta@mail.com';
        listaCuentas[0].billingStreet  = 'Calle Mayor 55';
        listaCuentas[0].BillingCountry = 'España';
        listaCuentas[0].recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        SPV_DatabaseDML.insertListDML(listaCuentas, true);

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
        grupo.SAC_DeveloperName__c = 'OFICINA';
        listGrupos.add(grupo);

        SPV_DatabaseDML.insertListDML(listGrupos, true);

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
        SPV_DatabaseDML.insertListDML(listaReclamaciones, true);

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

        SPV_DatabaseDML.insertListDML(listConsultas, true);

        //Oficinas afectadas
        List<SAC_ImagenDocumento__c> listaOficinasAfectadas = new List<SAC_ImagenDocumento__c>();

        SAC_ImagenDocumento__c objIntermedio1 = new SAC_ImagenDocumento__c();
        objIntermedio1.SAC_Caso__c = casoReclamacion.Id;
        objIntermedio1.SPV_OficinaAfectada_Lookup__c = listaCuentas[0].Id;
        objIntermedio1.RecordTypeId = Schema.SObjectType.SAC_ImagenDocumento__c.getRecordTypeInfosByDeveloperName().get('SPV_OficinaAfectada').getRecordTypeId();
        listaOficinasAfectadas.add(objIntermedio1);
        SPV_DatabaseDML.insertListDML(listaOficinasAfectadas, true);
   
        //Tareas
        List<SAC_Accion__c> listaDeTareasOtras2 = SPV_TestDataFactory.crearTareas(1,casoReclamacion,null);
        listaDeTareasOtras2[0].SAC_Observaciones__c = 'tarea3-testnuevaconsulta';
        listaDeTareasOtras2[0].OwnerId = usuarioAdmin.id;
        listaDeTareasOtras2[0].SPV_GrupoTarea__c = listGrupos[0].Id;

        System.runAs(usuarioAdmin){

            SPV_DatabaseDML.insertListDML(listaDeTareasOtras2, true);

            //Colaboradores
            List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact1 = SPV_TestDataFactory.crearColaboradorContact(usuarioAdmin.Id, grupo.Id);
            grupoColaboradorContact1.SAC_Administrador__c = true;
            listaColaboradores.add(grupoColaboradorContact1);
            SPV_DatabaseDML.insertListDML(listaColaboradores, true);
        }
    }

    @isTest
    static void insertarConsultaTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case caso = [SELECT Id,Subject FROM Case WHERE subject = 'TestRecCrearRec1' LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'grupotest' LIMIT 1];
        Account oficina = [SELECT Id FROM Account WHERE Name = 'Cuenta A - Test SPV' LIMIT 1];

        String idRec = caso.Id; 
        String idConsultaInsertada;

        Test.startTest();
        System.runAs(usuario) {
            idConsultaInsertada = SPV_LCMP_NuevaConsulta.insertarConsulta(idRec, grupo.Id, oficina.Id, 'Case');
        }
        Test.stopTest();

        Assert.areNotEqual(null, idConsultaInsertada, 'La ejecucion ha fallado a la hora de insertar la Consulta');
    }

    @isTest
    static void insertarConsultaTest2() {
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'tarea3-testnuevaconsulta' LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'grupotest' LIMIT 1];
        Account oficina = [SELECT Id FROM Account WHERE Name = 'Cuenta A - Test SPV' LIMIT 1];

        String idConsultaInsertada;

        Test.startTest();
        System.runAs(usuario) {
            idConsultaInsertada = SPV_LCMP_NuevaConsulta.insertarConsulta(tarea.Id, grupo.Id, oficina.Id, 'SAC_Accion__c');
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
            tienePermisos = SPV_LCMP_NuevaConsulta.tienePermisos(idRec, 'Case');
        }
        Test.stopTest();

        Assert.areEqual(false, tienePermisos, 'La ejecucion ha fallado al comprobar los permisos');
    }

    @isTest
    static void tienePermisosTest2() {
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'tarea3-testnuevaconsulta' LIMIT 1];
        Boolean tienePermisos;

        Test.startTest();
        System.runAs(usuario) {
            tienePermisos = SPV_LCMP_NuevaConsulta.tienePermisos(tarea.Id, 'SAC_Accion__c');
        }
        Test.stopTest();

        Assert.areNotEqual(false, tienePermisos, 'La ejecucion ha fallado al comprobar los permisos');
    }

    @istest 
    static void getConsultasTest() {
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
            SPV_DatabaseDML.insertDML(consulta, true);

            consultasPendientes = SPV_LCMP_NuevaConsulta.getConsultas(caso.id, caso.OwnerId);
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

    @istest 
    static void comprobarPosibleOficinaTest() {
        Case caso = [SELECT Id, Status, OwnerId  FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'grupotest' LIMIT 1];
        List<SAC_ImagenDocumento__c> listOficinas = new List<SAC_ImagenDocumento__c>();

        Test.startTest();
        System.runAs(usuario) {
            listOficinas = SPV_LCMP_NuevaConsulta.comprobarPosibleOficina(grupo.Id, caso.Id);
        }
        Test.stopTest();

        Assert.areEqual(false, listOficinas.isEmpty(), 'No se han comprobado las oficinas correctamente');
    }
}