@isTest
public class CBK_BatchJobCheck_test {
    @isTest 
    static void execute() {
        Test.StartTest();
        Datetime sysTime = Datetime.now().addMinutes(1);
        //parse to cron expression
		String chronExp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        CBK_BatchJobCheck scheduler = new CBK_BatchJobCheck(); 
        String jobName='Test_Framework Batch Check';
      	System.schedule(jobName, chronExp, scheduler);
        Test.StopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime,CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'Test_Framework Batch Check']; 
        System.assertEquals(sysTime, ct.NextFireTime);   
    }
}