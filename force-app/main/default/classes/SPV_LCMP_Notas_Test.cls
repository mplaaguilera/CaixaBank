/*****************************************************************
 * Name: SPV_LCMP_Notas_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de  SPV_LCMP_Notas
****************************************************************/
/**
*   @description SPV_LCMP_Notas_Test
*/

@isTest
public with sharing class SPV_LCMP_Notas_Test {

    @TestSetup
    static void makeData(){
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SPV_DatabaseDML.insertDML(usuarioAdmin, true);


        List<User> listUsuarios ;

        System.runAs(usuarioAdmin){
            listUsuarios  = SPV_TestDataFactory.crearUsuarioSPVGeneral(2);
            SPV_DatabaseDML.insertListDML(listUsuarios, true);
        }


        //Reclamaciones

        List<Case> listaReclamaciones = new List<Case>();
        Map<String, Object> camposReclamacion = new Map<String, Object>();
        camposReclamacion.put('Subject', 'TestRec');
        camposReclamacion.put('SPV_Organismo__c', 'SPV_BDE');
        camposReclamacion.put('Status', 'SPV_AnalisisDecision');
        camposReclamacion.put('OwnerId', listUsuarios[0].Id);
        camposReclamacion.put('SAC_StatusAuxiliar__c', 'SPV_AnalisisDecision');

        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion);
        listaReclamaciones.add(casoReclamacion);
        
        SPV_DatabaseDML.insertListDML(listaReclamaciones, true);
    }

    @isTest
    static void obtenerNotasAsociadasYAddNuevaNotaTest(){

        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        List<SPV_LCMP_Notas.NoteWrapper> listaResult = new List<SPV_LCMP_Notas.NoteWrapper>();

        Test.startTest();
        System.runAs(usuario){
            SPV_LCMP_Notas.addNuevaNota('Test', 'Test', reclamacion.Id);
            listaResult = SPV_LCMP_Notas.obtenerNotasAsociadas(reclamacion.Id);
        }

        Assert.areEqual(listaResult.isEmpty(), false, 'No se han obtenido las notas asociadas correctamente');
        Test.stopTest();
    }


    @isTest
    static void comprobarUserSystemAdminTest(){

        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Boolean resultado;
        Test.startTest();
        System.runAs(usuario){
            resultado = SPV_LCMP_Notas.comprobarUserSystemAdmin();
        }

        Assert.areEqual(resultado, false, 'No se ha realizado la comprobación correctamente');
        Test.stopTest();
    }

    @isTest
    static void obtenerContenidoTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        List<SPV_LCMP_Notas.NoteWrapper> listaResult = new List<SPV_LCMP_Notas.NoteWrapper>();
        String resultado = '';

        Test.startTest();
        System.runAs(usuario){
            SPV_LCMP_Notas.addNuevaNota('Test', 'Test', reclamacion.Id);
            listaResult = SPV_LCMP_Notas.obtenerNotasAsociadas(reclamacion.Id);

            ContentNote nota = [SELECT Id FROM ContentNote WHERE Title = 'Test'];
            resultado = SPV_LCMP_Notas.obtenerContenido(nota.Id);

        }

        Assert.areEqual(resultado, 'Test', 'NNo se ha obtenido el contenido de la nota correctamente');
        Test.stopTest();
    }

    @isTest
    static void recuperarNotasAsociadasRefreshTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        List<SPV_LCMP_Notas.NoteWrapper> listaResult = new List<SPV_LCMP_Notas.NoteWrapper>();

        Test.startTest();
        System.runAs(usuario){
            SPV_LCMP_Notas.addNuevaNota('Test', 'Test', reclamacion.Id);
            listaResult = SPV_LCMP_Notas.recuperarNotasAsociadasRefresh(reclamacion.Id);
        }

        Assert.areEqual(listaResult.isEmpty(), false, 'No se han obtenido las notas asociadas correctamente');
        Test.stopTest();
    }

    @isTest
    static void eliminarNotaTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        List<ContentNote> listaResult = new List<ContentNote>();

        Test.startTest();
        System.runAs(usuario){
            SPV_LCMP_Notas.addNuevaNota('Test', 'Test', reclamacion.Id);
            ContentNote nota = [SELECT Id FROM ContentNote WHERE Title = 'Test'];
            SPV_LCMP_Notas.eliminarNota(nota.Id);
            listaResult = [SELECT Id FROM ContentNote WHERE Title = 'Test'];
        }

        Assert.areEqual(listaResult.isEmpty(), true, 'No se ha eliminado la nota correctamente');
        Test.stopTest();
    }


}