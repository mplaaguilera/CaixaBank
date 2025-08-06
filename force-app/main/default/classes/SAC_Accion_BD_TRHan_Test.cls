@isTest 
public with sharing class SAC_Accion_BD_TRHan_Test {
    @testSetup
    static void setupData() {
        //Usuario SAC Admin
		User usuarioAdmin = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        usuarioAdmin.Username = 'usertestadmin@test.com.testSetup';     
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);  

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_SystemAdmin'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioAdmin.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        System.runAs(usuarioAdmin){
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'testrec1');
            camposRecl.put('Status', 'SAC_001');
            camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
            camposRecl.put('SuppliedCompany', 'testCaso');

            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            SAC_DatabaseDML.insertDML(reclamacion, false); 
        }
    }
    

    @IsTest
    static void deleteAccionTest() {
        User sacUser = [SELECT Id FROM User WHERE username = 'usertestadmin@test.com.testSetup' LIMIT 1];
        Case reclamacion = [SELECT Id, RecordTypeId FROM Case WHERE Subject = 'testrec1' LIMIT 1];

        SAC_Accion__c tareaOtra = SAC_TestDataFactory.crearTareas(1, reclamacion, false)[0];
        tareaOtra.SAC_Observaciones__c = 'Tarea Test SAC 15-04'; 
        SAC_DatabaseDML.insertDML(tareaOtra, false); 

        System.runAs(sacUser){

            SAC_DatabaseDML.deleteDML(tareaOtra, true);

            List<SAC_Accion__c> listAccion = [SELECT Id FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'Tarea Test SAC 15-04' LIMIT 1];        

            Assert.areEqual(true, listAccion.isEmpty(), 'La tarea no ha sido eliminada');
        }
    }
}