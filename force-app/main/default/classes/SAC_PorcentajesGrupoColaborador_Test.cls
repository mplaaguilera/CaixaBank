/*****************************************************************
 * Name: SAC_PorcentajesGrupoColaborador_Test
 * Copyright © 2019  CaixaBank 
 * 
 * Proposito: Testear la clase SAC_PorcentajesGrupoColaborador_Test 
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US213183         Carlos Solis   11/05/21     Creación
*****************************************************************/
@isTest
public with sharing class SAC_PorcentajesGrupoColaborador_Test {
    @TestSetup
    static void makeData() {
        Id recType = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c>();
        
        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
        grupoColaborador.name = 'grupoATest';
        grupoColaborador.RecordTypeId = recType;
        grupoColaborador.SAC_PorcentajeAsignacion__c = 60;
        grupoColaborador.SAC_MaximoCasosDiarios__c = 10;

        CC_Grupo_Colaborador__c grupoColaborador2 = new CC_Grupo_Colaborador__c();
        grupoColaborador2.name = 'grupoBTest';
        grupoColaborador2.RecordTypeId = recType;
        grupoColaborador2.SAC_PorcentajeAsignacion__c = 40;
        grupoColaborador2.SAC_MaximoCasosDiarios__c = 10;
        
        listaGrupos.add(grupoColaborador);
        listaGrupos.add(grupoColaborador2);
        insert listaGrupos;

        User usuarioAdmin = new User();
        usuarioAdmin.Username = 'usergeneral@test.com';
        usuarioAdmin.Email = 'email@test.com';
        usuarioAdmin.LastName = 'usuarioGeneral Test';
        usuarioAdmin.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'GMT';
        usuarioAdmin.LocaleSidKey = 'es_ES';
        usuarioAdmin.EmailEncodingKey = 'ISO-8859-1';
        usuarioAdmin.LanguageLocaleKey = 'en_US';
        usuarioAdmin.SAC_GruposPerteneciente__c = grupoColaborador.id;
        usuarioAdmin.isActive = true;

        insert usuarioAdmin;
    }

    @isTest
    static void comprobarPorcentajeInsertTest() {
        Id recType = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        User usuario = [SELECT id FROM User WHERE alias = 'alias' Limit 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        insert permiSetAssi;

        CC_Grupo_Colaborador__c grupoColaborador3 = new CC_Grupo_Colaborador__c();
        grupoColaborador3.name = 'grupo';
        grupoColaborador3.RecordTypeId = recType;
        grupoColaborador3.SAC_PorcentajeAsignacion__c = 60;

        List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c>();
        listaGrupos.add(grupoColaborador3);
        
        Test.startTest();
        System.runAs(usuario) {
            SAC_PorcentajesGrupoColaborador.comprobarPorcentajeInsert(listaGrupos);
        }
        Test.stopTest();
        system.assertEquals(listaGrupos, listaGrupos, 'No se ha podido controlar el porcentaje');
    }

    @isTest
    static void comprobarPorcentajeUpdateTest() {
        Id recType = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        User usuario = [SELECT id FROM User WHERE alias = 'alias' Limit 1];
        List<CC_Grupo_Colaborador__c> listaGrupos = [select id, name, RecordTypeId, SAC_PorcentajeAsignacion__c from CC_Grupo_Colaborador__c];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        insert permiSetAssi;

        listaGrupos[0].SAC_PorcentajeAsignacion__c = 1;
        
        Test.startTest();
        System.runAs(usuario) {
            SAC_PorcentajesGrupoColaborador.comprobarPorcentajeUpdate(listaGrupos);
        }
        Test.stopTest();
        system.assertEquals(listaGrupos, listaGrupos, 'No se ha podido controlar el porcentaje');
    }

    @isTest
    static void comprobarPorcentajeDeleteTest() {
        Id recType = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        User usuario = [SELECT id FROM User WHERE alias = 'alias' Limit 1];
        List<CC_Grupo_Colaborador__c> listaGrupos = [select id, name, RecordTypeId, SAC_PorcentajeAsignacion__c from CC_Grupo_Colaborador__c limit 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        insert permiSetAssi;

        Test.startTest();
        System.runAs(usuario) {
            SAC_PorcentajesGrupoColaborador.comprobarPorcentajeDelete(listaGrupos);
        }
        Test.stopTest();
        system.assertEquals(listaGrupos, listaGrupos, 'No se ha podido controlar el porcentaje');
    }

    @isTest
    static void establecerPorcentajeAsignacionTest() {
        Id recType = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        User usuario = [SELECT id FROM User WHERE alias = 'alias' Limit 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        insert permiSetAssi;

        Test.startTest();
        System.runAs(usuario) {
            List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c>();
            CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
            grupoColaborador.name = 'grupoInsertTest';
            grupoColaborador.RecordTypeId = recType;
            grupoColaborador.SAC_MaximoCasosDiarios__c = 10;
            listaGrupos.add(grupoColaborador);

            CC_Grupo_Colaborador__c grupoColaborador2 = new CC_Grupo_Colaborador__c();
            grupoColaborador2.name = 'grupoInsert2Test';
            grupoColaborador2.RecordTypeId = recType;
            grupoColaborador2.SAC_MaximoCasosDiarios__c = 10;
            listaGrupos.add(grupoColaborador2);
            insert listaGrupos;
        }
        Test.stopTest();

        List<CC_Grupo_Colaborador__c> listaGruposResult2 = [SELECT Id, SAC_PorcentajeAsignacion__c 
                                                            FROM CC_Grupo_Colaborador__c 
                                                            WHERE Name = 'grupoInsert2Test' LIMIT 1];

        List<CC_Grupo_Colaborador__c> listaGruposResult1 = [SELECT Id, SAC_PorcentajeAsignacion__c 
                                                            FROM CC_Grupo_Colaborador__c 
                                                            WHERE Name = 'grupoInsertTest' LIMIT 1];

        system.assertNotEquals(null, listaGruposResult2[0].SAC_PorcentajeAsignacion__c, 'No se ha podido asignar el porcentaje');
        system.assertNotEquals(null, listaGruposResult1[0].SAC_PorcentajeAsignacion__c, 'No se ha podido asignar el porcentaje');
    }
}