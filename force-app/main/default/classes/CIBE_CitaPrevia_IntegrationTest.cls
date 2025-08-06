/**********************************************************************************************************************
Name:	  CIBE_CitaPrevia_IntegrationTest
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración con API para Eventos Test
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Luis Martínez	   	25/10/2022		Init version
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_CitaPrevia_IntegrationTest {
    
    @TestSetup
    static void setup() {
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

        User usrTest2 = new User(
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
            AV_ExternalID__c = 'U0009004'
        );
        insert new List<User>{usrTest, usrTest2};
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            CIBE_TestHelper.activateLogger();
            CIBE_TestHelper.createUser('CIBE_Gestor');
            
            insert new CBK_IntegrationSetting__c(
                Name = 'CIBE_citaprevia_int',
                //NamedCredential__c = 'callout:API_GWT_CIBE/tech/asesorventasactivitiesapi/employees/{employeeId}/activities/eventsPremium',
                NamedCredential__c = 'callout:API_GWT_CIBE/tech/employees/{employeeId}',
                RegistroTrazaIntegracion__c = false,
                ResourcePath__c = ''
            );
            
            insert new CBK_IntegrationSetting__c(
                Name = 'CIBE_citaprevia_mo',
                //NamedCredential__c = 'callout:API_GWT_CIBE/tech/asesorventasactivitiesapi/activities/eventsPremium/{eventPremiumId}',
                //NamedCredential__c = 'callout:API_GWT_CIBE/tech/activities/eventsPremium/{eventPremiumId}	
                NamedCredential__c = 'callout:API_GWT_CIBE/tech/asesorventasactivitiesapi/activities/eventsPremium/{id}',
                RegistroTrazaIntegracion__c = false,
                ResourcePath__c = ''
            );
        }
    }

    @isTest
    public static void testInsCnt() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            String branchId = '13550';
            String employeeId = [Select AV_ExternalID__c From User Where Id = :UserInfo.getUserId()][0].AV_ExternalID__c;
            
            CIBE_CitaPrevia_Integration.Event parms = new CIBE_CitaPrevia_Integration.Event();
            
            parms.subject = 'Esto es test';
            parms.employeeEvent = employeeId;
            parms.branchId = Integer.valueOf(branchId);
            parms.type = 'O';
            parms.meetingRequester = 'G';
            parms.status = 'R';
            parms.dateReplacement =  DateTime.now().format('yyyy-MM-dd');
            parms.startTime =  DateTime.now().format('HH:mm');
            parms.endTime =  DateTime.now().format('HH:mm');
            parms.comment = 'Esto es isTest';
    
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
            Test.startTest();
                CIBE_CitaPrevia_Integration.InsCntResponse eventResponse = CIBE_CitaPrevia_Integration.intCnt(parms, employeeId);		
            Test.stopTest();
            System.assertEquals('201', eventResponse.statusCode);
        }
    }
    
    @isTest
    public static void testModCnt() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            String branchId = '13550';
            String eventPremiumtId = '8911100000000001';
            // String employeeId = [Select AV_ExternalID__c From User Where Id = :UserInfo.getUserId()][0].AV_ExternalID__c;
            List <String> lstMandatory = new List <String>{'U0009003'};
            CIBE_CitaPrevia_Integration.Event parms = new CIBE_CitaPrevia_Integration.Event();
            
            parms.subject = 'Esto es test 2';
            parms.employeeEvent = 'U0009003';
            parms.branchId = Integer.valueOf(branchId);     
            parms.type = 'O';
            parms.meetingRequester = 'G';
            parms.status = 'R';
            parms.dateReplacement =  DateTime.now().format('yyyy-MM-dd');
            parms.startTime =  DateTime.now().format('HH:mm');
            parms.endTime =  DateTime.now().format('HH:mm');
            parms.comment = 'Esto es isTest 2';
            parms.MandatoryAssistance = lstMandatory;
    
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_MOCNT','OK'));
            Test.startTest();		
                CIBE_CitaPrevia_Integration.MoCntResponse eventResponse = CIBE_CitaPrevia_Integration.moCnt(parms, 'U0009003', eventPremiumtId);		
            Test.stopTest();
            System.assertEquals('200', eventResponse.statusCode);
        }
    }
}