/*****************************************************************
 * Name: SAC_MilestoneTimeCalculator_Test
 * Copyright © 2019  CaixaBank
 * 
 * Proposito: Testear la clase SAC_MilestoneTimeCalculator
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US200213         Carlos Solis   21/04/21     Creación
*****************************************************************/
@isTest
public with sharing class SAC_MilestoneTimeCalculator_Test {
    @TestSetup
    static void makeData() {

        //Usuario SAC Admin
		User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        usuarioGeneral.Username = 'usertestadmin@test.com.testSetup';      
        SAC_DatabaseDML.insertDML(usuarioGeneral, false);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        System.runAs(usuarioGeneral){
            List<Case> listaReclamaciones = new List<Case>();

            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRec');
            camposRecl.put('Origin', 'Backoffice');
            Case reclamacion1 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            listaReclamaciones.add(reclamacion1);


            Map<String, Object> camposRec2 = new Map<String, Object>();
            camposRec2.put('Subject', 'TestRec2');
            camposRec2.put('Origin', 'Backoffice');
            camposRec2.put('SAC_Prorrogado__c', true);
            Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRec2);
            listaReclamaciones.add(reclamacion2);


            Map<String, Object> camposRec3 = new Map<String, Object>();
            camposRec3.put('Subject', 'TestRec3');
            camposRec3.put('Origin', 'Backoffice');
            camposRec3.put('SAC_Prorrogado__c', true);
            camposRec3.put('SAC_TiempoSLARegulatorio__c', 2);
            Case reclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRec3);
            listaReclamaciones.add(reclamacion3);

            SAC_DatabaseDML.insertListDML(listaReclamaciones, false);


            List<Case> pretensiones = new List<Case>();

            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('Origin', 'Backoffice');
            camposPret.put('SAC_Reclamacion__c', reclamacion1.Id);
            Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
            pretensiones.add(pretension);

            SAC_DatabaseDML.insertListDML(pretensiones, false);
        } 
    }

    @isTest
    static void calculateMilestoneTriggerTimeTest() {
        User usuarioGeneral = [SELECT id, name, UserRole.name FROM user WHERE Username = 'usertestadmin@test.com.testSetup' AND IsActive = true LIMIT 1];
        MilestoneType[] listMilestoneType = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(listMilestoneType.isEmpty()) { return; }
        MilestoneType mt = listMilestoneType[0];
        
        Case casoReclamacion = [SELECT id, RecordTypeId FROM case WHERE subject = 'TestRec'];
        SAC_MilestoneTimeCalculator calculator = new SAC_MilestoneTimeCalculator();
        Integer actualTriggerTime;

        System.runAs(usuarioGeneral){
            Test.startTest();
            actualTriggerTime = calculator.calculateMilestoneTriggerTime(casoReclamacion.Id, mt.Id);
            Test.stopTest();
        }
        
        
        System.assertNotEquals(0, actualTriggerTime, 'No se ha calculado el sla');
    }

    @isTest
    static void calculateMilestoneTriggerTime3Test() {
        User usuarioGeneral = [SELECT id, name, UserRole.name FROM user WHERE Username = 'usertestadmin@test.com.testSetup' AND IsActive = true LIMIT 1];
        MilestoneType[] listMilestoneType = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(listMilestoneType.isEmpty()) { return; }
        MilestoneType mt = listMilestoneType[0];
        
        Case casoReclamacion = [SELECT id, RecordTypeId, SAC_TiempoSLARegulatorio__c, SAC_Prorrogado__c FROM case WHERE subject = 'TestRec3'];
        SAC_MilestoneTimeCalculator calculator = new SAC_MilestoneTimeCalculator();
        Integer actualTriggerTime;

        System.runAs(usuarioGeneral){
            Test.startTest();
            actualTriggerTime = calculator.calculateMilestoneTriggerTime(casoReclamacion.Id, mt.Id);
            Test.stopTest();
        }
        
        System.assertNotEquals(0, actualTriggerTime, 'El recordType no es de tipo Reclamación');
    }
}