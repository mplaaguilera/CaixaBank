/*********************************************************************************************************
 * Name: SPV_UserHelper_Test
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Test de los triggers de SPV del objeto User
 * 
 * Historial
 * -------
 * VERSION        USER_STORY            AUTHOR               DATE             Description
 * 1.0             US828257           Raúl Santos          29/04/24             Creación
**********************************************************************************************************/

@isTest
public with sharing class SPV_UserHelper_Test {
    
    @TestSetup
    static void makeData(){
        Test.startTest();

        //Usuario
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);

        Test.stopTest();
    }

    @isTest
    static void insertarUserTest() {
        User usuarioAdmin = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        System.runas(usuarioAdmin){
            Boolean error = false;

            User usuario = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];

            try {
                Database.insert(usuario);
            } catch (Exception e) {
                error = true;
            }
            Assert.areEqual(false, error, 'Ha ocurrido un error al crear el usuario');
        }
    }
}