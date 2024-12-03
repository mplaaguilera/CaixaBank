/*****************************************************************
 * Name: SAC_LCMP_EnvioReclamante_Test
 * Copyright © 2019  CaixaBank
 * 
 * Proposito: Clase test para SAC_LCMP_EnvioReclamante
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US204755         Carlos Solis         02/06/21     Creación
 * 1.1            US563153         Jose Carlos Blanco   24/04/23     Modificación (test modificada usando el SAC_TestDataFactory)
*****************************************************************/
@isTest
public with sharing class SAC_LCMP_EnvioReclamante_Test {
    @TestSetup
    static void makeData(){
        //Usuarios
        List<User> usuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(2);      
        Database.insert(usuarios);

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TarjetaReclamacion');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl.put('OwnerId', usuarios[0].id);

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        Database.insert(reclamacion);

        //Pretension 1
        Map<String, Object> camposPret1 = new Map<String, Object>();
        camposPret1.put('SuppliedCompany', 'prueba1');
        camposPret1.put('Status', 'SAC_001');
        camposPret1.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposPret1.put('OwnerId', usuarios[0].id);
        camposPret1.put('SAC_Reclamacion__c', reclamacion.Id);

        Case pretension1 = SAC_TestDataFactory.crearCaso('Pretension',camposPret1);
        Database.insert(pretension1);  

        //Pretension 2
        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('SuppliedCompany', 'prueba2');
        camposPret2.put('Status', 'SAC_001');
        camposPret2.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposPret2.put('OwnerId', usuarios[0].id);
        camposPret2.put('SAC_Reclamacion__c', reclamacion.Id);

        Case pretension2 = SAC_TestDataFactory.crearCaso('Pretension',camposPret2);
        Database.insert(pretension2);  

        //Accion
        SAC_Accion__c tarea = SAC_TestDataFactory.crearTareas(1,reclamacion,true)[0];
        tarea.OwnerId = usuarios[0].id;   
        tarea.SAC_Comentarios__c='Llamar';
        tarea.SAC_Pretension__c = pretension1.Id;
        System.runAs(usuarios[0]){
            Database.insert(tarea);
        }        
    }

    @isTest
    static void envioReclamanteTest() {
        User usuario = [SELECT id FROM User WHERE alias = 'alias0' Limit 1];
        Case caso = [SELECT id, subject, status, ownerId FROM Case WHERE subject = 'TarjetaReclamacion'];
        List<SAC_Accion__c> listaTareas = new List<SAC_Accion__c>();
        Case pretension1 = [SELECT id, subject, status, ownerId FROM Case WHERE SuppliedCompany = 'prueba1'];


        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {
            listaTareas = SAC_LCMP_EnvioReclamante.envioReclamante(caso.Id);
        }
        Test.stopTest();

        system.assertEquals(false, listaTareas.isEmpty(), 'No se han podido comprobar las tareas');
    }

    @isTest
    static void cerrarCasos() {
        User usuario = [SELECT id FROM User WHERE alias = 'alias1' Limit 1];
        Case caso = [SELECT id, subject, status FROM Case WHERE subject = 'TarjetaReclamacion'];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {
            SAC_LCMP_EnvioReclamante.cerrarCasos(caso.Id);
        }
        Test.stopTest();

        Case reclamacionCerrada = [SELECT id, subject, status FROM Case WHERE subject = 'TarjetaReclamacion'];
        Case pretensionCerrada1 = [SELECT id, subject, status FROM Case WHERE SuppliedCompany = 'prueba1'];
        Case pretensionCerrada2 = [SELECT id, subject, status FROM Case WHERE SuppliedCompany = 'prueba2'];

        system.assertEquals('Cerrado', reclamacionCerrada.Status, 'No se han podido cerrar los casos');
        system.assertEquals('Cerrado', pretensionCerrada1.Status, 'No se han podido cerrar los casos');
        system.assertEquals('Cerrado', pretensionCerrada2.Status, 'No se han podido cerrar los casos');
    }

    @isTest
    static void reclamacionEjecucion() {
        User usuario = [SELECT id FROM User WHERE alias = 'alias0' Limit 1];
        Case caso = [SELECT id, subject, status FROM Case WHERE subject = 'TarjetaReclamacion'];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {
            SAC_LCMP_EnvioReclamante.reclamacionEjecucion(caso.Id);
        }
        Test.stopTest();

        Case reclamacionEjecucion = [SELECT id, subject, status FROM Case WHERE subject = 'TarjetaReclamacion'];
        Case pretensionCerrada1 = [SELECT id, subject, status FROM Case WHERE SuppliedCompany = 'prueba1'];
        Case pretensionCerrada2 = [SELECT id, subject, status FROM Case WHERE SuppliedCompany = 'prueba2'];

        system.assertEquals('SAC_004', reclamacionEjecucion.Status, 'No se han podido cerrar los casos');
        system.assertEquals('Cerrado', pretensionCerrada1.Status, 'No se han podido cerrar los casos');
        system.assertEquals('Cerrado', pretensionCerrada2.Status, 'No se han podido cerrar los casos');
    }
}