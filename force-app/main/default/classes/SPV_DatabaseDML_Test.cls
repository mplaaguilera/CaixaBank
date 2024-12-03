/*********************************************************************************************************
 * Name: SPV_DatabaseDML_Test
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Test de SPV_DatabaseDML
 * 
 * Historial
 * -------
 * VERSION        USER_STORY            AUTHOR               DATE             Description
 * 1.0               ---             Raúl Santos          29/04/24             Creación
**********************************************************************************************************/

@isTest
public with sharing class SPV_DatabaseDML_Test {
    
    @TestSetup
    static void makeData(){
        Test.startTest();
        //Usuario
        User usuario = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
        Database.insert(usuario);
        Test.stopTest();

        //Grupo Colaborador
        CC_Grupo_Colaborador__c grupoColaborador = SPV_TestDataFactory.crearGrupoColaborador('GrupoGestor', 1)[0];
        grupoColaborador.SAC_MaximoCasosDiarios__c = 5;
        grupoColaborador.SAC_Email__c = 'testspv@testemail.com.invalid';

        System.runAs(usuario){
            Database.insert(grupoColaborador);
        }
    }
    
    @isTest
    static void insertDMLTest(){
        Test.startTest();
        CC_Grupo_Colaborador__c grupoColaborador = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Gestor 0' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuario){
            CC_Grupo_Colaborador_Contact__c colaborador = SPV_TestDataFactory.crearColaboradorContact(usuario.Id, grupoColaborador.Id);
            SPV_DatabaseDML.insertDML(colaborador, true);
        }

        Test.stopTest();

        CC_Grupo_Colaborador_Contact__c colaboradorResultado = [SELECT Id FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =: usuario.Id];
        Assert.areNotEqual(null, colaboradorResultado.Id, 'No se ha podido insertar el colaborador');
    }

    @isTest
    static void updateDMLTest(){
        Test.startTest();
        CC_Grupo_Colaborador__c grupoColaborador = [SELECT Id, SAC_Email__c FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Gestor 0' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);


        System.runAs(usuario){
            grupoColaborador.SAC_Email__c = 'testspv@testemail.com.invalid2';
            SPV_DatabaseDML.updateDML(grupoColaborador, true);
        }

        Test.stopTest();

        CC_Grupo_Colaborador__c grupoColaboradorRes = [SELECT Id, SAC_Email__c FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Gestor 0' LIMIT 1];
        Assert.areEqual('testspv@testemail.com.invalid2', grupoColaboradorRes.SAC_Email__c, 'No se ha podido actualizar el grupo colaborador');
    }
    
    @isTest
    static void upsertDMLTest(){
        Test.startTest();
        CC_Grupo_Colaborador__c grupoColaborador = [SELECT Id, SAC_Email__c FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Gestor 0' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario){
            grupoColaborador.SAC_Email__c = 'testspv@testemail.com.invalid2';
            SPV_DatabaseDML.upsertDML(grupoColaborador, true);
        }

        Test.stopTest();

        CC_Grupo_Colaborador__c grupoColaboradorRes = [SELECT Id, SAC_Email__c FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Gestor 0' LIMIT 1];
        Assert.areEqual('testspv@testemail.com.invalid2', grupoColaboradorRes.SAC_Email__c, 'No se ha podido actualizar el grupo colaborador');
    }
    
    @isTest
    static void deletDMLTest(){
        Test.startTest();
        CC_Grupo_Colaborador__c grupoColaborador = [SELECT Id, SAC_Email__c FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Gestor 0' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario){
            SPV_DatabaseDML.deleteDML(grupoColaborador, true);
        }

        Test.stopTest();

        List<CC_Grupo_Colaborador__c> lstResult = [SELECT Id FROM CC_Grupo_Colaborador__c  WHERE Name = 'Grupo Gestor 0' LIMIT 1];
        Assert.isTrue(lstResult.isEmpty(), 'No existe el grupo colaborador');
    }
}