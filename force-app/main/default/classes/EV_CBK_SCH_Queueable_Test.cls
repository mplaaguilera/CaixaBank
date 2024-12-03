@isTest
public with sharing class EV_CBK_SCH_Queueable_Test {
    @isTest
    public static void validateWork() {
        List<CBK_SCH_PendingProcess__c> lstInsert = createData(2);
        Test.startTest();
		EV_CBK_SCH_Queueable implClass = new EV_CBK_SCH_Queueable();
		implClass.lstInfoProcess = lstInsert;
		System.enqueueJob(implClass);
        Test.stopTest();
    }
    private static List<CBK_SCH_PendingProcess__c> createData(integer numConf) {

		CBK_ScheduleControls__c schInf = new CBK_ScheduleControls__c(name = 'ScheduleInfo', Retries__c = 3);
		insert schInf;
		Campaign camp = EV_TestHelper.createChildCampaignVirtual();
		Campaign campTest = [SELECT id FROM Campaign WHERE EV_ExternalId__c = '234567890' ];
		

		Datetime vToday = datetime.now();
		List<CBK_SCH_PendingProcess__c> lstPending = new List<CBK_SCH_PendingProcess__c> ();
		CBK_SCH_PendingProcess__c pp = new CBK_SCH_PendingProcess__c();
		if (numConf != 2) {
			vToday = DateTime.newInstance(2021, 4, 23, 7, 8, 16);
			pp.Type__c = 'EMAIL';
			pp.RecordId__c = '12345677';
			pp.Schedule_Time__c = vToday.addDays(- 1);
			pp.ClassName__c = 'CBKSCHQueueable';
			pp.Retries__c = 0;
			lstPending.add(pp);

			vToday = DateTime.newInstance(2021, 4, 23, 7, 8, 17);
			pp = new CBK_SCH_PendingProcess__c();
			pp.Type__c = 'SMS';
			pp.RecordId__c = '5634565765';
			pp.Schedule_Time__c = vToday.addDays(- 1);
			pp.ClassName__c = 'CBKSCHQueueable';
			pp.Retries__c = 0;
			lstPending.add(pp);

			vToday = DateTime.newInstance(2021, 4, 23, 7, 8, 18);
			pp = new CBK_SCH_PendingProcess__c();
			pp.Type__c = 'SMS';
			pp.RecordId__c = '5634565765';
			pp.Schedule_Time__c = vToday.addDays(- 1);
			pp.ClassName__c = 'CBKSCHQueueableXXXX';
			pp.Retries__c = 0;
			lstPending.add(pp);

			if (numConf != 1) { insert lstPending; }


		} else if (numConf == 2) {


			DateTime myDateTime = DateTime.newInstance(2021, 4, 23, 7, 8, 17);
			pp = new CBK_SCH_PendingProcess__c();
			pp.Type__c = 'SMS';
			pp.RecordId__c = campTest.Id;
			pp.Schedule_Time__c = myDateTime;
			pp.ClassName__c = 'CBKSCHQueueable';
			pp.Retries__c = 1;
			insert pp;
			lstPending.add(pp);


			

		}

		return lstPending;
	}
}