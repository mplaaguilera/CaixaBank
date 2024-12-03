/**********************************************************************************************************************
Name:      AV_Teams_Integration_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: test de Integración con Teams
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY               AUTHOR              DATE                Description
    1.0            US153037 - Teams         Jashanpreet         02/06/2021          Init version
    1.1            Fix CS                   David Rufo          05/10/2021          CustomSetting update when exist
    1.2            AV_Query IT              Daniel Rodríguez    3/02/2022           Change AV_Query to SOQL for User and Account
    1.3            US649249                 Oscar Moreno        24/11/2023          Add processBodyTest and getTokenStringTest methods
    1.4            QC                       Oscar Moreno        05/06/2024          Comments MockHttpResponseGenerator class
 
***********************************************************************************************************************/
@isTest
public with sharing class AV_Teams_Integration_Test {
   
    @TestSetup
    static void setup(){
        AV_TestHelper.activateLogger();
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User usuarioCli =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];
        System.runAs(userGcf){
            User userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
            userGestor.Email = 'gestor-test@test.com';
            User usrTest = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01543678');
            List<User> listUserInsert = new List<User>();
            listUserInsert.add(userGestor);
            listUserInsert.add(usrTest);
            insert listUserInsert;
            List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
            List<PermissionSet> perSet = [SELECT Id FROM PermissionSet WHERE Name IN :new List<String>{ 'AV_GestorOperativa', 'AV_CustomMetadata' }];
            for(PermissionSet ps : perSet) {
                permissionSetList.add(
                    new PermissionSetAssignment(
                        AssigneeId = userGestor.Id,
                        PermissionSetId = ps.Id
                ));
            }
            if(!permissionSetList.isEmpty()) {
                insert permissionSetList;
            }
            Account centro = AV_TestHelper.createCaixaCenter();
            Contact empleado = AV_TestHelper.createEmployee(centro,userGestor,userGestor.AV_ExternalID__c);
            Account acc= AV_TestHelper.createCustomerSinInsert();
            acc.OwnerId = userGestor.Id;
            acc.AV_EAPGestor__c=empleado.Id;
            insert acc;
        }
    }
 
    
   
    /**
     * Validate Sync videoCall
     */
    /*@isTest
    private static void validateCreateOnlineMeetingNoCS() {
        createOnlineMeeting();
    }*/
    @isTest
    private static void getUserIdTest(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
 
            Test.startTest();
            AV_AzureTeamsToken__c cs = new AV_AzureTeamsToken__c();
            cs.Name = 'AzureTeamToken';
            cs.AV_ExpiresIn__c = 0; //Zero so cs.LastModifiedDate < now and syncCJ calls login method
            insert cs;
            CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_Teams_Integration.AV_TEAMSLOGIN);
            String tenant=dataInterface.CC_SoapAction__c.substringAfter('=');
            String urlLogin = 'callout:MICROSOFT_TEAMS/{tenant}/oauth2/v2.0/token'.replace('{tenant}',tenant);
            Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
            header2TestResp.put(urlLogin, new AV_MockCallout_Test('TEAMS_LOGIN','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/U01test_teams_caixa@caixabankpre.com',new AV_MockCallout_Test('TEAMS_GETUSERID','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/415b41e6-28ab-4ef1-9f46-13a6d53eb368/onlineMeetings',new AV_MockCallout_Test('TEAMS_GETURL','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/415b41e6-28ab-4ef1-9f46-13a6d53eb368/onlineMeetings',new AV_MockCallout_Test('TEAMS_GETURL','OK'));
            header2TestResp.put('callout:API_GWT_PRO/servicing/employees/U01545454/activities/eventsPremium', new AV_MockCallout_Test('CP_MOCNT','OK'));
            HttpCalloutMock multiCalloutMock = new AV_MultiRequestMock_Test(header2TestResp);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            //certificate=SF-MicrosoftTeams, dataMockup=null, debugMode=true, endpoint=callout:MICROSOFT_TEAMS/eccgcpre.onmicrosoft.com/oauth2/v2.0/token, errorMessage=null, exportBodyAsBlob=false, exportFullResponse=false, headers={Accept=application/json, Content-Type=application/x-www-form-urlencoded}, isActive=true, isSOAP=false, method=POST, response={ErrorDetail=null, StatusCode=200, TimeElapsed=5}, timeout=60000]
            //string Response =  '{"token_type":"Bearer","expires_in":86399,"ext_expires_in":86399,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IjhpUm54QmFEeXNQd0pTb0Rtd1lqQllGS2pqby1QS2sweldYN3dOYkRVLUUiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWF0IjoxNjE4OTkyOTYxLCJuYmYiOjE2MTg5OTI5NjEsImV4cCI6MTYxOTA3OTY2MSwiYWlvIjoiRTJaZ1lQaXJ4N2xVNE11bEU5ZVlqMjY0VlBsME5nQT0iLCJhcHBfZGlzcGxheW5hbWUiOiJUdXRvcmlhbCBTYW1wbGUgQXBwIiwiYXBwaWQiOiI2NzMxZGU3Ni0xNGE2LTQ5YWUtOTdiYy02ZWJhNjkxNDM5MWUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiJhODRkYjQ0YS1jZTlhLTQ4N2UtYTgxYi1hMTFkOTEyZTRjMGQiLCJyaCI6IjAuQVJvQXY0ajVjdkdHcjBHUnF5MTgwQkhiUjNiZU1XZW1GSzVKbDd4dXVta1VPUjRhQUFBLiIsInN1YiI6ImE4NGRiNDRhLWNlOWEtNDg3ZS1hODFiLWExMWQ5MTJlNGMwZCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJXVyIsInRpZCI6IjcyZjk4OGJmLTg2ZjEtNDFhZi05MWFiLTJkN2NkMDExZGI0NyIsInV0aSI6InlxYXkzc2FLVDBhTXNEMWVmQlBJQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfdGNkdCI6MTI4OTI0MTU0N30.fxx3i9FDTx10PK5l5d4TcxOWepZ5eYK7HAsUcCV19Q9iFQPR9sFOOFCR0NHaChDPwS4jfnZQzhcqA0PnrUhLl8PakVxn9WJP3Dls55JUZYyoDnYZ_rT4tNc0eq4Al-K7SWj977yIRRUAdmwqo39-jHMULD9YTBEBM6YZFxaaBjA26tWAj3tb-HIPgcjFkdGXiWFnqfDX1xZtSSUz8jq2nVqqXL4UUiYx7jShA0CsHR49St0pWiPsaRGv4bPrhST5C7xHm1o9ltFhRk8pVGNf0fPEusOHo4jBMP8cBNAxOCel6_A9_d70j3Q6aAMyM0MKv2MhTQ5JTNS23XjiTX4RcQ"}, Status=OK, StatusCode=200, TimeElapsed=345}';    
 
     
 
            User user  = [select id, username from user where AV_ExternalID__c = 'U01545454' limit 1];
            user.FederationIdentifier = 'U01test_teams_caixa@caixabankpre.com';
            user.AV_AzureId__c = '415b41e6-28ab-4ef1-9f46-13a6d53eb368';
            update user;
            Account acc= [Select Id from Account where recordType.DeveloperName='CC_ClientePA' limit 1];
            
            //Response resultMethod = new Response();
            String userIdResp;
            System.runAs(user){
                // Event event = AV_TestHelper.createEventVideocCall(user, DateTime.now(), acc);
                
                // Event ev =[Select Id, AV_Task__c,OwnerId from Event limit 1];
                // List<List<String>> fields = new List<List<String>>();
                // fields.add(new List<String>{ev.Id});
            try{
                userIdResp = AV_Teams_Integration.getUserId('415b41e6-28ab-4ef1-9f46-13a6d53eb368', user.username);
            }catch(Exception e){
                System.assert(!String.isEmpty(userIdResp), 'getUserIdTest: User ID is empty');
                }
            Test.stopTest();
    }
}
   
    @isTest
    private static void getTokenTest(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        System.runAs(userGcf){
           
            AV_AzureTeamsToken__c cs = new AV_AzureTeamsToken__c();
            cs.Name = 'AzureTeamToken';
            cs.AV_ExpiresIn__c = 0; //Zero so cs.LastModifiedDate < now and syncCJ calls login method
            insert cs;
            String methodName = 'createOnlineMeeting';
            CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_Teams_Integration.AV_TEAMSLOGIN);
            String tenant=dataInterface.CC_SoapAction__c.substringAfter('=');
            String urlLogin = 'callout:MICROSOFT_TEAMS/{tenant}/oauth2/v2.0/token'.replace('{tenant}',tenant);
            String Response = '{Body={"token_type":"Bearer","expires_in":86399,"ext_expires_in":86399,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IjhpUm54QmFEeXNQd0pTb0Rtd1lqQllGS2pqby1QS2sweldYN3dOYkRVLUUiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWF0IjoxNjE4OTkyOTYxLCJuYmYiOjE2MTg5OTI5NjEsImV4cCI6MTYxOTA3OTY2MSwiYWlvIjoiRTJaZ1lQaXJ4N2xVNE11bEU5ZVlqMjY0VlBsME5nQT0iLCJhcHBfZGlzcGxheW5hbWUiOiJUdXRvcmlhbCBTYW1wbGUgQXBwIiwiYXBwaWQiOiI2NzMxZGU3Ni0xNGE2LTQ5YWUtOTdiYy02ZWJhNjkxNDM5MWUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiJhODRkYjQ0YS1jZTlhLTQ4N2UtYTgxYi1hMTFkOTEyZTRjMGQiLCJyaCI6IjAuQVJvQXY0ajVjdkdHcjBHUnF5MTgwQkhiUjNiZU1XZW1GSzVKbDd4dXVta1VPUjRhQUFBLiIsInN1YiI6ImE4NGRiNDRhLWNlOWEtNDg3ZS1hODFiLWExMWQ5MTJlNGMwZCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJXVyIsInRpZCI6IjcyZjk4OGJmLTg2ZjEtNDFhZi05MWFiLTJkN2NkMDExZGI0NyIsInV0aSI6InlxYXkzc2FLVDBhTXNEMWVmQlBJQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfdGNkdCI6MTI4OTI0MTU0N30.fxx3i9FDTx10PK5l5d4TcxOWepZ5eYK7HAsUcCV19Q9iFQPR9sFOOFCR0NHaChDPwS4jfnZQzhcqA0PnrUhLl8PakVxn9WJP3Dls55JUZYyoDnYZ_rT4tNc0eq4Al-K7SWj977yIRRUAdmwqo39-jHMULD9YTBEBM6YZFxaaBjA26tWAj3tb-HIPgcjFkdGXiWFnqfDX1xZtSSUz8jq2nVqqXL4UUiYx7jShA0CsHR49St0pWiPsaRGv4bPrhST5C7xHm1o9ltFhRk8pVGNf0fPEusOHo4jBMP8cBNAxOCel6_A9_d70j3Q6aAMyM0MKv2MhTQ5JTNS23XjiTX4RcQ"}, Status=OK, StatusCode=200, TimeElapsed=345}';          
 
            Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
            header2TestResp.put(urlLogin, new AV_MockCallout_Test('TEAMS_LOGIN','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/U01test_teams_caixa@caixabankpre.com',new AV_MockCallout_Test('TEAMS_GETUSERID','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/415b41e6-28ab-4ef1-9f46-13a6d53eb368/onlineMeetings',new AV_MockCallout_Test('TEAMS_GETURL','OK'));
            header2TestResp.put('callout:API_GWT_PRO/servicing/employees/U01545454/activities/eventsPremium', new AV_MockCallout_Test('CP_MOCNT','OK'));
            header2TestResp.put('callout:API_GWT_PRO/servicing/employees/U01545454/activities/eventsPremium', new AV_MockCallout_Test('BODY_TEAMS','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/U01test_teams_caixa@caixabankpre.com',new AV_MockCallout_Test('BODY_TEAMS','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/415b41e6-28ab-4ef1-9f46-13a6d53eb368/onlineMeetings',new AV_MockCallout_Test('BODY_TEAMS','OK'));
            header2TestResp.put(urlLogin, new AV_MockCallout_Test('BODY_TEAMS','OK'));
            HttpCalloutMock multiCalloutMock = new AV_MultiRequestMock_Test(header2TestResp);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
 
            User user  = [select id, username from user where AV_ExternalID__c = 'U01545454' limit 1];
            user.FederationIdentifier = 'U01test_teams_caixa@caixabankpre.com';
            update user;
            Account acc= [Select Id from Account where recordType.DeveloperName='CC_ClientePA' limit 1];
            Event event = AV_TestHelper.createEventVideocCall(user, DateTime.now(), acc);
 
            Event ev =[Select Id, AV_Task__c,OwnerId from Event limit 1];
            List<List<String>> fields = new List<List<String>>();
            fields.add(new List<String>{ev.Id});
            AV_Teams_Integration.Response resp;
            Test.startTest();
            try{
                resp = AV_Teams_Integration.getToken();
                System.assert(resp.statusCode != null, 'Respons is empty');
            }catch(Exception e){
                e.getMessage();
                }
            Test.stopTest();
        }
    }
   
    @isTest
    private static void createOnlineMeetingTest(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        userGcf.FederationIdentifier = 'U0186920@lacaixa.es.old20221107123433';
        userGcf.AV_AzureId__c = '31a1b7ef-95e1-4f4b-b98f-719f1233fd54';
        update userGcf;
        System.runAs(userGcf){
           
            AV_AzureTeamsToken__c cs = new AV_AzureTeamsToken__c();
            cs.Name = 'AzureTeamToken';
            cs.AV_ExpiresIn__c = 0; //Zero so cs.LastModifiedDate < now and syncCJ calls login method
            insert cs;
            String methodName = 'createOnlineMeeting';
            CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_Teams_Integration.AV_TEAMSLOGIN);
            String tenant=dataInterface.CC_SoapAction__c.substringAfter('=');
            String urlLogin = 'callout:MICROSOFT_TEAMS/{tenant}/oauth2/v2.0/token'.replace('{tenant}',tenant);
            Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
            header2TestResp.put(urlLogin, new AV_MockCallout_Test('TEAMS_LOGIN','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/U01test_teams_caixa@caixabankpre.com',new AV_MockCallout_Test('TEAMS_GETUSERID','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/31a1b7ef-95e1-4f4b-b98f-719f1233fd54/onlineMeetings',new AV_MockCallout_Test('TEAMS_GETURL','OK'));
            header2TestResp.put('callout:API_GWT_PRO/servicing/employees/U01545454/activities/eventsPremium', new AV_MockCallout_Test('CP_MOCNT','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/U01test_teams_caixa@caixabankpre.com',new AV_MockCallout_Test('BODY_TEAMS','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/31a1b7ef-95e1-4f4b-b98f-719f1233fd54/onlineMeetings',new AV_MockCallout_Test('BODY_TEAMS','OK'));
            header2TestResp.put(urlLogin, new AV_MockCallout_Test('BODY_TEAMS','OK'));
           /*header2TestResp.put('callout:MICROSOFT/v1.0/users/U01test_teams_caixa@caixabankpre.com',new AV_MockCallout_Test('SURVEY_FC','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/415b41e6-28ab-4ef1-9f46-13a6d53eb368/onlineMeetings',new AV_MockCallout_Test('SURVEY_FC','OK'));
            header2TestResp.put(urlLogin, new AV_MockCallout_Test('BODY_TEAMS','OK'));*/
            HttpCalloutMock multiCalloutMock = new AV_MultiRequestMock_Test(header2TestResp);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            User user  = [select id, username from user where AV_ExternalID__c = 'U01545454' limit 1];
            user.FederationIdentifier = 'U01test_teams_caixa@caixabankpre.com';
            update user;
            Account acc= [Select Id from Account where recordType.DeveloperName='CC_ClientePA' limit 1];
            Event event = AV_TestHelper.createEventVideocCall(user, DateTime.now(), acc);
 
            Event ev =[Select Id, AV_Task__c,OwnerId from Event limit 1];
            List<List<String>> fields = new List<List<String>>();
            fields.add(new List<String>{ev.Id});
            Boolean check = true;
            Test.startTest();
            try{
                AV_Teams_Integration.createOnlineMeeting(fields);
            }catch(Exception e){
                check = false;
                e.getMessage();
            }
            System.assert(check, 'createOnlineMeetingTest Error');
 
            Test.stopTest();
        }
    }
   
    @isTest
    private static void createMeetingTest(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        System.runAs(userGcf){
           
            AV_AzureTeamsToken__c cs = new AV_AzureTeamsToken__c();
            cs.Name = 'AzureTeamToken';
            cs.AV_ExpiresIn__c = 0; //Zero so cs.LastModifiedDate < now and syncCJ calls login method
            insert cs;
            String methodName = 'createOnlineMeeting';
            CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_Teams_Integration.AV_TEAMSLOGIN);
            String tenant=dataInterface.CC_SoapAction__c.substringAfter('=');
            String urlLogin = 'callout:MICROSOFT_TEAMS/{tenant}/oauth2/v2.0/token'.replace('{tenant}',tenant);
            Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
            header2TestResp.put(urlLogin, new AV_MockCallout_Test('TEAMS_LOGIN','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/U01test_teams_caixa@caixabankpre.com',new AV_MockCallout_Test('TEAMS_GETUSERID','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/415b41e6-28ab-4ef1-9f46-13a6d53eb368/onlineMeetings',new AV_MockCallout_Test('TEAMS_GETURL','OK'));
            header2TestResp.put('callout:API_GWT_PRO/servicing/employees/U01545454/activities/eventsPremium', new AV_MockCallout_Test('CP_MOCNT','OK'));
                        header2TestResp.put('callout:MICROSOFT/v1.0/users/U01test_teams_caixa@caixabankpre.com',new AV_MockCallout_Test('BODY_TEAMS','OK'));
            header2TestResp.put('callout:MICROSOFT/v1.0/users/415b41e6-28ab-4ef1-9f46-13a6d53eb368/onlineMeetings',new AV_MockCallout_Test('BODY_TEAMS','OK'));
            header2TestResp.put(urlLogin, new AV_MockCallout_Test('BODY_TEAMS','OK'));
            HttpCalloutMock multiCalloutMock = new AV_MultiRequestMock_Test(header2TestResp);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            User user  = [select id, username from user where AV_ExternalID__c = 'U01545454' limit 1];
            user.FederationIdentifier = 'U01test_teams_caixa@caixabankpre.com';
            update user;
            Account acc= [Select Id from Account where recordType.DeveloperName='CC_ClientePA' limit 1];
            Event event = AV_TestHelper.createEventVideocCall(user, DateTime.now(), acc);
 
            Event ev =[Select Id, AV_Task__c,OwnerId from Event limit 1];
            List<List<String>> fields = new List<List<String>>();
            fields.add(new List<String>{ev.Id});
            AV_Teams_Integration.Meeting met = new AV_Teams_Integration.Meeting();
            met.endDateTime = datetime.now();
            met.startDateTime = datetime.now().addMinutes(-10);
            met.subject = 'Test';
            String resp;
             Boolean check = true;
            Test.startTest();
            try{
                resp = AV_Teams_Integration.createMeeting('415b41e6-28ab-4ef1-9f46-13a6d53eb368',met, user.id);
            }catch(Exception e){
                 check = false;
                e.getMessage();
                }
               System.assertNotEquals(header2TestResp, null);
            Test.stopTest();
        }
    }
   
    @isTest
    private static void getTokenStringTest(){
         User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
         String[] parts = new String[]{'Parte1', 'Parte2', 'Parte3', null, '', 'Parte4'};
         System.runAs(userGcf){
            Test.startTest();
                String result = AV_Teams_Integration.getTokenString(parts);
               System.assertEquals('Parte1Parte2Parte3Parte4', result);
            Test.stopTest();
        }
    }
   
    @isTest
    static void processBodyTest() {
         User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
       
        AV_AzureTeamsToken__c tk = new AV_AzureTeamsToken__c();
        String input = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        System.runAs(userGcf){
            Test.startTest();
            AV_Teams_Integration.processBody(tk, input);
            System.assertEquals(input, tk.AV_Token1__c);
            System.assertEquals(null, tk.AV_Token2__c);
            Test.stopTest();
        }
    }
   
}