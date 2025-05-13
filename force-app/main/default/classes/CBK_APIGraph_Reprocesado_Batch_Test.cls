@isTest
public with sharing class CBK_APIGraph_Reprocesado_Batch_Test {
    @testSetup 
    static void setup() {
        CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'CBK_API_Graph_Forward';
		wsc.NamedCredential__c = 'https://graph.microsoft.com/v1.0/users/354a0728-b7c2-456a-8f87-9fde583019cd/messages/forward';
		insert wsc;

        CBK_IntegrationSetting__c wsc2 = new CBK_IntegrationSetting__c();
		wsc2.Name = 'CBK_APIGraphToken';
		wsc2.NamedCredential__c = 'https://login.microsoftonline.com/ebd21683-cc08-4afc-bb24-26ea85b81dd9/oauth2/v2.0/token';
		insert wsc2;

        CBK_IntegrationSetting__c wsc3 = new CBK_IntegrationSetting__c();
		wsc3.Name = 'CBK API Graph Named Credential';
		wsc3.NamedCredential__c = '	callout:Microsoft_API';
		insert wsc3;

        CBK_IntegrationToken_Setting__c settingToken = new CBK_IntegrationToken_Setting__c();
        settingToken.Name = 'TokenApiGraph';
        settingToken.ClientId__c = '3MVG96mGXeuuwTZgrnuYA9KgpHuCp59fLcIGSVWl5Za4Z3AO3zSHngLaWnsyljR8v3Pg1cuWLUOCcE_';
        settingToken.ClientSecret__c = '17995D773DF5273ED4B871D431EC6945BAFAE6252BA4C226FA238FA2866A0647';
        settingToken.CBK_GrantType__c = 'client_credentials';
        settingToken.CBK_Scope__c = 'https://graph.microsoft.com/.default';
        settingToken.Username__c = 'test';
        insert settingToken;

        CBK_APIGraph_Mailbox__c mailbox = new CBK_APIGraph_Mailbox__c();
        mailbox.name = 'ScheduleApiGraph';
        mailbox.CBK_MailboxID__c = '354a0728-b7c2-456a-8f87-9fde583019cd';
        mailbox.CBK_IntervalMinutes__c = 15;
        mailbox.CBK_OffsetMinutes__c = 5;
        mailbox.CBK_LastMonitoringDate__c = datetime.now();
        mailbox.CBK_NumberOfRetries__c = 5;
        mailbox.CBK_App__c = 'Test';
        mailbox.CBK_Forward__c = true;
		insert mailbox;

        CBK_ScheduleControls__c schInf = new CBK_ScheduleControls__c();
        schInf.name = 'ScheduleApiGraph';
        schInf.Retries__c = 5;
        schInf.ExecutionPeriod__c = 15;
        schInf.Date_Last_Execution__c = datetime.now();
        //schInf.CBK_LimitQuery__c = '2';
		insert schInf;

        Id recordTypeId = Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('CBK_AutditEmail').getRecordTypeId();
        List<CBK_Log__c> logs =  new List<CBK_Log__c>();
        CBK_Log__c result = new CBK_Log__c(); 
        result.recordTypeId = recordTypeId;
        result.CBK_hdExchangeParentMessageId__c = '';
        result.CBK_sfdcMessageId__c = '<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM>';
        result.CBK_sfdcResultStatus__c = 'OK';
        result.CBK_sfdcResultDetail__c = 'TEST AUDIT';
        result.Subject__c = 'test';
        result.CBK_sfdcType__c = 'Entrada';
        result.CBK_sfdcEmailMessageId__c = '1355564687486415excz241';
        result.CBK_sfdcFromAdress__c = 'test@test.com';
        result.CBK_sfdcToAddress__c = 'test@test.com';
        result.CBK_BuzonCorreo__c = '354a0728-b7c2-456a-8f87-9fde583019cd';
        logs.add(result);

        result = new CBK_Log__c(); 
        result.recordTypeId = recordTypeId;
        result.CBK_hdExchangeParentMessageId__c = '';
        result.CBK_sfdcMessageId__c = '<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM2>';
        result.CBK_sfdcResultStatus__c = 'OK';
        result.CBK_sfdcResultDetail__c = 'TEST AUDIT';
        result.Subject__c = 'test';
        result.CBK_sfdcType__c = 'Resultado';
        result.CBK_sfdcEmailMessageId__c = '1355564687486415excz241';
        result.CBK_sfdcFromAdress__c = 'test@test.com';
        result.CBK_sfdcToAddress__c = 'test@test.com';
        result.CBK_BuzonCorreo__c = '354a0728-b7c2-456a-8f87-9fde583019cd';
        logs.add(result);

        result = new CBK_Log__c(); 
        result.recordTypeId = recordTypeId;
        result.CBK_hdExchangeParentMessageId__c = '';
        result.CBK_sfdcMessageId__c = '<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM2>';
        result.CBK_sfdcResultStatus__c = 'OK';
        result.CBK_sfdcResultDetail__c = 'TEST AUDIT';
        result.Subject__c = 'test';
        result.CBK_sfdcType__c = 'Entrada';
        result.CBK_sfdcEmailMessageId__c = '1355564687486415excz241';
        result.CBK_sfdcFromAdress__c = 'test@test.com';
        result.CBK_sfdcToAddress__c = 'test@test.com';
        result.CBK_BuzonCorreo__c = '354a0728-b7c2-456a-8f87-9fde583019cd';
        logs.add(result);
        
        recordTypeId = Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('CBK_AutditEmail').getRecordTypeId();
        result = new CBK_Log__c(); 
        result.recordTypeId = recordTypeId;
        result.CBK_hdExchangeParentMessageId__c = '';
        result.CBK_sfdcMessageId__c = '<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM3>';
        result.CBK_sfdcResultStatus__c = 'KO';
        result.CBK_sfdcResultDetail__c = 'Email Perdido';
        result.Subject__c = 'test';
        result.CBK_sfdcType__c = 'Perdido';
        result.CBK_sfdcEmailMessageId__c = '1355564687486415excz241';
        result.CBK_sfdcFromAdress__c = 'test@test.com';
        result.CBK_sfdcToAddress__c = 'test@test.com';
        result.CBK_BuzonCorreo__c = '354a0728-b7c2-456a-8f87-9fde583019cd';
        logs.add(result);
        insert logs;
    }
    
    @IsTest
    static void testBatch() {
        List<User> adminUser = [SELECT Id FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {
            Test.StartTest();
                CBK_WS_APIGraph.ResponseWrapperDTO resp = new CBK_WS_APIGraph.ResponseWrapperDTO();
                resp.odata_context = 'https://graph.microsoft.com/v1.0/$metadata#users(\'HenriettaM%400dhlf.onmicrosoft.com\')/messages';
                //resp.odata_nextLink = 'https://graph.microsoft.com/v1.0/Users/514486d2-808a-4045-a2ec-2ef02356ceeb/mailFolders(\'Inbox\')/messages?%24select=Id%2cinternetMessageId%2csubject%2cfrom%2ctoRecipients&%24top=2&%24skip=2';
                //resp.value = lstValues;
                Map<String, CBK_APIGraph_Mailbox__c> apiConf = CBK_APIGraph_Mailbox__c.getAll();
                Test.setMock(HttpCalloutMock.class, new CBK_APIGraph_Mock());
                CBK_APIGraph_Reprocesado_Batch batch = new CBK_APIGraph_Reprocesado_Batch(null, null, null);
                Database.executeBatch(batch);
            Test.stopTest();
            
            Assert.areEqual(1, [SELECT Id FROM CBK_Log__c WHERE CBK_sfdcType__c = 'Reprocesado' LIMIT 100].size(), 'No se han creado los CBK_Log__c reprocesados correctamente');
        }
    }
}