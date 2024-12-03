@isTest
public class CBK_Log_test {
    @isTest
    public static void Test01() {
		List<Object> detalle = new List<Object> {'Error 1', DateTime.newInstance(2020, 10, 26) };
		
        string txtError='Class.CBK_Log.emit: line 73, column 1\nClass.CBK_Log.error: line 64, column 1\nClass.CBK_Log.error: line 48, column 1\nAnonymousBlock: line 2, column 1\nAnonymousBlock: line 2, column 1';
        CBK_Log.debug(txtError);
		CBK_Log.debug(txtError,logginglevel.INFO);
		txtError = 'Test Debug';
        
        
        CBK_Log.debug('Contexto',txtError);
        CBK_Log.debug(txtError, detalle);
		CBK_Log.debug('Contexto',txtError, detalle);

        CBK_Log.debug('Contexto',txtError,logginglevel.INFO);
        CBK_Log.debug(txtError, detalle,logginglevel.INFO);
		CBK_Log.debug('Contexto',txtError, detalle,logginglevel.INFO);
        
        CBK_Log.error('Test');
        CBK_Log.error(txtError, detalle);
        CBK_Log.error('Contexto','Test');
        CBK_Log.error('Contexto',txtError,detalle);
    }
    
    @isTest
    public static void Test02() {
		List<Object> detalle = new List<Object> {'Error 1', DateTime.newInstance(2020, 10, 26) };
        
        try{
            User lst = [Select Id from User LIMIT 2];
        } catch (Exception e) {
            CBK_Log.error(e);
            CBK_Log.error(e, detalle);
            CBK_Log.error('Contexto',e);
            CBK_Log.error('Contexto',e,detalle);
            
            CBK_Log.error(e,'error');
            CBK_Log.error(e,'error', detalle);
            CBK_Log.error('Contexto',e,'error');
            CBK_Log.error('Contexto',e,'error',detalle);
        }
        
    }

    @isTest
    public static void Test03() {
		List<Object> detalle = new List<Object> {'Error 1', DateTime.newInstance(2020, 10, 26) };
		
        string txtError='Class.CBK_Log.emit: line 73, column 1\nClass.CBK_Log.error: line 64, column 1\nClass.CBK_Log.error: line 48, column 1\nAnonymousBlock: line 2, column 1\nAnonymousBlock: line 2, column 1';
        Map<String, String> mapError = New Map<String, String>{'MSG' => txtError, 'COD' => 'd', 'Type' => 'd'};

        CBK_Log.debug(mapError);
		CBK_Log.debug(mapError,logginglevel.INFO);

		txtError = 'Test Debug';
        
        mapError = New Map<String, String>{'MSG' => txtError, 'COD' => 'd', 'Type' => 'd'};
        
        CBK_Log.debug('Contexto',mapError);
        CBK_Log.debug(mapError, detalle);
		CBK_Log.debug('Contexto',mapError, detalle);

        CBK_Log.debug('Contexto',mapError,logginglevel.INFO);
        CBK_Log.debug(mapError, detalle,logginglevel.INFO);
		CBK_Log.debug('Contexto',mapError, detalle,logginglevel.INFO);
        
        CBK_Log.error(mapError);
        CBK_Log.error(mapError, detalle);
        CBK_Log.error('Contexto',mapError);
        CBK_Log.error('Contexto',mapError,detalle);
    }
    
    @isTest
    public static void Test04() {
		List<Object> detalle = new List<Object> {'Error 1', DateTime.newInstance(2020, 10, 26) };
        Map<String, String> mapError = New Map<String, String>{'MSG' => 'error', 'cod' => 'd', 'Type' => 'd'};

        
        try{
            User lst = [Select Id from User LIMIT 2];
        } catch (Exception e) {
            CBK_Log.error(e);
            CBK_Log.error(e, detalle);
            CBK_Log.error('Contexto',e);
            CBK_Log.error('Contexto',e,detalle);
            
            CBK_Log.error(e,mapError);
            CBK_Log.error(e,mapError, detalle);
            CBK_Log.error('Contexto',e,mapError);
            CBK_Log.error('Contexto',e,mapError,detalle);

            Map<String,String> mHeader = new Map<String,String>();
            mHeader.put('X-SFDC-Original-RCPT', 'TEST@TEST');

            List<Messaging.InboundEmail.Header> lstHeaders =  new List<Messaging.InboundEmail.Header> ();
            Messaging.InboundEmail.Header header;
            for(string st : mHeader.keySet()){
                header = new Messaging.InboundEmail.Header();
                header.name = st;
                header.value = mHeader.get(st);
                lstHeaders.add(header);
            }
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
            envelope.fromAddress = 'test@test.com';
            envelope.toAddress = 'test2@test.com';
            correo.subject = 'TEST';
            correo.fromAddress = 'test@test.com';
            correo.plainTextBody = 'Body test';
            correo.headers = lstHeaders;
            CBK_Log.error(e,'ERROR With Inbound email', correo);
        }
        
    }    
    
