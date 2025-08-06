@isTest
private class CBK_ScheduleProcess_BI_TRHan_Test {

	@isTest
	private static void TestBIShcheduleProccess() {
		List<CBK_SCH_PendingProcess__c> lstPending = new List<CBK_SCH_PendingProcess__c> ();
		CBK_SCH_PendingProcess__c pp = new CBK_SCH_PendingProcess__c();
		Datetime vToday = DateTime.newInstance(2021, 4, 23, 7, 8, 16);
		
		pp.Type__c = 'EMAIL';
		pp.RecordId__c = '12345677';
		pp.Schedule_Time__c = vToday.addDays(- 1);
		pp.ClassName__c = 'CBKQueuableTEST';
		pp.Retries__c = 0;
		lstPending.add(pp);

		pp = new CBK_SCH_PendingProcess__c();
		pp.Type__c = 'SMS';
		pp.RecordId__c = '5634565765';
		pp.Schedule_Time__c = vToday.addDays(- 1);
		pp.ClassName__c = 'CBKQueuableTEST';
		pp.Retries__c = 0;
		lstPending.add(pp);
		insert lstPending;

		set<string> sIds = new Set<String> ();
		for (CBK_SCH_PendingProcess__c sch : lstPending) {
			sIds.add(sch.Id);
		}

		List<CBK_SCH_PendingProcess__c> fSch = [SELECT Id, Check__c FROM CBK_SCH_PendingProcess__c WHERE Id IN :sIds];
		Boolean check = false;

		for (CBK_SCH_PendingProcess__c spp : fSch) {

			if (String.isNotBlank(spp.Check__c) && spp.Check__c == 'CBKQueuableTESTEMAIL123456772214227816') {
				check = true;
			}
			else if (String.isNotBlank(spp.Check__c) && spp.Check__c == 'CBKQueuableTESTSMS56345657652214227816') {
				check = true;
			}

		}

		System.assertEquals(true, check);

	}
}