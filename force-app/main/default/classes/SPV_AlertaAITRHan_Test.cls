@isTest
public with sharing class SPV_AlertaAITRHan_Test {
    @TestSetup
    static void makeData(){

        //Usuario SPV General
		User usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
        Database.insert(usuarioGeneral);
        
        List<User> listaUsersAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1);
        Database.insert(listaUsersAdmin);
        
        Case reclamacion = new Case();

        System.runAs(usuarioGeneral){
            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRec');

            reclamacion = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            Database.insert(reclamacion);
        }
        
        system.runAs(listaUsersAdmin[0]) {
            //Cambiar owner de la reclamación
            reclamacion.OwnerId = usuarioGeneral.Id;
            Database.update(reclamacion);
        }
    }
    @isTest
    static void sumarContadorAlertaTest() {
        Case reclamacion = [SELECT Id, SAC_AlertasPtes__c FROM Case];
        SAC_Alerta__c alerta = new SAC_Alerta__c(
                SAC_Reclamacion__c = reclamacion.Id,
                RecordTypeId = Schema.SObjectType.SAC_Alerta__c.getRecordTypeInfosByDeveloperName().get('SPV_Alerta').getRecordTypeId()
            );

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true LIMIT 1];
		System.runAs(usuario){
            Test.startTest();
            Database.insert(alerta);
            Test.stopTest();
        }

        Case reclamacionResult = [SELECT Id, SAC_AlertasPtes__c FROM Case LIMIT 1];

        System.assertEquals(1, reclamacionResult.SAC_AlertasPtes__c, 'No se ha añadido la alerta al contador de alertas pendientes');
    }
}