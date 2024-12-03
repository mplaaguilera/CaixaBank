@isTest
public with sharing class SAC_Alerta_BU_TRHan_Test {
    @TestSetup
    static void makeData(){

        //Usuario SAC General
		User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral){
            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRec');
            camposRecl.put('SAC_AlertasPtes__c', 2);

            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            Database.insert(reclamacion);
    
            //Alertas
            SAC_Alerta__c alerta = SAC_TestDataFactory.crearAlerta(1,reclamacion.id)[0];
            Database.insert(alerta);

            SAC_Alerta__c alerta2 = SAC_TestDataFactory.crearAlerta(1,reclamacion.id)[0];
            alerta2.SAC_Leido__c = true;
            Database.insert(alerta2);
        }
    }
    @isTest
    static void alertaCambioALeidaTest() {
        Case reclamacion = [SELECT Id, SAC_AlertasPtes__c FROM Case];
        SAC_Alerta__c alerta = [SELECT Id, SAC_Leido__c FROM SAC_Alerta__c WHERE SAC_Leido__c = null];
        
        alerta.SAC_Leido__c = true;
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		System.runAs(usuario){
            Test.startTest();
            Database.update(alerta);
            Test.stopTest();
        }
        Case reclamacionResult = [SELECT Id, SAC_AlertasPtes__c FROM Case LIMIT 1];
        System.assertEquals(reclamacion.SAC_AlertasPtes__c - 1, reclamacionResult.SAC_AlertasPtes__c, 'No se ha descontado la alerta leída');
    }

    @isTest
    static void alertaCambioANoLeidaTest() {
        Case reclamacion = [SELECT Id, SAC_AlertasPtes__c FROM Case];
        SAC_Alerta__c alerta = [SELECT Id, SAC_Leido__c FROM SAC_Alerta__c WHERE SAC_Leido__c = true];
        
        alerta.SAC_Leido__c = false;

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		System.runAs(usuario){
            Test.startTest();
            Database.update(alerta);
            Test.stopTest();
        }
        Case reclamacionResult = [SELECT Id, SAC_AlertasPtes__c FROM Case LIMIT 1];
        System.assertEquals(reclamacion.SAC_AlertasPtes__c + 1, reclamacionResult.SAC_AlertasPtes__c, 'No se ha añadido la alerta al quitar el check leída');
    }
}