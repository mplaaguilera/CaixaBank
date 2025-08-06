/*****************************************************************
 * Name: SAC_GrupoColaboradorMetodos_Test
 * Copyright © 2021  CaixaBank 
 * 
 * Proposito: Testear la clase SAC_GrupoColaboradorMetodos
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US304889         Marcela Neira        09/05/22     Creación
 * 1.1            US563153         Jose Carlos Blanco  	24/04/23     Modificación (test modificada usando el SAC_TestDataFactory)                                                             
*****************************************************************/
@istest
public with sharing class SAC_GrupoColaboradorMetodos_Test {
    @TestSetup
    static void makeData(){

        //USUARIO SAC_Administrador
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);
        //Database.insert(usuarioAdmin);

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE PermissionSet.Label = 'SAC_Administrador'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuarioAdmin.id);
        SAC_DatabaseDML.insertDML(psa, false);       
        //Database.insert(psa);

        System.runAs(usuarioAdmin){
            //grupo colaborador
            CC_Grupo_Colaborador__c grupo = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1)[0];
            grupo.SAC_Email__c = 'testing@test.test';
            grupo.SAC_DeveloperName__c = 'GRUPO';
            SAC_DatabaseDML.insertDML(grupo, false);   
            //Database.insert(grupo);
        }
    }
    @istest
    static void insertarGrupo() {
        User usuarioAdmin = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true];

        System.runas(usuarioAdmin){
            Boolean error = false;

            CC_Grupo_Colaborador__c grupo = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1)[0];
            grupo.SAC_Email__c = 'correo@correo.test';
            grupo.SAC_DeveloperName__c = 'GRUPO';

            try {
                SAC_DatabaseDML.insertDML(grupo, true);   
                //Database.insert(grupo);
            } catch (Exception e) {
                error = true;
            }
            System.assertEquals(true, error, 'No ha saltado la validación del developer name del grupo');
        }
    }
    @istest
    static void modificarGrupo() {
        User usuarioAdmin = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true];

        System.runAs(usuarioAdmin){
            Boolean error = false;

            CC_Grupo_Colaborador__c grupo = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1)[0];
            grupo.SAC_Email__c = 'correo@correo.test';
            grupo.SAC_DeveloperName__c = 'NUEVIOGRUPO';
            SAC_DatabaseDML.insertDML(grupo, false);   
            //Database.insert(grupo);

            try {
                grupo.SAC_DeveloperName__c = 'GRUPO';
                SAC_DatabaseDML.updateDML(grupo, true);   
                //Database.update(grupo);
            } catch (Exception e) {
                error = true;
            }
            System.assertEquals(true, error, 'No ha saltado la validación del developer name del grupo');
        }
    }
}