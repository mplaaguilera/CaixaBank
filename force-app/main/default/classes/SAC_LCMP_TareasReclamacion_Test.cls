/*****************************************************************
 * Name: SAC_LCMP_TareasReclamacion
 * Copyright © 2025  CaixaBank
 * 
 * Propósito: Clase test del componente SAC_LCMP_TareasReclamacion
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            --              Iria ANPC     08/01/25        Creación
*****************************************************************/
@isTest
public class SAC_LCMP_TareasReclamacion_Test {
    @TestSetup
    static void makeData(){
        List<User> usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(2);
        usuarioGeneral[0].Username = 'ustestesteo@test.com';   
        usuarioGeneral[1].Username = 'ustestesteoDOS@test.com';   
        SAC_DatabaseDML.insertListDML(usuarioGeneral, false); 
    
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral[0].Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false); 

        PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        permiSetAssi2.AssigneeId = usuarioGeneral[1].Id;
        permiSetAssi2.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi2, false);

        System.runAs(usuarioGeneral[0]){
            Test.startTest();

            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestTarea');
            camposRecl.put('Origin', 'Backoffice');
            camposRecl.put('Status', 'Alta');
            camposRecl.put('SAC_StatusAuxiliar__c', 'Alta');
            camposRecl.put('OwnerId', usuarioGeneral[0].Id);
            Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            SAC_DatabaseDML.insertDML(casoReclamacion, false);

            //Pretension
            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('Subject', 'TestTarea2');
            camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
            camposPret.put('Status', 'Alta');
            camposPret.put('SAC_StatusAuxiliar__c', 'Alta');
            camposPret.put('OwnerId', usuarioGeneral[0].Id);
            Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
            SAC_DatabaseDML.insertDML(casoPretension, false);

            //grupo colaborador
            List<CC_Grupo_Colaborador__c> listaGrupos = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1);
            listaGrupos[0].Name = 'grupo de tareas';
            SAC_DatabaseDML.insertListDML(listaGrupos, false);

            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact2 = SAC_TestDataFactory.crearColaboradorContact(usuarioGeneral[1].Id,listaGrupos[0].id);
            SAC_DatabaseDML.insertDML(grupoColaboradorContact2, false);

            List<SAC_MaestroAccionesReclamacion__c> maestroTareas = SAC_TestDataFactory.crearMaestroAcciones(1, listaGrupos[0].Id);
            maestroTareas[0].Name = 'maestro tarea';
            maestroTareas[0].SAC_Descripcion__c = 'test maestro';
            maestroTareas[0].SAC_PlazoMaximo__c = 8;
            SAC_DatabaseDML.insertListDML(maestroTareas, false);

            List<SAC_Accion__c> listaTareas = SAC_TestDataFactory.crearTareas(1, casoReclamacion, true);
            listaTareas[0].SAC_EquipoResponsable__c = listaGrupos[0].Id;
            SAC_DatabaseDML.insertListDML(listaTareas, false);

            Test.stopTest();
        }
    }
    @isTest static void createTarea(){
        Case caso = [SELECT Id,Subject FROM Case WHERE subject = 'TestTarea' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND IsActive = true Limit 1];
       	List<SAC_Accion__c> tareas = new List<SAC_Accion__c>();
        System.runAs(usuario){   
            Test.startTest();
            SAC_LCMP_TareasReclamacion.getRelatedTareas(caso.Id);
            tareas = [SELECT Id FROM SAC_Accion__c WHERE SAC_Reclamacion__r.Subject = 'TestTarea' LIMIT 1];
            Test.stopTest();
        }
        System.assertEquals(tareas.isEmpty(), false, 'La tarea existe');
    }
}