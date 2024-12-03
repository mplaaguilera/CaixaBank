/**********************************************************************************************************************
Name:      AV_TeamsGCF_Queueable_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Apex Class Test de AV_TeamsGCF_Queueable
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY 				AUTHOR              DATE                Description
    1.0            Fix GCF             		Sandra Gómez        27/06/2022          Init version

***********************************************************************************************************************/
@isTest
public with sharing class AV_TeamsGCF_Queueable_Test {
    @TestSetup
	static void setup(){
		AV_TestHelper.activateLogger();
        Account centro = AV_TestHelper.createCaixaCenter();
        User us= AV_TestHelper.createUser('AV_Usuario_CaixaBank','U01231231231231');
        Contact empleado = AV_TestHelper.createEmployee(centro,us);
        Account acc=AV_TestHelper.createCustomer();
        DateTime activityTime= DateTime.now();
        Event ev=AV_TestHelper.createEventVideocCall(us, activityTime, acc);
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
	}

    @isTest
    private static void validateQueueable() {
        AV_AzureTeamsToken__c cs = new AV_AzureTeamsToken__c();
        cs.Name = 'AzureTeamToken';
        cs.AV_ExpiresIn__c = 0;
        insert cs;
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_Teams_Integration.AV_TEAMSLOGIN);
        String tenant=dataInterface.CC_SoapAction__c.substringAfter('=');
        String urlLogin = 'callout:MICROSOFT_TEAMS/{tenant}/oauth2/v2.0/token'.replace('{tenant}',tenant);
        Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
        header2TestResp.put(urlLogin, new AV_MockCallout_Test('TEAMS_LOGIN','OK'));
        header2TestResp.put('callout:MICROSOFT/v1.0/users/U01test_teams_caixa@caixabankpre.com',new AV_MockCallout_Test('TEAMS_GETUSERID','OK'));
        header2TestResp.put('callout:MICROSOFT/v1.0/users/415b41e6-28ab-4ef1-9f46-13a6d53eb368/onlineMeetings',new AV_MockCallout_Test('TEAMS_GETURL','OK'));
        header2TestResp.put('callout:API_GWT_PRO/servicing/employees/U0009003/activities/eventsPremium', new AV_MockCallout_Test('CP_MOCNT','OK'));
        HttpCalloutMock multiCalloutMock = new AV_MultiRequestMock_Test(header2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Event ev = [Select Id, IsRecurrence2, AV_origenApp__c, IsRecurrence, WhatId, OwnerId, AV_ExternalId__c, AV_CodigoGestorAsignado__c, CreatedDate, Subject, RecordTypeId, Description, AV_Tipo__c, CSBD_Evento_Estado__c, AV_BranchPhysicalMeet__c, Location, StartDateTime, EndDateTime, isPrivate, AV_Task__c from Event limit 1];
		User emp = [Select Id, AV_ExternalID__c, AV_AzureId__c,FederationIdentifier From User Where AV_ExternalID__c = 'U01231231231231' limit 1];
        emp.FederationIdentifier = 'U01test_teams_caixa@caixabankpre.com';
        update emp;
        Test.startTest();
		String jsonString = json.serialize(ev);
        System.enqueueJob(new AV_TeamsGCF_Queueable(jsonString, ev.Subject, ev.EndDateTime, ev.StartDateTime, ev.AV_Task__c,emp.FederationIdentifier , emp.AV_AzureId__c));
        System.enqueueJob(new AV_TeamsGCF_Queueable(jsonString, ev.Subject, ev.EndDateTime, ev.StartDateTime, ev.AV_Task__c,emp.FederationIdentifier , emp.AV_AzureId__c));
        System.assertEquals('AV_Salesforce',ev.AV_origenApp__c,'validateQueueable');
        Test.stopTest();
    }
    
    @isTest
    private static void validateQueueableSinAzure() {
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_Teams_Integration.AV_TEAMSLOGIN);
        String tenant=dataInterface.CC_SoapAction__c.substringAfter('=');
        String urlLogin = 'callout:MICROSOFT_TEAMS/{tenant}/oauth2/v2.0/token'.replace('{tenant}',tenant);
        Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
        header2TestResp.put(urlLogin, new AV_MockCallout_Test('TEAMS_LOGIN','OK'));
        header2TestResp.put('callout:MICROSOFT/v1.0/users/U01test_teams_caixa@caixabankpre.com',new AV_MockCallout_Test('TEAMS_GETUSERID','OK'));
        header2TestResp.put('callout:MICROSOFT/v1.0/users/415b41e6-28ab-4ef1-9f46-13a6d53eb368/onlineMeetings',new AV_MockCallout_Test('TEAMS_GETURL','OK'));
        header2TestResp.put('callout:API_GWT_PRO/servicing/employees/U0009003/activities/eventsPremium', new AV_MockCallout_Test('CP_MOCNT','OK'));
        HttpCalloutMock multiCalloutMock = new AV_MultiRequestMock_Test(header2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Event ev = [Select Id, IsRecurrence2, AV_origenApp__c, IsRecurrence, WhatId, OwnerId, AV_ExternalId__c, AV_CodigoGestorAsignado__c, CreatedDate, Subject, RecordTypeId, Description, AV_Tipo__c, CSBD_Evento_Estado__c, AV_BranchPhysicalMeet__c, Location, StartDateTime, EndDateTime, isPrivate, AV_Task__c from Event limit 1];
		User emp = [Select Id, AV_ExternalID__c, AV_AzureId__c,FederationIdentifier From User Where AV_ExternalID__c = 'U01231231231231' limit 1];
        emp.FederationIdentifier = 'U01test_teams_caixa@caixabankpre.com';
        update emp;
        Test.startTest();
		String jsonString = json.serialize(ev);
        System.enqueueJob(new AV_TeamsGCF_Queueable(jsonString, ev.Subject, ev.EndDateTime, ev.StartDateTime, ev.AV_Task__c,emp.FederationIdentifier , emp.AV_AzureId__c));
        System.assertEquals('AV_Salesforce',ev.AV_origenApp__c,'validateQueueableSinAzure');
        Test.stopTest();
    }
    
    @isTest
    private static void validateInsertEventGCFFuture() {
        Event ev = [Select Id, IsRecurrence2, AV_origenApp__c, IsRecurrence, WhatId, OwnerId, AV_ExternalId__c, AV_CodigoGestorAsignado__c, CreatedDate, Subject, RecordTypeId, Description, AV_Tipo__c, CSBD_Evento_Estado__c, AV_BranchPhysicalMeet__c, Location, StartDateTime, EndDateTime, isPrivate, AV_Task__c from Event limit 1];
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        Test.startTest();
		String jsonString = json.serialize(ev);
        AV_TeamsGCF_Queueable.insertEventGCFFuture(jsonString);
        System.assertEquals('AV_Salesforce',ev.AV_origenApp__c,'validateInsertEventGCFFuture');

        Test.stopTest();
    }
}