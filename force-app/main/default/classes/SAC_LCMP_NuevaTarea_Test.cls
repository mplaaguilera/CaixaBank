/*****************************************************************
 * Name: SAC_LCMP_NuevaTarea_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_LCMP_NuevaTarea.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US518126         Raúl Santos    08/02/2023    Creación 
 * 1.1            US577617         Raúl Santos    25/06/2023    Modicación:  framework y cubrir nuevos métodos
*****************************************************************/

@isTest
public with sharing class SAC_LCMP_NuevaTarea_Test {
    @TestSetup
    static void makeData(){

        List<User> usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(2);
        usuarioGeneral[0].Username = 'ustestesteo@test.com';   
        usuarioGeneral[1].Username = 'ustestesteoDOS@test.com';   
        SAC_DatabaseDML.insertListDML(usuarioGeneral, false); 
        //Database.insert(usuarioGeneral);
    
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral[0].Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false); 
        //Database.insert(permiSetAssi);

        PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        permiSetAssi2.AssigneeId = usuarioGeneral[1].Id;
        permiSetAssi2.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi2, false);
        //Database.insert(permiSetAssi2);

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
            //Database.insert(casoReclamacion);

            //Pretension
            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('Subject', 'TestTarea2');
            camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
            camposPret.put('Status', 'Alta');
            camposPret.put('SAC_StatusAuxiliar__c', 'Alta');
            camposPret.put('OwnerId', usuarioGeneral[0].Id);
            Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
            SAC_DatabaseDML.insertDML(casoPretension, false);
            //Database.insert(casoPretension);  

            //grupo colaborador
            List<CC_Grupo_Colaborador__c> listaGrupos = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1);
            listaGrupos[0].Name = 'grupo de tareas';
            SAC_DatabaseDML.insertListDML(listaGrupos, false);
            //Database.insert(listaGrupos);

            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact2 = SAC_TestDataFactory.crearColaboradorContact(usuarioGeneral[1].Id,listaGrupos[0].id);
            SAC_DatabaseDML.insertDML(grupoColaboradorContact2, false);
            //Database.insert(grupoColaboradorContact2);

            List<SAC_MaestroAccionesReclamacion__c> maestroTareas = SAC_TestDataFactory.crearMaestroAcciones(1, listaGrupos[0].Id);
            maestroTareas[0].Name = 'maestro tarea';
            maestroTareas[0].SAC_Descripcion__c = 'test maestro';
            maestroTareas[0].SAC_PlazoMaximo__c = 8;
            SAC_DatabaseDML.insertListDML(maestroTareas, false);
            //Database.insert(maestroTareas);

            List<SAC_Accion__c> listaTareas = SAC_TestDataFactory.crearTareas(1, casoReclamacion, true);
            listaTareas[0].SAC_EquipoResponsable__c = listaGrupos[0].Id;
            SAC_DatabaseDML.insertListDML(listaTareas, false);
            //Database.insert(listaTareas);

            Test.stopTest();
        }

    }

    @isTest
    static void insertarTareaTest() {

        Case caso = [SELECT Id,Subject FROM Case WHERE subject = 'TestTarea' LIMIT 1];
        CC_Grupo_Colaborador__c grupoTarea = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE name = 'grupo de tareas' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND IsActive = true Limit 1];
        
        String idRec = caso.Id; 
        String descripcion = 'test';
        String equipoResponsableId = grupoTarea.Id;
        Boolean esMaestroOrOtras = true;
        Case tareaInsertada;

        System.RunAs(usuario){   
            Test.startTest();
            SAC_LCMP_NuevaTarea.insertarTarea(idRec, descripcion, equipoResponsableId, esMaestroOrOtras);
            tareaInsertada = [SELECT Id,Subject FROM Case WHERE subject = 'TestTarea' LIMIT 1];
            Test.stopTest();
        }

        system.assertEquals(idRec, tareaInsertada.id, 'La ejecucion ha fallado a la hora de insertar la tarea');
    }

    @isTest
    static void insertarTareaTest2() {

        Case caso = [SELECT Id,Subject FROM Case WHERE subject = 'TestTarea' LIMIT 1];
        SAC_MaestroAccionesReclamacion__c maestroTarea = [SELECT Id FROM SAC_MaestroAccionesReclamacion__c WHERE Name = 'maestro tarea' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND IsActive = true Limit 1];
        
        String idRec = caso.Id; 
        String descripcion = '';
        String equipoResponsableId = maestroTarea.Id;
        Boolean esMaestroOrOtras = false;
        Case tareaInsertada;

        System.RunAs(usuario){   
            Test.startTest();
            SAC_LCMP_NuevaTarea.insertarTarea(idRec, descripcion, equipoResponsableId, esMaestroOrOtras);
            tareaInsertada = [SELECT Id,Subject FROM Case WHERE subject = 'TestTarea' LIMIT 1];
            Test.stopTest();
        }

        system.assertEquals(idRec, tareaInsertada.id, 'La ejecucion ha fallado a la hora de insertar la tarea');
    }

    @isTest
    static void insertarTareaTest3() {

        Case caso = [SELECT Id,Subject FROM Case WHERE subject = 'TestTarea2' LIMIT 1];
        CC_Grupo_Colaborador__c grupoTarea = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE name = 'grupo de tareas' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND IsActive = true Limit 1];
        
        String idRec = caso.Id; 
        String descripcion = 'test';
        String equipoResponsableId = grupoTarea.Id;
        Boolean esMaestroOrOtras = true;
        Case tareaInsertada;

        System.RunAs(usuario){   
            Test.startTest();
            SAC_LCMP_NuevaTarea.insertarTarea(idRec, descripcion, equipoResponsableId, esMaestroOrOtras);
            tareaInsertada = [SELECT Id,Subject FROM Case WHERE subject = 'TestTarea2' LIMIT 1];
            Test.stopTest();
        }

        system.assertEquals(idRec, tareaInsertada.id, 'La ejecucion ha fallado a la hora de insertar la tarea');
    }

    @isTest
    static void insertarTareaTest4() {

        Case caso = [SELECT Id,Subject FROM Case WHERE subject = 'TestTarea2' LIMIT 1];
        SAC_MaestroAccionesReclamacion__c maestroTarea = [SELECT Id FROM SAC_MaestroAccionesReclamacion__c WHERE name = 'maestro tarea' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND IsActive = true Limit 1];
        
        String idRec = caso.Id; 
        String descripcion = '';
        String equipoResponsableId = maestroTarea.Id;
        Boolean esMaestroOrOtras = false;
        Case tareaInsertada;

        System.RunAs(usuario){   
            Test.startTest();
            SAC_LCMP_NuevaTarea.insertarTarea(idRec, descripcion, equipoResponsableId, esMaestroOrOtras);
            tareaInsertada = [SELECT Id,Subject FROM Case WHERE subject = 'TestTarea2' LIMIT 1];
            Test.stopTest();
        }

        system.assertEquals(idRec, tareaInsertada.id, 'La ejecucion ha fallado a la hora de insertar la tarea');
    }

    @isTest 
    static void tienePermisosTest() {
        Boolean respuesta=false;
        Case casoReclamacion = [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestTarea' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND IsActive = true LIMIT 1];

        System.RunAs(usuario){   
            Test.startTest();
            respuesta = SAC_LCMP_NuevaTarea.tienePermisos(casoReclamacion.id);
            Test.stopTest();
        }

        system.assertEquals( True, respuesta, 'No tiene permisos para insertar una tarea ');
    }
    

    @isTest
    static void camposRequeridosTest() {

        Case casoReclamacion = [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestTarea' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND IsActive = true LIMIT 1];

        List<CC_Grupo_Colaborador__c> listaGrupos;

        System.RunAs(usuario){   
            Test.startTest();
            listaGrupos = SAC_LCMP_NuevaTarea.camposRequeridos(casoReclamacion.id, 'OtrasTareas');
            Test.stopTest();
        }
        
        System.assertNotEquals(null, listaGrupos, 'No se han podido recuperar los grupos');
    }

    @isTest
    static void camposRequeridosMaestroTest() {

        Case casoReclamacion = [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestTarea' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND IsActive = true LIMIT 1];

        List<SAC_MaestroAccionesReclamacion__c> listaGrupos;

        System.RunAs(usuario){   
            Test.startTest();
            listaGrupos = SAC_LCMP_NuevaTarea.camposRequeridosMaestro(casoReclamacion.id, 'MaestroTareas');
            Test.stopTest();
        }
        
        System.assertNotEquals(null, listaGrupos, 'No se han podido recuperar los grupos');
    }

    @isTest 
    static void tienePermisosTest2() {
        Boolean respuesta=false;
        Case casoReclamacion = [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestTarea' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteoDOS@test.com' AND IsActive = true LIMIT 1];

        System.RunAs(usuario){   
            Test.startTest();
            respuesta = SAC_LCMP_NuevaTarea.tienePermisos(casoReclamacion.id);
            Test.stopTest();
        }

        system.assertEquals( True, respuesta, 'No tiene permisos para insertar una tarea ');
    }
}