    @isTest
    public static void Test_populateLocation() { 
        CBK_Log__c logEvent = New CBK_Log__c();
        logEvent.Log_Level__c='ERROR';
        logEvent.Log_Message__c='Class.CBK_Log.emit: line 73, column 1\nClass.CBK_Log.error: line 64, column 1\nClass.CBK_Log.error: line 48, column 1\nAnonymousBlock: line 2, column 1\nAnonymousBlock: line 2, column 1';
        CBK_Log.populateLocation(logEvent);
    }
    
    @isTest
    public static void Test_populateLocation2() { 
        CBK_Log__c logEvent = New CBK_Log__c();
        logEvent.Log_Level__c='ERROR';
        logEvent.Apex_Stack_Trace__c='Class.CBK_Log.emit: line 73, column 1\nClass.CBK_Log.error: line 64, column 1\nClass.CBK_Log.error: line 48, column 1\nAnonymousBlock: line 2, column 1\nAnonymousBlock: line 2, column 1';
        CBK_Log.populateLocation(logEvent);

    }

    @isTest
    public static void Test_enviomail() { 
        CBK_Log__c logEvent = New CBK_Log__c();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'Framework de Login'];

        CBK_Log.enviomail(logEvent,owea.get(0).Id,'TEST@TEST.COM');
    }

    @isTest
    public static void Test_auditemail() { 
        Messaging.InboundEmail email = new  Messaging.InboundEmail();
        CBK_Log.auditemail(email);

        Map<String,String> mHeader = new Map<String,String>();
        mHeader.put('X-SFDC-Original-RCPT', 'TEST@TEST');
        mHeader.put('Return-Path', 'TEST/TEST');
        mHeader.put('Resent-Message-Id', '345234523');
        mHeader.put('To','toTest@test.com');
        mHeader.put('Message-ID','123456');
        mHeader.put('X-MS-Exchange-Inbox-Rules-Loop', 'test@test');
        mHeader.put('Resent-From', 'test@test');
        mHeader.put('x-ms-exchange-parent-message-id', '123456');
        mHeader.put('X-SFDC-Original-RCPT', 'test@test');
        mHeader.put('X-MS-Has-Attach','test@test');
        mHeader.put('Delivered-To','test@test');
        mHeader.put('Reference','test@test');
        mHeader.put('In-Reply-To','test@test');
        List<Messaging.InboundEmail.Header> lstHeaders =  new List<Messaging.InboundEmail.Header> ();
        Messaging.InboundEmail.Header header;
        for(string st : mHeader.keySet()){
            header = new Messaging.InboundEmail.Header();
            header.name = st;
            header.value = mHeader.get(st);
            lstHeaders.add(header);
        }
		email.headers = lstHeaders;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        CBK_Log.auditemail(email, envelope);
        CBK_Log.ResultWrapper wr = new CBK_Log.ResultWrapper();
        wr.Status = 'OK';
        wr.Detail = 'Se ha credo todo correcto';
        wr.CaseId = '12345678654';
        wr.EmailMessageId = '9887908789';
        CBK_Log.auditemailResult(wr, email);
    } 

    @isTest
    public static void Test_deserializeMsg() { 
        CBK_Log__c EvtLog = New CBK_Log__c();
        EvtLog.Log_Message__c = '{"Type":"d","COD":"d","MSdG":"b"}';
        EvtLog.Error_Code__c='';
		CBK_Log.deserializeMsg(EvtLog);
    } 
}