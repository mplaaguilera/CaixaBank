/**********************************************************************************************************************
 Name:	  CIBE_CallReportCountry_Test 
 Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
@description Clase test de CIBE_CallReportCountry
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR		            DATE				Description
	1.0			PPM100361710	    Carolina lopez		    19/08/2024  		Init version
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_CallReportCountry_Test {
    @TestSetup
    static void setUp(){
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        User usuarioCIB = new User();
        User u1 = new User();
        Event evento2 = new Event();
        //CIB
        usuarioCIB = CIBE_TestHelper.loginUser(null, CIBE_AppConstants.CIBE_ROLECIB, null, new List<String>{
            CIBE_AppConstants.CIBE_OPERATIVACIB,
            CIBE_AppConstants.CIBE_INTEGRACION,
            CIBE_AppConstants.CIBE_CUSTOMMETADATA,
            CIBE_AppConstants.CIBE_ANALYTICSINTEGRACION
        });
        u1 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' AND UserRole.DeveloperName = 'CIB'];
        System.runAs(usuarioCIB){
            Account acc1 = new Account(
                Name = 'NameTest',
                OwnerId = u1.Id,
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '12345'
            );
            insert acc1;
            evento2 = CIBE_TestHelper.createEventVideocCall(u1, System.now(), acc1);
        }
    }
    @isTest
    public static void getPicklistValueTestCIB(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' AND UserRole.DeveloperName = 'CIB'];
        Test.StartTest();
        System.runAs(usuario){
            List<String> result = CIBE_CallReportCountry.getPicklistValues('CIBE_Country__c');
            System.assertEquals(result != null, true, 'OK');
        }
        Test.stopTest();
    }
    @isTest
    public static void updateRecordTestCIB(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' AND UserRole.DeveloperName = 'CIB'];
        List<CBK_Activity_Extension__c> eventoExtension  = new List<CBK_Activity_Extension__c>();
        System.runAs(usuario){
            List<Event> evento = [SELECT Id FROM Event WHERE AV_Tipo__c = 'VLD'];
            eventoExtension = [SELECT Id, CIBE_Country__c, AV_ActivityId__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c =:evento[0].Id Limit 1];
        }
        Test.StartTest();
        System.runAs(usuario){
            CIBE_CallReportCountry.updateRecord(eventoExtension[0].AV_ActivityId__c, 'Alemania', true);
        }
        Test.stopTest();
        CBK_Activity_Extension__c updatedRecord = [SELECT Id, AV_ActivityId__c, CIBE_Country__c FROM CBK_Activity_Extension__c WHERE Id =:eventoExtension[0].Id];
        System.assertEquals('Alemania', updatedRecord.CIBE_Country__c, 'The country value should not have changed.');

    }
}