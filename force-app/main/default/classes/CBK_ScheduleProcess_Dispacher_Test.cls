@isTest
private class CBK_ScheduleProcess_Dispacher_Test {

	@isTest
	private static void testSchPendingProcess() {
		Map<String, List<CBK_SCH_PendingProcess__c>> mapToProcess = new Map<String, List<CBK_SCH_PendingProcess__c>> ();
		list<CBK_SCH_PendingProcess__c> lstpp = new list<CBK_SCH_PendingProcess__c> ();
		Datetime vToday = datetime.now();
		CBK_SCH_PendingProcess__c pp = new CBK_SCH_PendingProcess__c();
		pp.Type__c = 'SMS';
		pp.RecordId__c = '225841111';
		pp.Schedule_Time__c = vToday;
		pp.ClassName__c = 'test';
		pp.Retries__c = 0;
		lstpp.add(pp);
		mapToProcess.put('test', lstpp);
		pp = new CBK_SCH_PendingProcess__c();
		pp.Type__c = 'SMS';
		pp.RecordId__c = '225841111';
		pp.Schedule_Time__c = vToday;
		pp.ClassName__c = 'CBK_SCH_Queueable';
		pp.Retries__c = 0;
		lstpp.add(pp);
		mapToProcess.put('CBK_SCH_Queueable', lstpp);
		CBK_ScheduleProcess_Dispacher ppDis = new CBK_ScheduleProcess_Dispacher();
		ppDis.execute(mapToProcess);
	}
}