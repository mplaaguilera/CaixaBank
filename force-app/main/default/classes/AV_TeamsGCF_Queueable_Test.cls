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
	1.1		       Fix PMD Errors 	        Daniel Rodriguez	20/11/2023	    	Modified test to increase coverage and add runAss
***********************************************************************************************************************/
@isTest
public with sharing class AV_TeamsGCF_Queueable_Test {
    @TestSetup
	static void setup(){
	      AV_TestHelper.activateLogger();
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User usuarioCli =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];
        System.runAs(userGcf){
            User userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
            userGestor.Email = 'gestor-test@test.com';
            userGestor.AV_AzureId__c = 'eae66be1-fd82-45d1-9cce-022a6a4a2c87';
            userGestor.FederationIdentifier = 'U01test_teams_caixa@caixabankpre.com';
            List<User> listUserInsert = new List<User>();
            listUserInsert.add(userGestor);
            insert listUserInsert;
            AV_TestHelper.insertNeededPermissions(userGestor);
            Account centro = AV_TestHelper.createCaixaCenter();
            Contact empleado = AV_TestHelper.createEmployee(centro,userGestor,userGestor.AV_ExternalID__c);
            Account acc= AV_TestHelper.createCustomerSinInsert();
            acc.OwnerId = userGestor.Id;
            acc.AV_EAPGestor__c=empleado.Id;
            insert acc;
            Event event = AV_TestHelper.createEventVideocCall(userGestor, DateTime.now(), acc);
        }
	}
    
    
    @isTest
    private static void validateQueueable() {
        
        AV_AzureTeamsToken__c cs = new AV_AzureTeamsToken__c();
        cs.Name = 'AzureTeamToken';
        cs.AV_ExpiresIn__c = 0;
        insert cs;
                List<User> empAdmin = [SELECT Id, AV_ExternalID__c, AV_AzureId__c,FederationIdentifier FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];
        empAdmin[0].FederationIdentifier = 'U01test_teams_caixa@caixabankpre.com';
        update empAdmin;
        String Response = '{Body={"tokenType":"Bearer","expiresIn":86399,"extExpiresIn":86399,"accessToken":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IjhpUm54QmFEeXNQd0pTb0Rtd1lqQllGS2pqby1QS2sweldYN3dOYkRVLUUiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWF0IjoxNjE4OTkyOTYxLCJuYmYiOjE2MTg5OTI5NjEsImV4cCI6MTYxOTA3OTY2MSwiYWlvIjoiRTJaZ1lQaXJ4N2xVNE11bEU5ZVlqMjY0VlBsME5nQT0iLCJhcHBfZGlzcGxheW5hbWUiOiJUdXRvcmlhbCBTYW1wbGUgQXBwIiwiYXBwaWQiOiI2NzMxZGU3Ni0xNGE2LTQ5YWUtOTdiYy02ZWJhNjkxNDM5MWUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiJhODRkYjQ0YS1jZTlhLTQ4N2UtYTgxYi1hMTFkOTEyZTRjMGQiLCJyaCI6IjAuQVJvQXY0ajVjdkdHcjBHUnF5MTgwQkhiUjNiZU1XZW1GSzVKbDd4dXVta1VPUjRhQUFBLiIsInN1YiI6ImE4NGRiNDRhLWNlOWEtNDg3ZS1hODFiLWExMWQ5MTJlNGMwZCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJXVyIsInRpZCI6IjcyZjk4OGJmLTg2ZjEtNDFhZi05MWFiLTJkN2NkMDExZGI0NyIsInV0aSI6InlxYXkzc2FLVDBhTXNEMWVmQlBJQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfdGNkdCI6MTI4OTI0MTU0N30.fxx3i9FDTx10PK5l5d4TcxOWepZ5eYK7HAsUcCV19Q9iFQPR9sFOOFCR0NHaChDPwS4jfnZQzhcqA0PnrUhLl8PakVxn9WJP3Dls55JUZYyoDnYZ_rT4tNc0eq4Al-K7SWj977yIRRUAdmwqo39-jHMULD9YTBEBM6YZFxaaBjA26tWAj3tb-HIPgcjFkdGXiWFnqfDX1xZtSSUz8jq2nVqqXL4UUiYx7jShA0CsHR49St0pWiPsaRGv4bPrhST5C7xHm1o9ltFhRk8pVGNf0fPEusOHo4jBMP8cBNAxOCel6_A9_d70j3Q6aAMyM0MKv2MhTQ5JTNS23XjiTX4RcQ"}, Status=OK, StatusCode=201, TimeElapsed=345}';          
		AV_Teams_Integration.Response resp;
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_Teams_Integration.AV_TEAMSLOGIN);
        String tenant=dataInterface.CC_SoapAction__c.substringAfter('=');
        String urlLogin = 'callout:MICROSOFT_TEAMS/{tenant}/oauth2/v2.0/token'.replace('{tenant}',tenant);
                    Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
            header2TestResp.put(urlLogin, new AV_MockCallout_Test('TEAMS_LOGIN','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/U01test_teams_caixa@caixabankpre.com',new AV_MockCallout_Test('TEAMS_GETUSERID','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/eae66be1-fd82-45d1-9cce-022a6a4a2c87/onlineMeetings',new AV_MockCallout_Test('TEAMS_GETURL','OK'));
            header2TestResp.put('callout:API_GWT_PRO/servicing/employees/U01545454/activities/eventsPremium', new AV_MockCallout_Test('CP_MOCNT','OK'));
            header2TestResp.put('callout:API_GWT_PRO/servicing/employees/U01545454/activities/eventsPremium', new AV_MockCallout_Test('BODY_TEAMS','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/U01test_teams_caixa@caixabankpre.com',new AV_MockCallout_Test('BODY_TEAMS','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/eae66be1-fd82-45d1-9cce-022a6a4a2c87/onlineMeetings',new AV_MockCallout_Test('BODY_TEAMS','OK'));
            header2TestResp.put(urlLogin, new AV_MockCallout_Test('BODY_TEAMS','OK'));
            HttpCalloutMock multiCalloutMock = new AV_MultiRequestMock_Test(header2TestResp);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];
        System.runAs(runAsUser) {
            List<Event> ev = [SELECT Id, IsRecurrence2, AV_origenApp__c, IsRecurrence, WhatId, OwnerId, AV_ExternalId__c, AV_CodigoGestorAsignado__c, CreatedDate, Subject, RecordTypeId, Description, AV_Tipo__c, CSBD_Evento_Estado__c, AV_BranchPhysicalMeet__c, Location, StartDateTime, EndDateTime, isPrivate, AV_Task__c FROM Event LIMIT 1];
            List<User> emp = [SELECT Id, AV_ExternalID__c, AV_AzureId__c,FederationIdentifier FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];       
            String jsonString = json.serialize(ev[0]);
            Test.startTest();
            System.enqueueJob(new AV_TeamsGCF_Queueable(jsonString, ev[0].Subject, ev[0].EndDateTime, ev[0].StartDateTime, ev[0].AV_Task__c,emp[0].FederationIdentifier , emp[0].AV_AzureId__c));
            System.enqueueJob(new AV_TeamsGCF_Queueable(jsonString, ev[0].Subject, ev[0].EndDateTime, ev[0].StartDateTime, ev[0].AV_Task__c,emp[0].FederationIdentifier , emp[0].AV_AzureId__c));
            System.assertEquals('AV_Salesforce',ev[0].AV_origenApp__c,'validateQueueable');
            Test.stopTest();
        }
    }

    @isTest
    private static void validateQueueable2() {
        
        AV_AzureTeamsToken__c cs = new AV_AzureTeamsToken__c();
        cs.Name = 'AzureTeamToken';
        insert cs;
                List<User> empAdmin = [SELECT Id, AV_ExternalID__c, AV_AzureId__c,FederationIdentifier FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];
        empAdmin[0].FederationIdentifier = 'U01test_teams_caixa@caixabankpre.com';
        update empAdmin;
        String Response = '{Body={"tokenType":"Bearer","expiresIn":86399,"extExpiresIn":86399,"accessToken":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IjhpUm54QmFEeXNQd0pTb0Rtd1lqQllGS2pqby1QS2sweldYN3dOYkRVLUUiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWF0IjoxNjE4OTkyOTYxLCJuYmYiOjE2MTg5OTI5NjEsImV4cCI6MTYxOTA3OTY2MSwiYWlvIjoiRTJaZ1lQaXJ4N2xVNE11bEU5ZVlqMjY0VlBsME5nQT0iLCJhcHBfZGlzcGxheW5hbWUiOiJUdXRvcmlhbCBTYW1wbGUgQXBwIiwiYXBwaWQiOiI2NzMxZGU3Ni0xNGE2LTQ5YWUtOTdiYy02ZWJhNjkxNDM5MWUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiJhODRkYjQ0YS1jZTlhLTQ4N2UtYTgxYi1hMTFkOTEyZTRjMGQiLCJyaCI6IjAuQVJvQXY0ajVjdkdHcjBHUnF5MTgwQkhiUjNiZU1XZW1GSzVKbDd4dXVta1VPUjRhQUFBLiIsInN1YiI6ImE4NGRiNDRhLWNlOWEtNDg3ZS1hODFiLWExMWQ5MTJlNGMwZCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJXVyIsInRpZCI6IjcyZjk4OGJmLTg2ZjEtNDFhZi05MWFiLTJkN2NkMDExZGI0NyIsInV0aSI6InlxYXkzc2FLVDBhTXNEMWVmQlBJQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfdGNkdCI6MTI4OTI0MTU0N30.fxx3i9FDTx10PK5l5d4TcxOWepZ5eYK7HAsUcCV19Q9iFQPR9sFOOFCR0NHaChDPwS4jfnZQzhcqA0PnrUhLl8PakVxn9WJP3Dls55JUZYyoDnYZ_rT4tNc0eq4Al-K7SWj977yIRRUAdmwqo39-jHMULD9YTBEBM6YZFxaaBjA26tWAj3tb-HIPgcjFkdGXiWFnqfDX1xZtSSUz8jq2nVqqXL4UUiYx7jShA0CsHR49St0pWiPsaRGv4bPrhST5C7xHm1o9ltFhRk8pVGNf0fPEusOHo4jBMP8cBNAxOCel6_A9_d70j3Q6aAMyM0MKv2MhTQ5JTNS23XjiTX4RcQ"}, Status=OK, StatusCode=201, TimeElapsed=345}';          
		AV_Teams_Integration.Response resp;
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_Teams_Integration.AV_TEAMSLOGIN);
        String tenant=dataInterface.CC_SoapAction__c.substringAfter('=');
        String urlLogin = 'callout:MICROSOFT_TEAMS/{tenant}/oauth2/v2.0/token'.replace('{tenant}',tenant);
                    Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
            header2TestResp.put(urlLogin, new AV_MockCallout_Test('TEAMS_LOGIN','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/U01test_teams_caixa@caixabankpre.com',new AV_MockCallout_Test('TEAMS_GETUSERID','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/eae66be1-fd82-45d1-9cce-022a6a4a2c87/onlineMeetings',new AV_MockCallout_Test('TEAMS_GETURL','OK'));
            header2TestResp.put('callout:API_GWT_PRO/servicing/employees/U01545454/activities/eventsPremium', new AV_MockCallout_Test('CP_MOCNT','OK'));
            header2TestResp.put('callout:API_GWT_PRO/servicing/employees/U01545454/activities/eventsPremium', new AV_MockCallout_Test('BODY_TEAMS','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/U01test_teams_caixa@caixabankpre.com',new AV_MockCallout_Test('BODY_TEAMS','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/eae66be1-fd82-45d1-9cce-022a6a4a2c87/onlineMeetings',new AV_MockCallout_Test('BODY_TEAMS','OK'));
            header2TestResp.put(urlLogin, new AV_MockCallout_Test('BODY_TEAMS','OK'));
            HttpCalloutMock multiCalloutMock = new AV_MultiRequestMock_Test(header2TestResp);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];
        System.runAs(runAsUser) {
            List<Event> ev = [SELECT Id, IsRecurrence2, AV_origenApp__c, IsRecurrence, WhatId, OwnerId, AV_ExternalId__c, AV_CodigoGestorAsignado__c, CreatedDate, Subject, RecordTypeId, Description, AV_Tipo__c, CSBD_Evento_Estado__c, AV_BranchPhysicalMeet__c, Location, StartDateTime, EndDateTime, isPrivate, AV_Task__c FROM Event LIMIT 1];
            List<User> emp = [SELECT Id, AV_ExternalID__c, AV_AzureId__c,FederationIdentifier FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];       
            String jsonString = json.serialize(ev[0]);
            Test.startTest();
            System.enqueueJob(new AV_TeamsGCF_Queueable(jsonString, ev[0].Subject, ev[0].EndDateTime, ev[0].StartDateTime, ev[0].AV_Task__c,emp[0].FederationIdentifier , emp[0].AV_AzureId__c));
            System.enqueueJob(new AV_TeamsGCF_Queueable(jsonString, ev[0].Subject, ev[0].EndDateTime, ev[0].StartDateTime, ev[0].AV_Task__c,emp[0].FederationIdentifier , emp[0].AV_AzureId__c));
            System.assertEquals('AV_Salesforce',ev[0].AV_origenApp__c,'validateQueueable');
            Test.stopTest();
        }
    }

  
   
    @isTest
    private static void validateInsertEventGCFFuture() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		System.runAs(userGcf){
            String Response = '{Body={"tokenType":"Bearer","expiresIn":86399,"extExpiresIn":86399,"accessToken":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IjhpUm54QmFEeXNQd0pTb0Rtd1lqQllGS2pqby1QS2sweldYN3dOYkRVLUUiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWF0IjoxNjE4OTkyOTYxLCJuYmYiOjE2MTg5OTI5NjEsImV4cCI6MTYxOTA3OTY2MSwiYWlvIjoiRTJaZ1lQaXJ4N2xVNE11bEU5ZVlqMjY0VlBsME5nQT0iLCJhcHBfZGlzcGxheW5hbWUiOiJUdXRvcmlhbCBTYW1wbGUgQXBwIiwiYXBwaWQiOiI2NzMxZGU3Ni0xNGE2LTQ5YWUtOTdiYy02ZWJhNjkxNDM5MWUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiJhODRkYjQ0YS1jZTlhLTQ4N2UtYTgxYi1hMTFkOTEyZTRjMGQiLCJyaCI6IjAuQVJvQXY0ajVjdkdHcjBHUnF5MTgwQkhiUjNiZU1XZW1GSzVKbDd4dXVta1VPUjRhQUFBLiIsInN1YiI6ImE4NGRiNDRhLWNlOWEtNDg3ZS1hODFiLWExMWQ5MTJlNGMwZCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJXVyIsInRpZCI6IjcyZjk4OGJmLTg2ZjEtNDFhZi05MWFiLTJkN2NkMDExZGI0NyIsInV0aSI6InlxYXkzc2FLVDBhTXNEMWVmQlBJQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfdGNkdCI6MTI4OTI0MTU0N30.fxx3i9FDTx10PK5l5d4TcxOWepZ5eYK7HAsUcCV19Q9iFQPR9sFOOFCR0NHaChDPwS4jfnZQzhcqA0PnrUhLl8PakVxn9WJP3Dls55JUZYyoDnYZ_rT4tNc0eq4Al-K7SWj977yIRRUAdmwqo39-jHMULD9YTBEBM6YZFxaaBjA26tWAj3tb-HIPgcjFkdGXiWFnqfDX1xZtSSUz8jq2nVqqXL4UUiYx7jShA0CsHR49St0pWiPsaRGv4bPrhST5C7xHm1o9ltFhRk8pVGNf0fPEusOHo4jBMP8cBNAxOCel6_A9_d70j3Q6aAMyM0MKv2MhTQ5JTNS23XjiTX4RcQ"}, Status=OK, StatusCode=201, TimeElapsed=345}';          
			AV_Teams_Integration.Response resp;
            Event ev = [Select Id, IsRecurrence2, AV_origenApp__c, IsRecurrence, WhatId, OwnerId, AV_ExternalId__c, AV_CodigoGestorAsignado__c, CreatedDate, Subject, RecordTypeId, Description, AV_Tipo__c, CSBD_Evento_Estado__c, AV_BranchPhysicalMeet__c, Location, StartDateTime, EndDateTime, isPrivate, AV_Task__c from Event limit 1];
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
            Test.startTest();
            String jsonString = json.serialize(ev);
            AV_TeamsGCF_Queueable.insertEventGCFFuture(jsonString);
            System.assertEquals('AV_Salesforce',ev.AV_origenApp__c,'validateInsertEventGCFFuture');

            Test.stopTest();
        }
    }
    
        @isTest
    private static void getTokenStringTest(){
         User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
         String[] parts = new String[]{'Parte1', 'Parte2', 'Parte3', null, '', 'Parte4'};
             String Response = '{Body={"tokenType":"Bearer","expiresIn":86399,"extExpiresIn":86399,"accessToken":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IjhpUm54QmFEeXNQd0pTb0Rtd1lqQllGS2pqby1QS2sweldYN3dOYkRVLUUiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWF0IjoxNjE4OTkyOTYxLCJuYmYiOjE2MTg5OTI5NjEsImV4cCI6MTYxOTA3OTY2MSwiYWlvIjoiRTJaZ1lQaXJ4N2xVNE11bEU5ZVlqMjY0VlBsME5nQT0iLCJhcHBfZGlzcGxheW5hbWUiOiJUdXRvcmlhbCBTYW1wbGUgQXBwIiwiYXBwaWQiOiI2NzMxZGU3Ni0xNGE2LTQ5YWUtOTdiYy02ZWJhNjkxNDM5MWUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiJhODRkYjQ0YS1jZTlhLTQ4N2UtYTgxYi1hMTFkOTEyZTRjMGQiLCJyaCI6IjAuQVJvQXY0ajVjdkdHcjBHUnF5MTgwQkhiUjNiZU1XZW1GSzVKbDd4dXVta1VPUjRhQUFBLiIsInN1YiI6ImE4NGRiNDRhLWNlOWEtNDg3ZS1hODFiLWExMWQ5MTJlNGMwZCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJXVyIsInRpZCI6IjcyZjk4OGJmLTg2ZjEtNDFhZi05MWFiLTJkN2NkMDExZGI0NyIsInV0aSI6InlxYXkzc2FLVDBhTXNEMWVmQlBJQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfdGNkdCI6MTI4OTI0MTU0N30.fxx3i9FDTx10PK5l5d4TcxOWepZ5eYK7HAsUcCV19Q9iFQPR9sFOOFCR0NHaChDPwS4jfnZQzhcqA0PnrUhLl8PakVxn9WJP3Dls55JUZYyoDnYZ_rT4tNc0eq4Al-K7SWj977yIRRUAdmwqo39-jHMULD9YTBEBM6YZFxaaBjA26tWAj3tb-HIPgcjFkdGXiWFnqfDX1xZtSSUz8jq2nVqqXL4UUiYx7jShA0CsHR49St0pWiPsaRGv4bPrhST5C7xHm1o9ltFhRk8pVGNf0fPEusOHo4jBMP8cBNAxOCel6_A9_d70j3Q6aAMyM0MKv2MhTQ5JTNS23XjiTX4RcQ"}, Status=OK, StatusCode=201, TimeElapsed=345}';          
			AV_Teams_Integration.Response resp;
         System.runAs(userGcf){
            Test.startTest();
                String result = AV_Teams_Integration.getTokenString(parts);
               System.assertEquals('Parte1Parte2Parte3Parte4', result);
            Test.stopTest();
        }
    }
}