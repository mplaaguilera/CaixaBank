/***************************************************************************
 * Name: SAC_ProrrogaAutomatica_Test.cls
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Probar la clase SAC_ProrrogaAutomatica
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR           DATE         Description
 * 1.0            US568372      Raul y Sergio      18/05/2023     Creación
 * 1.1            US568372      Carlos Gómez       18/05/2023     Modificado (TestDataFactory)
***************************************************************************/

@isTest
public with sharing class SAC_ProrrogaAutomatica_Test {
   
    @TestSetup
    static void makeData() {
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];   
        SAC_DatabaseDML.insertDML(usuarioGeneral, false);   
        //Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false); 
        //Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral){
        Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
        cuenta.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Generico').getRecordTypeId();
        SAC_DatabaseDML.insertDML(cuenta, false); 
        //Database.insert(cuenta);
        
        Entitlement entitle = SAC_TestDataFactory.crearEntitlement(cuenta.id);
        SAC_DatabaseDML.insertDML(entitle, false); 
        //Database.insert(entitle);

        CC_MCC__c mcc = new CC_MCC__c();
        mcc.Name = 'PSD2';
        mcc.SAC_EsPsd2__c = true;
        mcc.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        SAC_DatabaseDML.insertDML(mcc, false); 
        //Database.insert(mcc);

  
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec2');
        camposRecl.put('Origin','Backoffice');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('AccountId', cuenta.Id);
        camposRecl.put('OwnerId', usuarioGeneral.id);
        camposRecl.put('SAC_ProrrogaCounter__c', 0);
        camposRecl.put('RecordTypeId', Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId());
        camposRecl.put('SAC_Prorrogado__c', false);
        camposRecl.put('OS_Email__c', 'Test@test.com');
        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        SAC_DatabaseDML.insertDML(casoReclamacion2, false); 
        //Database.insert(casoReclamacion2);

        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'TestPret1');
        camposPret.put('Origin', 'Backoffice');
        camposPret.put('Status', 'SAC_001');
        camposPret.put('OwnerId', usuarioGeneral.id);
        camposPret.put('SAC_Reclamacion__c', casoReclamacion2.Id);
        camposPret.put('RecordTypeId', Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId());
        camposPret.put('SEG_Detalle__c', mcc.Id);
        camposPret.put('SAC_CASE_esPSD2__c', true);
        Case pretension1 = SAC_TestDataFactory.crearCaso('Pretension', camposPret);
        SAC_DatabaseDML.insertDML(pretension1, false); 
        //Database.insert(pretension1);
        }  
    }

    @isTest
    static void testProrroga() {
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
       
        System.runAs(usuarioGeneral){
        Test.startTest();
        Case casoP = [SELECT Id, OS_Alerta_Descripcion__c,SAC_FechaRecepcion__c, OS_Email__c FROM case WHERE Subject = 'TestRec2' LIMIT 1];
        casoP.SAC_FechaRecepcion__c = system.now().addDays(-2);
        casoP.OS_Email__c = 'Test@test.com';
        SAC_DatabaseDML.updateDML(casoP, false); 
        //Database.update(casoP);
        
        SAC_ProrrogaAutomatica obj = new SAC_ProrrogaAutomatica();
        DataBase.executeBatch(obj); 
        Test.stopTest();
        
        List<Case> casosProrrogados = [SELECT Id, OS_Alerta_Descripcion__c, SAC_Prorrogado__c FROM case WHERE Subject = 'TestRec2' LIMIT 1];
        system.assertEquals(true, casosProrrogados[0].SAC_Prorrogado__c, 'No se ha prorrogado correctamente');
        }
    }

    @isTest
    static void testProrroga2() {
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
       
        System.runAs(usuarioGeneral){
        Test.startTest();
        Case casoP = [SELECT Id, OS_Alerta_Descripcion__c,SAC_FechaRecepcion__c, OS_Email__c FROM case WHERE Subject = 'TestRec2' LIMIT 1];
        casoP.SAC_FechaRecepcion__c = system.now().addDays(-2);
        casoP.OS_Email__c = '';
        SAC_DatabaseDML.updateDML(casoP, false); 
        //Database.update(casoP);
        
        SAC_ProrrogaAutomatica obj = new SAC_ProrrogaAutomatica();
        DataBase.executeBatch(obj); 
        Test.stopTest();
        
        List<Case> casosProrrogados = [SELECT Id, OS_Alerta_Descripcion__c, SAC_Prorrogado__c, CBK_Case_Extension_Id__c, CBK_Case_Extension_Id__r.SAC_PendienteEnvioProrroga__c FROM case WHERE Subject = 'TestRec2' LIMIT 1];
        system.assertEquals(true, casosProrrogados[0].CBK_Case_Extension_Id__r.SAC_PendienteEnvioProrroga__c, 'No se ha prorrogado correctamente');
        }
    }
}