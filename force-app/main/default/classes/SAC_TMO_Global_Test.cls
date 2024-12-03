/*****************************************************************
 * Name: SAC_TMO_Global_Test 
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_TMOGlobal
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US449416         Marcela Neira        28/09/22     Creación
 * 1.1              ---            Jose Carlos Blanco   07/09/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@istest
public with sharing class SAC_TMO_Global_Test {
    
    @TestSetup
    static void makeData(){

        User usuarioGeneral;
        //System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC Admin
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];  
            Database.insert(usuarioGeneral);

            //PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            //PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            //permiSetAssi.AssigneeId = usuarioGeneral.Id;
            //permiSetAssi.PermissionSetId = permiSet.Id;
            //Database.insert(permiSetAssi);   
        //}

        List<Case> listaCasos = new List<Case>();
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Reclamacion');
        camposRecl.put('OwnerId', usuarioGeneral.Id);

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        //Reclamacion subsanacion
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'R Subsanacion');
        camposRecl2.put('Status', 'SAC_006');
        camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_006');
        camposRecl2.put('OwnerId', usuarioGeneral.Id);

        Case reclamacionSubsanacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
        
        listaCasos.add(reclamacion);
        listaCasos.add(reclamacionSubsanacion);
        Database.insert(listaCasos);

        //Pretension subsanacion
        camposRecl2.clear();
        camposRecl2.put('SAC_Reclamacion__c', reclamacionSubsanacion.Id);
        camposRecl2.put('SuppliedCompany', 'pret1');
        camposRecl2.put('Status', 'SAC_006');
        camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_006');
        camposRecl2.put('OwnerId', usuarioGeneral.Id);

        Case pretensionSubsanacion = SAC_TestDataFactory.crearCaso('Pretension',camposRecl2);
        Database.insert(pretensionSubsanacion);
    }

    @IsTest
    static void modificarFechaInicial_Test(){
        
        Case reclamacion = [SELECT Id FROM Case WHERE Subject= 'Reclamacion'];
        reclamacion.SAC_FechaRecepcion__c = DateTime.newInstance(2022, 6, 6, 3, 3, 3);

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            Database.update(reclamacion);
            Test.stopTest();
        }

        List<SAC_TiempoEstados__c> listaTpes = [SELECT Id FROM SAC_TiempoEstados__c WHERE SAC_TMECaso__r.SAC_Caso__c =: reclamacion.Id];
        
        System.assertNotEquals(null, listaTpes, 'Modificar la fecha inicial del TMO global ha fallado');
    }

    @IsTest
    static void modificarFechaFinal_Test(){
        
        Case reclamacion = [SELECT Id FROM Case WHERE Subject= 'Reclamacion'];
        reclamacion.OS_Fecha_Resolucion__c = DateTime.newInstance(2022, 6, 6, 3, 3, 3);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            Database.update(reclamacion);
            Test.stopTest();
        }
        
        List<SAC_TiempoEstados__c> listaTpes = [SELECT Id FROM SAC_TiempoEstados__c WHERE SAC_TMECaso__r.SAC_Caso__c =: reclamacion.Id];
        
        System.assertNotEquals(null, listaTpes, 'Modificar la fecha final del TMO global ha fallado');
    }
    
    @IsTest
    static void crearNuevoTPE_Test(){
        
        Case reclamacion = [SELECT Id FROM Case WHERE Subject= 'R Subsanacion'];
        reclamacion.Status = 'SAC_001';
        reclamacion.SAC_StatusAuxiliar__c = 'SAC_001';
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            Database.update(reclamacion);
            Test.stopTest();
        }

        List<SAC_TiempoEstados__c> listaTpes = [SELECT Id FROM SAC_TiempoEstados__c WHERE SAC_TMECaso__r.SAC_Caso__c =: reclamacion.Id];
        
        System.assertNotEquals(null, listaTpes, 'Crear el nuevo TMO global ha fallado');
        
    }

     @IsTest
    static void tmoGlobal_Test(){
        
        Case reclamacion = [SELECT Id FROM Case WHERE Subject= 'R Subsanacion'];
        reclamacion.Status = 'SAC_001';
        reclamacion.SAC_StatusAuxiliar__c = 'SAC_001';
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            Database.update(reclamacion);
            Test.stopTest();
        }

        List<SAC_TiempoEstados__c> listaTpes = [SELECT Id FROM SAC_TiempoEstados__c WHERE SAC_TMECaso__r.SAC_Caso__c =: reclamacion.Id];
        
        System.assertNotEquals(null, listaTpes, 'TMO global ha fallado');
        
    }
    @isTest
    static void filtrarListaSelect_Test(){
        List<Case> listaCasos = [SELECT id, Subject FROM Case];
        Set<Id> ideBusqueda = new Set<Id>();

        for (Case caso : listaCasos) {
            ideBusqueda.add(caso.Id);
        }

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            List<Case> listaCasos2 = SAC_TMOGlobal.filtrarListaSelect(ideBusqueda, listaCasos);
            System.assertEquals(listaCasos2, listaCasos, 'Las listas no son iguales');
            Test.stopTest();
        }
    }

    @isTest
    static void insertarTPEVueltaSubsanacionTest(){
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany= 'pret1'];
        pretension.Status = 'SAC_001';
        pretension.SAC_StatusAuxiliar__c = 'SAC_001';
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            Database.update(pretension);
            Test.stopTest();
        }

        List<SAC_TiempoEstados__c> listaTpes = [SELECT Id FROM SAC_TiempoEstados__c WHERE SAC_TMECaso__r.SAC_Caso__c =: pretension.Id];
        
        System.assertNotEquals(null, listaTpes, 'Crear el nuevo TMO global ha fallado');
    }
}