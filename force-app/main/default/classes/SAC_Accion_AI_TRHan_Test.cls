/*****************************************************************
 * Name: SAC_Accion_AI_TRHan_Test
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Test de SAC_Accion_AI_TRHan
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR                   DATE         Description
 * 1.0            US539784         Jose Carlos Blanco       20/03/23     Creación
*****************************************************************/
@isTest
public with sharing class SAC_Accion_AI_TRHan_Test {
    @TestSetup
    static void makeData(){

        User usuarioGeneral;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            usuarioGeneral.SAC_PerteneceCOPSAJ__c = true;      
            Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Test');
        camposRecl.put('OwnerId', usuarioGeneral.id);
        
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        Database.insert(reclamacion);
    }

    @isTest
    static void insertarTareas(){
        Case reclamacion = [SELECT id, RecordTypeId FROM Case WHERE Subject = 'Test'];
        List<SAC_Accion__c> listaAcciones = new List<SAC_Accion__c>();

        SAC_Accion__c tareaMaestro = SAC_TestDataFactory.crearTareas(1, reclamacion, true)[0];
         
        SAC_Accion__c tareaOtra = SAC_TestDataFactory.crearTareas(1, reclamacion, false)[0];
            
        listaAcciones.add(tareaMaestro);
        listaAcciones.add(tareaOtra);

        List<SAC_Accion__c> tareas = [SELECT id FROM SAC_Accion__c];
        
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];
		System.runAs(usuario){
            test.startTest();
            Database.insert(listaAcciones);
            test.stopTest();
        }
        List<SAC_Accion__c> tareasAI = [SELECT id FROM SAC_Accion__c];
        
        System.assertNotEquals(tareas, tareasAI, 'No se han insertado las tareas.');
    }
}