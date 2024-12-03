@isTest
public with sharing class SEG_ConciliacionAccount_SC_Test
{ 

    @isTest
    public static void conciliacionSC()
    {

        String cronEXP = '0 0 0 1/1 * ? *';

		Test.startTest();
        	String jobId = System.schedule('ScheduledApexTest', cronEXP, new SEG_ConciliacionAccount_SC());
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cronEXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    }
}