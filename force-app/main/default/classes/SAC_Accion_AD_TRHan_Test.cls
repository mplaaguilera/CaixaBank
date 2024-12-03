/*****************************************************************
 * Name: SAC_Accion_AD_TRHan_Test
 * Copyright © 2022  CaixaBank
 * 
 * Proposito: test de SAC_Accion_AD_TRHan
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US356803         alex perez           21/10/22     Creación
 * 1.1            US563153         Jose Carlos Blanco   14/02/23     Modificación (test modificada usando el SAC_TestDataFactory)
*****************************************************************/
@istest
public with sharing class SAC_Accion_AD_TRHan_Test {
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

        //Usuario SAC Admin
		User usuarioAdmin = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        usuarioAdmin.Username = 'usertestadmin@test.com.testSetup';      
        Database.insert(usuarioAdmin);

        PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
        permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
        permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
        Database.insert(permiSetAssiAdmin);

        System.runAs(usuarioAdmin){
            //Grupo Colaborador
            List<CC_Grupo_Colaborador__c> grupoColab = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1);
            Database.insert(grupoColab);

            //Maestro Acciones
            List<SAC_MaestroAccionesReclamacion__c> maestroAcciones = SAC_TestDataFactory.crearMaestroAcciones(1,grupoColab[0].id);
            Database.insert(maestroAcciones);
        }
        
        System.runAs(usuarioGeneral){
            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRec');
            camposRecl.put('SAC_Importe_Resuelto__c', 400.0);
            camposRecl.put('CC_Importe_Abonado__c', 400.0);

            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            Database.insert(reclamacion);

            //Pretension
            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('SuppliedCompany', 'TestPret');
            camposPret.put('SAC_Reclamacion__c', reclamacion.Id);
            camposPret.put('SAC_Importe_Resuelto__c', 400.0);
            camposPret.put('CC_Importe_Abonado__c', 400.0);

            Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
            Database.insert(casoPretension);  

            List<SAC_Accion__c> tareas = SAC_TestDataFactory.crearTareas(2,casoPretension,false);
            tareas[0].SAC_ImporteResuelto__c = 100.0;
            tareas[0].SAC_ImpResueltoInteresesLegales__c = 100.0;
            tareas[0].SAC_ImporteAbonar__c = 200.0;
            tareas[1].SAC_ImporteResuelto__c = 100.0;
            tareas[1].SAC_ImpResueltoInteresesLegales__c = 100.0;
            tareas[1].SAC_ImporteAbonar__c = 200.0;
            Database.insert(tareas);
        }
    }
    @istest
    static void restarImportes(){
        list<SAC_Accion__c> tareas = [SELECT Id, SAC_ImporteResuelto__c, SAC_ImpResueltoInteresesLegales__c, 
                                     SAC_ImporteAbonar__c, SAC_Pretension__c, SAC_Reclamacion__c FROM SAC_Accion__c];

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            test.startTest();
            Database.delete(tareas);
            test.stopTest();
        }
        Case reclUpd = [SELECT Id, SAC_Importe_Resuelto__c, CC_Importe_Abonado__c FROM Case Where Id =: tareas[0].SAC_Pretension__c]; 

        system.assert(reclUpd.SAC_Importe_Resuelto__c == 0.0 && reclUpd.CC_Importe_Abonado__c == 0.0, 'los importes calculados no son los esperados ' + reclUpd);
    }
}