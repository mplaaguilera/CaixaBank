/*****************************************************************
 * Name: SPV_LCMP_RecuperarProductosContratosTest
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de la clase SPV_LCMP_RecuperarProductosContratos
 * 
****************************************************************/ 
@isTest
public with sharing class SPV_LCMP_RecuperarProductosContratosTest {
    @TestSetup
    static void makeData(){
        // User
        List<User> listaUsuarios = SPV_TestDataFactory.crearUsuarioSPVGeneral(1);
        Database.insert(listaUsuarios);

        List<User> listaUsersAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1);
        Database.insert(listaUsersAdmin);

        Case reclamacion = new Case();

        System.runAs(listaUsuarios[0]) {
            // Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRecl');
            camposRecl.put('OwnerId', listaUsuarios[0].Id);
            
            reclamacion = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            Database.insert(reclamacion);
        }

        System.runAs(listaUsersAdmin[0]) {
            //Cambiar owner de la reclamación
            reclamacion.OwnerId = listaUsuarios[0].Id;
            Database.update(reclamacion);   
        }

        System.runAs(listaUsuarios[0]) {
            Map<String, Object> camposPretl = new Map<String, Object>();
            camposPretl.put('Subject', 'TestPretl');
            
            Case pretension = SPV_TestDataFactory.crearCaso('Pretension',camposPretl);
            pretension.SAC_Reclamacion__c = reclamacion.Id;
            Database.insert(pretension);

            SAC_ProductCase__c producto  = new SAC_ProductCase__c();
            producto.SAC_Pretension__c = pretension.Id;
            producto.SAC_Descripcion__c = 'Descripcion test';
            Database.insert(producto);

            CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();
            grupo.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoDeTareas').getRecordTypeId();
            grupo.Name = 'grupotest';
            grupo.SAC_PermiteEscalado__c = true;
            grupo.OS_Negocio__c = 'SPV';
            Database.insert(grupo);

            CC_Grupo_Colaborador_Contact__c colabcontact = new CC_Grupo_Colaborador_Contact__c();
            colabcontact.CC_Usuario__c = listaUsuarios[0].Id;
            colabcontact.CC_Grupo_Colaborador__c = grupo.Id;
            Database.insert(colabcontact);

            //Interaccion
            Map<String, Object> camposEsc = new Map<String, Object>();
            camposEsc.put('SAC_Titulo__c', 'propuesta test');
            camposEsc.put('SAC_Propuesta__c', 'propuesta test');
            camposEsc.put('SAC_MotivoEscalado__c', 'SPV_Alegación');
            camposEsc.put('SAC_CasoEscalado__c', reclamacion.Id);
            camposEsc.put('OwnerId', listaUsuarios[0].Id);
            camposEsc.put('SAC_GrupoColaborador__c', grupo.Id);
            camposEsc.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
            
            SAC_Interaccion__c escalado = SPV_TestDataFactory.crearInteraccion('Escalado',camposEsc);
            Database.insert(escalado); 
        }
    }

    @isTest
    static void getProductosContratosReclamacionTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];
        List<SAC_ProductCase__c> productos = new List<SAC_ProductCase__c>();

        System.runAs(usuario) {
            productos = SPV_LCMP_RecuperarProductosContratos.getProductosContratosReclamacion(escalado.Id);
            System.assertNotEquals(null, productos, 'No se han recuperado los productos de la reclamación');
        }
    }
}