public class CBK_DataManager_BU_TRHan  extends CC_TriggerHandlerBase {
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CBK_DataManager__c>) tp.oldList, (Map<Id, CBK_DataManager__c>) tp.oldMap,(List<CBK_DataManager__c>) tp.newList, (Map<Id, CBK_DataManager__c>) tp.newMap);
	}

	private void process(List<CBK_DataManager__c> listOldObj, Map<Id, CBK_DataManager__c> mapOldObj, List<CBK_DataManager__c> listNewObj, Map<Id, CBK_DataManager__c> mapNewObj) {

		for(CBK_DataManager__c dm : mapNewObj.values()){

			if (dm.RecordType.DeveloperName == 'RecordType'  && dm.Proyectos__c != mapOldObj.get(dm.id).Proyectos__c && dm.Proyectos__c == 'Approved'){
				dm.Status__c = 'Pending';
			}
		}

		if (listNewObj != null && listNewObj.size() > 0) {	
			CBK_DataManagerTriggerHelper.checkDataManagerApp(listOldObj, listNewObj);
		}
	}
}