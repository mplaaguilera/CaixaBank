@isTest
public with sharing class HDT_TestDataFactory_Test {
    @isTest static void testUsuarioPruebasHdt() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        // Create test user
        User testUser = HDT_TestDataFactory.usuarioPruebasHdt();
        //insert testUser;

        // Retrieve inserted user and assert values
        User insertedUser = [SELECT Id, Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, UserRoleId, ProfileId, TimeZoneSidKey, UserName FROM User WHERE Id = :testUser.Id];
        
        System.assertEquals('usr_test', insertedUser.Alias);
        System.assertEquals('usuario_test@test.com', insertedUser.Email);
        System.assertEquals('ISO-8859-1', insertedUser.EmailEncodingKey);
        System.assertEquals('Usuario Test', insertedUser.LastName);
        System.assertEquals('es', insertedUser.LanguageLocaleKey);
        System.assertEquals('es_ES', insertedUser.LocaleSidKey);
        System.assertEquals([SELECT Id FROM UserRole WHERE Name = 'HDT'].Id, insertedUser.UserRoleId);
        System.assertEquals([SELECT Id FROM Profile WHERE Name = 'HDT_Usuario_CaixaBank'].Id, insertedUser.ProfileId);
        System.assertEquals('Europe/Madrid', insertedUser.TimeZoneSidKey);
        
        }
    }

    
    @isTest static void testusuarioAHdt() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        // Create test user
        User testUser = HDT_TestDataFactory.usuarioAHdt();
        //insert testUser;

        // Retrieve inserted user and assert values
        User insertedUser = [SELECT Id, Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, UserRoleId, ProfileId, TimeZoneSidKey, UserName FROM User WHERE Id = :testUser.Id];
        
        System.assertEquals('usr_test', insertedUser.Alias);
        System.assertEquals('usuario_test@test.com', insertedUser.Email);
        System.assertEquals('ISO-8859-1', insertedUser.EmailEncodingKey);
        System.assertEquals('Usuario Test', insertedUser.LastName);
        System.assertEquals('es', insertedUser.LanguageLocaleKey);
        System.assertEquals('es_ES', insertedUser.LocaleSidKey);
        System.assertEquals([SELECT Id FROM UserRole WHERE Name = 'HDT'].Id, insertedUser.UserRoleId);
        System.assertEquals([SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, insertedUser.ProfileId);
        System.assertEquals('Europe/Madrid', insertedUser.TimeZoneSidKey);
        
        }
    }
}