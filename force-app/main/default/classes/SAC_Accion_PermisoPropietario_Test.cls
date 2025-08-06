/*****************************************************************
* Name: SAC_Accion_PermisoPropietario_Test
* Copyright © 2021  CaixaBank
* 
* Proposito: Testear la clase SAC_Accion_PermisoPropietario
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR               DATE         Description
* 1.0            DE53083          Daniel Benito        22/10/21     Creación
* 1.1            US563153         Jose Carlos Blanco   08/03/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/

@isTest
public with sharing class SAC_Accion_PermisoPropietario_Test {
    
    @TestSetup
    static void makeData(){
        
        User usuarioGeneral;
        User usuarioGeneral2;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            List<User> usuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(2);

            usuarioGeneral = usuarios[0];
            usuarioGeneral2 = usuarios[1];
            SAC_DatabaseDML.insertDML(usuarioGeneral, false);
            //Database.insert(usuarioGeneral);
            SAC_DatabaseDML.insertDML(usuarioGeneral2, false);
            //Database.insert(usuarioGeneral2);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);
            //Database.insert(permiSetAssi);

            PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
            permiSetAssi2.AssigneeId = usuarioGeneral2.Id;
            permiSetAssi2.PermissionSetId = permiSet2.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi2, false);
            //Database.insert(permiSetAssi2);
        }

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Reclamacion test');
        camposRecl.put('OwnerId', usuarioGeneral.id);
        
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        //Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('Subject', 'Pretension test');
        camposPret.put('OwnerId', usuarioGeneral.id);
        
        Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        
        List<Case> listaCasos = new List<Case>();
        listaCasos.add(reclamacion);
        listaCasos.add(pretension);
        SAC_DatabaseDML.insertListDML(listaCasos, false);
        //Database.insert(listaCasos);
        
        List<SAC_Accion__c> acciones = new List<SAC_Accion__c>();
        SAC_Accion__c accion1 = SAC_TestDataFactory.crearTareas(1,pretension,false)[0];
        SAC_Accion__c accion2 = SAC_TestDataFactory.crearTareas(1,pretension,false)[0];
        SAC_Accion__c accion3 = SAC_TestDataFactory.crearTareas(1,reclamacion,false)[0];
        SAC_Accion__c accion4 = SAC_TestDataFactory.crearTareas(1,reclamacion,false)[0];
        accion1.SAC_Prorroga__c = 4;
        accion2.SAC_Prorroga__c = 4;
        accion2.SAC_Pretension__c = reclamacion.id;
        accion3.SAC_Prorroga__c = 4;
        accion4.SAC_Prorroga__c = 4;
        accion4.SAC_Reclamacion__c = pretension.id;
        acciones.add(accion1);
        acciones.add(accion2);
        acciones.add(accion3);
        acciones.add(accion4);

        System.runAs(usuarioGeneral){
            SAC_DatabaseDML.insertListDML(acciones, false);
            //Database.insert(acciones);
        }           
    }

    @istest
    static void insertarTarea(){

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        User usuario2 = [SELECT Id FROM User WHERE Username = 'usertest1@test.com.testSetup' AND isActive = true LIMIT 1];

        Case caso = [SELECT id, OwnerId from Case WHERE subject = 'Reclamacion test'];

        caso.OwnerId = usuario2.id;

        System.runAs(usuario2){
            Test.startTest();
            SAC_DatabaseDML.updateDML(caso, false);
            //Database.update(caso);
            Test.stopTest();
        }

        Case casoNuevo = [SELECT id, OwnerId from Case WHERE subject = 'Reclamacion test'];

        System.assertEquals(usuario2.Id, casoNuevo.OwnerId, 'No se ha cambiado el owner');
    }
    
    @istest
    static void insertarTarea2(){

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        User usuario2 = [SELECT Id FROM User WHERE Username = 'usertest1@test.com.testSetup' AND isActive = true LIMIT 1];

        Case caso = [SELECT id, OwnerId from Case WHERE subject = 'Reclamacion test'];

        caso.OwnerId = usuario2.id;

        SAC_DatabaseDML.updateDML(caso, false);
        //Database.update(caso);

        Case casoNuevo = [SELECT id, OwnerId from Case WHERE subject = 'Reclamacion test'];

        casoNuevo.OwnerId = usuario.id;

        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(casoNuevo, false);
            //Database.update(casoNuevo);
            Test.stopTest();
        }
        System.assertEquals(usuario.Id, casoNuevo.OwnerId, 'No se ha cambiado el owner por segunda vez');
    }
}