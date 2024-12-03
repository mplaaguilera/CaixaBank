/***************************************************************************
 * Name: SPV_Reclamaciones_IntegrationBatch_Test.cls
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de la clase SPV_Reclamaciones_IntegrationBatch
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR           DATE         Description
 * 1.0             US1031912      Álex Polo       04/10/2024     Creación
***************************************************************************/


@isTest
public with sharing class SPV_Reclamaciones_IntegrationBatch_Test {
  
    @TestSetup
    static void makeData(){
        Test.startTest();

        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);
    
        List<User> listUsuarios ;
    
        System.runAs(usuarioAdmin){
            listUsuarios  = SPV_TestDataFactory.crearUsuarioSPVGeneral(2);
            Database.insert(listUsuarios );
        }

        Test.stopTest();
    }


    @isTest
    static void batchRclamacionesIntegration_Test(){

        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        Id batchJobId;
       
        System.runAs(usuario){
            Test.startTest();
            batchJobId = Database.executeBatch(new SPV_Reclamaciones_IntegrationBatch(), 200);
            Test.stopTest();
        }

        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'SubjectTest' LIMIT 1];
        Assert.areNotEqual(reclamacion, null, 'No se ha insertado la reclamación.');
        
    }

    @isTest
    static void comprobarTrueFalse_Test(){

        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Test.startTest();
        Boolean resultado = false;
        System.runAs(usuario){
            resultado = SPV_Reclamaciones_IntegrationBatch.comprobarTrueFalse('s');
        }

        Assert.areEqual(true, resultado);
        Test.stopTest();

    }

    @isTest
    static void obtenerApiPicklist_Test(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Test.startTest();
        String resultado = '';
        System.runAs(usuario){
            resultado = SPV_Reclamaciones_IntegrationBatch.obtenerApiPicklist('Status', 'Alta');
        }

        Assert.areEqual('SAC_001', resultado);
        Test.stopTest();
    }

}