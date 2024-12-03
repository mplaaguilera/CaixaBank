@isTest
private class CBK_SCH_Queueable_Test {

	@isTest
	private static void testImpFWK() {
		List<CBK_SCH_PendingProcess__c> lstPending = new List<CBK_SCH_PendingProcess__c> ();
		CBK_SCH_PendingProcess__c pp = new CBK_SCH_PendingProcess__c();
		Datetime vToday = datetime.now();
		pp.Type__c = 'EMAIL';
		pp.RecordId__c = '12345677';
		pp.Schedule_Time__c = vToday.addDays(- 1);
		pp.ClassName__c = 'CBK_Queuable_TEST';
		pp.Retries__c = 0;
		lstPending.add(pp);

		pp = new CBK_SCH_PendingProcess__c();
		pp.Type__c = 'SMS';
		pp.RecordId__c = '5634565765';
		pp.Schedule_Time__c = vToday.addDays(- 1);
		pp.ClassName__c = 'CBK_Queuable_TEST';
		pp.Retries__c = 0;
		lstPending.add(pp);

		CBK_SCH_Queueable implClass = new CBK_SCH_Queueable();
		implClass.lstInfoProcess = lstPending;
		System.enqueueJob(implClass);
	}
}