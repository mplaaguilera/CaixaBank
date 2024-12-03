/**********************************************************************************************************************
Name:      AV_Teams_Integration_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: test de Integración con Teams
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY 				AUTHOR              DATE                Description
    1.0            US153037 - Teams    		Jashanpreet         02/06/2021          Init version
	1.1            Fix CS		    		David Rufo	     	05/10/2021          CustomSetting update when exist
    1.2			   AV_Query IT		        Daniel Rodríguez	3/02/2022			Change AV_Query to SOQL for User and Account

***********************************************************************************************************************/
@isTest
public with sharing class AV_Teams_Integration_Test {
    
    @TestSetup
	static void setup(){
		AV_TestHelper.activateLogger();
        Account centro = AV_TestHelper.createCaixaCenter();
        User us= AV_TestHelper.createUser('AV_Usuario_CaixaBank');
        Contact empleado = AV_TestHelper.createEmployee(centro,us,us.AV_ExternalID__c);
        Account acc= AV_TestHelper.createCustomer();
        acc.OwnerId = us.Id;
        acc.AV_EAPGestor__c=empleado.Id;
        update acc;
	}

    /**
	 * Validate Sync videoCall
	 */
    @isTest
    private static void validateCreateOnlineMeetingWithCS() {
        AV_AzureTeamsToken__c cs = new AV_AzureTeamsToken__c();
        cs.Name = 'AzureTeamToken';
        cs.AV_ExpiresIn__c = 0; //Zero so cs.LastModifiedDate < now and syncCJ calls login method
        insert cs;
        createOnlineMeeting();
    }
    
    /**
	 * Validate Sync videoCall
	 */
    @isTest
    private static void validateCreateOnlineMeetingNoCS() {
        createOnlineMeeting();
    }
    
    private static void createOnlineMeeting(){
        String methodName = 'createOnlineMeeting';
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_Teams_Integration.AV_TEAMSLOGIN);
        String tenant=dataInterface.CC_SoapAction__c.substringAfter('=');
        String urlLogin = 'callout:MICROSOFT_TEAMS/{tenant}/oauth2/v2.0/token'.replace('{tenant}',tenant);
        Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
        header2TestResp.put(urlLogin, new AV_MockCallout_Test('TEAMS_LOGIN','OK'));
        header2TestResp.put('callout:MICROSOFT/v1.0/users/U01test_teams_caixa@caixabankpre.com',new AV_MockCallout_Test('TEAMS_GETUSERID','OK'));
        header2TestResp.put('callout:MICROSOFT/v1.0/users/415b41e6-28ab-4ef1-9f46-13a6d53eb368/onlineMeetings',new AV_MockCallout_Test('TEAMS_GETURL','OK'));
        header2TestResp.put('callout:API_GWT_TST/servicing/employees/U0009003/activities/eventsPremium', new AV_MockCallout_Test('CP_MOCNT','OK'));
        HttpCalloutMock multiCalloutMock = new AV_MultiRequestMock_Test(header2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        User user  = [Select Id From User Where Email = 'test@test.dev' limit 1];
        user.FederationIdentifier = 'U01test_teams_caixa@caixabankpre.com';
        update user;
        Test.startTest();
        Account acc= [Select Id from Account where recordType.DeveloperName='CC_ClientePA' limit 1];
        System.runAs(user) {
            Event event = AV_TestHelper.createEventVideocCall(user, DateTime.now(), acc);
        }
        Event ev =[Select Id, AV_Task__c,OwnerId from Event limit 1];
        List<List<String>> fields = new List<List<String>>();
        fields.add(new List<String>{ev.Id});
        Test.stopTest();
    }
}