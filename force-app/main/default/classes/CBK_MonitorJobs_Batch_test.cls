@isTest
private class CBK_MonitorJobs_Batch_test {
    @testSetup 
    static void setup() {
       User usr = [Select Id from User LIMIT 1];
        CBK_log__c job = New CBK_log__c();
        job.Job_Id__c='7503Y00000TGeNyQAL';
        job.RecordtypeId=Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('Data_Load_Log').getRecordTypeId();
        job.operation__c='upsert';
        job.object__c='Case';
        job.createdBy__c=usr.Id;
        job.createdDate__c=datetime.now();
        job.systemModstamp__c=datetime.now();
        job.state__c='Closed';
        job.concurrencyMode__c='Parallel';
        job.contentType__c='CSV';
        job.apiVersion__c='49.0';
        job.jobType__c='Classic';   
        insert job;

    }
    
    static testmethod void test() {
        Test.setMock(HttpCalloutMock.class, new CBK_MonitorJobs_Mock());

        Test.startTest();
        CBK_MonitorJobs_Batch uca = new CBK_MonitorJobs_Batch();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        System.assertnotEquals(null, batchId);

    }
    
}