@isTest
public with sharing class CBK_WS_APIGraph_Test {
    @testSetup 
    static void setup() {
        CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'CBK API Graph';
		wsc.NamedCredential__c = 'https://graph.microsoft.com/v1.0/users/354a0728-b7c2-456a-8f87-9fde583019cd/messages';
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
        logs.add(result);
         insert logs;
    }
    @isTest
    public static void callApiGraphByMailbox(){
        Test.startTest();
        List<CBK_WS_APIGraph.Value> lstValues = new List<CBK_WS_APIGraph.Value>();
        CBK_WS_APIGraph.Value val =  createValueResponse('<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM>');
        lstValues.add(val);
        val =  createValueResponse('<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM1>');
        lstValues.add(val);
        val =  createValueResponse('<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM2>');
        lstValues.add(val);
        val =  createValueResponse('<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM3>');
        lstValues.add(val);

        CBK_WS_APIGraph.ResponseWrapperDTO resp = new CBK_WS_APIGraph.ResponseWrapperDTO();
        resp.odata_context = 'https://graph.microsoft.com/v1.0/$metadata#users(\'HenriettaM%400dhlf.onmicrosoft.com\')/messages';
        //resp.value = lstValues;
        Map<String, CBK_APIGraph_Mailbox__c> apiConf = CBK_APIGraph_Mailbox__c.getAll();
        Map<String, CBK_ScheduleControls__c> apiControls = CBK_ScheduleControls__c.getAll();
        Test.setMock(HttpCalloutMock.class, new CBK_HttpService_Mock_TEST('https://graph.microsoft.com', JSON.serialize(resp), 'GET', 200));
        CBK_WS_APIGraph byMailbox = new CBK_WS_APIGraph(apiConf.values(), apiControls.values()[0]);
        System.enqueueJob(byMailbox);
		Test.stopTest();
    }

    @isTest
    public static void callApiGraphNextLink(){
        Test.startTest();
        List<CBK_WS_APIGraph.Value> lstValues = new List<CBK_WS_APIGraph.Value>();
        CBK_WS_APIGraph.Value val =  createValueResponse('<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM>');
        lstValues.add(val);
        val =  createValueResponse('<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM1>');
        lstValues.add(val);
        val =  createValueResponse('<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM2>');
        lstValues.add(val);
        val =  createValueResponse('<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM3>');
        lstValues.add(val);

        CBK_WS_APIGraph.ResponseWrapperDTO resp = new CBK_WS_APIGraph.ResponseWrapperDTO();
        resp.odata_context = 'https://graph.microsoft.com/v1.0/$metadata#users(\'HenriettaM%400dhlf.onmicrosoft.com\')/messages';
        //resp.odata_nextLink = 'https://graph.microsoft.com/v1.0/Users/514486d2-808a-4045-a2ec-2ef02356ceeb/mailFolders(\'Inbox\')/messages?%24select=Id%2cinternetMessageId%2csubject%2cfrom%2ctoRecipients&%24top=2&%24skip=2';
        //resp.value = lstValues;
        Map<String, CBK_APIGraph_Mailbox__c> apiConf = CBK_APIGraph_Mailbox__c.getAll();
        Test.setMock(HttpCalloutMock.class, new CBK_HttpService_Mock_TEST('https://graph.microsoft.com', JSON.serialize(resp), 'GET', 200));
        CBK_WS_APIGraph byMailbox = new CBK_WS_APIGraph('https://graph.microsoft.com/v1.0/Users/514486d2-808a-4045-a2ec-2ef02356ceeb/mailFolders(\'Inbox\')/messages?%24select=Id%2cinternetMessageId%2csubject%2cfrom%2ctoRecipients&%24top=2&%24skip=2', true, apiConf.values()[0]);
        System.enqueueJob(byMailbox);
		Test.stopTest();
    }

    @isTest
    public static void getTokenTest(){
        Test.startTest();
        String jsonToken = '{"access_token": "123456789", "expires_in": "300"}';
        HttpResponse resp = new HttpResponse();
		resp.setBody(jsonToken);	
		resp.setStatusCode(200);
		resp.setStatus('Ok');
		CBK_HttpService_Mock_TEST vMock = new CBK_HttpService_Mock_TEST(resp);
		Test.setMock(HttpCalloutMock.class, vMock);
        CBK_WS_APIGraph.getTokenAccess('TokenApiGraph');
		Test.stopTest();
    }
    @isTest
    public static void getTokenTestNull(){
        Test.startTest();
        String jsonToken = '{"access_token": "", "expires_in": "300"}';
        HttpResponse resp = new HttpResponse();
		resp.setBody(jsonToken);	
		resp.setStatusCode(200);
		resp.setStatus('Ok');
		CBK_HttpService_Mock_TEST vMock = new CBK_HttpService_Mock_TEST(resp);
		Test.setMock(HttpCalloutMock.class, vMock);
        try{
            CBK_WS_APIGraph.getTokenAccess('TokenApiGraph');
        }catch(Exception e){
            System.assertEquals(true, e.getMessage().contains('Received null token'));
        }
		Test.stopTest();
    }
    @isTest
    public static void getTokenTestKO(){
        Test.startTest();
        String jsonToken = '{"error":"unsupported_grant_type","error_description":"AADSTS70003: The app requested an unsupported grant type \'client_credential\'.\r\nTrace ID: c47a67d1-27ad-463c-8f5a-8725d13c1200\r\nCorrelation ID: 91c712c9-eb0d-44e5-ac21-f0eaea96a001\r\nTimestamp: 2023-02-16 13:04:46Z","error_codes":[70003],"timestamp":"2023-02-16 13:04:46Z","trace_id":"c47a67d1-27ad-463c-8f5a-8725d13c1200","correlation_id":"91c712c9-eb0d-44e5-ac21-f0eaea96a001"}';
        HttpResponse resp = new HttpResponse();
		resp.setBody(jsonToken);	
		resp.setStatusCode(400);
		resp.setStatus('KO');
		CBK_HttpService_Mock_TEST vMock = new CBK_HttpService_Mock_TEST(resp);
		Test.setMock(HttpCalloutMock.class, vMock);
        try{
            CBK_WS_APIGraph.getTokenAccess('TokenApiGraph');
        }catch(Exception e){
            System.assertEquals(true, e.getMessage().contains('"error":"unsupported_grant_type"'));
        }
		Test.stopTest();
    }

    @isTest
    public static void mapApiGraphTest(){
        test.startTest();
        List<CBK_WS_APIGraph.ResponseWrapperDTO> lstResp =  new List<CBK_WS_APIGraph.ResponseWrapperDTO>();
        List<CBK_WS_APIGraph.Value> lstValues = new List<CBK_WS_APIGraph.Value>();
        CBK_WS_APIGraph.Value val =  createValueResponse('<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM>');
        lstValues.add(val);
        val =  createValueResponse('<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM1>');
        lstValues.add(val);
        val =  createValueResponse('<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM2>');
        lstValues.add(val);
        val =  createValueResponse('<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM3>');
        lstValues.add(val);

        CBK_WS_APIGraph.ResponseWrapperDTO resp = new CBK_WS_APIGraph.ResponseWrapperDTO();
        resp.odata_context = 'https://graph.microsoft.com/v1.0/$metadata#users(\'HenriettaM%400dhlf.onmicrosoft.com\')/messages';
        Map<String, CBK_APIGraph_Mailbox__c> apiConf = CBK_APIGraph_Mailbox__c.getAll();
        resp.mailbox = apiConf.values()[0];
        resp.Mails = new List<CBK_WS_APIGraph.Value>();
        resp.xSFDCOriginalRCPT = '<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM>';
        resp.Mails = lstValues;
        lstResp.add(resp);
        CBK_WS_APIGraph_MAP mapGrpah = new CBK_WS_APIGraph_MAP(lstResp);
        System.enqueueJob(mapGrpah);
		Test.stopTest();
    }

    @isTest
    public static void sheduleApiGraphTest(){
        CBK_ScheduleControls__c schInf = new CBK_ScheduleControls__c(name = 'ScheduleApiGraph', Retries__c = 5, ExecutionPeriod__c = 15, Date_Last_Execution__c = datetime.now() );
        test.startTest();
        List<CBK_WS_APIGraph.Value> lstValues = new List<CBK_WS_APIGraph.Value>();
        CBK_WS_APIGraph.Value val =  createValueResponse('<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM>');
        lstValues.add(val);
        val =  createValueResponse('<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM1>');
        lstValues.add(val);
        val =  createValueResponse('<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM2>');
        lstValues.add(val);
        val =  createValueResponse('<VI1P195MB0398BEE6C059E257EA56F116C5DB9@VI1P195MB0398.EURP195.PROD.OUTLOOK.COM3>');
        lstValues.add(val);

        CBK_WS_APIGraph.ResponseWrapperDTO resp = new CBK_WS_APIGraph.ResponseWrapperDTO();
        resp.odata_context = 'https://graph.microsoft.com/v1.0/$metadata#users(\'HenriettaM%400dhlf.onmicrosoft.com\')/messages';
        resp.Mails = lstValues;

        Test.setMock(HttpCalloutMock.class, new CBK_HttpService_Mock_TEST('https://graph.microsoft.com', JSON.serialize(resp), 'GET', 200));
        Map<String, CBK_APIGraph_Mailbox__c> apiConf = CBK_APIGraph_Mailbox__c.getAll();
        CBK_WS_APIGraph mapGrpah = new CBK_WS_APIGraph(apiConf.values(),schInf);
        System.enqueueJob(mapGrpah);
		Test.stopTest();
    }

    @isTest
    public static void responseErrorApigraph(){
        Test.startTest();
        CBK_WS_APIGraph.ResponseErrorWrapperDTO resp =  createResponseError();
        Test.setMock(HttpCalloutMock.class, new CBK_HttpService_Mock_TEST('https://graph.microsoft.com', JSON.serialize(resp), 'GET', 400));
        CBK_WS_APIGraph byMailbox = new CBK_WS_APIGraph(null, null);
        System.enqueueJob(byMailbox);
		Test.stopTest();
    }

    public static CBK_WS_APIGraph.ResponseErrorWrapperDTO createResponseError(){

        CBK_WS_APIGraph.ResponseErrorWrapperDTO response = new CBK_WS_APIGraph.ResponseErrorWrapperDTO();
        CBK_WS_APIGraph.ErrorDetail errordetail = new CBK_WS_APIGraph.ErrorDetail();
        errordetail.code = 'ResourceNotFound';
        errordetail.message = 'Resource could not be discovered.';

        CBK_WS_APIGraph.InnerError innerError = new CBK_WS_APIGraph.InnerError();
        innerError.vdate = '2023-02-16T12:37:14';
        innerError.requestId = '05a84e88-c042-4183-8878-9a01b2835db3';
        innerError.clientRequestId = '05a84e88-c042-4183-8878-9a01b2835db3';
        errordetail.innerError = innerError;

        response.error = errordetail;    
        
        return response;
    }

    public static CBK_WS_APIGraph.Value createValueResponse(String mailboxId){

        CBK_WS_APIGraph.Value values = new CBK_WS_APIGraph.Value();
        List<CBK_WS_APIGraph.EmailAddress> lstemailObj = new list<CBK_WS_APIGraph.EmailAddress>();
        CBK_WS_APIGraph.EmailAddress emailAdd = new CBK_WS_APIGraph.EmailAddress();

        //values.id = 'AAMkADMzZDRkYzFmLWYzNjAtNDM4Mi05NzY2LTZhNWU2ODk5YzY1NQBGAAAAAADjAcRZ5BPwRY8ErkRe0HcnBwDzlqm5AmWFSK1edWmnYkixAAAAAAEMAADzlqm5AmWFSK1edWmnYkixAAADjwLmAAA=';
        values.internetMessageId = mailboxId;
        values.subject = 'TEST APIGraph';
        Datetime dtNow = Datetime.now();
        values.createdDate = String.valueOf(dtNow);
        values.receivedDate = String.valueOf(dtNow);
        values.attachments = false;

        /*values.odata_etag = 'FGVXFVZXCVZXCVZXCVZ';
        values.lastModifiedDateTime = '2023-02-07T17:08:56Z';
        values.changeKey = 'CQAAABYAAADzlqm5AmWFSK1edWmnYkixAAADjLEO';
        values.categories = new List<String>{'TEST'};
        values.sentDateTime = '2023-02-07T17:08:49Z"';
        values.bodyPreview = 'tghdfghdfghdfghdgfh\r\n________________________________\r\nDe: test\r\nEnviado: viernes, 3 de febrero de 2023 12:25\r\nPara: Diego@0dhlf.onmicrosoft.com <Diego@0dhlf.onmicrosoft.com>\r\nAsunto: test1';
        values.importance = 'normal';
        values.parentFolderId = 'AMkADMzZDRkYzFmLWYzNjAtNDM4Mi05NzY2LTZhNWU2ODk5YzY1NQAuAAAAAADjAcRZ5BPwRY8ErkRe0HcnAQDzlqm5AmWFSK1edWmnYkixAAAAAAEMAAA=';
        values.conversationId = 'AAQkADMzZDRkYzFmLWYzNjAtNDM4Mi05NzY2LTZhNWU2ODk5YzY1NQAQAFfft-K7rZpMtGaRZy1tifA=';
        values.conversationIndex = 'AQHZN8ItV9+38rutmky0ZpFnLW2J8K7Dviqa';
        values.isDeliveryReceiptRequested = false;
        values.isReadReceiptRequested = false;
        values.isRead = false;
        values.isDraft = false;
        values.webLink = 'https://outlook.office365.com/owa/?ItemID=AAMkADMzZDRkYzFmLWYzNjAtNDM4Mi05NzY2LTZhNWU2ODk5YzY1NQBGAAAAAADjAcRZ5BPwRY8ErkRe0HcnBwDzlqm5AmWFSK1edWmnYkixAAAAAAEMAADzlqm5AmWFSK1edWmnYkixAAADjwLmAAA%3D&exvsurl=1&viewmodel=ReadMessageItem';
        values.inferenceClassification = 'focused';*/

        emailAdd.name = 'TEST API';
        emailAdd.address = 'testApiGraph@test.com';
        values.mailFrom = emailAdd;

        emailAdd =  new CBK_WS_APIGraph.EmailAddress();
        emailAdd.name = 'TEST API';
        emailAdd.address = 'testApiGraph@test.com';
        values.mailSender = emailAdd;

        emailAdd =  new CBK_WS_APIGraph.EmailAddress();
        emailAdd.name = 'TEST API';
        emailAdd.address = 'testApiGraph@test.com';

        lstemailObj.add(emailAdd);
        values.mailRecipients = lstemailObj;
        values.mailCCRecipients = lstemailObj;
        values.mailBCCRecipients = lstemailObj;

        /*CBK_WS_APIGraph.Flag flag = new CBK_WS_APIGraph.Flag();
        flag.flagStatus = 'notFlagged';
        values.flag = flag;

        CBK_WS_APIGraph.BodyObject body = new CBK_WS_APIGraph.BodyObject();
        body.content = 'html';
        body.contentType = '<html><head>\r\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"><style type=\"text/css\" style=\"display:none\">\r\n<!--\r\np\r\n\t{margin-top:0;\r\n\tmargin-bottom:0}\r\n-->\r\n</style></head><body dir=\"ltr\"><div class=\"elementToProof\" style=\"font-family:Calibri,Arial,Helvetica,sans-serif; font-size:12pt; color:rgb(0,0,0); background-color:rgb(255,255,255)\">tghdfghdfghdfghdgfh</div><div id=\"appendonsend\"></div><hr tabindex=\"-1\" style=\"display:inline-block; width:98%\"><div id=\"divRplyFwdMsg\" dir=\"ltr\"><font face=\"Calibri, sans-serif\" color=\"#000000\" style=\"font-size:11pt\"><b>De:</b> test<br><b>Enviado:</b> viernes, 3 de febrero de 2023 12:25<br><b>Para:</b> Diego@0dhlf.onmicrosoft.com &lt;Diego@0dhlf.onmicrosoft.com&gt;<br><b>Asunto:</b> test1</font> <div>&nbsp;</div></div><style type=\"text/css\" style=\"display:none\">\r\n<!--\r\np\r\n\t{margin-top:0;\r\n\tmargin-bottom:0}\r\n-->\r\n</style><div dir=\"ltr\"><div class=\"x_elementToProof\" style=\"font-family:Calibri,Arial,Helvetica,sans-serif; font-size:12pt; color:rgb(0,0,0); background-color:rgb(255,255,255)\"><br></div></div></body></html>';
        values.body = body;
        */

        return values;
    }
}