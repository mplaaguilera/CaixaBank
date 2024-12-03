/***********************************************************************
 * Name: SAC_LCMP_BtnComentarioTarea_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Clase para operaciones de LWC sAC_ResponderConsulta
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US361683         Marcela Neira        21/06/22     Creación
 * 1.1            US563153         Jose Carlos Blanco  	18/04/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*************************************************************************/
@istest
public with sharing class SAC_LCMP_BtnComentarioTarea_Test {
    @TestSetup
    static void makeData(){

        //Usuario SAC_General
        User usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        Database.insert(usuario);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuario){
            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'reclamacion');
            
            Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            Database.insert(casoReclamacion);

            SAC_Accion__C tarea = SAC_TestDataFactory.crearTareas(1,casoReclamacion,false)[0];
            tarea.SAC_Comentarios__c ='comentarios 1'; 
            tarea.SAC_Comentarios2__c = 'comentarios 2';
            Database.insert(tarea);
        }
    }

    @istest
    static void getComentarios1_Test() {
        SAC_Accion__C tarea = [SELECT Id FROM SAC_Accion__C ];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuario){
            Test.startTest();
            String respuesta = SAC_LCMP_BtnComentarioTarea.getComentarios1(tarea.id);
            Test.stopTest();

            System.assertEquals('comentarios 1', respuesta, 'No se ha devuelto el comentario 1');
        } 
    }
    
    @istest
    static void getComentarios2_Test() {
        SAC_Accion__C tarea = [SELECT Id FROM SAC_Accion__C ];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuario){
            Test.startTest();
            String respuesta = SAC_LCMP_BtnComentarioTarea.getComentarios2(tarea.id);
            Test.stopTest();

            System.assertEquals('comentarios 2', respuesta, 'No se ha devuelto el comentario 2');
        }
    }

    @istest 
    static void guardarComentario1Apex_Test() {
        SAC_Accion__C tarea = [SELECT Id FROM SAC_Accion__C ];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_BtnComentarioTarea.guardarComentario1Apex(tarea.id, 'comentario');
            Test.stopTest();
        }

        tarea = [SELECT Id, SAC_Comentarios__c FROM SAC_Accion__C ];

        System.assertEquals('comentario', tarea.SAC_Comentarios__c, 'Los comentarios no son iguales');
    }

    @istest 
    static void guardarComentario2Apex_Test() {
        SAC_Accion__C tarea = [SELECT Id FROM SAC_Accion__C ];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_BtnComentarioTarea.guardarComentario2Apex(tarea.id, 'comentario');
            Test.stopTest();
        }

        tarea = [SELECT Id, SAC_Comentarios2__c FROM SAC_Accion__C ];

        System.assertEquals('comentario', tarea.SAC_Comentarios2__c, 'Los comentarios no son iguales');
    }
}