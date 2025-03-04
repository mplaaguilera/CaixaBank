/*****************************************************************
 * Name: SAC_MilTimeCalcEstadosReclamacion_Test
 * Copyright © 2019  CaixaBank
 * 
 * Proposito: Testear la clase SAC_MilTimeCalcEstadosReclamacion
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US200213         Carlos Solis         21/04/21     Creación
 * 1.1            US643756         Jose Carlos Blanco   05/07/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@isTest
public with sharing class SAC_MilTimeCalcEstadosReclamacion_Test {
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

        //Reclamación Alta
        Map<String, Object> camposReclAlta = new Map<String, Object>();
        camposReclAlta.put('Subject', 'TestRec');
        camposReclAlta.put('Origin', 'Backoffice');
        camposReclAlta.put('Status', 'SAC_001');
        camposReclAlta.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposReclAlta.put('OwnerId', usuarioGeneral.id);
      
        Case casoReclamacionAlta = SAC_TestDataFactory.crearCaso('Reclamacion', camposReclAlta);

        //Reclamación Análisis
        Map<String, Object> camposReclAnalisis = new Map<String, Object>();
        camposReclAnalisis.put('Subject', 'TestRec2');
        camposReclAnalisis.put('Origin', 'Backoffice');
        camposReclAnalisis.put('Status', 'SAC_002');
        camposReclAnalisis.put('SAC_StatusAuxiliar__c', 'SAC_002');
        camposReclAnalisis.put('OwnerId', usuarioGeneral.id);
      
        Case casoReclamacionAnalisis = SAC_TestDataFactory.crearCaso('Reclamacion', camposReclAnalisis);

        //Reclamación Redacción
        Map<String, Object> camposReclRed = new Map<String, Object>();
        camposReclRed.put('Subject', 'TestRec3');
        camposReclRed.put('Origin', 'Backoffice');
        camposReclRed.put('Status', 'SAC_003');
        camposReclRed.put('SAC_StatusAuxiliar__c', 'SAC_003');
        camposReclRed.put('OwnerId', usuarioGeneral.id);
      
        Case casoReclamacionRedaccion = SAC_TestDataFactory.crearCaso('Reclamacion', camposReclRed);

        //Reclamación Ejecución
        Map<String, Object> camposReclEjec = new Map<String, Object>();
        camposReclEjec.put('Subject', 'TestRec4');
        camposReclEjec.put('Origin', 'Backoffice');
        camposReclEjec.put('Status', 'SAC_004');
        camposReclEjec.put('SAC_StatusAuxiliar__c', 'SAC_004');
        camposReclEjec.put('OwnerId', usuarioGeneral.id);
      
        Case casoReclamacionEjecucion = SAC_TestDataFactory.crearCaso('Reclamacion', camposReclEjec);

        //Reclamación Subsanación
        Map<String, Object> camposReclSub = new Map<String, Object>();
        camposReclSub.put('Subject', 'TestRec5');
        camposReclSub.put('Origin', 'Backoffice');
        camposReclSub.put('Status', 'SAC_006');
        camposReclSub.put('SAC_StatusAuxiliar__c', 'SAC_006');
        camposReclSub.put('OwnerId', usuarioGeneral.id);
      
        Case casoReclamacionSubsanacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposReclSub);

        //Reclamación Negociación
        Map<String, Object> camposReclNeg = new Map<String, Object>();
        camposReclNeg.put('Subject', 'TestRec6');
        camposReclNeg.put('Origin', 'Backoffice');
        camposReclNeg.put('Status', 'SAC_007');
        camposReclNeg.put('SAC_StatusAuxiliar__c', 'SAC_007');
        camposReclNeg.put('OwnerId', usuarioGeneral.id);
      
        Case casoReclamacionNegociacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposReclNeg);

        //Pretensión
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('Subject', 'TestPret');
        camposPret.put('Origin', 'Backoffice');
        camposPret.put('Status', 'SAC_007');
        camposPret.put('SAC_StatusAuxiliar__c', 'SAC_007');
        camposPret.put('OwnerId', usuarioGeneral.id);
      
        Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension', camposPret);

        List<Case> listaCasos = new List<Case>();
        listaCasos.add(casoReclamacionAlta);
        listaCasos.add(casoReclamacionAnalisis);
        listaCasos.add(casoPretension);
        listaCasos.add(casoReclamacionRedaccion);
        listaCasos.add(casoReclamacionEjecucion);
        listaCasos.add(casoReclamacionSubsanacion);
        listaCasos.add(casoReclamacionNegociacion);

        SAC_DatabaseDML.insertListDML(listaCasos, false);
    }

    @isTest
    static void calculateMilestoneTriggerTimeAltaTest() {
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];

        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(mtLst.isEmpty()) { return; }
        MilestoneType mt = mtLst[0];
        
        Case casoReclamacionAlta = [SELECT id, RecordTypeId from case where subject = 'TestRec'];
        SAC_MilTimeCalcEstadosReclamacion calculator = new SAC_MilTimeCalcEstadosReclamacion();
        
        Integer actualTriggerTime;
        System.runAs(usuario){
            Test.startTest();
            actualTriggerTime = calculator.calculateMilestoneTriggerTime(casoReclamacionAlta.Id, mt.Id);
            Test.stopTest();
        }
        System.assertEquals(320, actualTriggerTime, 'No se cumple el estado Alta');
    }

    @isTest
    static void calculateMilestoneTriggerTimeAnalisisTest() {
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];

        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(mtLst.isEmpty()) { return; }
        MilestoneType mt = mtLst[0];
        
        Case casoReclamacionAnalisis = [SELECT id, RecordTypeId from case where subject = 'TestRec2'];
        SAC_MilTimeCalcEstadosReclamacion calculator = new SAC_MilTimeCalcEstadosReclamacion();
        
        Integer actualTriggerTime;
        System.runAs(usuario){
            Test.startTest();
            actualTriggerTime = calculator.calculateMilestoneTriggerTime(casoReclamacionAnalisis.Id, mt.Id);
            Test.stopTest();
        }
        System.assertEquals(320, actualTriggerTime, 'No se cumple el estado Análisis');
    }

    @isTest
    static void calculateMilestoneTriggerTimeNegativeTest() {
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];

        MilestoneType[] listMilestoneType = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(listMilestoneType.isEmpty()) { return; }
        MilestoneType mt = listMilestoneType[0];

        Case casoPretension = [SELECT id, RecordTypeId from case where subject = 'TestPret'];
        SAC_MilTimeCalcEstadosReclamacion calculator = new SAC_MilTimeCalcEstadosReclamacion();
        
        Integer actualTriggerTime;
        System.runAs(usuario){
            Test.startTest();
            actualTriggerTime = calculator.calculateMilestoneTriggerTime(casoPretension.Id, mt.Id);
            Test.stopTest();
        }  
        System.assertEquals(1, actualTriggerTime, 'El recordType no es diferente a Reclamación');
    }

    @isTest
    static void calculateMilestoneTriggerTimeRedaccionTest() {
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];

        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(mtLst.isEmpty()) { return; }
        MilestoneType mt = mtLst[0];
        
        Case casoReclamacionRedaccion = [SELECT id, RecordTypeId from case where subject = 'TestRec3'];
        SAC_MilTimeCalcEstadosReclamacion calculator = new SAC_MilTimeCalcEstadosReclamacion();
        
        Integer actualTriggerTime;
        System.runAs(usuario){
            Test.startTest();
            actualTriggerTime = calculator.calculateMilestoneTriggerTime(casoReclamacionRedaccion.Id, mt.Id);
            Test.stopTest();
        }

        System.assertEquals(320, actualTriggerTime, 'No se cumple el estado Redacción');
    }

    @isTest
    static void calculateMilestoneTriggerTimeEjecucionTest() {
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];

        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(mtLst.isEmpty()) { return; }
        MilestoneType mt = mtLst[0];
        
        Case casoReclamacionEjecucion = [SELECT id, RecordTypeId from case where subject = 'TestRec4'];
        SAC_MilTimeCalcEstadosReclamacion calculator = new SAC_MilTimeCalcEstadosReclamacion();
        
        Integer actualTriggerTime;
        System.runAs(usuario){
            Test.startTest();
            actualTriggerTime = calculator.calculateMilestoneTriggerTime(casoReclamacionEjecucion.Id, mt.Id);
            Test.stopTest();
        }
        System.assertEquals(320, actualTriggerTime, 'No se cumple el estado Ejecución');
    }

    @isTest
    static void calculateMilestoneTriggerTimeSubsanacionTest() {
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];

        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(mtLst.isEmpty()) { return; }
        MilestoneType mt = mtLst[0];
        
        Case casoReclamacionSubsanacion = [SELECT id, RecordTypeId from case where subject = 'TestRec5'];
        SAC_MilTimeCalcEstadosReclamacion calculator = new SAC_MilTimeCalcEstadosReclamacion();
        
        Integer actualTriggerTime;
        System.runAs(usuario){
            Test.startTest();
            actualTriggerTime = calculator.calculateMilestoneTriggerTime(casoReclamacionSubsanacion.Id, mt.Id);
            Test.stopTest();
        }
        System.assertEquals(320, actualTriggerTime, 'No se cumple el estado Subsanación');
    }

    @isTest
    static void calculateMilestoneTriggerTimeNegociacionTest() {
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];

        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(mtLst.isEmpty()) { return; }
        MilestoneType mt = mtLst[0];
        
        Case casoReclamacionNegociacion = [SELECT id, RecordTypeId from case where subject = 'TestRec6'];
        SAC_MilTimeCalcEstadosReclamacion calculator = new SAC_MilTimeCalcEstadosReclamacion();
        
        Integer actualTriggerTime;
        System.runAs(usuario){
            Test.startTest();
            actualTriggerTime = calculator.calculateMilestoneTriggerTime(casoReclamacionNegociacion.Id, mt.Id);
            Test.stopTest();
        }
        System.assertEquals(320, actualTriggerTime, 'No se cumple el estado Negociación');
    }
}