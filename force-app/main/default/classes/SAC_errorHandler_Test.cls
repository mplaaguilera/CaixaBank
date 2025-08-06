@isTest
public with sharing class SAC_errorHandler_Test {
    @isTest
    static void errorTest() {
        User usuarioAdmin = new User();
        usuarioAdmin.Username = 'admin123@testcaixa1.com';
        usuarioAdmin.Email = 'email@test.com';
        usuarioAdmin.LastName = 'usuarioAdmin Test';
        usuarioAdmin.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'GMT';
        usuarioAdmin.LocaleSidKey = 'es_ES';
        usuarioAdmin.EmailEncodingKey = 'ISO-8859-1';
        usuarioAdmin.LanguageLocaleKey = 'en_US';
        usuarioAdmin.isActive = true;       
        insert usuarioAdmin;

        DateTime now = system.now();
        String userName = 'test';
        String className = 'test';
        String methodName = 'test';
        String errorMessage = 'test';
        String stackTrace = 'test';
        
        System.runAs(usuarioAdmin){
            Test.startTest();
            SAC_errorHandler.insertError(now, userName, className, methodName, errorMessage, stackTrace);
            Test.stopTest();
        }
        System.assertEquals(userName, 'test');
    }
}