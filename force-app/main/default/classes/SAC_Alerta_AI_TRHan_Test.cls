@isTest
public with sharing class SAC_Alerta_AI_TRHan_Test {
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

            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            Database.insert(reclamacion);
        }
    }
    @isTest
    static void sumarContadorAlertaTest() {
        Case reclamacion = [SELECT Id, SAC_AlertasPtes__c FROM Case];
        SAC_Alerta__c alerta = SAC_TestDataFactory.crearAlerta(1,reclamacion.id)[0];

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		System.runAs(usuario){
            Test.startTest();
            Database.insert(alerta);
            Test.stopTest();
        }

        Case reclamacionResult = [SELECT Id, SAC_AlertasPtes__c FROM Case LIMIT 1];

        System.assertEquals(1, reclamacionResult.SAC_AlertasPtes__c, 'No se ha añadido la alerta al contador de alertas pendientes');
    }
}