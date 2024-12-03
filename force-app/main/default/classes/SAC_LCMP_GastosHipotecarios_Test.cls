/*****************************************************************
 * Name: SAC_LCMP_GastosHipotecarios_Test
 * Copyright © 2022 CaixaBank  
 * 
 * Proposito: Testear la clase SAC_LCMP_GastosHipotecarios
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US431440         Marcela Neira        07/09/22     Creación
 * 1.1            US563153         Jose Carlos Blanco  	27/04/23     Modificación (test modificada usando el SAC_TestDataFactory)             
*****************************************************************/
@isTest
public with sharing class SAC_LCMP_GastosHipotecarios_Test {

    @TestSetup
    static void makeData(){       
 
        //Usuario SAC General
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        usuarioGeneral.SAC_PerteneceCOPSAJ__c = true;      
        Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral){
            //Grupo Colaborador
            CC_Grupo_Colaborador__c grupoColaborador = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1)[0];
            Database.insert(grupoColaborador);

            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestResolucion');

            Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            Database.insert(casoReclamacion);

            //Pretension
            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('SuppliedCompany', 'pretension');
            camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);

            Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
            Database.insert(casoPretension); 
    
            //Maestro acciones
            SAC_MaestroAccionesReclamacion__c maestro = SAC_TestDataFactory.crearMaestroAcciones(1, grupoColaborador.Id)[0];
            maestro.SAC_DeveloperName__c ='GGH';
            maestro.SAC_Descripcion__c = 'Maestro'; 
            maestro.SAC_PlazoMaximo__c = 4; 
            maestro.SAC_Prorroga__c= 4; 
            maestro.SAC_Activo__c = true;
            Database.insert(maestro);

            //Tarea
            SAC_Accion__c tarea = SAC_TestDataFactory.crearTareas(1, casoPretension, true)[0]; 
            tarea.SAC_MaestroAccionesReclamacion__c = maestro.id; 
            tarea.SAC_Estado__c = 'SAC_PendienteEnviar';
            Database.insert(tarea);
        }
    }

    @IsTest
    static void comprobarTareas_Test(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany ='pretension'];   

        System.runAs(usuario){
            Test.startTest();
            Boolean respuesta = SAC_LCMP_GastosHipotecarios.comprobarTareas(pretension.Id);  
            Test.stopTest();
            System.assertEquals(false, respuesta, 'El resultado deberia ser un false la variable de metodo se llama noSePuedeModificarTarea');
        }     
    }

    @isTest
    static void modificarImportesTarea_Test(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany ='pretension'];
        Integer[] arrayImportes = new List<Integer>();
        
        arrayImportes.add(10);
        arrayImportes.add(10);
        arrayImportes.add(10);
        arrayImportes.add(10);
        arrayImportes.add(10);

        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_GastosHipotecarios.modificarImportesTarea(pretension.Id, arrayImportes);
            Test.stopTest();
        }

        SAC_Accion__c tarea = [SELECT Id, SAC_ImpResueltoNotaria__c FROM SAC_Accion__c];

        System.assertNotEquals(null, tarea.SAC_ImpResueltoNotaria__c,'ha fallado el test');
    }
}