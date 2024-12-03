/*****************************************************************
 * Name: SAC_LCMP_Alertas_Test
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Testear la clase SAC_LCMP_Alertas
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US687443         Jose Carlos Blanco   08/08/2023   Creación 
*****************************************************************/
@isTest
public with sharing class SAC_LCMP_Alertas_Test {
    @TestSetup
    static void makeData(){
        User usuarioGeneral;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];     
            Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }

        System.runAs(usuarioGeneral) {
            // Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRecl');
            
            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            Database.insert(reclamacion);

            // Alerta
            List<SAC_Alerta__c> listaAlertas = SAC_TestDataFactory.crearAlerta(1, reclamacion.Id);
            Database.insert(listaAlertas);
        }
    }

    @isTest
    static void getAlertasByCaseIdTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRecl' LIMIT 1];
        List<SAC_Alerta__c> listaAlertas;

        System.runAs(usuario) {
            listaAlertas = SAC_LCMP_Alertas.getAlertasByCaseId(reclamacion.Id);
        }
        System.assertEquals(!listaAlertas.isEmpty(), true, 'No se han recuperado las alertas.');
    }
}