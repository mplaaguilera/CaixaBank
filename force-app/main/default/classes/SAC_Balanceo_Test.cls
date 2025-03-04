/*****************************************************************
 * Name: SAC_Balanceo_Test
 * Copyright © 2019  CaixaBank
 * 
 * Proposito: Testear la clase SAC_Balanceo
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US213183         Carlos Solis         10/05/21     Creación
 * 1.1            US563153         Jose Carlos Blanco   24/02/23     Modificación (test modificada usando el SAC_TestDataFactory)
*****************************************************************/
@isTest
public with sharing class SAC_Balanceo_Test {
    @TestSetup
    static void makeData(){

        //Usuario SAC Admin
		User usuarioAdmin = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        usuarioAdmin.Username = 'usertestadmin@test.com.testSetup';
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);        
        //Database.insert(usuarioAdmin);

        PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
        permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
        permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
        SAC_DatabaseDML.insertDML(permiSetAssiAdmin, false); 
        //Database.insert(permiSetAssiAdmin);

        //Creamos grupos
        System.runAs(usuarioAdmin){
            List<CC_Grupo_Colaborador__c> grupos = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor',2);
            grupos[0].SAC_PorcentajeAsignacion__c = 80;
            grupos[0].SAC_MaximoCasosDiarios__c = 1;
            grupos[1].SAC_PorcentajeAsignacion__c = 20;
            grupos[1].SAC_MaximoCasosDiarios__c = 1;
            SAC_DatabaseDML.insertListDML(grupos, false); 
            //Database.insert(grupos);
        }

        //Recuperamos grupos
        CC_Grupo_Colaborador__c grupo1 = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Proveedor 0'];
        // CC_Grupo_Colaborador__c grupo2 = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Proveedor 1'];

        //Usuario SAC General
		User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0]; 
        usuarioGeneral.SAC_GruposPerteneciente__c = grupo1.id;
        SAC_DatabaseDML.insertDML(usuarioGeneral, false);     
        //Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false); 
        //Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral){
            Test.startTest();
            //Cuentas
            List<Account> cuentas = SAC_TestDataFactory.crearCuentasNoClientePA(2);
            cuentas[0].OwnerId = usuarioGeneral.id;
            cuentas[1].OwnerId = usuarioGeneral.id;
            SAC_DatabaseDML.insertListDML(cuentas, false); 
            //Database.insert(cuentas);

            //Reclamacion 1
            Map<String, Object> camposRecl1 = new Map<String, Object>();
            camposRecl1.put('Subject', 'TestRec1');
            camposRecl1.put('Status', 'SAC_001');
            camposRecl1.put('SAC_StatusAuxiliar__c', 'SAC_001');
            //camposRecl1.put('SEG_Grupo__c', grupo1.id);
            camposRecl1.put('AccountId', cuentas[0].id);
            camposRecl1.put('OwnerId', usuarioGeneral.id);

            Case reclamacion1 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl1);
            SAC_DatabaseDML.insertDML(reclamacion1, false); 
            //Database.insert(reclamacion1);

            //Reclamacion 2
            Map<String, Object> camposRecl2 = new Map<String, Object>();
            camposRecl2.put('Subject', 'TestRec2');
            //camposRecl2.put('SEG_Grupo__c', grupo2.id);

            Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
            SAC_DatabaseDML.insertDML(reclamacion2, false); 
            //Database.insert(reclamacion2);

            //Reclamacion 3
            Map<String, Object> camposRecl3 = new Map<String, Object>();
            camposRecl3.put('Subject', 'TestRec3');
            //camposRecl3.put('SEG_Grupo__c', grupo2.id);
            camposRecl3.put('AccountId', cuentas[1].id);

            Case reclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl3);
            SAC_DatabaseDML.insertDML(reclamacion3, false);
            //Database.insert(reclamacion3);

            //Reclamacion 4
            Map<String, Object> camposRecl4 = new Map<String, Object>();
            camposRecl4.put('Subject', 'TestRec4');
            //camposRecl4.put('SEG_Grupo__c', grupo2.id);
            camposRecl4.put('AccountId', cuentas[0].id);
            camposRecl4.put('OwnerId', usuarioGeneral.id);

            Case reclamacion4 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl4);
            SAC_DatabaseDML.insertDML(reclamacion4, false);
            //Database.insert(reclamacion4);
    
            Test.stopTest();
        }

    }
    @isTest
    static void balanceoGruposTest () {
        // Account cuenta = [select id from account limit 1];
        // List<Case> listacasos = [select id, Subject, Origin, Status, SEG_Grupo__c, AccountId, OwnerId, RecordTypeId from case];

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		System.runAs(usuario){
            Test.startTest();
            Case caso3 = new Case();
            caso3.Subject = 'Tec';
            caso3.Origin = 'Backoffice';
            caso3.Status = 'SAC_001';
            caso3.SAC_StatusAuxiliar__c = caso3.Status;
            //caso3.AccountId = cuenta.Id;
            caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
            SAC_DatabaseDML.insertDML(caso3, false);
            //Database.insert(caso3);

            Case caso4 = new Case();
            caso4.Subject = 'Tec';
            caso4.Origin = 'Backoffice';
            caso4.Status = 'SAC_001';
            caso4.SAC_StatusAuxiliar__c = caso4.Status;
            //caso4.AccountId = cuenta.Id;
            caso4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
            SAC_DatabaseDML.insertDML(caso4, false);
            //Database.insert(caso4);
            Test.stopTest();
        }
        Case caso = [select id, Subject, SEG_Grupo__c from Case where subject = 'Tec' limit 1];
        system.assertEquals(String.isBlank(caso.SEG_Grupo__c), false, 'No se ha podido efectuar el balanceo');
    }

    @isTest
    static void comprobarReclamantePrincipalBeforeUpdateTest () {
        Account cuenta = [select id from account limit 1];
        List<Case> listacasos = [select id, Subject, Origin, Status, SEG_Grupo__c, AccountId, OwnerId, RecordTypeId from case];
        
        listacasos[1].AccountId = cuenta.Id;

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateListDML(listacasos, false);
            //Database.update(listacasos);
            Test.stopTest();
        }
        system.assertEquals(listacasos.isEmpty(), false, 'No se ha podido efectuar el balanceo');
    }
}