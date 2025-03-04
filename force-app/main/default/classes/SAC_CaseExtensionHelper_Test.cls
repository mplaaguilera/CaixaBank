/*****************************************************************
 * Name: SAC_CaseExtensionHelper_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito_ Test de los Triggers de Case Extension
 * 
****************************************************************/
@isTest
public with sharing class SAC_CaseExtensionHelper_Test {

    
    private static Set<String> objetos = new Set<String>{'CBK_Case_Extension__c', 'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    //Record Type de Case Extension para SAC
    private static final Id RECTYPERECLAMACIONEXTENSION = mapRTsObjects.get('CBK_Case_Extension__c').get('SAC_ReclamacionCaseExt').getRecordTypeId();

    //Record Type de Case 
    private static final Id RECTYPEPRETENSIONCASE = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();

    @TestSetup
    static void makeData(){
        
        Test.startTest();

        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SAC_DatabaseDML.insertDML(usuarioAdmin, true);

        List<User> listUsuarios;
        System.runAs(usuarioAdmin){
            listUsuarios  = SAC_TestDataFactory.crearUsuarioSACGeneral(2);
            SAC_DatabaseDML.insertListDML(listUsuarios, true);
        }

        Test.stopTest();

    }


    @isTest
    static void filtrarCasosSACTest(){

        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        List<CBK_Case_Extension__c> listaResult = new List<CBK_Case_Extension__c>();
        Integer numeroCasos;
        System.runAs(usuario){

            Test.startTest();
            List<CBK_Case_Extension__c> listaCasosExtAdd = new List<CBK_Case_Extension__c>();
            CBK_Case_Extension__c caseExt1 = new CBK_Case_Extension__c();
            CBK_Case_Extension__c caseExt2 = new CBK_Case_Extension__c();
            CBK_Case_Extension__c caseExt3 = new CBK_Case_Extension__c();

            caseExt1.RecordTypeId = RECTYPERECLAMACIONEXTENSION;
            caseExt2.RecordTypeId = RECTYPEPRETENSIONCASE;
            caseExt3.RecordTypeId = RECTYPERECLAMACIONEXTENSION;

            listaCasosExtAdd.add(caseExt1);
            listaCasosExtAdd.add(caseExt2);
            listaCasosExtAdd.add(caseExt3);

            listaResult = SAC_CaseExtensionHelper.filtrarCasosSAC(listaCasosExtAdd);
            numeroCasos = listaResult.size();
            Test.stopTest();

        }

        Assert.areEqual(numeroCasos, 2, 'No se han filtrado los casos correctamente');
    }

}