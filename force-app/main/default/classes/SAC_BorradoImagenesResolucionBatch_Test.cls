/***************************************************************************
 * Name: SAC_BorradoImagenesResolucionBatch_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Probar la clase SAC_BorradoImagenesResolucionBatch
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR           DATE         Description
 * 1.0             US934210     Sergio Martín     10/06/2024      Creación
***************************************************************************/
@isTest
public with sharing class SAC_BorradoImagenesResolucionBatch_Test {
    @TestSetup
    static void makeData() {
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral){    
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRec');
            camposRecl.put('Origin','Backoffice');
            camposRecl.put('Status', 'Cerrado');
            camposRecl.put('SAC_StatusAuxiliar__c', 'Cerrado');
            camposRecl.put('OwnerId', usuarioGeneral.id);
            camposRecl.put('RecordTypeId', Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId());
            camposRecl.put('OS_Email__c', 'Test@test.com');
            Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
            Database.insert(casoReclamacion);

            SAC_ImagenDocumento__c imagenCaso = new SAC_ImagenDocumento__c();
            imagenCaso.SAC_Caso__c = casoReclamacion.id;
            imagenCaso.SAC_Imagen__c = '<p><img></img></p>';
            Database.insert(imagenCaso);
        }  
    }

    @isTest
    static void testProrroga() {
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        Case caso = [SELECT Id FROM case WHERE Subject = 'TestRec' LIMIT 1];
        Integer imagenAntesBorrado = [SELECT COUNT() FROM SAC_ImagenDocumento__c WHERE SAC_Caso__c =: caso.id];
        System.runAs(usuarioGeneral){
            Test.startTest();        
            Id batchId = Database.executeBatch(new SAC_BorradoImagenesResolucionBatch(), 1);
            Test.stopTest();
        }
        Integer imagenDespuesBorrado = [SELECT COUNT() FROM SAC_ImagenDocumento__c WHERE SAC_Caso__c =: caso.id];
        system.assertNotEquals(imagenDespuesBorrado, imagenAntesBorrado, 'No se ha borrado el registro correctamente');
    }
}