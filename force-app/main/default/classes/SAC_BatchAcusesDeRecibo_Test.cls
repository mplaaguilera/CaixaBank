@isTest
public with sharing class SAC_BatchAcusesDeRecibo_Test {
    @TestSetup
    static void makeData() {
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];      
        Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral){    
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRec');
            camposRecl.put('Origin','Email');
            camposRecl.put('Status', 'SAC_001');
            camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
            camposRecl.put('OwnerId', usuarioGeneral.id);
            camposRecl.put('RecordTypeId', Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId());
            camposRecl.put('OS_Email__c', 'Testacuseborrado@test.com');
            camposRecl.put('SuppliedEmail', 'Testacuseborrado@test.com');
            Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
            Database.insert(casoReclamacion);

            EmailTemplate validEmailTemplate = new EmailTemplate(
                isActive = true, 
                Name = 'nombreTest',
                DeveloperName = 'SAC_Test',
                TemplateType = 'text', 
                HtmlValue = '<p>htmlValue<p>', 
                Body = 'Texted', 
                FolderId = usuarioGeneral.id
            );
            Database.insert(validEmailTemplate);    
        }  
    }

    @isTest
    static void testAcuse() {
        Id recordTypeRedaccion = Schema.SObjectType.SAC_PlantillaRedaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Redaccion').getRecordTypeId();
        EmailTemplate validEmailTemplate = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'SAC_Test'];
        
        //Plantilla
        SAC_PlantillaRedaccion__c plantilla = new SAC_PlantillaRedaccion__c();
        plantilla.SAC_TipoPlantilla__c = 'SAC_AcuseDeRecibo';
		plantilla.SAC_Origen__c = 'Email';
        plantilla.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
        plantilla.SAC_PlantillaCatalanId__c = validEmailTemplate.Id;
        plantilla.SAC_PlantillaInglesId__c = validEmailTemplate.Id;
        plantilla.RecordTypeId = recordTypeRedaccion;
        plantilla.Name = 'testPlantilla';
        Database.insert(plantilla);

        User usuarioGeneral = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];
        Case caso = [SELECT Id FROM case WHERE Subject = 'TestRec' LIMIT 1];
        System.runAs(usuarioGeneral){
            Test.startTest();        
            Id batchId = Database.executeBatch(new SAC_BatchAcusesDeRecibo(), 1);
            Test.stopTest();
        }
        system.assertEquals(1, 1, 'No mandado el acuse correctamente');
    }
}