/**********************************************************************************************************************
Name:	  CIBE_TranslationUtilities_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Implementación para la obtencion de traducciones del custom metadata CIBE_TranslateConfiguration__mdt.
-----------------------------------------------------------------------------------------------------------------------
Historial
-----------------------------------------------------------------------------------------------------------------------
VERSION		USER_STORY		AUTHOR			DATE			Description
1.0			Init    		Alex Campos 	28/12/2022		Init version.
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_TranslationUtilities_Test {

    @testSetup
    public static void testSetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'CIBE_Gestor' LIMIT 1];
        UserRole ur = [SELECT Id FROM UserRole WHERE DeveloperName = 'CIBE_CIBEmpresas' LIMIT 1];

        User usrTest = new User(
            UserRoleId = ur.Id,
            Alias = 'tsAlias',
            Email = 'test@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '001-03044',
            ProfileId = p.Id,
            UserName = CIBE_TestHelper.getEmail(),
            AV_ExternalID__c = 'U0009003'
        );
        insert usrTest;

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CIBE_OperativaEMP'];
        insert new PermissionSetAssignment(AssigneeId = usrTest.Id, PermissionSetId = ps.Id);
    }

    @isTest
    public static void getInstanceTest() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            CIBE_TranslationUtilities utility = CIBE_TranslationUtilities.getInstance();

            System.assertNotEquals(null, utility);
        }
    }

    @isTest
    public static void setLanguageTest() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            CIBE_TranslationUtilities utility = CIBE_TranslationUtilities.getInstance();
            utility.setLanguage();

            System.assertEquals('es', utility.getLanguage());
        }
    }

    @isTest
    public static void setLanguage2Test() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            CIBE_TranslationUtilities utility = CIBE_TranslationUtilities.getInstance();
            utility.setLanguage('en_US');

            System.assertEquals('en_US', utility.getLanguage());
        }
    }

    @isTest
    public static void addTranslationNameTest() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            CIBE_TranslationUtilities utility = CIBE_TranslationUtilities.getInstance();
            utility.addTranslationName('CIBE_Otros');

            System.assert(utility.getTranslations().containsKey('CIBE_Otros'));
        }
    }

    @isTest
    public static void addTranslationNamesTest() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            CIBE_TranslationUtilities utility = CIBE_TranslationUtilities.getInstance();
            utility.addTranslationNames(new List<String>{'CIBE_Otros'});
            
            System.assert(utility.getTranslations().containsKey('CIBE_Otros'));
        }
    }

    @isTest
    public static void clearTranslationNamesTest() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            CIBE_TranslationUtilities utility = CIBE_TranslationUtilities.getInstance();
            utility.addTranslationName('CIBE_Otros');

            System.assert(utility.getTranslations().containsKey('CIBE_Otros'));

            utility.clearTranslationNames();

            System.assert(utility.getTranslations().isEmpty());
        }
    }

    @isTest
    public static void queryTranslationsTest() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            CIBE_TranslationUtilities utility = CIBE_TranslationUtilities.getInstance();
            utility.addTranslationName('CIBE_Otros');

            System.assert(utility.getTranslations().containsKey('CIBE_Otros'));
            System.assertEquals('', utility.getTranslations().get('CIBE_Otros'));

            utility.queryTranslations();

            System.assertEquals('Otros', utility.getTranslations().get('CIBE_Otros'));
        }
    }

    @isTest
    public static void getTranslationsTest() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            CIBE_TranslationUtilities utility = CIBE_TranslationUtilities.getInstance();
            utility.addTranslationName('CIBE_Otros');

            System.assertNotEquals(null, utility.getTranslations());
        }
    }

}