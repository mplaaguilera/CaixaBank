/*****************************************************************
 * Name: SAC_Accion_RellenarImporte_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_Accion_RellenarImporte
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US277162         Daniel Benito        19/10/21     Creación
 * 1.1			  US507573		   Jose Carlos Blanco	17/01/23	 Modificación (agregada assertion)
 * 1.2            US563153         Jose Carlos Blanco   20/02/23     Modificación (test modificada usando el SAC_TestDataFactory)
*****************************************************************/

@isTest
public with sharing class SAC_Accion_RellenarImporte_Test {
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
            camposPret.put('CC_Importe_Abonado__c', 12.00);

            Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
            Database.insert(pretension);  

            //Tarea
            List<SAC_Accion__c> acciones = SAC_TestDataFactory.crearTareas(1,pretension,false);
            Database.insert(acciones);
        }
    }
    @istest
    static void insertarTarea(){
        List<SAC_Accion__c> acciones = [SELECT id,SAC_Pretension__c,SAC_ImporteAbonar__c from SAC_Accion__c];
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		System.runAs(usuario){
            test.startTest();
            SAC_Accion_RellenarImporte.rellenarImporteAbono(acciones);
            test.stopTest();
        }
        System.assertEquals(12.00, acciones[0].SAC_ImporteAbonar__c, 'No se ha modificado el importe.');
    }
}