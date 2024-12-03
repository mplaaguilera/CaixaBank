public with sharing class CBK_ScheduleProcess_BI_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CBK_SCH_PendingProcess__c>) tp.newList, (Map<Id, CBK_SCH_PendingProcess__c>) tp.newMap);
	}

	private void process(List<CBK_SCH_PendingProcess__c> listNewObj, Map<Id, CBK_SCH_PendingProcess__c> mapNewObj) {
	
		CBK_ScheduleProcessTriggerHelper.generateCheck(listNewObj);
	}
}