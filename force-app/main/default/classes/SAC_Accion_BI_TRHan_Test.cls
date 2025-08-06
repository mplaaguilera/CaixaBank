/*****************************************************************
 * Name: SAC_Accion_BI_TRHan_Test
 * Copyright © 2019  CaixaBank
 * 
 * Proposito: Testear la clase SAC_Accion_BI_TRHan
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            		         Daniel Benito          03/11/21     Creación
 * 1.1			  US507573		 Jose Carlos Blanco	    18/01/23	 Modificación (agregada assertion y QualityCloud)
 * 1.2            US563153       Jose Carlos Blanco     20/02/23     Modificación (test modificada usando el SAC_TestDataFactory)
*****************************************************************/
@isTest
public with sharing class SAC_Accion_BI_TRHan_Test {
    @TestSetup
    static void makeData(){

        //Usuario SAC General
		User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral){
            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRec');

            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            Database.insert(reclamacion);

            //Pretension
            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('SAC_Reclamacion__c', reclamacion.Id);
            
            Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
            Database.insert(pretension);  

            //Tareas
            SAC_Accion__c tarea1 = SAC_TestDataFactory.crearTareas(1,pretension,true)[0];
            SAC_Accion__c tarea2 = SAC_TestDataFactory.crearTareas(1,pretension,false)[0];
            Database.insert(tarea1);
            Database.insert(tarea2);
        }   
    }
    @isTest
    static void insertarAcciones() {
        List<SAC_Accion__c> acciones = [SELECT id,SAC_Pretension__c, SAC_Estado__c FROM SAC_Accion__c];

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		System.runAs(usuario){
            Test.startTest();
            SAC_Accion_BI_TRHan.insertarAccionesReclamacion(acciones);
            Test.stopTest();
        }
        System.assertEquals('SAC_PendienteEnviar', acciones[0].SAC_Estado__c, 'No se ha insertado la acción.');
        System.assertEquals('SAC_PendienteEnviar', acciones[1].SAC_Estado__c, 'No se ha insertado la acción.');
    }  
}