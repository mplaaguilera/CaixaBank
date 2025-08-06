/*****************************************************************
 * Name: SPV_MCCHelper_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de la clase SPV_MCCHelper y los trigger del objeto CC_MCC__c
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             US909081      Raúl Santos    24/06/24        Creación
****************************************************************/ 

@isTest
public with sharing class SPV_MCCHelper_Test {
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

        CC_MCC__c mccDetalle2 = new CC_MCC__c(
        RecordTypeId = recTypeDetalle,
        Name = 'Discrepancia con importe deuda MCC Clase Test2',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101016',
        CC_Motivo__c = mccMotivo1.id,
        OwnerId = usuarioGeneral.id,
        SPV_BalanceoForzado__c = false);
        Database.insert(mccDetalle2);

        List<CC_Grupo_Colaborador__c> gruposColaboradores = new List <CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupoGestor = SPV_TestDataFactory.crearGrupoColaborador('GrupoGestor',1)[0];
        grupoGestor.SAC_MaximoCasosDiarios__c = 5;
        grupoGestor.SAC_DeveloperName__c = 'SPV_TESTGRUPOGESTOR';
        grupoGestor.SAC_Email__c = 'testSPV@testemail.com.invalid';
        gruposColaboradores.add(grupoGestor);
        Database.insert(gruposColaboradores);

        CC_MCC_Grupo_Colaborador__c mccGrupoColab = new CC_MCC_Grupo_Colaborador__c();
        mccGrupoColab.CC_Grupo_Colaborador__c = grupoGestor.Id;
        mccGrupoColab.CC_MCC__c = mccDetalle2.Id;
        mccGrupoColab.Name = 'Test1 Grupo Colaborador MCC1';
        mccGrupoColab.SAC_MaximoDeCasosDiarios__c = 100;
        mccGrupoColab.SAC_PorcentajeAsignacion__c = 100;
        mccGrupoColab.SPV_Tipo_Cliente__c = 'SPV';
        Database.insert(mccGrupoColab);        
    }

    @isTest
    static void checkBalaceoForzadoTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true LIMIT 1];
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        CC_MCC__c mcct = [SELECT id, SPV_BalanceoForzado__c FROM CC_MCC__c WHERE Name = 'Avales MCC Clase Test' LIMIT 1];

        System.RunAs(usuario){
            mcct.SPV_BalanceoForzado__c = true;
            Database.update(mcct);

        }
        Test.stopTest();
        
        Assert.areNotEqual(false, mcct.SPV_BalanceoForzado__c, 'No se ha podido actualizar el MCC');
    }

    @isTest
    static void comprobarGruposColaboradoresTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true LIMIT 1];
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        CC_MCC__c mccd = [SELECT id, SPV_BalanceoForzado__c FROM CC_MCC__c WHERE Name = 'Discrepancia con importe deuda MCC Clase Test2' LIMIT 1];

        System.RunAs(usuario){
            mccd.SPV_BalanceoForzado__c = true;
            Database.update(mccd);

        }
        Test.stopTest();
        
        Assert.areNotEqual(false, mccd.SPV_BalanceoForzado__c, 'No se ha podido actualizar el MCC');
    }
}