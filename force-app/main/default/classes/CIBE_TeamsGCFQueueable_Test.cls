/**********************************************************************************************************************
Name:      CIBE_TeamsGCFQueueable_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Apex Class Test de CIBE_TeamsGCF_Queueable
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY 				AUTHOR              DATE                Description
    1.0            US507827             	Jose Maria        	06/02/2023          Init version (copy from retail)

***********************************************************************************************************************/
@isTest
public with sharing class CIBE_TeamsGCFQueueable_Test {
    
    @TestSetup
	static void setup(){
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        User usrGes = CIBE_TestHelper.loginUser('CIBE_Gestor', null, 'U0009003',ps);
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            CIBE_TestHelper.activateLogger();
            Account centro = CIBE_TestHelper.createCaixaCenter();
            
            CBK_IntegrationSetting__c endpointConf = new CBK_IntegrationSetting__c(Name='CIBE_citaprevia_int', NamedCredential__c = 'CIBE_citaprevia_int');
            insert endpointConf;
        }
        
        System.runAs(usrGes) {
            Account acc = CIBE_TestHelper.createCustomer();
            DateTime activityTime= DateTime.now();
            Event ev = CIBE_TestHelper.createEventVideocCall(usrGes, activityTime, acc);
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        }
    }

    @isTest
    private static void validateQueueable() {
        
        AV_AzureTeamsToken__c cs = new AV_AzureTeamsToken__c();
        cs.Name = 'AzureTeamToken';
        cs.AV_ExpiresIn__c = 0;
        insert cs;
        
        List<User> empAdmin = [SELECT Id, AV_ExternalID__c, AV_AzureId__c,FederationIdentifier FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        empAdmin[0].FederationIdentifier = 'U01test_teams_caixa@caixabankpre.com';
        update empAdmin;
        
        CC_InterfaceSettings__mdt dataInterface = CIBE_IntegrationUtilities.fetchMetadataInterface(CIBE_Teams_Integration.AV_TEAMSLOGIN);
        String tenant=dataInterface.CC_SoapAction__c.substringAfter('=');
        String urlLogin = 'callout:MICROSOFT_TEAMS/{tenant}/oauth2/v2.0/token'.replace('{tenant}',tenant);
        Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
        header2TestResp.put(urlLogin, new AV_MockCallout_Test('TEAMS_LOGIN','OK'));
        header2TestResp.put('callout:MICROSOFT/v1.0/users/U01test_teams_caixa@caixabankpre.com',new AV_MockCallout_Test('TEAMS_GETUSERID','OK'));
        header2TestResp.put('callout:MICROSOFT/v1.0/users/415b41e6-28ab-4ef1-9f46-13a6d53eb368/onlineMeetings',new AV_MockCallout_Test('TEAMS_GETURL','OK'));
        header2TestResp.put('callout:API_GWT_PRO/servicing/employees/U0009003/activities/eventsPremium', new AV_MockCallout_Test('CP_MOCNT','OK'));
        HttpCalloutMock multiCalloutMock = new AV_MultiRequestMock_Test(header2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            List<Event> ev = [SELECT Id, IsRecurrence2, AV_origenApp__c, IsRecurrence, WhatId, OwnerId, AV_ExternalId__c, AV_CodigoGestorAsignado__c, CreatedDate, Subject, RecordTypeId, Description, AV_Tipo__c, CSBD_Evento_Estado__c, AV_BranchPhysicalMeet__c, Location, StartDateTime, EndDateTime, isPrivate, AV_Task__c FROM Event LIMIT 1];
            List<User> emp = [SELECT Id, AV_ExternalID__c, AV_AzureId__c,FederationIdentifier FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];

       
            Test.startTest();
            String jsonString = json.serialize(ev[0]);
            System.enqueueJob(new CIBE_TeamsGCFQueueable(jsonString, ev[0].Subject, ev[0].EndDateTime, ev[0].StartDateTime, ev[0].AV_Task__c,emp[0].FederationIdentifier , emp[0].AV_AzureId__c));
            System.enqueueJob(new CIBE_TeamsGCFQueueable(jsonString, ev[0].Subject, ev[0].EndDateTime, ev[0].StartDateTime, ev[0].AV_Task__c,emp[0].FederationIdentifier , emp[0].AV_AzureId__c));
            System.assertEquals('AV_Salesforce',ev[0].AV_origenApp__c,'validateQueueable');
            Test.stopTest();
        }
    }
    
    @isTest
    private static void validateQueueableWithoyToken() {
        
        AV_AzureTeamsToken__c cs = new AV_AzureTeamsToken__c();
        cs.Name = 'AzureTeamToken2';
        cs.AV_ExpiresIn__c = 0;
        insert cs;
        
        List<User> empAdmin = [SELECT Id, AV_ExternalID__c, AV_AzureId__c,FederationIdentifier FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        empAdmin[0].FederationIdentifier = 'U01test_teams_caixa@caixabankpre.com';
        update empAdmin;
        
        CC_InterfaceSettings__mdt dataInterface = CIBE_IntegrationUtilities.fetchMetadataInterface(CIBE_Teams_Integration.AV_TEAMSLOGIN);
        String tenant=dataInterface.CC_SoapAction__c.substringAfter('=');
        String urlLogin = 'callout:MICROSOFT_TEAMS/{tenant}/oauth2/v2.0/token'.replace('{tenant}',tenant);
        Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
        header2TestResp.put(urlLogin, new AV_MockCallout_Test('TEAMS_LOGIN','OK'));
        header2TestResp.put('callout:MICROSOFT/v1.0/users/U01test_teams_caixa@caixabankpre.com',new AV_MockCallout_Test('TEAMS_GETUSERID','OK'));
        header2TestResp.put('callout:MICROSOFT/v1.0/users/415b41e6-28ab-4ef1-9f46-13a6d53eb368/onlineMeetings',new AV_MockCallout_Test('TEAMS_GETURL','OK'));
        header2TestResp.put('callout:API_GWT_PRO/servicing/employees/U0009003/activities/eventsPremium', new AV_MockCallout_Test('CP_MOCNT','OK'));
        HttpCalloutMock multiCalloutMock = new AV_MultiRequestMock_Test(header2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            List<Event> ev = [SELECT Id, IsRecurrence2, AV_origenApp__c, IsRecurrence, WhatId, OwnerId, AV_ExternalId__c, AV_CodigoGestorAsignado__c, CreatedDate, Subject, RecordTypeId, Description, AV_Tipo__c, CSBD_Evento_Estado__c, AV_BranchPhysicalMeet__c, Location, StartDateTime, EndDateTime, isPrivate, AV_Task__c FROM Event LIMIT 1];
            List<User> emp = [SELECT Id, AV_ExternalID__c, AV_AzureId__c,FederationIdentifier FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];

       
            Test.startTest();
            String jsonString = json.serialize(ev[0]);
            System.enqueueJob(new CIBE_TeamsGCFQueueable(jsonString, ev[0].Subject, ev[0].EndDateTime, ev[0].StartDateTime, ev[0].AV_Task__c,emp[0].FederationIdentifier , emp[0].AV_AzureId__c));
            System.enqueueJob(new CIBE_TeamsGCFQueueable(jsonString, ev[0].Subject, ev[0].EndDateTime, ev[0].StartDateTime, ev[0].AV_Task__c,emp[0].FederationIdentifier , emp[0].AV_AzureId__c));
            System.assertEquals('AV_Salesforce',ev[0].AV_origenApp__c,'validateQueueable');
            Test.stopTest();
        }
    }
    
    @isTest
    private static void validateInsertEventGCFFuture() {        
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'CC_Cliente' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            	Contact empleado  = CIBE_TestHelper.createEmployee(null, runAsUser);
            
            	Event ev1 = [SELECT Id, IsRecurrence2, AV_origenApp__c, IsRecurrence, WhatId,WhoId,Who.name, OwnerId, AV_ExternalId__c, AV_CodigoGestorAsignado__c, CreatedDate, Subject, RecordTypeId, Description, AV_Tipo__c, CSBD_Evento_Estado__c, AV_BranchPhysicalMeet__c, Location, StartDateTime, EndDateTime, isPrivate, AV_Task__c FROM Event LIMIT 1];      
                ev1.WhoId = empleado.id;
            	update ev1;
	
            	CBK_Activity_Extension__c crmTaskNew = new CBK_Activity_Extension__c();
                crmTaskNew.AV_ActivityId__c = ev1.Id;
            	insert crmTaskNew;
            
            	Event ev2 = CIBE_TestHelper.createEventConClienteRecurrente(runAsUser, acc);
            
            	Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
				
                String jsonString1 = JSON.serialize(ev1);
                String jsonString2 = JSON.serialize(ev2);
                CIBE_TeamsGCFQueueable.insertEventGCFFuture(jsonString1);
                CIBE_TeamsGCFQueueable.insertEventGCFFuture(jsonString2);
            
                System.assertEquals('AV_Salesforce', ev1.AV_origenApp__c, 'validateInsertEventGCFFuture');
            Test.stopTest();
        }
    }
   
}