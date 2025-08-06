@isTest
private class CBK_BatchJob_Sched_test {
    @isTest 
    static void newSchedule() {
        list<AdminSettings__c>  lstcs = [Select ScheduleJob__c from AdminSettings__c ];
        AdminSettings__c  cs;
        if (lstcs.size()==0) {
	        cs = new AdminSettings__c ();    
        } else {
            cs = lstcs[0];
        }
        cs.ScheduleJob__c  =5;
        upsert cs;
        
        Test.StartTest();
        CBK_BatchJob_Sched.start();
        Test.StopTest();
        //System.assertEquals(sysTime, ct.NextFireTime);   
        list<CronTrigger> lstjobs = [SELECT Id, CronJobDetail.name, State FROM CronTrigger
									  Where CronJobDetail.name like 'Framework Batch:%'
                                        and State in ('WAITING','ACQUIRED','EXECUTING')];
        
        //En modo Test no planifica el JOB
        system.assertEquals(lstjobs.size(), 0);

    }
    
    @isTest 
    static void execute() {
        Test.StartTest();
        Datetime sysTime = Datetime.now().addMinutes(1);
        //parse to cron expression
		String chronExp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        CBK_BatchJob_Sched scheduler = new CBK_BatchJob_Sched(); 
        String jobName='Test_Framework Batch';
      	System.schedule(jobName, chronExp, scheduler);
        Test.StopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime,CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'Test_Framework Batch']; 
        System.assertEquals(sysTime, ct.NextFireTime);   
    }
    
    
    


}