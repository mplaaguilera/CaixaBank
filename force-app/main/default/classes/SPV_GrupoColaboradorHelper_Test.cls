/*********************************************************************************************************
 * Name: SPV_GrupoColaboradorHelper_Test
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Test de los triggers de SPV del objeto CC_Grupo_Contact__c
 * 
 * Historial
 * -------
 * VERSION        USER_STORY            AUTHOR               DATE             Description
 * 1.0             US828257           Raúl Santos          29/04/24             Creación
**********************************************************************************************************/

@isTest
public with sharing class SPV_GrupoColaboradorHelper_Test {

    @TestSetup
    static void makeData(){
        Test.startTest();

        //Usuario
        User usuario = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
        Database.insert(usuario);

        Test.stopTest();
    }

    @isTest
    static void insertarGrupoTest() {
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];

        System.runas(usuarioGeneral){
            Boolean error = false;

            List<CC_Grupo_Colaborador__c> listaGruposColaboradores = new List<CC_Grupo_Colaborador__c>();
            CC_Grupo_Colaborador__c grupoGestor = SPV_TestDataFactory.crearGrupoColaborador('GrupoGestor',1)[0];
            grupoGestor.SAC_MaximoCasosDiarios__c = 5;
            grupoGestor.SAC_Email__c = 'testSPV@testemail.com.invalid';
            grupoGestor.SAC_DeveloperName__c = 'GRUPOGESTORTESTSPV';
            listaGruposColaboradores.add(grupoGestor);

            CC_Grupo_Colaborador__c grupoLetrado = SPV_TestDataFactory.crearGrupoColaborador('GrupoLetrado',1)[0];
            grupoLetrado.SAC_Email__c = 'testSPV@testemail.com.invalid';
            grupoLetrado.SAC_DeveloperName__c = 'GRUPOLETRADOTESTSPV';
            listaGruposColaboradores.add(grupoLetrado);

            CC_Grupo_Colaborador__c grupoDeTareas = SPV_TestDataFactory.crearGrupoColaborador('GrupoDeTareas',1)[0];
            grupoDeTareas.SAC_Email__c = 'testSPV@testemail.com.invalid';
            grupoDeTareas.SAC_DeveloperName__c = 'GRUPODETAREASTESTSPV';
            listaGruposColaboradores.add(grupoDeTareas);

            try {
                Database.insert(listaGruposColaboradores);
            } catch (Exception e) {
                error = true;
            }
            Assert.areEqual(false, error, 'Ha ocurrido un error al crear los grupos colaboradores');
        }
    }
}