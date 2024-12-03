@isTest
public with sharing class CC_DeleteReadOnly_Batch_Schedule_Test {
    @isTest 
    public static void scheduleTest() 
    {
        String scheduleName = 'Delete Read Only';
        String dt = DateTime.now().addMinutes(10).format('s m H d M ? y');
        String CRON_EXP = string.valueOf(dt);
        CC_DeleteReadOnly_Batch_Schedule apexEje = new CC_DeleteReadOnly_Batch_Schedule();

        Test.startTest();
            String jobId = System.schedule(scheduleName, CRON_EXP,apexEje);
        Test.stopTest();

        // Check schedulable is in the job list
        List<AsyncApexJob> jobsScheduled = [SELECT Id, ApexClassID, ApexClass.Name, Status, JobType FROM AsyncApexJob WHERE JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertEquals('CC_DeleteReadOnly_Batch_Schedule', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');
        
        // check apex batch is in the job list
        // List<AsyncApexJob> jobsApexBatch = [SELECT Id, ApexClassID, ApexClass.Name, Status, JobType FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        // System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');
        // System.assertEquals('CC_FacturarCasosCerrados_Batch', jobsApexBatch[0].ApexClass.Name, 'expecting specific batch job');

    }
}