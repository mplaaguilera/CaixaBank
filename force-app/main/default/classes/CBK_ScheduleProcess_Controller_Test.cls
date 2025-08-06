@isTest
public class CBK_ScheduleProcess_Controller_Test {

	@isTest
	private static void testControllerPP() {
		List<CBK_SCH_PendingProcess__c> lstInsert = createData(3);
		Test.startTest();
		String CRON_EXP = '0 0 0 1 1 ? 2025';
		String jobId = System.schedule('testScheduledApex', CRON_EXP, new CBK_ScheduleProcess_Controller());

		CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct.NextFireTime));
		Test.stopTest();
	}
	@isTest
	private static void testCreateRecordPP_AllNews() {
		List<CBK_SCH_PendingProcess__c> lstInsert = createData(1);
		List<CBK_ScheduleProcess_Controller.ResponseInsert> lstResponse = CBK_ScheduleProcess_Controller.createRecordSchProcess(lstInsert);
		asserts(lstResponse);
	}

	@isTest
	private static void testGetInfoRecordPP() {
		List<CBK_SCH_PendingProcess__c> lstInsert = createData(3);
		set<string> sIds = new Set<string> ();
		for (CBK_SCH_PendingProcess__c scp : lstInsert) {
			sIds.add(scp.RecordId__c);
		}
		List<CBK_SCH_PendingProcess__c> Lsinfo = CBK_ScheduleProcess_Controller.getInfoRecordSchProcess(sIds);
		Boolean vcheck = false;
		if (Lsinfo.size() > 0) {
			vcheck = true;
		}

		System.assertEquals(true, vcheck);

	}

	@isTest
	private static void testCreateRecordPP_NoNews() {
		List<CBK_SCH_PendingProcess__c> lstInsert = createData(2);
		List<CBK_ScheduleProcess_Controller.ResponseInsert> lstResponse = CBK_ScheduleProcess_Controller.createRecordSchProcess(lstInsert);
		asserts(lstResponse);
	}

	@isTest
	private static void testDeleteRecordPP() {
		List<CBK_SCH_PendingProcess__c> lstInsert = createData(3);
		set<string> sIds = new Set<string> ();

		for (CBK_SCH_PendingProcess__c scp : lstInsert) { sIds.add(scp.Id); }


		CBK_ScheduleProcess_Controller.deleteRecordSchProcess(sIds);

		lstInsert = new List<CBK_SCH_PendingProcess__c> ();
		lstInsert = [SELECT Id, Check__c FROM CBK_SCH_PendingProcess__c where Id IN :sIds];

		System.assertEquals(0, lstInsert.size());
	}

	//@isTest
	//private static void testInsertRecordPP_ErrorDML() {
		//List<CBK_SCH_PendingProcess__c> lstInsert = createData(4);
		//List<CBK_ScheduleProcess_Controller.ResponseInsert> lstResponse = CBK_ScheduleProcess_Controller.createRecordSchProcess(lstInsert);
		//Boolean check = false;
		//for (CBK_ScheduleProcess_Controller.ResponseInsert respIst : lstResponse) {

			//if (respIst.hasError) {
				//check = true;
			//}
		//}
		//System.assertEquals(true, check);
	//}

	@isTest
	private static void testUpdateRecordPP() {
		List<CBK_SCH_PendingProcess__c> lstInsert = createData(3);
		List<CBK_SCH_PendingProcess__c> lstUpdate = new List<CBK_SCH_PendingProcess__c> ();
		Map<String, CBK_SCH_PendingProcess__c> mapInsert = new Map<String, CBK_SCH_PendingProcess__c> ();
		set<string> sIds = new Set<string> ();

		for (CBK_SCH_PendingProcess__c scp : lstInsert) {
			sIds.add(scp.Id);
			mapInsert.put(scp.Id, scp);
		}

		Datetime vScheDate = datetime.now().addDays(3);
		CBK_ScheduleProcess_Controller.updateRecordSchProcess(sIds, vScheDate, true);

		lstUpdate = [SELECT Id, Schedule_Time__c FROM CBK_SCH_PendingProcess__c where Id IN :sIds];

		Boolean checkUdp = false;
		if (lstUpdate.size() > 0) {

			for (CBK_SCH_PendingProcess__c scUdp : lstUpdate) {

				if (scUdp.Schedule_Time__c > mapInsert.get(scUdp.id).Schedule_Time__c) {
					checkUdp = true;
				}
			}
			System.assertEquals(true, checkUdp);
		}
	}

	private static void asserts(List<CBK_ScheduleProcess_Controller.ResponseInsert> lstResponse) {
		for (CBK_ScheduleProcess_Controller.ResponseInsert rep : lstResponse)
		{
			if (rep.CheckSum == 'CBKSCHQueueableEMAIL123456772214227816' || rep.CheckSum == 'CBKSCHQueueableOTROS222222222214287817' ||
			    rep.CheckSum == 'CBKSCHQueueableSMS56345657652214227817' || rep.CheckSum == 'CBKSCHQueueableXXXXSMS56345657652214227818') {
				System.assertEquals(false, rep.hasError);
			} else {
				System.assertEquals(true, rep.hasError);
			}
		}
	}

	private static List<CBK_SCH_PendingProcess__c> createData(integer numConf) {

		CBK_ScheduleControls__c schInf = new CBK_ScheduleControls__c(name = 'ScheduleInfo', Retries__c = 3, ExecutionPeriod__c = 1, Date_Last_Execution__c = datetime.now() );
		insert schInf;

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
			vToday = DateTime.newInstance(2021, 4, 23, 7, 8, 16);
			pp.Type__c = 'EMAIL';
			pp.RecordId__c = '12345677';
			pp.Schedule_Time__c = vToday.addDays(- 1);
			pp.ClassName__c = 'CBKSCHQueueable';
			pp.Retries__c = 0;
			lstPending.add(pp);

			DateTime myDateTime = DateTime.newInstance(2021, 4, 23, 7, 8, 17);
			pp = new CBK_SCH_PendingProcess__c();
			pp.Type__c = 'SMS';
			pp.RecordId__c = '225841111';
			pp.Schedule_Time__c = myDateTime;
			pp.ClassName__c = 'CBKSCHQueueable';
			pp.Retries__c = 1;
			insert pp;

			//myDateTime = DateTime.newInstance(2021, 4, 23, 7, 8, 18);
			pp = new CBK_SCH_PendingProcess__c();
			pp.Type__c = 'SMS';
			pp.RecordId__c = '225841111';
			pp.Schedule_Time__c = myDateTime;
			pp.ClassName__c = 'CBKSCHQueueable';
			pp.Retries__c = 0;
			lstPending.add(pp);


			pp = new CBK_SCH_PendingProcess__c();
			pp.Type__c = 'OTROS';
			pp.RecordId__c = '22222222';
			pp.Schedule_Time__c = myDateTime;
			pp.ClassName__c = 'CBKSCHQueueable';
			pp.Retries__c = 1;
			insert pp;

			pp = new CBK_SCH_PendingProcess__c();
			pp.Type__c = 'OTROS';
			pp.RecordId__c = '22222222';
			pp.Schedule_Time__c = myDateTime.addDays(5);
			pp.ClassName__c = 'CBKSCHQueueable';
			pp.Retries__c = 0;
			lstPending.add(pp);

			myDateTime = DateTime.newInstance(2021, 4, 23, 7, 8, 16);
			pp = new CBK_SCH_PendingProcess__c();
			pp.Type__c = 'OTROS';
			pp.RecordId__c = '333333';
			pp.Schedule_Time__c = myDateTime;
			pp.ClassName__c = 'CBKSCHQueueable';
			pp.Retries__c = 4;
			insert pp;

			pp = new CBK_SCH_PendingProcess__c();
			pp.Type__c = 'OTROS';
			pp.RecordId__c = '333333';
			pp.Schedule_Time__c = myDateTime;
			pp.ClassName__c = 'CBKSCHQueueable';
			pp.Retries__c = 0;
			lstPending.add(pp);

		}

		return lstPending;
	}
}