@isTest
public with sharing class SAC_PruebaTiemposTest {
    @TestSetup
    static void makeData(){
            Id profileId = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce'].Id;
        	UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'pruebaTiempos'];
            User usuarioPrueba = new User(
                Username = 'usertest' + '@test.com.testSetup',
                Email = 'email' + '@test.com',
                LastName = 'Usuario Test',
                ProfileId = profileId,
                Alias = 'alias',
                TimeZoneSidKey = 'GMT',
                LocaleSidKey = 'es_ES',
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                isActive = true,
                userRole = uRole // <---- añadido recientemente
            );
            Database.insert(usuarioPrueba);
        }
}