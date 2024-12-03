@isTest
public with sharing class FRA_CaseTriggerHelper_Test {

    // @TestSetup
    // static void testSetup(){
    //     String orgId = UserInfo.getOrganizationId();
    //     String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    //     Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
    //     String uniqueName = orgId + dateString + randomInt;
    //     System.runAs(new User(Id = UserInfo.getUserId())) {
    //         User usuario = new User();
    //         usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'FRA_Usuario_Caixabank'].Id;
    //         usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'FRA'].Id;
    //         usuario.FirstName = 'Fraude';
    //         usuario.LastName = 'Prueba';
    //         usuario.Alias = uniqueName.substring(18, 23);
    //         usuario.Email = uniqueName + '@test' + orgId + '.org';
    //         usuario.Username = uniqueName + '@test' + orgId + '.org';
    //         usuario.EmailEncodingKey = 'UTF-8';
    //         usuario.LanguageLocaleKey = 'es';
    //         usuario.LocaleSidKey = 'es_ES';
    //         usuario.TimezonesIdKey = 'Europe/Madrid';
    //         insert usuario;
    
    //         List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
    //         for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('FRA_PS_Operador')]) {
    //             PermissionSetAssignment psAssignment = new PermissionSetAssignment();
    //             psAssignment.AssigneeId = usuario.Id;
    //             psAssignment.PermissionSetId = ps.Id;
    //             psAssignments.add(psAssignment);
    //         }
    //         insert psAssignments;
    //     }    
    // }
    
    @isTest
    public static void testInformarCanalResolucion() {
        // User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()){
            Test.startTest();
            Case caso1 = new Case(
                RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente'),
                Subject = 'Test FRAUDE 1',
                Origin = 'Phone',
                CC_Idioma__c = 'es',
                CC_Canal_Procedencia__c = 'Teléfono FRAUDE CaixaBankNow',
                CC_Canal_Resolucion__c = 'Teléfono FRAUDE Canal Oficina'
            );
            insert caso1;
            Case caso2 = new Case(
                RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente'),
                Subject = 'Test FRAUDE 2',
                Origin = 'Phone',
                CC_Idioma__c = 'es',
                CC_Canal_Procedencia__c = 'Teléfono FRAUDE CaixaBankNow'
            );
            insert caso2;

            System.assertEquals('Teléfono FRAUDE Canal Oficina', [SELECT CC_Canal_Resolucion__c FROM Case WHERE Subject = 'Test FRAUDE 1'].CC_Canal_Resolucion__c);
            System.assertEquals('Teléfono FRAUDE CaixaBankNow', [SELECT CC_Canal_Resolucion__c FROM Case WHERE Subject = 'Test FRAUDE 2'].CC_Canal_Resolucion__c);
            Test.stopTest();
        }
    }

}