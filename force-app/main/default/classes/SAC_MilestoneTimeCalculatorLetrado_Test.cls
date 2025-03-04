/*****************************************************************
 * Name: SAC_MilestoneTimeCalculatorLetrado_Test
 * Copyright © 2019  CaixaBank
 * 
 * Proposito: Testear la clase SAC_MilestoneTimeCalculatorLetrado
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US219264         Carlos Solis         07/06/21     Creación
 * 1.1            US643756         Jose Carlos Blanco   05/07/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@isTest
public with sharing class SAC_MilestoneTimeCalculatorLetrado_Test {
    @TestSetup
    static void makeData() {

        User usuarioGeneral;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];     
            SAC_DatabaseDML.insertDML(usuarioGeneral, false);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);
        }

        //MCCs
        String mccDetalleRecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();

        CC_MCC__c mccDetalle = new CC_MCC__c(Name='Prueba', CC_Codigo_Externo__c='a', RecordTypeId=mccDetalleRecordTypeId, CC_Tipo_Cliente__c='SAC');
        SAC_DatabaseDML.upsertDML(mccDetalle, false);
        CC_MCC__c mccDetalle2 = new CC_MCC__c(Name='Prueba2', CC_Codigo_Externo__c='b', RecordTypeId=mccDetalleRecordTypeId, CC_Tipo_Cliente__c='SAC');
        SAC_DatabaseDML.upsertDML(mccDetalle, false);

        //PARAMETRIZACIONES MCC
        SAC_ParametrizacionSLATME__c parametrizacion1  = SAC_TestDataFactory.crearParamsSla('Regulatorio',1)[0];
        parametrizacion1.SAC_Duracion__c = 10;
        parametrizacion1.SAC_MCC__c = mccDetalle.Id;
        parametrizacion1.SAC_CanalProcedencia__c = ''; 
        SAC_DatabaseDML.upsertDML(parametrizacion1, false);

        SAC_ParametrizacionSLATME__c parametrizacion2  = SAC_TestDataFactory.crearParamsSla('Letrado',1)[0];
        parametrizacion2.SAC_Duracion__c = 20;
        parametrizacion2.SAC_MCC__c = mccDetalle2.Id;
        parametrizacion2.SAC_CanalProcedencia__c = ''; 
        SAC_DatabaseDML.upsertDML(parametrizacion2, false);
        
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('SEG_Detalle__c', mccDetalle.id);
        camposRecl.put('SAC_TiempoSLALetradoAlta__c', 1);
        camposRecl.put('OwnerId', usuarioGeneral.id);
      
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        SAC_DatabaseDML.insertDML(casoReclamacion, false);
        
        //Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'prueba');
        camposPret.put('Origin', 'Backoffice');
        camposPret.put('SEG_Detalle__c', mccDetalle.id);
        camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret.put('OwnerId', usuarioGeneral.id);

        Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension', camposPret);
        SAC_DatabaseDML.insertDML(casoPretension, false); 
    }

    @isTest
    static void calculateMilestoneTriggerTimeTest() {
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];

        MilestoneType[] listMilestoneType = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(listMilestoneType.isEmpty()) { 
            return; 
        }
        MilestoneType mt = listMilestoneType[0];
        
        Case casoReclamacion = [SELECT id, RecordTypeId FROM case WHERE SuppliedCompany = 'prueba'];
        SAC_MilestoneTimeCalculatorLetrado calculator = new SAC_MilestoneTimeCalculatorLetrado();

        Integer actualTriggerTime;
        System.runAs(usuario){
            Test.startTest();
            actualTriggerTime = calculator.calculateMilestoneTriggerTime(casoReclamacion.Id, mt.Id);
            Test.stopTest();
        }
        
        System.assertNotEquals(0, actualTriggerTime, 'No se ha podido asociar un tiempo');
    }

    @isTest
    static void calculateMilestoneTriggerTimeTest2() {
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];

        MilestoneType[] listMilestoneType = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(listMilestoneType.isEmpty()) { 
            return; 
        }
        MilestoneType mt = listMilestoneType[0];
        
        Case casoReclamacion = [SELECT id, RecordTypeId, SAC_FechaRecepcion__c FROM case WHERE Subject = 'TestRec'];
        SAC_MilestoneTimeCalculatorLetrado calculator = new SAC_MilestoneTimeCalculatorLetrado();

        Integer actualTriggerTime;
        System.runAs(usuario){
            Test.startTest();
            casoReclamacion.SAC_FechaRecepcion__c = null;
            SAC_DatabaseDML.updateDML(casoReclamacion, false);

            actualTriggerTime = calculator.calculateMilestoneTriggerTime(casoReclamacion.Id, mt.Id);
            Test.stopTest();
        }
        
        System.assertNotEquals(0, actualTriggerTime, 'No se ha podido asociar un tiempo');
    }
}