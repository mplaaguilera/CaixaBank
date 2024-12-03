/*****************************************************************
 * Name: SPV_MCCGrupoColaboradorHelper_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de la clase SPV_MCCGrupoColaboradorHelper y los trigger del objeto CC_MCC_Grupo_Colaborador__c
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             US909081      Raúl Santos    24/06/24        Creación
****************************************************************/ 

@isTest
public with sharing class SPV_MCCGrupoColaboradorHelper_Test {
    @TestSetup
    static void makeData(){
        Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);

        User usuarioGeneral;
        System.runAs(usuarioAdmin){
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            Database.insert(usuarioGeneral);

            PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
            PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
            permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
            permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
            Database.insert(permiSetAssiAdmin);
        }
        Test.stopTest();
        
        Id recTypeTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recTypeProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recTypeMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recTypeDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();

        //MCC
        CC_MCC__c mccTematica1 = new CC_MCC__c(
        RecordTypeId = recTypeTematica,
        Name = 'Avales MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-0101',
        OwnerId = usuarioGeneral.id,
        SPV_BalanceoForzado__c = false);
        Database.insert(mccTematica1);

        CC_MCC__c mccProdServ1 = new CC_MCC__c(
        RecordTypeId = recTypeProdServ,
        Name = 'Avales Fianzas y Otras Garantías MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101',
        CC_Tematica__c = mccTematica1.id,
        OwnerId = usuarioGeneral.id,
        SPV_BalanceoForzado__c = false);
        Database.insert(mccProdServ1);

        CC_MCC__c mccMotivo1 = new CC_MCC__c(
        RecordTypeId = recTypeMotivo,
        Name = 'Discrepancia con importe deuda reclamada MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Producto_Servicio__c = mccProdServ1.id,
        CC_Codigo_Externo__c = 'TEST-0102',
        OwnerId = usuarioGeneral.id,
        SPV_BalanceoForzado__c = false);
        Database.insert(mccMotivo1);

        CC_MCC__c mccDetalle1 = new CC_MCC__c(
        RecordTypeId = recTypeDetalle,
        Name = 'Discrepancia con importe deuda MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101012',
        CC_Motivo__c = mccMotivo1.id,
        OwnerId = usuarioGeneral.id,
        SPV_BalanceoForzado__c = false);
        Database.insert(mccDetalle1);

        CC_MCC__c mccTematica2 = new CC_MCC__c(
        RecordTypeId = recTypeTematica,
        Name = 'Avales MCC Clase Test2',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-0102864',
        OwnerId = usuarioGeneral.id,
        SPV_BalanceoForzado__c = true);
        Database.insert(mccTematica2);
        
        List<CC_Grupo_Colaborador__c> gruposColaboradores = new List <CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupoGestor = SPV_TestDataFactory.crearGrupoColaborador('GrupoGestor',1)[0];
        grupoGestor.SAC_MaximoCasosDiarios__c = 5;
        grupoGestor.SAC_DeveloperName__c = 'SPV_TESTGRUPOGESTOR';
        grupoGestor.SAC_Email__c = 'testSPV@testemail.com.invalid';
        gruposColaboradores.add(grupoGestor);
        Database.insert(gruposColaboradores);

        CC_MCC_Grupo_Colaborador__c mccGrupoColab = new CC_MCC_Grupo_Colaborador__c();
        mccGrupoColab.CC_Grupo_Colaborador__c = grupoGestor.Id;
        mccGrupoColab.CC_MCC__c = mccTematica1.Id;
        mccGrupoColab.Name = 'Test1 Grupo Colaborador MCC1';
        mccGrupoColab.SAC_MaximoDeCasosDiarios__c = 100;
        mccGrupoColab.SAC_PorcentajeAsignacion__c = 100;
        mccGrupoColab.SPV_Tipo_Cliente__c = 'SPV';
        Database.insert(mccGrupoColab);
    }

    @isTest
    static void insertarGrupoColabTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];

        CC_MCC__c mcct = [SELECT id FROM CC_MCC__c WHERE Name = 'Avales MCC Clase Test' LIMIT 1];
        CC_Grupo_Colaborador__c grupoColab = [SELECT id FROM CC_Grupo_Colaborador__c WHERE SAC_DeveloperName__c = 'SPV_TESTGRUPOGESTOR' LIMIT 1];


        System.RunAs(usuario){
            
            CC_MCC_Grupo_Colaborador__c mccGrupoColab = new CC_MCC_Grupo_Colaborador__c();

            mccGrupoColab.CC_Grupo_Colaborador__c = grupoColab.Id;
            mccGrupoColab.CC_MCC__c = mcct.Id;
            mccGrupoColab.Name = 'Test Grupo Colaborador MCC';
            mccGrupoColab.SAC_MaximoDeCasosDiarios__c = 100;
            mccGrupoColab.SAC_PorcentajeAsignacion__c = 100;
            mccGrupoColab.SPV_Tipo_Cliente__c = 'SPV';
    
            Database.insert(mccGrupoColab);

            Assert.areNotEqual(null, mccGrupoColab, 'No se ha podido insertar el grupo colaborador del MCC');
        }
        Test.stopTest();
    }

    @isTest
    static void actualizarGrupoColabTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        CC_MCC_Grupo_Colaborador__c mccGrupoColab = [SELECT Id, SAC_PorcentajeAsignacion__c FROM CC_MCC_Grupo_Colaborador__c WHERE Name = 'Test1 Grupo Colaborador MCC1' LIMIT 1];

        System.RunAs(usuario){
            
            mccGrupoColab.SAC_PorcentajeAsignacion__c = 50;
            Database.update(mccGrupoColab);

            Assert.areNotEqual(100, mccGrupoColab.SAC_PorcentajeAsignacion__c, 'No se ha podido actualizar el grupo colaborador del MCC');
        }
        Test.stopTest();
    }

    @isTest
    static void eliminarGrupoColabTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        CC_MCC_Grupo_Colaborador__c mccGrupoColab = [SELECT Id, SAC_PorcentajeAsignacion__c FROM CC_MCC_Grupo_Colaborador__c WHERE Name = 'Test1 Grupo Colaborador MCC1' LIMIT 1];

        System.RunAs(usuario){
            
            Database.delete(mccGrupoColab);

            Assert.areNotEqual(mccGrupoColab, null, 'No se ha podido eliminar el grupo colaborador del MCC');
        }
        Test.stopTest();
    }

    @isTest
    static void insertarGrupoColabTest2(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];

        CC_MCC__c mcct = [SELECT id FROM CC_MCC__c WHERE Name = 'Avales MCC Clase Test2' LIMIT 1];
        CC_Grupo_Colaborador__c grupoColab = [SELECT id FROM CC_Grupo_Colaborador__c WHERE SAC_DeveloperName__c = 'SPV_TESTGRUPOGESTOR' LIMIT 1];


        System.RunAs(usuario){
            
            CC_MCC_Grupo_Colaborador__c mccGrupoColab = new CC_MCC_Grupo_Colaborador__c();

            mccGrupoColab.CC_Grupo_Colaborador__c = grupoColab.Id;
            mccGrupoColab.CC_MCC__c = mcct.Id;
            mccGrupoColab.Name = 'Test Grupo Colaborador MCC';
            mccGrupoColab.SAC_MaximoDeCasosDiarios__c = 100;
            mccGrupoColab.SAC_PorcentajeAsignacion__c = 100;
            mccGrupoColab.SPV_Tipo_Cliente__c = 'SPV';
    
            Database.insert(mccGrupoColab);

            Assert.areNotEqual(null, mccGrupoColab, 'No se ha podido insertar el grupo colaborador del MCC');
        }
        Test.stopTest();
    }
}