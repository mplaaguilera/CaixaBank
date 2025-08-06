/*****************************************************************
 * Name: SPV_LCMP_ProductosPretension_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de la clase SPV_LCMP_ProductosPretension
 * 
****************************************************************/ 
@isTest
public with sharing class SPV_LCMP_ProductosPretension_Test {
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
            camposRecl.put('OwnerId', listaUsuarios[0].Id);
            camposRecl.put('Subject', 'TestRecl');
            
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
        }
    }

    @isTest
    static void getProductosPretensionesTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        Case pretension = [SELECT Id FROM Case WHERE Subject = 'TestPretl' LIMIT 1];

        System.runAs(usuario) {
            SPV_LCMP_ProductosPretension.ProductosPretension productos = SPV_LCMP_ProductosPretension.getProductosPretensiones(pretension.Id);
            System.assertNotEquals(null, productos, 'No se han recuperado los productos de pretension');
        }
    }

    @isTest
    static void getProductosPretensionesTest2() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRecl' LIMIT 1];

        System.runAs(usuario) {
            SPV_LCMP_ProductosPretension.ProductosPretension productos = SPV_LCMP_ProductosPretension.getProductosPretensiones(reclamacion.Id);
            System.assertNotEquals(null, productos, 'No se han recuperado los productos de pretension');
        }
    }
}