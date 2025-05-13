@isTest
public class CBK_WS_APIGraph_Schedule_Test {
    @testSetup 
    static void setup() {
        CBK_ScheduleControls__c schInf = new CBK_ScheduleControls__c(name = 'ScheduleApiGraph', Retries__c = 5, ExecutionPeriod__c = 15, Date_Last_Execution__c = datetime.now() );
		insert schInf;
        
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
        
        CBK_APIGraph_Mailbox__c mailbox2 = new CBK_APIGraph_Mailbox__c();
        mailbox2.name = 'ScheduleApiGraph2';
        mailbox2.CBK_MailboxID__c = '354a0728-b7c2-456a-8f87-9fde583019ce';
        mailbox2.CBK_IntervalMinutes__c = 15;
        mailbox2.CBK_OffsetMinutes__c = 5;
        mailbox2.CBK_LastMonitoringDate__c = datetime.now();
        mailbox2.CBK_NumberOfRetries__c = 5;
        mailbox2.CBK_App__c = 'Test';
        mailbox2.CBK_Forward__c = true;
		insert mailbox2;
    }
    @isTest
    public static void scheduleApiGraphTest(){
        Test.startTest();
        String CRON_EXP = '0 0 0 ? * * *';
		String jobId = System.schedule('TestScheduleApiGraph', CRON_EXP, new CBK_WS_APIGraph_Schedule());
		CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression);
		Test.stopTest();
    }
    
    @isTest
    public static void nextLinkScheduleApiGraphTest(){
        Map<String, CBK_APIGraph_Mailbox__c> nexExecutionParams = new Map<String, CBK_APIGraph_Mailbox__c>();
        for(CBK_APIGraph_Mailbox__c oMailbox : [SELECT Id FROM CBK_APIGraph_Mailbox__c]){
            nexExecutionParams.put(oMailbox.Id, oMailbox);
        }
        
        Test.startTest();
		String jobId = System.enqueueJob(new CBK_WS_APIGraph_NextLink_Schedule(nexExecutionParams));
		Assert.areEqual(true, !nexExecutionParams.isEmpty(), 'Lista de Mailboxes correcta');
		Test.stopTest();
    }
}