/*****************************************************************
 * Name: SAC_NotificacionesBatch_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_NotificacionesBatch y la clase SAC_NotificacionesBatchSchedule
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US271705         Carlos Solis         21/10/21     Creación Clase
 * 1.1            US643756         Jose Carlos Blanco   05/07/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@isTest
public with sharing class SAC_NotificacionesBatch_Test {
    @TestSetup
    static void makeData(){

        User usuarioGeneral;
          System.runAs(new User(Id = Userinfo.getUserId())) {
               //Usuario SAC General
               usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];   
               SAC_DatabaseDML.insertDML(usuarioGeneral, false);  
               //Database.insert(usuarioGeneral);

               PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
               PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
               permiSetAssi.AssigneeId = usuarioGeneral.Id;
               permiSetAssi.PermissionSetId = permiSet.Id;
               SAC_DatabaseDML.insertDML(permiSetAssi, false); 
               //Database.insert(permiSetAssi);
          }

        //Reclamaciones
        List<Case> listaReclamaciones = new List<Case>();
        Map<String, Object> camposRecl1 = new Map<String, Object>();
        camposRecl1.put('Subject', 'reclamacion2');
        camposRecl1.put('SAC_FechaRecepcion__c', system.now());
        camposRecl1.put('Status', 'SAC_007'); //Negociación
    
        Case reclamacion1 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl1);
        listaReclamaciones.add(reclamacion1);


        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'reclamacion5');
        camposRecl2.put('SAC_FechaRecepcion__c', system.now());
        camposRecl2.put('Status', 'SAC_007'); //Negociación
    
        Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl2);
        listaReclamaciones.add(reclamacion2);

        SAC_DatabaseDML.insertListDML(listaReclamaciones, false); 
        //Database.insert(listaReclamaciones);

        //Pretensiones
        List<Case> listaPretensiones = new List<Case>();
        Map<String, Object> camposPret1 = new Map<String, Object>();
        camposPret1.put('SAC_Reclamacion__c', reclamacion1.Id);
    
        Case pretension1 = SAC_TestDataFactory.crearCaso('Pretension', camposPret1);
        listaPretensiones.add(pretension1);


        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('SAC_Reclamacion__c', reclamacion2.Id);
    
        Case pretension2 = SAC_TestDataFactory.crearCaso('Pretension', camposPret2);
        listaPretensiones.add(pretension2);

        SAC_DatabaseDML.insertListDML(listaPretensiones, false); 
        //Database.insert(listaPretensiones);

        //TMEs
        List<SAC_TMECaso__c> listaTMEs = new List<SAC_TMECaso__c>();

        Map<String, Object> camposTME = new Map<String, Object>();
        camposTME.put('Name', 'Negociacion1');
        camposTME.put('SAC_Caso__c', reclamacion1.Id);
        //camposTME.put('SAC_FechaInicio__c', ); roll up summary max de el campo SAC_Inicio__c del objeto SAC_TiempoEstados__c

        SAC_TMECaso__c tme1 = SAC_TestDataFactory.crearTMECaso(camposTME);
        listaTMEs.add(tme1);


        Map<String, Object> camposTME2 = new Map<String, Object>();
        camposTME2.put('Name', 'Negociacion2');
        camposTME2.put('SAC_Caso__c', reclamacion2.Id);
        //camposTME2.put('SAC_FechaInicio__c', ); roll up summary max de el campo SAC_Inicio__c del objeto SAC_TiempoEstados__c

        SAC_TMECaso__c tme2 = SAC_TestDataFactory.crearTMECaso(camposTME2);
        listaTMEs.add(tme2);

        SAC_DatabaseDML.insertListDML(listaTMEs, false); 
        //Database.insert(listaTMEs);

        //Tiempo por estados
        List<SAC_TiempoEstados__c> listaTiemposEstado = new List<SAC_TiempoEstados__c>();
        
        Map<String, Object> camposTiempo = new Map<String, Object>();
        camposTiempo.put('SAC_Inicio__c', system.today() - 3);

        SAC_TiempoEstados__c tiempoPorEstado1 = SAC_TestDataFactory.crearTiempoEstados(tme1.Id, camposTiempo);
        listaTiemposEstado.add(tiempoPorEstado1);


        Map<String, Object> camposTiempo2 = new Map<String, Object>();
        camposTiempo2.put('SAC_Inicio__c', system.today() - 7);

        SAC_TiempoEstados__c tiempoPorEstado2 = SAC_TestDataFactory.crearTiempoEstados(tme2.Id, camposTiempo2);
        listaTiemposEstado.add(tiempoPorEstado2);
        
        SAC_DatabaseDML.insertListDML(listaTiemposEstado, false); 
        //Database.insert(listaTiemposEstado);
    }

    @isTest
    static void notificacionesBatchTest(){
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];

        System.runAs(usuario){
            Test.startTest();
            String cronExp = '0 0 0 3 9 ? 2030';
            String jobId = system.schedule('testNotificaciones', cronExp, new SAC_NotificacionesBatchSchedule());
            Test.stopTest();

            System.assertNotEquals(null, jobId, 'No se ha podido comprobar si existen notificaciones que lanzar');
        }
    }
}