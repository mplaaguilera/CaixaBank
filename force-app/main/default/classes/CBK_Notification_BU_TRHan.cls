public class CBK_Notification_BU_TRHan extends CC_TriggerHandlerBase {
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CBK_Notification__c>) tp.newList, (Map<Id, CBK_Notification__c>) tp.newMap, (List<CBK_Notification__c>) tp.oldList, (Map<Id, CBK_Notification__c>) tp.oldMap);
	}

	private void process(List<CBK_Notification__c> listNewObj, Map<Id, CBK_Notification__c> mapNewObj, List<CBK_Notification__c> listOldObj, Map<Id, CBK_Notification__c> mapOldObj) {
		System.debug(JSON.serializePretty(listNewObj));

		Set<string> setIds = new Set<string> ();

		for (CBK_Notification__c noti : listNewObj) {
			setIds.add(noti.Id);
		}
		Map<String, CBK_Notification__c> mNoti = new map<String, CBK_Notification__c> ();
		List<CBK_Notification__c> lstNoti = [SELECT Id, Autor__c, App__c, CreatedBy.Name FROM CBK_Notification__c where Id = :setIds];

		for (CBK_Notification__c noti : lstNoti){
			noti.Autor__c = String.isNotBlank(noti.Autor__c) ? noti.Autor__c : noti.CreatedBy.Name;
			//noti.AppStr__c = noti.App__c;
			mNoti.put(noti.Id, noti);
		}
		
		set<string> setApp = new Set<String>();
		for (CBK_Notification__c noti : listNewObj) {
			noti.Autor__c = mNoti.get(noti.Id).Autor__c;
			noti.AppStr__c = noti.App__c;
			CBK_NotificationBar_Controller.registerCache(noti.App__c, noti.Id);
		}
	}
}