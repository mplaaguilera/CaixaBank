/*****************************************************************
 * Name: SAC_LCMP_AltaAutomatica
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Clase test para la clase SAC_LCMP_AltaAutomatica
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US354289         CS                   09/10/2023   Creación
*****************************************************************/
@isTest
public with sharing class SAC_LCMP_AltaAutomatica_Test {
    @TestSetup
    static void makeData(){
        User usuarioGeneral;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];  
            SAC_DatabaseDML.insertDML(usuarioGeneral, false);       
            //Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);    
            //Database.insert(permiSetAssi);
        }

        System.runAs(usuarioGeneral) {
            // Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();            
            camposRecl.put('Subject', 'TestRecl');
            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            SAC_DatabaseDML.insertDML(reclamacion, false); 
            //Database.insert(reclamacion);

            //Reclamacion relacionada
            camposRecl.clear();
            camposRecl.put('Subject', 'TestRecl2');
            camposRecl.put('SAC_CasoRelacionado__c', reclamacion.Id);
            camposRecl.put('SAC_FechaRecepcion__c', System.now().addDays(-1));
            camposRecl.put('SAC_M2P__c', true);
            camposRecl.put('SAC_Entidad_Afectada__c', 'SAC_009');
            Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            SAC_DatabaseDML.insertDML(reclamacion2, false);
            //Database.insert(reclamacion2);

            //Pretension
            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('SuppliedCompany', 'TestPret');
            camposPret.put('SAC_Reclamacion__c', reclamacion2.Id);
            camposPret.put('SAC_Entidad_Afectada__c', 'SAC_009');

            Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
            SAC_DatabaseDML.insertDML(casoPretension, false);
            //Database.insert(casoPretension);
        }
    }

    @isTest
    static void recuperarCasosReclamacionTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, RecordTypeId, SAC_Entidad_Afectada__c, SAC_SentidoResolucion__c, Status, SAC_CasoRelacionado__c, SAC_M2P__c, SAC_Reclamacion__c, SAC_Reclamacion__r.SAC_M2P__c FROM Case WHERE Subject = 'TestRecl2' LIMIT 1];
        SAC_LCMP_AltaAutomatica.WrapperAvisos wpAvisos = new SAC_LCMP_AltaAutomatica.WrapperAvisos();

        Test.startTest();
        System.runAs(usuario) {
            wpAvisos = SAC_LCMP_AltaAutomatica.recuperarCasos(reclamacion.Id, reclamacion.RecordTypeId, reclamacion.SAC_Reclamacion__c, reclamacion.SAC_Reclamacion__r.SAC_M2P__c, reclamacion.SAC_M2P__c, reclamacion.SAC_Entidad_Afectada__c, reclamacion.SAC_SentidoResolucion__c, reclamacion.Status, reclamacion.SAC_CasoRelacionado__c);
        }
        Test.stopTest();

        System.assertNotEquals(null, wpAvisos, 'No se ha devuelto ningun aviso');
    }

    @isTest
    static void recuperarCasosPretensionTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case pretension = [SELECT Id, RecordTypeId, SAC_Entidad_Afectada__c, SAC_SentidoResolucion__c, Status, SAC_CasoRelacionado__c, SAC_M2P__c, SAC_Reclamacion__c, SAC_Reclamacion__r.SAC_M2P__c FROM Case WHERE SuppliedCompany = 'TestPret' LIMIT 1];
        SAC_LCMP_AltaAutomatica.WrapperAvisos wpAvisos = new SAC_LCMP_AltaAutomatica.WrapperAvisos();

        Test.startTest();
        System.runAs(usuario) {
            wpAvisos = SAC_LCMP_AltaAutomatica.recuperarCasos(pretension.Id, pretension.RecordTypeId, pretension.SAC_Reclamacion__c, pretension.SAC_Reclamacion__r.SAC_M2P__c, pretension.SAC_M2P__c, pretension.SAC_Entidad_Afectada__c, pretension.SAC_SentidoResolucion__c, pretension.Status, pretension.SAC_CasoRelacionado__c);
        }
        Test.stopTest();

        System.assertNotEquals(null, wpAvisos, 'No se ha devuelto ningun aviso');
    }
}