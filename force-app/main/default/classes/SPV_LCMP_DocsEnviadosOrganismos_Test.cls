@isTest
public with sharing class SPV_LCMP_DocsEnviadosOrganismos_Test {
    @TestSetup
    static void makeData(){
        Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        usuarioAdmin.Username = 'useraadmin@test.com.testdata';
        SPV_DatabaseDML.insertDML(usuarioAdmin, true);

        User usuarioGeneral;
        System.runAs(usuarioAdmin){
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            usuarioGeneral.Username = 'userageneral@test.com.testdata';
            SPV_DatabaseDML.insertDML(usuarioGeneral, true);

            PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
            PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
            permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
            permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
            SPV_DatabaseDML.insertDML(permiSetAssiAdmin, true);
        }
            Test.stopTest();

            List<Case> listaReclamaciones = new List<Case>();
            Case caso = new Case();
            caso.Subject = 'ReclamacionTest';
            caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId();
            listaReclamaciones.add(caso);
            SPV_DatabaseDML.insertListDML(listaReclamaciones, true);
    
            SAC_DocumentoEnvio__c doc = SAC_TestDataFactory.crearDocumentoEnvio(1,caso)[0];
            doc.SAC_Caso__c = caso.id;
            doc.SAC_TipoDocumento__c = 'Alegaciones';
            doc.Name = 'Test';
            doc.SAC_Documento__c='BDE';
            SPV_DatabaseDML.insertDML(doc, true);
    }

    @isTest
    static void getDocsEnviadosOrgTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'userageneral@test.com.testdata' AND IsActive = true LIMIT 1];
        Case caso = [SELECT id  FROM Case WHERE subject = 'ReclamacionTest' limit 1];
        List<SAC_DocumentoEnvio__c> resultado = new List<SAC_DocumentoEnvio__c>();
        Test.startTest();
        System.runAs(usuario) {
            resultado = SPV_LCMP_DocsEnviadosOrganismos.getDocsEnviadosOrg(caso.id);
        }
        Test.stopTest();
        system.assertNotEquals(null , resultado, 'No se ha podido enviar la documentacion');
    }

}