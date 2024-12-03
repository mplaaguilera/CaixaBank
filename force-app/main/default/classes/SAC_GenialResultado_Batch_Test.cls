/*****************************************************************
 * Name: SAC_GenialResultado_Batch_test
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Testear el componente SAC_GenialResultado_Batch
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR           DATE         Description
 * 1.0                             David Ramos      20/11/2023   Creación
****************************************************************/
@isTest
public with sharing class SAC_GenialResultado_Batch_Test {
    @TestSetup
    static void makeData(){
        //Usuario SAC General
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        Database.insert(usuarioGeneral);

        List<PermissionSet> permiSets = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSet permiSet = permiSets[0];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];      
        Database.insert(usuarioAdmin);
        System.runAs(usuarioGeneral){
            //MCC
            //List<CC_MCC__c> listaMCCs = new List<CC_MCC__c>();
            Id recTypeTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
            Id recTypeProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
            Id recTypeMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
            Id recTypeDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();

            CC_MCC__c mccTematica1 = new CC_MCC__c(
                RecordTypeId = recTypeTematica,
                Name = 'Tematica',
                CC_Tipo_Cliente__c = 'SAC',
                CC_Codigo_Externo__c = 'TEST-Tematica1');
            Database.insert(mccTematica1);

            CC_MCC__c mccProdServ1 = new CC_MCC__c(
                RecordTypeId = recTypeProdServ,
                Name = 'ProdServ',
                CC_Tipo_Cliente__c = 'SAC',
                CC_Codigo_Externo__c = 'TEST-ProdServ1',
                CC_Tematica__c = mccTematica1.id);
            Database.insert(mccProdServ1);

            CC_MCC__c mccMotivo1 = new CC_MCC__c(
                RecordTypeId = recTypeMotivo,
                Name = 'Motivo',
                CC_Tipo_Cliente__c = 'SAC',
                CC_Producto_Servicio__c = mccProdServ1.id,
                CC_Codigo_Externo__c = 'TEST-Motivo1');
            Database.insert(mccMotivo1);

            CC_MCC__c mccDetalle1 = new CC_MCC__c(
                RecordTypeId = recTypeDetalle,
                Name = 'Detalle',
                CC_Tipo_Cliente__c = 'SAC',
                CC_Codigo_Externo__c = 'TEST-Detalle1',
                CC_Motivo__c = mccMotivo1.id);
            Database.insert(mccDetalle1);

            CC_MCC__c mccDetalle2 = new CC_MCC__c(
                RecordTypeId = recTypeDetalle,
                Name = 'Detalle 2',
                CC_Tipo_Cliente__c = 'SAC',
                CC_Codigo_Externo__c = 'TEST-Detalle2',
                CC_Motivo__c = mccMotivo1.id);
            Database.insert(mccDetalle2);

            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'Reclamacion');
            camposRecl.put('Description', 'Reclamacion');
            camposRecl.put('Status', 'Cerrado');
            camposRecl.put('CC_MCC_Tematica__c', mccTematica1.id);
            camposRecl.put('CC_MCC_ProdServ__c', mccProdServ1.id);
            camposRecl.put('CC_MCC_Motivo__c', mccMotivo1.id);
            camposRecl.put('SEG_Detalle__c', mccDetalle1.id);

            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            Database.insert(reclamacion);

            list<case> pretensiones = new list<case>();
            //Pretension
            Map<String, Object> camposPretl = new Map<String, Object>();
            camposPretl.put('Subject', 'Pretension 1');
            camposPretl.put('Description', 'Pretension 1');
            camposPretl.put('SAC_Reclamacion__c', reclamacion.id);
            camposPretl.put('CC_MCC_Tematica__c', mccTematica1.id);
            camposPretl.put('CC_MCC_ProdServ__c', mccProdServ1.id);
            camposPretl.put('CC_MCC_Motivo__c', mccMotivo1.id);
            camposPretl.put('SEG_Detalle__c', mccDetalle1.id);
            camposPretl.put('Status', 'Cerrado');
            camposPretl.put('SAC_StatusAuxiliar__c', 'Cerrado');
            Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPretl);
            pretensiones.add(pretension);
            //Database.insert(pretension);

            //Pretension
            Map<String, Object> camposPret2 = new Map<String, Object>();
            camposPret2.put('Subject', 'Pretension 2');
            camposPret2.put('Description', 'Pretension 2');
            camposPret2.put('SAC_Reclamacion__c', reclamacion.id);
            camposPret2.put('CC_MCC_Tematica__c', mccTematica1.id);
            camposPret2.put('CC_MCC_ProdServ__c', mccProdServ1.id);
            camposPret2.put('CC_MCC_Motivo__c', mccMotivo1.id);
            camposPret2.put('SEG_Detalle__c', mccDetalle2.id);
            camposPret2.put('Status', 'Cerrado');
            camposPret2.put('SAC_StatusAuxiliar__c', 'Cerrado');
            Case pretension2 = SAC_TestDataFactory.crearCaso('Pretension',camposPret2);
            pretensiones.add(pretension2);
            //Database.insert(pretension2);
            insert pretensiones;
        }
    }
    @isTest
    public static void testExecuteBatchIA() {
        //User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        User usuarioAdmin = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];

        //List<SAC_Genial_Resultado__c> scope = new List<SAC_Genial_Resultado__c>();

        Case reclamacion = [SELECT Id, Subject FROM Case 
                            WHERE Subject = 'Reclamacion' Limit 1];

        Case pretension = [SELECT Id, Subject  FROM Case 
                            WHERE Subject = 'Pretension 1' Limit 1];

        Case pretension2 = [SELECT Id, Subject  FROM Case 
                            WHERE Subject = 'Pretension 2' Limit 1];

        CC_MCC__c mccTematica1 = [SELECT Id, CC_Codigo_Externo__c 
                                FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'TEST-Tematica1' Limit 1];

        CC_MCC__c mccProdServ1 = [SELECT Id, CC_Codigo_Externo__c 
                                FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'TEST-ProdServ1' Limit 1];

        CC_MCC__c mccMotivo1 = [SELECT Id, CC_Codigo_Externo__c 
                                FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'TEST-Motivo1' Limit 1];

        CC_MCC__c mccDetalle1 = [SELECT Id, CC_Codigo_Externo__c 
                                FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'TEST-Detalle1' Limit 1];
                                
        CC_MCC__c mccDetalle2 = [SELECT Id, CC_Codigo_Externo__c 
                                FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'TEST-Detalle2' Limit 1];

        String recResRT = Schema.SObjectType.SAC_Genial_Resultado__c.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion_IA').getRecordTypeId();
        String pretResRT = Schema.SObjectType.SAC_Genial_Resultado__c.getRecordTypeInfosByDeveloperName().get('SAC_Pretension_IA').getRecordTypeId();
        
        //Resultado genial Reclamacion
        SAC_Genial_Resultado__c genRes;
        genRes = new SAC_Genial_Resultado__c(
            SAC_Reclamacion__c = reclamacion.id,
            recordTypeId = recResRT,
            SAC_Procesado__c = false
        );
        Database.insert(genRes);

        //Resultado genial Pretension
        SAC_Genial_Resultado__c genResPret;
        genResPret = new SAC_Genial_Resultado__c(
            SAC_Reclamacion__c = reclamacion.id,
            SAC_Pretension__c = pretension2.id,
            recordTypeId = pretResRT,
            SAC_MCC_Tematica__c = mccTematica1.id,
            SAC_MCC_ProdServ__c = mccProdServ1.id,
            SAC_MCC_Motivo__c = mccMotivo1.id,
            SAC_Detalle__c = mccDetalle1.id
        );
        Database.insert(genResPret);
 
        //Resultado genial Pretension
        SAC_Genial_Resultado__c genResPret2;
        genResPret2 = new SAC_Genial_Resultado__c(
            SAC_Reclamacion__c = reclamacion.id,
            SAC_Pretension__c = pretension.id,
            recordTypeId = pretResRT,
            SAC_MCC_Tematica__c = mccTematica1.id,
            SAC_MCC_ProdServ__c = mccProdServ1.id,
            SAC_MCC_Motivo__c = mccMotivo1.id,
            SAC_Detalle__c = mccDetalle2.id
        );
        Database.insert(genResPret2);

        System.runAs(usuarioAdmin){
            Test.startTest();
            SAC_GenialResultado_Batch obj = new SAC_GenialResultado_Batch();
            DataBase.executeBatch(obj); 
            Test.stopTest();
        }

        SAC_Genial_Resultado__c pretRes = [SELECT Id, SAC_Pretension__c, SAC_Detalle__c  FROM SAC_Genial_Resultado__c 
                                            WHERE SAC_Detalle__c = :mccDetalle2.id Limit 1];

        System.assertEquals(pretension2.id, pretRes.SAC_Pretension__c, 'Las pretensiones no se asignan correctamente');
    }
    
    @isTest
    public static void testExecuteBatchShadow() {
        //User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        User usuarioAdmin = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];

        //List<SAC_Genial_Resultado__c> scope = new List<SAC_Genial_Resultado__c>();

        Case reclamacion = [SELECT Id, Subject FROM Case 
                            WHERE Subject = 'Reclamacion' Limit 1];

        Case pretension = [SELECT Id, Subject  FROM Case 
                            WHERE Subject = 'Pretension 1' Limit 1];

        CC_MCC__c mccTematica1 = [SELECT Id, CC_Codigo_Externo__c 
                                FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'TEST-Tematica1' Limit 1];

        CC_MCC__c mccProdServ1 = [SELECT Id, CC_Codigo_Externo__c 
                                FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'TEST-ProdServ1' Limit 1];

        CC_MCC__c mccMotivo1 = [SELECT Id, CC_Codigo_Externo__c 
                                FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'TEST-Motivo1' Limit 1];

        CC_MCC__c mccDetalle1 = [SELECT Id, CC_Codigo_Externo__c 
                                FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'TEST-Detalle1' Limit 1];
                                
        CC_MCC__c mccDetalle2 = [SELECT Id, CC_Codigo_Externo__c 
                                FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'TEST-Detalle2' Limit 1];

        String recResRT = Schema.SObjectType.SAC_Genial_Resultado__c.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion_IA').getRecordTypeId();
        String pretResRT = Schema.SObjectType.SAC_Genial_Resultado__c.getRecordTypeInfosByDeveloperName().get('SAC_Pretension_IA').getRecordTypeId();
        
        //Resultado genial Reclamacion
        SAC_Genial_Resultado__c genRes;
        genRes = new SAC_Genial_Resultado__c(
            SAC_Reclamacion__c = reclamacion.id,
            recordTypeId = recResRT,
            SAC_Procesado__c = false
        );
        Database.insert(genRes);

        //Resultado genial Pretension
        SAC_Genial_Resultado__c genResPret;
        genResPret = new SAC_Genial_Resultado__c(
            SAC_Reclamacion__c = reclamacion.id,
            SAC_Pretension__c = null,
            recordTypeId = pretResRT,
            SAC_MCC_Tematica__c = mccTematica1.id,
            SAC_MCC_ProdServ__c = mccProdServ1.id,
            SAC_MCC_Motivo__c = mccMotivo1.id,
            SAC_Detalle__c = mccDetalle1.id
        );
        Database.insert(genResPret);
 
        //Resultado genial Pretension
        SAC_Genial_Resultado__c genResPret2;
        genResPret2 = new SAC_Genial_Resultado__c(
            SAC_Reclamacion__c = reclamacion.id,
            SAC_Pretension__c = null,
            recordTypeId = pretResRT,
            SAC_MCC_Tematica__c = mccTematica1.id,
            SAC_MCC_ProdServ__c = mccProdServ1.id,
            SAC_MCC_Motivo__c = mccMotivo1.id,
            SAC_Detalle__c = mccDetalle2.id
        );
        Database.insert(genResPret2);

        System.runAs(usuarioAdmin){
            Test.startTest();
            SAC_GenialResultado_Batch obj = new SAC_GenialResultado_Batch();
            DataBase.executeBatch(obj); 
            Test.stopTest();
        }

        SAC_Genial_Resultado__c pretRes = [SELECT Id, SAC_Pretension__c, SAC_Detalle__c  FROM SAC_Genial_Resultado__c 
                                            WHERE SAC_Detalle__c = :mccDetalle1.id Limit 1];

        System.assertEquals(pretension.id, pretRes.SAC_Pretension__c, 'Las pretensiones no se asignan correctamente');
    }

    @isTest
    public static void testExecuteBatchReasigna() {
        //User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        User usuarioAdmin = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];

        //List<SAC_Genial_Resultado__c> scope = new List<SAC_Genial_Resultado__c>();

        Case reclamacion = [SELECT Id, Subject FROM Case 
                            WHERE Subject = 'Reclamacion' Limit 1];

        //Case pretension = [SELECT Id, Subject  FROM Case WHERE Subject = 'Pretension 1' Limit 1];
                            
        Case pretension2 = [SELECT Id, Subject  FROM Case 
                            WHERE Subject = 'Pretension 2' Limit 1];

        CC_MCC__c mccTematica1 = [SELECT Id, CC_Codigo_Externo__c 
                                FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'TEST-Tematica1' Limit 1];

        CC_MCC__c mccProdServ1 = [SELECT Id, CC_Codigo_Externo__c 
                                FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'TEST-ProdServ1' Limit 1];

        CC_MCC__c mccMotivo1 = [SELECT Id, CC_Codigo_Externo__c 
                                FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'TEST-Motivo1' Limit 1];

        CC_MCC__c mccDetalle1 = [SELECT Id, CC_Codigo_Externo__c 
                                FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'TEST-Detalle1' Limit 1];
                                
        CC_MCC__c mccDetalle2 = [SELECT Id, CC_Codigo_Externo__c 
                                FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'TEST-Detalle2' Limit 1];

        String recResRT = Schema.SObjectType.SAC_Genial_Resultado__c.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion_IA').getRecordTypeId();
        String pretResRT = Schema.SObjectType.SAC_Genial_Resultado__c.getRecordTypeInfosByDeveloperName().get('SAC_Pretension_IA').getRecordTypeId();
        
        //Resultado genial Reclamacion
        SAC_Genial_Resultado__c genRes;
        genRes = new SAC_Genial_Resultado__c(
            SAC_Reclamacion__c = reclamacion.id,
            recordTypeId = recResRT,
            SAC_Procesado__c = false
        );
        Database.insert(genRes);

        //Resultado genial Pretension
        SAC_Genial_Resultado__c genResPret;
        genResPret = new SAC_Genial_Resultado__c(
            SAC_Reclamacion__c = reclamacion.id,
            SAC_Pretension__c = null,
            recordTypeId = pretResRT,
            SAC_MCC_Tematica__c = mccTematica1.id,
            SAC_MCC_ProdServ__c = mccProdServ1.id,
            SAC_MCC_Motivo__c = mccMotivo1.id,
            SAC_Detalle__c = mccDetalle2.id
        );
        Database.insert(genResPret);
 
        //Resultado genial Pretension
        SAC_Genial_Resultado__c genResPret2;
        genResPret2 = new SAC_Genial_Resultado__c(
            SAC_Reclamacion__c = reclamacion.id,
            SAC_Pretension__c = null,
            recordTypeId = pretResRT,
            SAC_MCC_Tematica__c = mccTematica1.id,
            SAC_MCC_ProdServ__c = mccProdServ1.id,
            SAC_MCC_Motivo__c = mccMotivo1.id,
            SAC_Detalle__c = mccDetalle1.id
        );
        Database.insert(genResPret2);

        System.runAs(usuarioAdmin){
            Test.startTest();
            SAC_GenialResultado_Batch obj = new SAC_GenialResultado_Batch();
            DataBase.executeBatch(obj); 
            Test.stopTest();
        }

        SAC_Genial_Resultado__c pretRes2 = [SELECT Id, SAC_Pretension__c, SAC_Detalle__c  FROM SAC_Genial_Resultado__c 
                                            WHERE SAC_Detalle__c = :mccDetalle2.id Limit 1];

        System.assertEquals(pretension2.id, pretRes2.SAC_Pretension__c, 'Las pretensiones no se asignan correctamente');
    }
}