/*****************************************************************
 * Name: SAC_LCMP_ProductosPretensionWOSharing
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Clase test de SAC_LCMP_ProductosPretensionWOSharing
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            --              Iria ANPC     24/12/24        Creación
*****************************************************************/
@isTest
public class SAC_LCMP_ProductosPretensionWOShar_Test {
    @TestSetup
    static void makeData(){
        // User
        List<User> listaUsuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(1);
        SAC_DatabaseDML.insertListDML(listaUsuarios, false);

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = listaUsuarios[0].id);
        SAC_DatabaseDML.insertDML(psa, false);

        System.runAs(listaUsuarios[0]) {
            // Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRecl');
            
            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            SAC_DatabaseDML.insertDML(reclamacion, false);

            Map<String, Object> camposPretl = new Map<String, Object>();
            camposPretl.put('Subject', 'TestPretl');
            
            Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPretl);
            pretension.SAC_Reclamacion__c = reclamacion.Id;
            SAC_DatabaseDML.insertDML(pretension, false);

            SAC_ProductCase__c producto  = new SAC_ProductCase__c();
            producto.SAC_Pretension__c = pretension.Id;
            producto.SAC_Descripcion__c = 'Descripcion test';
            SAC_DatabaseDML.insertDML(producto, false);
        }
    }
    
    @isTest
    static void createProductWithoutPermission() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case pretension = [SELECT Id FROM Case WHERE Subject = 'TestPretl' LIMIT 1];
        
        System.runAs(usuario) {
            try{
            SAC_LCMP_ProductosPretensionWOSharing.createRecordWithoutSharing('Descripción', '12345', 'Dental', System.today(), System.today(), pretension.Id, 10, 10, null, null);
            //System.assertNotEquals(null, productos, 'No se han recuperado los productos de pretension');
            }catch(Exception e){
                
            }
        }
    }
    
    @isTest
    static void editProductWithoutPermission() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case pretension = [SELECT Id FROM Case WHERE Subject = 'TestPretl' LIMIT 1];
        SAC_ProductCase__c product = [SELECT Id FROM SAC_ProductCase__c WHERE SAC_Pretension__c =: pretension.Id];
        System.runAs(usuario) {
            try{
                SAC_LCMP_ProductosPretensionWOSharing.editRecordWithoutSharing(product.Id, 'Descripción Edit', '12345', 'Dental', System.today(), System.today(), pretension.Id, 10, 10, null, null);
                //System.assertNotEquals(null, productos, 'No se han recuperado los productos de pretension');
            }catch(Exception e){
                
            }
        }
    }
    
    @isTest
    static void createProductWithPermission() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case pretension = [SELECT Id FROM Case WHERE Subject = 'TestPretl' LIMIT 1];
        
        System.runAs(usuario) {
            try{
            SAC_LCMP_ProductosPretensionWOSharing.createRecordWithoutSharing('Descripción', '12345', 'Dental', System.today(), System.today(), pretension.Id, 10, 10, null, null);
            //System.assertNotEquals(null, productos, 'No se han recuperado los productos de pretension');
            }catch(Exception e){
                
            }
        }
    }
    
    @isTest
    static void editProductWithPermission() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case pretension = [SELECT Id FROM Case WHERE Subject = 'TestPretl' LIMIT 1];
        SAC_ProductCase__c product = [SELECT Id FROM SAC_ProductCase__c WHERE SAC_Pretension__c =: pretension.Id];
        System.runAs(usuario) {
            try{
                SAC_LCMP_ProductosPretensionWOSharing.editRecordWithoutSharing(product.Id, 'Descripción Edit', '12345', 'Dental', System.today(), System.today(), pretension.Id, 10, 10, null, null);
                //System.assertNotEquals(null, productos, 'No se han recuperado los productos de pretension');
            }catch(Exception e){
                
            }
        }
    }
}