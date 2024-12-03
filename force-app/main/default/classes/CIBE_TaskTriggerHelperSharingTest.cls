@IsTest
public with sharing class CIBE_TaskTriggerHelperSharingTest {
    
    @TestSetup
    static void makeData(){
        CIBE_TestInitialSetup.setupInitialDataEMP();
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
    }

    @IsTest
    static void borrarClaseTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        System.runAs(usuario){
            String result;
            result = CIBE_TaskTriggerHelperSharing.borrarClase();
            System.assertEquals(result, 'borrar clase');
        }
        
    }
}