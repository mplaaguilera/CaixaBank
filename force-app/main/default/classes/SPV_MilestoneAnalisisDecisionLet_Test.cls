/*****************************************************************
 * Name: SPV_MilestoneAnalisisDecisionLet_Test
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Testear la clase SPV_MilestoneAnalisisDecisionLetrado
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US1208700       Sergio Martín        21/05/25        Creación
*****************************************************************/
@istest
public with sharing class SPV_MilestoneAnalisisDecisionLet_Test {
    @TestSetup
    static void makeData(){
        
       Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        usuarioAdmin.Username = 'useraadmin@test.com.testdata';
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);

        User usuarioGeneral;
        System.runAs(usuarioAdmin){
            //Usuario SPV General
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            usuarioGeneral.Username = 'userageneral@test.com.testdata';
            SAC_DatabaseDML.insertDML(usuarioGeneral, false);
        }


        //Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('Subject', 'TestPret');
        camposPret.put('Origin', 'Backoffice');
    
        Case casoPretension = SPV_TestDataFactory.crearCaso('Pretension', camposPret);
        SAC_DatabaseDML.insertDML(casoPretension, false);

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'SPV_AnalisisDecision');
        camposRecl.put('SPV_EscaladoAJ__c', true);
        camposRecl.put('SPV_DiasProrroga__c', 12);
        camposRecl.put('SAC_PretensionPrincipal__c', casoPretension.id);
    
        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        SAC_DatabaseDML.insertDML(casoReclamacion, false);

        //Reclamacion
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('Origin', 'Backoffice');
        camposRecl2.put('SPV_Organismo__c', 'SPV_Consumo');
        camposRecl2.put('SPV_DiasProrroga__c', 12);
        camposRecl2.put('Status', 'SPV_AnalisisDecision');
        camposRecl2.put('SPV_EscaladoAJ__c', true);
        camposRecl2.put('SAC_FechaVencimientoSLA__c', CBK_UtilsDate.nowSYS());
        camposRecl2.put('SAC_PretensionPrincipal__c', casoPretension.id);
    
        Case casoReclamacion2 = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl2);
        SAC_DatabaseDML.insertDML(casoReclamacion2, false);
    }

    @istest
    static void testMilestoneAnalisisDecisionLet(){
        User usuario = [SELECT id FROM User WHERE username = 'userageneral@test.com.testdata' and IsActive = true limit 1];

        MilestoneType[] listMilestoneType = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(listMilestoneType.isEmpty()) { 
            return; 
        }

        MilestoneType mt = listMilestoneType[0];
        
        Case casoReclamacion = [SELECT id, RecordTypeId, SAC_Reclamacion__c from case where subject = 'TestRec'];

        SPV_MilestoneAnalisisDecisionLetrado calculator = new SPV_MilestoneAnalisisDecisionLetrado();

        Integer actualTriggerTime;
        System.runAs(usuario){
            Test.startTest();
            actualTriggerTime = calculator.calculateMilestoneTriggerTime(casoReclamacion.Id, mt.Id);
            Test.stopTest();
        }

        System.assertNotEquals(0, actualTriggerTime, 'No se ha podido asociar un tiempo');
    }

    @istest
    static void testMilestoneAnalisisDecisionLet2(){
        User usuario = [SELECT id FROM User WHERE username = 'userageneral@test.com.testdata' and IsActive = true limit 1];

        MilestoneType[] listMilestoneType = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(listMilestoneType.isEmpty()) { 
            return; 
        }

        MilestoneType mt = listMilestoneType[0];
        
        Case casoReclamacion = [SELECT id, RecordTypeId, SAC_Reclamacion__c from case where subject = 'TestRec2'];

        SPV_MilestoneAnalisisDecisionLetrado calculator = new SPV_MilestoneAnalisisDecisionLetrado();

        Integer actualTriggerTime;
        System.runAs(usuario){
            Test.startTest();
            actualTriggerTime = calculator.calculateMilestoneTriggerTime(casoReclamacion.Id, mt.Id);
            Test.stopTest();
        }

        System.assertNotEquals(0, actualTriggerTime, 'No se ha podido asociar un tiempo');
    }
}