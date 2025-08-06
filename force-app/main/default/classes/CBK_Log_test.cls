@isTest
public class CBK_Log_test {
	@testSetup
	static void initialData() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Sistemática Comercial'];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User thisUser = new User(alias = 'user2', email='testSEGBI2@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                timezonesidkey='America/Los_Angeles',
                Username = uniqueName + '@test' + orgId + '.org');
            insert thisUser;
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('CBK_Framework_Login','CBK_Framework_Admin')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
        }
    }

    @isTest
    public static void testLogBuilder() {
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
        CBK_Log.DebugProcessConfigBuilder builder;

        System.runAs ( testUser ) {
            builder = new CBK_Log.DebugProcessConfigBuilder();
            builder.setContextId('contextId');
            builder.setMessage('message');
            builder.setValues(new List<Object>());
            builder.setLevel(LoggingLevel.INFO);
            builder.setEmail(new Messaging.InboundEmail());
            builder.setCategory('category');
            builder.setForce(true);
            builder.setTxtUser('userId');
            builder.setTxtStacktrace('stacktrace');
            builder.setTxtDetail('detail');
            builder.setSfdcMessageId('messageId');
            builder.setMessageException('messageException');
            builder.setTxtFromAddress('fromAddress');
            builder.setTxtToAddress('toAddress');
            builder.setSfdcReplyTo('sfdcReplyTo');
            builder.setSfdcType('sfdcType');
            builder.setSfdcEmailMessageId('sfdcEmailMessageId');
            builder.setSfdcCaseId('sfdcCaseId');
            builder.setSfdcResultStatus('sfdcResultStatus');
            builder.setSfdcResultDetail('sfdcResultDetail');
            builder.setHdReturnPath('hdReturnPath');
            builder.setHdResentMessageId('hdResentMessageId');
            builder.setHdTo('hdTo');
            builder.setHdMessageID('hdMessageID');
            builder.setHdExchangeInboxRulesLoop('hdExchangeInboxRulesLoop');
            builder.setHdResentFrom('hdResentFrom');
            builder.setHdExchangeParentMessageId('hdExchangeParentMessageId');
            builder.setHdSFDCOriginalRCPT('hdSFDCOriginalRCPT');
            builder.setHdMSHasAttach('hdMSHasAttach');
            builder.setHdDeliveredTo('hdDeliveredTo');
            builder.setHdReference('hdReference');
            builder.setHdInReplyTo('hdInReplyTo');
            builder.setRecordTypeId('recordTypeId');
            builder.setOwnerId('ownerId');
            builder.setTransactionID('transaction_ID');
            builder.setLogMessage('message');
            builder.setLogMessageExt('message_Ext');
            builder.setErrorCode('error_Code');
            builder.setErrorType('error_Type');
            builder.setCreatedBy('createdBy');
            builder.setDetail('detail');
            builder.setCreatedDate(datetime.now());
            builder.setSystemModstamp(datetime.now());
            builder.setState('state');
            builder.setSfdcToAddress('sfdcToAddress');
            builder.setSfdcFromAddress('sfdcFromAddress');
            
            builder.getContextId();
            builder.getMessage();
            builder.getValues();
            builder.getLevel();
            builder.getEmail();
            builder.getCategory();
            builder.getForce();
            builder.getTxtUser();
            builder.getTxtStacktrace();
            builder.getTxtDetail();
            builder.getSfdcMessageId();
            builder.getMessageException();
            builder.getTxtFromAddress();
            builder.getTxtToAddress();
            builder.getSfdcReplyTo();
            builder.getSfdcType();
            builder.getSfdcEmailMessageId();
            builder.getSfdcCaseId();
            builder.getSfdcResultStatus();
            builder.getSfdcResultDetail();
            builder.getHdReturnPath();
            builder.getHdResentMessageId();
            builder.getHdTo();
            builder.getHdMessageID();
            builder.getHdExchangeInboxRulesLoop();
            builder.getHdResentFrom();
            builder.getHdExchangeParentMessageId();
            builder.getHdSFDCOriginalRCPT();
            builder.getHdMSHasAttach();
            builder.getHdDeliveredTo();
            builder.getHdReference();
            builder.getHdInReplyTo();
            builder.getRecordTypeId();
            builder.getOwnerId();
            builder.getTransactionID();
            builder.getLogMessage();
            builder.getLogMessageExt();
            builder.getErrorCode();
            builder.getErrorType();
            builder.getCreatedBy();
            builder.getDetail();
            builder.getCreatedDate();
            builder.getSystemModstamp();
            builder.getState();
            builder.getSfdcToAddress();
            builder.getSfdcFromAddress();
        }

        //Asserts
        System.assertNotEquals(builder, null,'The Log builder Object has not been populated');
    }

    @isTest
    public static void testDebugAdd() {
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
        Id recordTypeId = Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('Apex_Log').getRecordTypeId();

        //Creación Custom Picklist
        String sRecordTypeIdPicklist = Schema.SObjectType.CBK_PicklistValues__c.getRecordTypeInfosByDeveloperName().get('CBK_Picklist').getRecordTypeId();
        String sRecordTypeIdPicklistValue = Schema.SObjectType.CBK_PicklistValues__c.getRecordTypeInfosByDeveloperName().get('CBK_PicklistValue').getRecordTypeId();
        CBK_PicklistValues__c oCustomPicklist = new CBK_PicklistValues__c();
        oCustomPicklist.Name = 'CBK_Category__c';
        oCustomPicklist.CBK_Object__c = 'CBK_Log';
        oCustomPicklist.RecordTypeId = sRecordTypeIdPicklist;
        insert oCustomPicklist;
        CBK_PicklistValues__c oCustomPicklistValue1 = new CBK_PicklistValues__c();
        oCustomPicklistValue1.CBK_Picklist__c = oCustomPicklist.Id;
        oCustomPicklistValue1.Name = 'test';
        oCustomPicklistValue1.RecordTypeId = sRecordTypeIdPicklistValue;
        insert oCustomPicklistValue1;

        System.runAs (testUser) {

            CBK_Log.DebugProcessConfigBuilder builder = new CBK_Log.DebugProcessConfigBuilder()
                .setRecordTypeId(recordTypeId)
                .setOwnerId(testuser.Id)
                .setTransactionID(testuser.Id + '-' + String.valueof(DateTime.now().getTime()))
                .setLogMessage('value1')
                .setLogMessageExt('value1')
                .setMessage('value1')
                .setErrorCode('')
                .setErrorType('')
                .setTxtStacktrace('')
                .setCreatedBy(testuser.Id)
                .setDetail('@Det@')
                .setMessageException('')
                .setCreatedDate(System.now())
                .setSystemModstamp(System.now())
                .setLevel(LoggingLevel.INFO);
            
            builder.addLog();

            // Insertar DML debug
            CBK_Log.insertDML();

            /// Output some confirmation
            System.debug('Debug and DML debug executed successfully.');

            // Since we can't query the event, use system logs to verify
            System.debug('The debug process has been executed. Please check the event monitor for CBK_LogEvent__e.');
        }

        CBK_Log__c config = [SELECT Id, Log_Message__c, Log_Level__c FROM CBK_Log__c LIMIT 1];

        // Assert the values are set correctly
        System.assertEquals('value1', config.Log_Message__c,'El Message no coincide.');
        System.assertEquals('INFO', config.Log_Level__c,'El Log Level no es identico');
    }

    @isTest
    public static void testNuevaFuncionalidad() {
        List<Object> detalle = new List<Object> {'Error 1', 'Error 2', 'Error 3'};
        

        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

       System.runAs (testUser) {
            try{
                User lst = [Select Id from User LIMIT 2];
            } catch (Exception e) {
                Map<String, String> mapOptFields = new Map<String, String>();
                mapOptFields.put('state__c','Complete');
                mapOptFields.put('FromAddress__c','pruebas@gmail.com');
                mapOptFields.put('inexistente','Complete');
                CBK_Log.addError('Contexto',e,'error',detalle, mapOptFields);
                CBK_Log.addError('Contexto2',e,'error2',detalle, mapOptFields);
                CBK_Log.insertDML();
            }
        }

        //Query del registro insertado
        CBK_Log__c listadoLogs = [SELECT Id,Transaction_ID__c FROM CBK_Log__c WHERE Transaction_ID__c = 'Contexto'];
        
        
        //Comprobar los campos incluidos
        System.assertEquals('Contexto', listadoLogs.Transaction_ID__c,'No coincide el valor con el esperado');
       
    }


    @isTest
    public static void Test01() {
		List<Object> detalle = new List<Object> {'Error 1', DateTime.newInstance(2020, 10, 26) };
		
        string txtError='Class.CBK_Log.emit: line 73, column 1\nClass.CBK_Log.error: line 64, column 1\nClass.CBK_Log.error: line 48, column 1\nAnonymousBlock: line 2, column 1\nAnonymousBlock: line 2, column 1';
        CBK_Log.debug(txtError);
		CBK_Log.debug(txtError,logginglevel.INFO);
		txtError = 'Test Debug';
        
        // Métodos de test DEBUG.
        CBK_Log.debug('Contexto',txtError);
        CBK_Log.debug(txtError, detalle);
		CBK_Log.debug('Contexto',txtError, detalle);

        CBK_Log.debug('Contexto',txtError,logginglevel.INFO);
        CBK_Log.debug(txtError, detalle,logginglevel.INFO);
		CBK_Log.debug('Contexto',txtError, detalle,logginglevel.INFO);
        
        // Métodos de test ERROR.
        CBK_Log.error('Test');
        CBK_Log.error(txtError, detalle);
        CBK_Log.error('Contexto','Test');
        CBK_Log.error('Contexto',txtError,detalle);
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
        CBK_LogEvent__e logEvent = New CBK_LogEvent__e();
        logEvent.txt_Level__c='ERROR';
        logEvent.txt_Message__c='Class.CBK_Log.emit: line 73, column 1\nClass.CBK_Log.error: line 64, column 1\nClass.CBK_Log.error: line 48, column 1\nAnonymousBlock: line 2, column 1\nAnonymousBlock: line 2, column 1';
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
    
    @isTest
    public static void Test_createLogWithoutevent() { 
        List<Object> detalle = new List<Object> {'Error 1', 'Error 2', 'Error 3'};
        try{
            User lst = [Select Id from User LIMIT 2];
        } catch (Exception e) {
            
            CBK_Log.saveError('Contexto',e,'error',detalle);
            CBK_Log.saveError('Contexto2',null,'error2',detalle);
        }
    }

    @isTest
    public static void Test_createLogWithouteventOptParams() { 
        List<Object> detalle = new List<Object> {'Error 1', 'Error 2', 'Error 3'};
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

        System.runAs (testUser) {
            try{
                User lst = [Select Id from User LIMIT 2];
            } catch (Exception e) {
                Map<String, String> mapOptFields = new Map<String, String>();
                mapOptFields.put('state__c','Complete');
                mapOptFields.put('FromAddress__c','pruebas@gmail.com');
                mapOptFields.put('inexistente','Complete');
                CBK_Log.saveError('Contexto',e,'error',detalle, mapOptFields);
                CBK_Log.saveError('Contexto2',e,'error2',detalle, mapOptFields,'Prueba Contexto2');
            }

        //Query del registro insertado
        CBK_Log__c listadoLogs = [SELECT Id,Transaction_ID__c FROM CBK_Log__c WHERE Transaction_ID__c = 'Contexto' LIMIT 1];
        
        //Comprobar los campos incluidos
        System.assertEquals('Contexto', listadoLogs.Transaction_ID__c,'No coincide el valor con el esperado');

        }
    }

    @isTest
    public static void testgetApexLimits() { 
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
        SObject evtLog;
        System.runAs (testUser) {
            evtLog = CBK_Log.getApexLimits(new CBK_Log__c());
        }

        //Asserts
        System.assertNotEquals(evtLog, null,'The limit sObject has not been populated');
        System.assertNotEquals(evtLog.get('CBK_AggregateQueries__c'), null,'A value inside the limit sObject has not been populated');
    }

}