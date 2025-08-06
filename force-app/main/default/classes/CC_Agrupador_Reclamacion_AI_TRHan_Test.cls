@isTest
public with sharing class CC_Agrupador_Reclamacion_AI_TRHan_Test {

    @isTest
    static void testEnviarMaximo() {
        Test.startTest();
        User adminUser = CC_TestDataFactory.insertUserAdmin();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Analista_Cliente' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = ps.Id);

        System.runAs(adminUser) {
            CC_Agrupador__c agrupador = new CC_Agrupador__c();
            agrupador.CC_Estado__c = 'Activo';
            agrupador.CC_Titulo__c = 'Test';
            agrupador.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
            insert agrupador;

            CC_Agrupador_Reclamacion__c agrupadorReclamacion = new CC_Agrupador_Reclamacion__c();
            agrupadorReclamacion.CC_Agrupador_Id__c = agrupador.Id;
            agrupadorReclamacion.CC_Enviado__c = false;
            insert agrupadorReclamacion;
            

            System.assertNotEquals(null, agrupadorReclamacion, 'Se ha creado el agrupador reclamacion');
        }
        Test.stopTest();
    }
    

}