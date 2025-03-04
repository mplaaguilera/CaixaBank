/*****************************************************************
 * Name: SAC_Grupo_Colaborador_BU_TRHan_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_Grupo_Colaborador_BU_TRHan
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            DE51351          Marcela Neira        06/09/21     Creación
 * 1.1            US563153         Jose Carlos Blanco  	30/03/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@isTest
public with sharing class SAC_Grupo_Colaborador_BU_TRHan_Test {
    @TestSetup
    static void makeData(){

        //USUARIO SAC_Administrador
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        usuarioAdmin.Username = 'admin123436@caixatest.com';     
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);

        //GRUPO COLABORADOR
        CC_Grupo_Colaborador__c grupoColaborador = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor',1)[0];
        grupoColaborador.SAC_PorcentajeAsignacion__c=100;
        grupoColaborador.SAC_MaximoCasosDiarios__c = 15;
        grupoColaborador.OwnerId = usuarioAdmin.id;
        SAC_DatabaseDML.insertDML(grupoColaborador, false);

        //USUARIO SAC_General
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        usuarioGeneral.SAC_GruposPerteneciente__c = grupoColaborador.id;      
        SAC_DatabaseDML.insertDML(usuarioGeneral, false);
    }

    @isTest
    static void modificarGrupoColaboradorTest() {
        CC_Grupo_Colaborador__c gc = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Proveedor 0'];
        User usuarioAdministrador = [SELECT id From User Where Username = 'admin123436@caixatest.com' AND isActive = true Limit 1];
        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_Administrador'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuarioAdministrador.id);       
        SAC_DatabaseDML.insertDML(psa, false);

        system.runAs(usuarioAdministrador){
            gc.name='Grupo modificado';
            Test.startTest();
            SAC_DatabaseDML.updateDML(gc, false);
            Test.stopTest();  
        }  
        
        system.assertEquals([SELECT Count() FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo modificado'] , 1, 'No se ha modificado la lista.');
    }   
}