public with sharing class CIBE_TaskCallReportFields {
	@AuraEnabled(cacheable=true)
    public static String getExtensionId(String eventId){
		List<CBK_Activity_Extension__c> actExtensionList = 	[SELECT ID FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :eventId];
        
		return  actExtensionList[0].Id;       
    }
}