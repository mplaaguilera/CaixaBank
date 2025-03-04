/*****************************************************************
 * Name: SAC_LCMP_DesmarcarNotificacion_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_LCMP_DesmarcarNotificacion
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US219258         Marcela Neira        15/06/21     Creación Clase
 * 1.1            US563153         Jose Carlos Blanco  	26/04/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@istest
public with sharing class SAC_LCMP_DesmarcarNotificacion_Test {
    @TestSetup
    static void makeData(){

        //Usuario SAC General
		User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];  
        SAC_DatabaseDML.insertDML(usuarioGeneral, false);    
        //Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);    
        //Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral){
            //Reclamacion 1
            Map<String, Object> camposRecl1 = new Map<String, Object>();
            camposRecl1.put('Subject', 'Un nuevo caso');
            camposRecl1.put('OwnerId', usuarioGeneral.id);
            camposRecl1.put('SAC_NotificacionSinLeer__c', true);

            Case reclamacion1 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl1);
            SAC_DatabaseDML.insertDML(reclamacion1, false); 
            //Database.insert(reclamacion1);

            //Reclamacion 2
            Map<String, Object> camposRecl2 = new Map<String, Object>();
            camposRecl2.put('Subject', 'Caso Dos');
            camposRecl2.put('OwnerId', usuarioGeneral.id);
            camposRecl2.put('SAC_NotificacionSinLeer__c', false);

            Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
            SAC_DatabaseDML.insertDML(reclamacion2, false); 
            //Database.insert(reclamacion2);
        }
   
    }
    @istest
    static void desmarcarNotificacionTest(){
        User usuarioGeneral = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'Un nuevo caso' LIMIT 1];
        Boolean seActualizoNotificacionSinLeer = false;

        System.runAs(usuarioGeneral){
            Test.startTest();
            seActualizoNotificacionSinLeer = SAC_LCMP_DesmarcarNotificacion.desmarcarNotificacion(usuarioGeneral.id, caso.id);   
            Test.stopTest();          
        }

        boolean notificacionSinLeer = [SELECT id, SAC_NotificacionSinLeer__C FROM Case LIMIT 1].SAC_NotificacionSinLeer__C;

        system.assertEquals(false, notificacionSinLeer, 'Se tendria que modificar el campo Notificación sin Leer');
    }
    @istest
    static void desmarcarNotificacionTestNegativo(){
        User usuarioGeneral = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case caso = [SELECT id, SAC_NotificacionSinLeer__c FROM Case WHERE Subject = 'Caso Dos' LIMIT 1];
        Boolean seActualizoNotificacionSinLeer = false;

        System.runAs(usuarioGeneral){
            Test.startTest();
            seActualizoNotificacionSinLeer = SAC_LCMP_DesmarcarNotificacion.desmarcarNotificacion(usuarioGeneral.id, caso.id);                          
            Test.stopTest();          
        }

        system.assertEquals(false, seActualizoNotificacionSinLeer, 'No se debe actualizar el campo Notificación sin leer');
    }
}