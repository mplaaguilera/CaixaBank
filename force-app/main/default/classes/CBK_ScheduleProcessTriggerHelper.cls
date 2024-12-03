public with sharing class CBK_ScheduleProcessTriggerHelper {

	public static void generateCheck(List<CBK_SCH_PendingProcess__c> lstPendingProcess) {
		string checkSum;
		string strDate;
		for (CBK_SCH_PendingProcess__c pendingProcess : lstPendingProcess)
		{
			strDate = String.valueOf(pendingProcess.Schedule_Time__c);
			checkSum = (String.isNotBlank(pendingProcess.ClassName__c) ? pendingProcess.ClassName__c : '')
			+ (String.isNotBlank(pendingProcess.Type__c) ? pendingProcess.Type__c : '')
			+ (String.isNotBlank(pendingProcess.RecordId__c) ? pendingProcess.RecordId__c : '')
			+ (String.isNotBlank(strDate) ? strDate : '');
			pendingProcess.Check__c = checkSum.replaceAll('[^(a-zA-Z1-9) ]','').deleteWhitespace();

		}
	}
}