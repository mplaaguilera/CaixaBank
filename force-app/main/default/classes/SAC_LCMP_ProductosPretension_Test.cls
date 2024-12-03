@isTest
public with sharing class SAC_LCMP_ProductosPretension_Test {
    @TestSetup
    static void makeData(){
        // User
        List<User> listaUsuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(1);
        Database.insert(listaUsuarios);

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = listaUsuarios[0].id);
        Database.insert(psa);

        System.runAs(listaUsuarios[0]) {
            // Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRecl');
            
            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            Database.insert(reclamacion);

            Map<String, Object> camposPretl = new Map<String, Object>();
            camposPretl.put('Subject', 'TestPretl');
            
            Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPretl);
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
}