@isTest
public with sharing class SAC_LCMP_ProductosPretension_Test {
    @TestSetup
    static void makeData(){
        // User
        List<User> listaUsuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(1);
        SAC_DatabaseDML.insertListDML(listaUsuarios, false);
        //Database.insert(listaUsuarios);

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = listaUsuarios[0].id);
        SAC_DatabaseDML.insertDML(psa, false);
        //Database.insert(psa);

        System.runAs(listaUsuarios[0]) {
            // Reclamacion
            List<Case> listaReclamaciones = new List<Case>();

            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRecl');
            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            listaReclamaciones.add(reclamacion);

            camposRecl.clear();
            camposRecl.put('Subject', 'TestRecl2');
            camposRecl.put('Status', 'SAC_001');
            camposRecl.put('OwnerId', listaUsuarios[0].id);
            Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            listaReclamaciones.add(reclamacion2);

            camposRecl.clear();
            camposRecl.put('Subject', 'TestRecl3');
            camposRecl.put('Status', 'Cerrado');
            camposRecl.put('OwnerId', listaUsuarios[0].id);
            Case reclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            listaReclamaciones.add(reclamacion3);

            SAC_DatabaseDML.insertListDML(listaReclamaciones, false);
            //Database.insert(reclamacion);


            //Pretensiones
            List<Case> listaPret = new List<Case>();
            Map<String, Object> camposPretl = new Map<String, Object>();
            camposPretl.put('Subject', 'TestPretl');
            
            Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPretl);
            pretension.SAC_Reclamacion__c = reclamacion.Id;
            listaPret.add(pretension);

            Map<String, Object> camposPretl2 = new Map<String, Object>();
            camposPretl2.put('Subject', 'TestPretl2');
            Case pretension2 = SAC_TestDataFactory.crearCaso('Pretension',camposPretl2);
            pretension2.SAC_Reclamacion__c = reclamacion2.Id;
            listaPret.add(pretension2);

            camposPretl2.clear();
            camposPretl2.put('Subject', 'TestPretl3');
            Case pretension3 = SAC_TestDataFactory.crearCaso('Pretension',camposPretl2);
            pretension3.SAC_Reclamacion__c = reclamacion3.Id;
            listaPret.add(pretension3);

            SAC_DatabaseDML.insertListDML(listaPret, false);

            //Productos
            SAC_ProductCase__c producto  = new SAC_ProductCase__c();
            producto.SAC_Pretension__c = pretension.Id;
            producto.SAC_Descripcion__c = 'Descripcion test';
            SAC_DatabaseDML.insertDML(producto, false);
            //Database.insert(producto);

          


        }
    }

    @isTest
    static void getProductosPretensionesTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case pretension = [SELECT Id FROM Case WHERE Subject = 'TestPretl' LIMIT 1];

        System.runAs(usuario) {
            SAC_LCMP_ProductosPretension.ProductosPretension productos = SAC_LCMP_ProductosPretension.getProductosPretensiones(pretension.Id);
            System.assertNotEquals(null, productos, 'No se han recuperado los productos de pretension');
        }
    }

    @isTest
    static void getProductosPretensionesTest2() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRecl' LIMIT 1];

        System.runAs(usuario) {
            SAC_LCMP_ProductosPretension.ProductosPretension productos = SAC_LCMP_ProductosPretension.getProductosPretensiones(reclamacion.Id);
            System.assertNotEquals(null, productos, 'No se han recuperado los productos de pretension');
        }
    }
    
    @isTest
    static void createProductWithPermission() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case pretension = [SELECT Id FROM Case WHERE Subject = 'TestPretl' LIMIT 1];
        
        System.runAs(usuario) {
            test.startTest();
            SAC_LCMP_ProductosPretension.createProductCase('Descripción', '12345', 'Dental', System.today(), System.today(), pretension.Id, 10, 10, null, null, null, null, null, null, null, null, true);
            test.stopTest();
            List<SAC_ProductCase__c> productos = [SELECT Id FROM SAC_ProductCase__c WHERE N_Contrato__c = '12345' LIMIT 1];
            System.assertEquals(productos.isEmpty(), false, 'Se ha generado el producto');
        }
    }
    
    @isTest
    static void editProductWithPermission() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case pretension = [SELECT Id FROM Case WHERE Subject = 'TestPretl' LIMIT 1];
        SAC_ProductCase__c product = [SELECT Id FROM SAC_ProductCase__c WHERE SAC_Pretension__c =: pretension.Id];
        System.runAs(usuario) {
            test.startTest();
            SAC_LCMP_ProductosPretension.editProductCase(product.Id, 'Descripción Edit', '67890', 'Dental', System.today(), System.today(), pretension.Id, 10, 10, null, null, null, null, null, null, null, null, true);
            test.stopTest();
            List<SAC_ProductCase__c> productos = [SELECT Id FROM SAC_ProductCase__c WHERE N_Contrato__c = '67890' LIMIT 1];
            System.assertEquals(productos.isEmpty(), false, 'Se ha generado el producto');
        }
    }

    @isTest
    static void eliminarProductoTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case pretension = [SELECT Id FROM Case WHERE Subject = 'TestPretl' LIMIT 1];
        SAC_ProductCase__c product = [SELECT Id FROM SAC_ProductCase__c WHERE SAC_Pretension__c =: pretension.Id];
        System.runAs(usuario) {
            SAC_LCMP_ProductosPretension.eliminarProducto(product.Id);
            List<SAC_ProductCase__c> listaProductos = [SELECT Id FROM SAC_ProductCase__c WHERE Id = :product.Id];
            System.assertEquals(listaProductos.isEmpty(), true, 'No se ha eliminado el producto correctamente.');
        }
    }

}