@isTest
public with sharing class SAC_DatabaseDML_Test {
    @TestSetup
    static void makeData(){
        User usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        usuario.Username = 'ustestesteo@test.com'; 
        SAC_DatabaseDML.insertDML(usuario, false);      
        //Database.insert(usuario);


        //RECLAMACION 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'Alta');
        camposRecl.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl.put('OwnerId', usuario.Id);
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(casoReclamacion, false);  
        //Database.insert(casoReclamacion);
    }


    @isTest
    static void insertDMLTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        System.runAs(usuario){
            SAC_Interaccion__c interaccion = new SAC_Interaccion__c();
            interaccion.SAC_Titulo__c = 'testConsulta';
            interaccion.SAC_Propuesta__c = 'testConsulta';
            interaccion.SAC_Reclamacion__c = reclamacion.Id;
            interaccion.recordTypeId = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
            SAC_DatabaseDML.insertDML(interaccion, true);
        }

        Test.stopTest();

        SAC_Interaccion__c interaccionResultado = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testConsulta'];
        Assert.areNotEqual(null, interaccionResultado.Id, 'No se ha podido insertar la interaccion');
    }

    @isTest
    static void updateDMLTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id, Origin FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        System.runAs(usuario){
            reclamacion.Origin = 'Email';
            SAC_DatabaseDML.updateDML(reclamacion, true);
        }

        Test.stopTest();

        Case reclamacionResultado = [SELECT Id, Origin FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Assert.areEqual('Email', reclamacionResultado.Origin, 'No se ha podido actualizar la reclamacion');
    }
    
    @isTest
    static void upsertDMLTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id, Origin FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        System.runAs(usuario){
            reclamacion.Origin = 'Email';
            SAC_DatabaseDML.upsertDML(reclamacion, true);
        }

        Test.stopTest();

        Case reclamacionResultado = [SELECT Id, Origin FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Assert.areEqual('Email', reclamacionResultado.Origin, 'No se ha podido actualizar la reclamacion');
    }
    
    @isTest
    static void deletDMLTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id, Origin FROM Case WHERE Subject = 'TestRec' and Origin = 'Backoffice' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        System.runAs(usuario){
            SAC_DatabaseDML.deleteDML(reclamacion, true);
        }

        Test.stopTest();

        List<Case> lstResult = [SELECT Id, Origin FROM Case WHERE Subject = 'TestRec' and Origin = 'Backoffice'];
        Assert.isTrue(lstResult.isEmpty(), 'No existe la reclamación');
    }
}