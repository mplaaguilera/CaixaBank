@isTest
public with sharing class FRA_TestDataFactory_Test {
    
    @TestSetup
    static void makeData(){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User usuario = new User();
        usuario.IsActive = true;
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'FRA_Usuario_CaixaBank'].Id;
        usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'FRA'].Id;
        usuario.FirstName = 'FRA Prueba Clases Test';
        usuario.LastName = 'FRA Prueba Clases Test';
        usuario.Alias = uniqueName.substring(18, 23);
        usuario.Email = uniqueName + '@test' + orgId + '.org';
        usuario.Username = uniqueName + '@test' + orgId + '.org';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        usuario.TimezonesIdKey = 'Europe/Madrid';
        insert usuario;
        List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
        for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('FRA_PS_Operador')]) {
            PermissionSetAssignment psAssignment = new PermissionSetAssignment();
            psAssignment.AssigneeId = usuario.Id;
            psAssignment.PermissionSetId = ps.Id;
            psAssignments.add(psAssignment);
        }
        insert psAssignments;
    }
    
    @isTest 
    public static void testUsuarioPruebasFRA() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'FRA Prueba Clases Test' LIMIT 1];
        User testUser = FRA_TestDataFactory.usuarioPruebasFRA();

        System.runAs(usuario) {
        User insertedUser = [SELECT Id, Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, UserRoleId, ProfileId, TimeZoneSidKey, UserName FROM User WHERE Id = :testUser.Id];
                
        System.assertEquals('UTF-8', insertedUser.EmailEncodingKey);
        System.assertEquals('Prueba Clases Test', insertedUser.LastName);
        System.assertEquals('es', insertedUser.LanguageLocaleKey);
        System.assertEquals('es_ES', insertedUser.LocaleSidKey);
        System.assertEquals([SELECT Id FROM UserRole WHERE Name = 'FRA'].Id, insertedUser.UserRoleId);
        System.assertEquals([SELECT Id FROM Profile WHERE Name = 'FRA_Usuario_CaixaBank'].Id, insertedUser.ProfileId);
        System.assertEquals('Europe/Madrid', insertedUser.TimeZoneSidKey);
        
        }
    }

    @isTest static void testusuarioAFRA() {
        //System.runAs(new User(Id = UserInfo.getUserId())) {

        // Create test user
        User testUser = FRA_TestDataFactory.usuarioAFRA();
        //insert testUser;

        // Retrieve inserted user and assert values
        User insertedUser = [SELECT Id, Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, UserRoleId, ProfileId, TimeZoneSidKey, UserName FROM User WHERE Id = :testUser.Id];
        
        System.assertEquals('usr_test', insertedUser.Alias);
        System.assertEquals('usuario_test@test.com', insertedUser.Email);
        System.assertEquals('ISO-8859-1', insertedUser.EmailEncodingKey);
        System.assertEquals('Usuario Test', insertedUser.LastName);
        System.assertEquals('es', insertedUser.LanguageLocaleKey);
        System.assertEquals('es_ES', insertedUser.LocaleSidKey);
        System.assertEquals([SELECT Id FROM UserRole WHERE Name = 'FRA'].Id, insertedUser.UserRoleId);
        System.assertEquals([SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, insertedUser.ProfileId);
        System.assertEquals('Europe/Madrid', insertedUser.TimeZoneSidKey);
        
        //}
    }


}