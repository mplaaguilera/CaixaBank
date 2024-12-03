/*****************************************************************
 * Name: SAC_SetupSandbox_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_SetupSandbox
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0                             Daniel Benito        07/10/21     Creación
 * 1.1			  US507573		   Jose Carlos Blanco	19/06/23	 Modificación
*****************************************************************/
@isTest
public with sharing class SAC_SetupSandbox_Test {
    
    @isTest
    static void parametrizacionDatosTest(){
        //Usuario Admin
        User userAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(userAdmin);
        
        System.runAs(userAdmin){
            SAC_SetupSandbox.crearUsuarios();
        }
		
        Test.startTest();
        SAC_SetupSandbox.parametrizacionDatos();
        SAC_SetupSandbox.creacionEntitlement();
        Test.stopTest();
        
        System.assertNotEquals(null, SAC_SetupSandbox.creacionEntitlement(),'No se han insertado los entitlements.');
    }

    @isTest
    static void creacionPersonAccountTest(){
        //Usuario Admin
        User userAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(userAdmin);
        
        Test.startTest();
        System.runAs(userAdmin){
            SAC_SetupSandbox.creacionPersonAccount();
        }
        Test.stopTest();

        System.assertNotEquals(null, SAC_SetupSandbox.creacionPersonAccount(),'No se han insertado las cuentas.');
    }

    @isTest
    static void creacionCasoAntTest(){
        //Usuario Admin
        User userAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(userAdmin);
        
        Test.startTest();
        System.runAs(userAdmin){
            SAC_SetupSandbox.creacionCasoAnt();
        }
        Test.stopTest();
        System.assertNotEquals(null, SAC_SetupSandbox.creacionCasoAnt(),'No se han insertado los casos con antecedentes.');
    }
}