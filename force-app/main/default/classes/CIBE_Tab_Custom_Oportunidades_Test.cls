@isTest

public with sharing class CIBE_Tab_Custom_Oportunidades_Test {

    @TestSetup
    static void setup(){

        User us = AV_TestHelper.createUser('CIBE_Gestor','','CIB');
    }

    @isTest
    private static void testGetReportsUniqueName() {
        User testUser = [SELECT Id, Email FROM User WHERE Email = 'test@test.dev' LIMIT 1];
        Test.startTest();
        CIBE_Tab_Custom_Oportunidades.Response reportsUniqueName = CIBE_Tab_Custom_Oportunidades.getReportsUniqueName(testUser.Id);
        Test.stopTest();
        
        System.assertNotEquals(reportsUniqueName.wrapperReports, null,'Reports should not be null');
        System.assertNotEquals(reportsUniqueName.wrapperTabs, null,'Tabs should not be empty');
    
    }
   
}