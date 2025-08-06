/*****************************************************************
 * Name: SAC_CaseExtension_AU_TRHan_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito_ Test de los Triggers de Case Extension AU
 * 
****************************************************************/
@isTest
public with sharing class SAC_CaseExtension_AU_TRHan_Test {
    private static Set<String> objetos = new Set<String>{'CBK_Case_Extension__c', 'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    //Record Type de Case Extension para SAC
    private static final Id RECTYPERECLAMACIONEXTENSION = mapRTsObjects.get('CBK_Case_Extension__c').get('SAC_ReclamacionCaseExt').getRecordTypeId();

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

        //Case Extension
        CBK_Case_Extension__c caseExt = new CBK_Case_Extension__c();
        caseExt.RecordTypeId = RECTYPERECLAMACIONEXTENSION;
        caseExt.Name = 'NombrePrueba1';
        SAC_DatabaseDML.insertDML(caseExt, false);

        //Reclamacion
        Map<String, Object> camposReclamacion = new Map<String, Object>();
        camposReclamacion.put('Subject', 'TestRec PteAsignar');
        camposReclamacion.put('Origin', 'Backoffice');
        camposReclamacion.put('Status', 'SAC_001');
        camposReclamacion.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposReclamacion.put('CBK_Case_Extension_Id__c', caseExt.Id);

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposReclamacion);
        SAC_DatabaseDML.insertDML(reclamacion, false);
        





        Test.stopTest();
    }



    @isTest
    static void actualizarCaseExtensionTest(){

        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        CBK_Case_Extension__c caseExt = [SELECT Id, Name FROM CBK_Case_Extension__c WHERE Name = 'NombrePrueba1'];
        
        System.runAs(usuario){
            Test.startTest();
                caseExt.Name = 'PruebaCambiada';
                SAC_DatabaseDML.updateDML(caseExt, false);
            Test.stopTest();
        }

        CBK_Case_Extension__c caseExtResult = [SELECT Id, Name FROM CBK_Case_Extension__c WHERE Name = 'PruebaCambiada'];
        Assert.areNotEqual(null, caseExtResult, 'No se ha actualizado correctamente');

    }
}