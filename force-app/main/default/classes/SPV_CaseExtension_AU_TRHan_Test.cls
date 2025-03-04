/*****************************************************************
 * Name: SPV_CaseExtension_BU_TRHan_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito_ Test de los Triggers de Case Extension AU
 * 
****************************************************************/
@isTest
public with sharing class SPV_CaseExtension_AU_TRHan_Test {

    private static Set<String> objetos = new Set<String>{'CBK_Case_Extension__c', 'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    //Record Type de Case Extension para SPV
    private static final Id RECTYPERECLAMACIONEXTENSION = mapRTsObjects.get('CBK_Case_Extension__c').get('SPV_ReclamacionCaseExt').getRecordTypeId();

    @TestSetup
    static void makeData(){

        Test.startTest();

        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SPV_DatabaseDML.insertDML(usuarioAdmin, true);

        List<User> listUsuarios;
        System.runAs(usuarioAdmin){
            listUsuarios  = SPV_TestDataFactory.crearUsuarioSPVGeneral(2);
            SPV_DatabaseDML.insertListDML(listUsuarios, true);
        }

        //Case Extension
        CBK_Case_Extension__c caseExt = new CBK_Case_Extension__c();
        caseExt.RecordTypeId = RECTYPERECLAMACIONEXTENSION;
        caseExt.Name = 'NombrePrueba1';
        SPV_DatabaseDML.insertDML(caseExt, false);

        //Reclamacion
        Map<String, Object> camposReclamacion = new Map<String, Object>();
        camposReclamacion.put('Subject', 'TestRec PteAsignar');
        camposReclamacion.put('Origin', 'Backoffice');
        camposReclamacion.put('Status', 'SAC_001');
        camposReclamacion.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposReclamacion.put('CBK_Case_Extension_Id__c', caseExt.Id);

        Case reclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion);
        SPV_DatabaseDML.insertDML(reclamacion, false);

        Test.stopTest();
    }



    @isTest
    static void actualizarCaseExtensionTest(){

        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        CBK_Case_Extension__c caseExt = [SELECT Id, Name FROM CBK_Case_Extension__c WHERE Name = 'NombrePrueba1'];
        
        System.runAs(usuario){
            Test.startTest();
                caseExt.Name = 'PruebaCambiada';
                SPV_DatabaseDML.updateDML(caseExt, false);
            Test.stopTest();
        }

        CBK_Case_Extension__c caseExtResult = [SELECT Id, Name FROM CBK_Case_Extension__c WHERE Name = 'PruebaCambiada'];
        Assert.areNotEqual(null, caseExtResult, 'No se ha actualizado correctamente');

    }

}