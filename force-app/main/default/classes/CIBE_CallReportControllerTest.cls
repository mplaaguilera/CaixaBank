/**********************************************************************************************************************
 Name:	  CIBE_CallReportControllerTest 
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test de CIBE_callReportControllerv
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR		    DATE				Description
	1.0			US584193		    Lucía		    29/05/2023  		Init version
    1.1			US584194		    Lucía		    29/06/2023  		

***********************************************************************************************************************/

@isTest
public with sharing class CIBE_CallReportControllerTest {

    @TestSetup
    static void setUp(){
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        //EMP
        CIBE_TestInitialSetup.setupInitialData(null, CIBE_AppConstants.CIBE_ROLEMP, null, null, null, new List<String>{
            CIBE_AppConstants.CIBE_OPERATIVAEMP,
            CIBE_AppConstants.CIBE_CUSTOMMETADATA
        });

        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP'];

        //CIB
        User usuarioCIB = CIBE_TestHelper.loginUser(null, CIBE_AppConstants.CIBE_ROLECIB, null, new List<String>{
            CIBE_AppConstants.CIBE_OPERATIVACIB,
            CIBE_AppConstants.CIBE_CUSTOMMETADATA
        });

        User u1 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' AND UserRole.DeveloperName = 'CIB'];

        System.runAs(new User(Id = UserInfo.getUserId())){
            Account acc = CIBE_TestHelper.createCustomer(u);

            Account acc1 = new Account(
                Name = 'NameTest',
                OwnerId = u1.Id,
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '12345'
            );
            insert acc1;
            

            Event evento = CIBE_TestHelper.createEvent(u, System.now(), acc);

            Event evento2 = CIBE_TestHelper.createEventVideocCall(u1, System.now(), acc1);
        }
    }


    @isTest
    public static void getRecordsTestEmp(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP'];
        Test.StartTest();
        System.runAs(usuario){
            List<Event> evento = [SELECT Id FROM Event WHERE AV_Tipo__c = 'EC'];
            List<CBK_Activity_Extension__c> eventoExtension = [SELECT Id FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c =: evento[0].Id];
            CIBE_callReportController.getRecords(evento[0].Id);
            System.assertEquals(1, evento.size());
            System.assertEquals(1, eventoExtension.size());
        }
        Test.stopTest();

    }

    @isTest
    public static void getRecordsTestCIB(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' AND UserRole.DeveloperName = 'CIB'];
        Test.StartTest();
        System.runAs(usuario){
            List<Event> evento = [SELECT Id FROM Event WHERE AV_Tipo__c = 'VLD'];
            List<CBK_Activity_Extension__c> eventoExtension = [SELECT Id FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c =: evento[0].Id];
            CIBE_callReportController.getRecords(evento[0].Id);
            System.assertEquals(1, evento.size());
            System.assertEquals(1, eventoExtension.size());
        }
        Test.stopTest();

    }

}