@isTest
public with sharing class SPV_AlertaBUTRHan_Test {
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
            camposRecl.put('SAC_AlertasPtes__c', 2);

            reclamacion = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            Database.insert(reclamacion);
        }
        
        system.runAs(listaUsersAdmin[0]) {
            //Cambiar owner de la reclamación
            reclamacion.OwnerId = usuarioGeneral.Id;
            Database.update(reclamacion);
            
        }
        
        System.runAs(usuarioGeneral){
            //Alertas
            SAC_Alerta__c alerta = new SAC_Alerta__c(
                SAC_Reclamacion__c = reclamacion.Id,
                RecordTypeId = Schema.SObjectType.SAC_Alerta__c.getRecordTypeInfosByDeveloperName().get('SPV_Alerta').getRecordTypeId()
            );
            Database.insert(alerta);

            SAC_Alerta__c alerta2 = new SAC_Alerta__c(
                SAC_Reclamacion__c = reclamacion.Id,
                RecordTypeId = Schema.SObjectType.SAC_Alerta__c.getRecordTypeInfosByDeveloperName().get('SPV_Alerta').getRecordTypeId(),
                SAC_Leido__c = true
            );
            Database.insert(alerta2);
        }
    }
    @isTest
    static void alertaCambioALeidaTest() {
        Case reclamacion = [SELECT Id, SAC_AlertasPtes__c FROM Case];
        SAC_Alerta__c alerta = [SELECT Id, SAC_Leido__c FROM SAC_Alerta__c WHERE SAC_Leido__c = null];
        
        alerta.SAC_Leido__c = true;
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true LIMIT 1];
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

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true LIMIT 1];
		System.runAs(usuario){
            Test.startTest();
            Database.update(alerta);
            Test.stopTest();
        }
        Case reclamacionResult = [SELECT Id, SAC_AlertasPtes__c FROM Case LIMIT 1];
        System.assertEquals(reclamacion.SAC_AlertasPtes__c + 1, reclamacionResult.SAC_AlertasPtes__c, 'No se ha añadido la alerta al quitar el check leída');
    }
}