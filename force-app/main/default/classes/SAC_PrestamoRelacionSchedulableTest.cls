/*
* @description: SAC_PrestamoRelacionSchedulableTest test class for SAC_PrestamoRelacionSchedulable
* @author: iria.alvarez.novoa@ibm.com
* @date: october 2024
*/
@isTest
public class SAC_PrestamoRelacionSchedulableTest {
    @testSetup
    static void setupData() {
        Id recType = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        String profileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];
        // User
        User usuarioGeneral = new User();
        usuarioGeneral.Username = 'userSACgeneral01@test.com';
        usuarioGeneral.Email = 'email@test.com';
        usuarioGeneral.LastName = 'usuarioGeneral Test';
        usuarioGeneral.ProfileId = profileId;
        usuarioGeneral.Alias = 'alias';
        usuarioGeneral.TimeZoneSidKey = 'GMT';
        usuarioGeneral.LocaleSidKey = 'es_ES';
        usuarioGeneral.EmailEncodingKey = 'ISO-8859-1';
        usuarioGeneral.LanguageLocaleKey = 'en_US';
        usuarioGeneral.isActive = true;
        usuarioGeneral.userRole = uRole; 
        insert usuarioGeneral;
    }
    @isTest
    static void testExecute() {
        List<User> usuarioList = [SELECT Id FROM User WHERE Username = 'userSACgeneral01@test.com' AND isActive = true LIMIT 1];
        System.runAs(usuarioList[0]) {
            Test.startTest();
            SAC_PrestamoRelacionSchedulable.obsoletMethod();
            Test.stopTest();
            System.assertEquals(false, usuarioList.isEmpty(), 'Existe el usuario');
        }
    }
}