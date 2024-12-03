@isTest
public with sharing class SEG_ReclamAuto_Schedule_Test {
    @isTest
	public static void startCalled() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
            String cronExp = '0 0 0 3 9 ? 2024';
            system.schedule('TestReclamaciones', cronExp, new SEG_ReclamacionesAutomaticas_Schedulable());
		Test.stopTest();     

        System.assertNotEquals(cronExp,null,'SEG_ReclamAuto_Schedule_Test-->CRON_EXP');
        }
	}
}