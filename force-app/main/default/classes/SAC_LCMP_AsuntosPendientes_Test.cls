/*****************************************************************
 * Name: SAC_LCMP_AsuntosPendientes_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_LCMP_AsuntosPendientes
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US308697         Marcela Neira        24/03/22     Creación
 * 1.1            US563153         Jose Carlos Blanco  	18/04/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@isTest
public with sharing class SAC_LCMP_AsuntosPendientes_Test {
    @TestSetup
    static void makeData(){

        //Usuario SAC_General
        User usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        SAC_DatabaseDML.insertDML(usuario, false);
        //Database.insert(usuario);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);
        

        //grupo colaborador
        CC_Grupo_Colaborador__c grupo = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion', 1)[0];
        grupo.SAC_PermiteEscalado__c = true;
        grupo.SAC_NivelGrupo__c = 'SAC_Nivel2';
        grupo.SAC_Email__c = 'testing@test.test';
        

        List<Case> listacasos = new List<Case>();
        List<SAC_Interaccion__c> listaInteracciones = new List<SAC_Interaccion__c>();
        
        System.runAs(usuario){
            SAC_DatabaseDML.insertDML(grupo, false);
            //Database.insert(grupo);

            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'reclamacion');
            
            Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            listacasos.add(casoReclamacion);

            //Reclamacion 2
            Map<String, Object> camposRecl2 = new Map<String, Object>();
            camposRecl2.put('Subject', 'reclamacion2');
            
            Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
            listacasos.add(casoReclamacion2);

            SAC_DatabaseDML.insertListDML(listacasos, false);
            //Database.insert(listacasos);

            SAC_Accion__c tarea = SAC_TestDataFactory.crearTareas(1, casoReclamacion, false)[0];
            SAC_DatabaseDML.insertDML(tarea, false);
            //Database.insert(tarea);


            //Interaccion Escalado
            Map<String, Object> camposEsc = new Map<String, Object>();
            camposEsc.put('SAC_Titulo__c', 'propuesta test');
            camposEsc.put('SAC_Propuesta__c', 'propuesta test');
            camposEsc.put('SAC_CasoEscalado__c', casoReclamacion.Id);
            camposEsc.put('SAC_Email1__c', 'testing@test.test');
            camposEsc.put('SAC_GrupoColaborador__c', grupo.Id);
            camposEsc.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
            camposEsc.put('SAC_ImporteAutorizado__c', 20);
            
            SAC_Interaccion__c escalado = SAC_TestDataFactory.crearInteraccion('Escalado',camposEsc);
            listaInteracciones.add(escalado);

            //Interaccion Consulta
            Map<String, Object> camposCons = new Map<String, Object>();
            camposCons.put('SAC_Reclamacion__c', casoReclamacion.id);
            camposCons.put('SAC_EmailRespuesta__c', 'emailentrante@entrante.com');
            camposCons.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
            
            SAC_Interaccion__c consulta = SAC_TestDataFactory.crearInteraccion('Consulta',camposCons);
            listaInteracciones.add(consulta);

            SAC_DatabaseDML.insertListDML(listaInteracciones, false);
            //Database.insert(listaInteracciones);
        }   
    }

    @isTest 
    static void comprobarAsuntosTest() {
        Case caso = [SELECT id FROM Case WHERE Subject = 'reclamacion'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuario){
            SAC_LCMP_AsuntosPendientes.AsuntosPendientesWrapper resultado = SAC_LCMP_AsuntosPendientes.comprobarAsuntos(caso.id);
            System.assertNotEquals(null, resultado, 'No se ha podido comprobar los asuntos');
        }
    }
    @isTest 
    static void comprobarAsuntosTest2() {
        Case caso = [SELECT id FROM Case WHERE Subject = 'reclamacion2'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        System.runAs(usuario){
            SAC_LCMP_AsuntosPendientes.AsuntosPendientesWrapper resultado = SAC_LCMP_AsuntosPendientes.comprobarAsuntos(caso.id);
            System.assertNotEquals(null, resultado, 'No se ha podido comprobar los asuntos');
        }
    }
}