/*****************************************************************
 * Name: SAC_BatchCargaSLAMCC_Test
 * Copyright © 2021  CaixaBank
 *  
 * Proposito: Test para la clase SAC_BatchCargaSLAMCC
 *  
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US335889  	   Marcela Neira        17/02/22     Creación
 * 1.1			  US507573		   Jose Carlos Blanco	17/01/23	 Modificación (agregada assertion)
 * 1.2            US563153         Jose Carlos Blanco   07/03/23     Modificación (test modificada usando el SAC_TestDataFactory)
*****************************************************************/
@isTest
public with sharing class SAC_BatchCargaSLAMCC_Test {
    @TestSetup
    static void makeData(){

        User usuarioAdmin;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            //Usuario SAC General
            usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];    
            SAC_DatabaseDML.insertDML(usuarioAdmin, false);   
            //Database.insert(usuarioAdmin);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioAdmin.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);
            //Database.insert(permiSetAssi);
        }

        List<CC_MCC__c> listaMCCs = SAC_TestDataFactory.crearMCCs();
        SAC_DatabaseDML.upsertListDML(listaMCCs, false);
        //Database.upsert(listaMCCs);
    }
   
    @istest 
    static void cargarSLAMCC() { 
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
		System.runAs(usuario){
            Test.startTest();
            SAC_BatchCargaSLAMCC myBatchObject = new SAC_BatchCargaSLAMCC();
            Id batchId = Database.executeBatch(myBatchObject);
            System.assertNotEquals(null, batchId, 'No se ha cargado el batch.');
            Test.stopTest();
        }        
    }
}