@isTest
private class CBK_MonitorJobs_Test {
    @isTest 
    static void RunJob() {
		Test.setMock(HttpCalloutMock.class, new CBK_MonitorJobs_Mock());
		CBK_MonitorJobs_CoreBatch batch = new CBK_MonitorJobs_CoreBatch();
        test.startTest();
        Id batchId=database.executeBatch(batch,1); 
        test.stopTest();
        System.assertnotEquals(null, batchId);

     }

    @isTest 
    static void RunJob_query() {
		Test.setMock(HttpCalloutMock.class, new CBK_MonitorJobs_Mock());
		CBK_MonitorJobs_Query_CoreBatch batch = new CBK_MonitorJobs_Query_CoreBatch();
        test.startTest();
        Id batchId = database.executeBatch(batch,1); 
        test.stopTest();
        System.assertnotEquals(null, batchId);

     }    
     
    
    @isTest 
    static void cabecera() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new CBK_MonitorJobs_Mock());
		test.startTest();
        CBK_MonitorJobs.CBK_Jobs();
        test.stopTest();
        list<AsyncApexJob> lstJobs = [Select Id from AsyncApexJob where ApexClass.Name ='CBK_MonitorJobsDetail'];
        System.assertnotEquals(0, lstJobs.size());
    }
     
    
    @isTest
    static void detalle() {
        User usr = [Select Id from User LIMIT 1];
        CBK_log__c job = New CBK_log__c();
        job.RecordTypeId=Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('Data_Load_Log').getRecordTypeId();
        job.Job_Id__c='7503Y00000TGeNyQAL';
        job.operation__c='upsert';
        job.object__c='Case';
        job.Entidad__c ='Test';
        job.createdBy__c=usr.Id;
        job.createdDate__c=datetime.now();
        job.systemModstamp__c=datetime.now();
        job.state__c='Closed';
        job.concurrencyMode__c='Parallel';
        job.contentType__c='CSV';
        job.apiVersion__c='49.0';
        job.jobType__c='Classic';   
        insert job;
        
        Test.setMock(HttpCalloutMock.class, new CBK_MonitorJobs_Mock());
        
        Test.startTest();
        CBK_MonitorJobs.CBK_JobDetail(job.Job_Id__c);
        Test.stopTest();
        job = [Select Entidad__c from CBK_log__c where Id=:job.Id];
        System.assertnotEquals('Test', job.Entidad__c);


    }
    @isTest
    static void detalle2() {
        User usr = [Select Id from User LIMIT 1];
        CBK_log__c job = New CBK_log__c();
        job.RecordTypeId=Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('Data_Load_Log').getRecordTypeId();
        job.Job_Id__c='7503Y00000TGeNyQAL';
        job.operation__c='upsert';
        job.object__c='User';
        job.Entidad__c ='Test';
        job.createdBy__c=usr.Id;
        job.createdDate__c=datetime.now();
        job.systemModstamp__c=datetime.now();
        job.state__c='Closed';
        job.concurrencyMode__c='Parallel';
        job.contentType__c='CSV';
        job.apiVersion__c='49.0';
        job.jobType__c='Classic';   
        insert job;
        
        Test.setMock(HttpCalloutMock.class, new CBK_MonitorJobs_Mock());
        
        Test.startTest();
        CBK_MonitorJobs.CBK_JobDetail(job.Job_Id__c);
        Test.stopTest();
        job = [Select Entidad__c from CBK_log__c where Id=:job.Id];
        System.assertnotEquals('Test', job.Entidad__c);

    }

    @isTest
    static void detalle3() {
        User usr = [Select Id from User LIMIT 1];
        CBK_log__c job = New CBK_log__c();
        job.RecordTypeId=Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('Data_Load_Log').getRecordTypeId();
        job.Job_Id__c='7503Y00000TGeNyQAL';
        job.operation__c='upsert';
        job.object__c='Case';
        job.Entidad__c ='Test';
        job.createdBy__c=usr.Id;
        job.createdDate__c=datetime.now();
        job.systemModstamp__c=datetime.now();
        job.state__c='Closed';
        job.concurrencyMode__c='Parallel';
        job.contentType__c='CSV';
        job.apiVersion__c='49.0';
        job.jobType__c='Classic';   
        insert job;
        
        Test.setMock(HttpCalloutMock.class, new CBK_MonitorJobs_Mock());
        
        Test.startTest();
        CBK_MonitorJobs.CBK_JobDetail2(job.Job_Id__c);
        Test.stopTest();
        job = [Select Entidad__c from CBK_log__c where Id=:job.Id];
        System.assertnotEquals('Test', job.Entidad__c);

    }    

    @isTest
    static void detalleBatchesbyjob_Inprogress() {
        User usr = [SELECT id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        CBK_log__c job = New CBK_log__c();
        job.RecordTypeId=Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('Data_Load_Log').getRecordTypeId();
        job.Job_Id__c='7503Y00000TGeNyQAL';
        job.operation__c='query';
        job.object__c='Case';
        job.Entidad__c ='Test';
        job.createdBy__c=usr.Id;
        job.createdDate__c=datetime.now();
        job.systemModstamp__c=datetime.now();
        job.state__c='Closed';
        job.concurrencyMode__c='Parallel';
        job.contentType__c='CSV';
        job.apiVersion__c='49.0';
        job.jobType__c='Classic';   
        insert job;

        String vUrl = 'https://caixabankcc--str4.sandbox.my.salesforce.com/services/async/59.0/job/7505r0000088obPAAQ/batch';

        List<CBK_MonitorJobs.responseParse> lstrequestDto = new List<CBK_MonitorJobs.responseParse>();
        CBK_MonitorJobs.responseParse requestDto = new CBK_MonitorJobs.responseParse();
        requestDto.id = '12345678';
        requestDto.jobId = '7503Y00000TGeNyQAL';
        requestDto.state = 'InProgress';
        requestDto.systemModstamp = '2023-09-07T12:15:25.000+0000';
        lstrequestDto.add(requestDto);
        requestDto = new CBK_MonitorJobs.responseParse();
        requestDto.id = '9876543121';
        requestDto.jobId = '7503Y00000TGeNyQAL';
        requestDto.state = 'InProgress';
        requestDto.systemModstamp = '2023-09-07T12:15:25.000+0000';
        lstrequestDto.add(requestDto);

        CBK_MonitorJobs.lstInfobatches infobatches = new CBK_MonitorJobs.lstInfobatches();
        infobatches.batchInfo = lstrequestDto;

        Test.setMock(HttpCalloutMock.class, new CBK_HttpService_Mock_TEST(vUrl, JSON.serialize(infobatches), 'GET', 200));
        
        Test.startTest();
        System.runAs (usr) {
            CBK_MonitorJobs.CBK_JobDetail(job.Job_Id__c);
        }
        Test.stopTest();
        job = [Select Entidad__c from CBK_log__c where Id=:job.Id];
        System.assertnotEquals('Test', job.Entidad__c);


    }
    @isTest
    static void detalleBatchesbyjob_completed() {
        User usr = [SELECT id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        CBK_log__c job = New CBK_log__c();
        job.RecordTypeId=Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('Data_Load_Log').getRecordTypeId();
        job.Job_Id__c='7503Y00000TGeNyQAL';
        job.operation__c='query';
        job.object__c='Case';
        job.Entidad__c ='Test';
        job.createdBy__c=usr.Id;
        job.createdDate__c=datetime.now();
        job.systemModstamp__c=datetime.now();
        job.state__c='Closed';
        job.concurrencyMode__c='Parallel';
        job.contentType__c='CSV';
        job.apiVersion__c='49.0';
        job.jobType__c='Classic';   
        insert job;

        String vUrl = 'https://caixabankcc--str4.sandbox.my.salesforce.com/services/async/59.0/job/7505r0000088obPAAQ/batch';

        List<CBK_MonitorJobs.responseParse> lstrequestDto = new List<CBK_MonitorJobs.responseParse>();
        CBK_MonitorJobs.responseParse requestDto = new CBK_MonitorJobs.responseParse();
        requestDto.id = '12345678';
        requestDto.jobId = '7503Y00000TGeNyQAL';
        requestDto.state = 'Completed';
        requestDto.systemModstamp = '2023-09-07T12:15:25.000+0000';
        lstrequestDto.add(requestDto);
        requestDto = new CBK_MonitorJobs.responseParse();
        requestDto.id = '9876543121';
        requestDto.jobId = '12345678888';
        requestDto.state = 'Completed';
        requestDto.systemModstamp = '2023-09-07T12:15:25.000+0000';
        lstrequestDto.add(requestDto);

        CBK_MonitorJobs.lstInfobatches infobatches = new CBK_MonitorJobs.lstInfobatches();
        infobatches.batchInfo = lstrequestDto;

        Test.setMock(HttpCalloutMock.class, new CBK_HttpService_Mock_TEST(vUrl, JSON.serialize(infobatches), 'GET', 200));
        
        Test.startTest();
        System.runAs (usr) {
            CBK_MonitorJobs.CBK_JobDetail(job.Job_Id__c);
        }
        Test.stopTest();
        job = [Select Entidad__c from CBK_log__c where Id=:job.Id];
        System.assertnotEquals('Test', job.Entidad__c);


    }

    @isTest
    static void detalleBatchesbyjob_completedXML() {
        String xmlResp = '<batchInfoList><batchInfo><id>7515r000008oHprAAE</id><jobId>7505r0000088yZKAAY</jobId><state>Completed</state><createdDate>2023-09-13T09:32:13.000Z</createdDate><systemModstamp>2023-09-13T09:32:24.000Z</systemModstamp><numberRecordsProcessed>249997</numberRecordsProcessed><numberRecordsFailed>0</numberRecordsFailed><totalProcessingTime>0</totalProcessingTime><apiActiveProcessingTime>0</apiActiveProcessingTime><apexProcessingTime>0</apexProcessingTime></batchInfo><batchInfo><id>7515r000008oHq6AAE</id><jobId>7505r0000088yZKAAY</jobId><state>Completed</state><createdDate>2023-09-13T09:32:24.000Z</createdDate><systemModstamp>2023-09-13T09:32:28.000Z</systemModstamp><numberRecordsProcessed>25149</numberRecordsProcessed><numberRecordsFailed>0</numberRecordsFailed><totalProcessingTime>0</totalProcessingTime><apiActiveProcessingTime>0</apiActiveProcessingTime><apexProcessingTime>0</apexProcessingTime></batchInfo></batchInfoList>';
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/xml');
        response.setBody(xmlResp);
        response.setStatusCode(200);

        CBK_MonitorJobs.lstInfobatches result =  new CBK_MonitorJobs.lstInfobatches();        
        Test.startTest();
        User usr = [SELECT id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        System.runAs (usr) {
            result = CBK_MonitorJobs.parseResponse(response, 'application/xml');
        }
        Test.stopTest();
        System.assertEquals(2, result.batchInfo.size());
    }
    @testSetup
    static void setup()
    {
        User user = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema'].Id,
            LastName = 'LastNameTest',
            Email = 'test@test.com',
            Username = 'test@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
        insert user;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CBK_Framework_Login'];
        insert new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps.Id);
    }
}