/*****************************************************************
 * Name: SPV_MilestonePlazoRegCompleOrganismoTest
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de SPV_MilestonePlazoRegCompleOrganismo
 * 
****************************************************************/
/**
*   @description SPV_MilestonePlazoRegCompleOrganismoTest
*/
@isTest
public with sharing class SPV_MilestonePlazoRegCompleOrganismoTest {
    
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
            //Database.insert(usuarioGeneral);
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
        camposRecl.put('SAC_PretensionPrincipal__c', casoPretension.id);
    
        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        SAC_DatabaseDML.insertDML(casoReclamacion, false);

        //Case extension
        Case reclamacionAniadida = [SELECT Id, CBK_Case_Extension_Id__c FROM Case WHERE Id = :casoReclamacion.Id];
        CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
        caseExtension.Id = reclamacionAniadida.CBK_Case_Extension_Id__c;
        caseExtension.SPV_FechaVencimientoPlazoRegOrganismo__c = CBK_UtilsDate.todayDT();

        SPV_DatabaseDML.updateDML(caseExtension, true);
    }

    @isTest
    static void testMilestonePlazoRegCompleOrganismo(){
        User usuario = [SELECT id FROM User WHERE username = 'userageneral@test.com.testdata' and IsActive = true limit 1];

        MilestoneType[] listMilestoneType = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(listMilestoneType.isEmpty()) { 
            return; 
        }

        MilestoneType mt = listMilestoneType[0];
        
        Case casoReclamacion = [SELECT id, RecordTypeId, SAC_Reclamacion__c from case where subject = 'TestRec'];

        SPV_MilestonePlazoRegCompleOrganismo calculator = new SPV_MilestonePlazoRegCompleOrganismo();

        Integer actualTriggerTime;
        System.runAs(usuario){
            Test.startTest();
            actualTriggerTime = calculator.calculateMilestoneTriggerTime(casoReclamacion.Id, mt.Id);
            Test.stopTest();
        }

        System.assertNotEquals(0, actualTriggerTime, 'No se ha podido asociar un tiempo');
    }

}