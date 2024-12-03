public class CBK_DataManager_BI_TRHan extends CC_TriggerHandlerBase {
	static String OBJECT_RT_ID = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByName().get('Object').getRecordTypeId();
	static String FIELD_RT_ID = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByName().get('Field').getRecordTypeId();

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CBK_DataManager__c>) tp.newList, (Map<Id, CBK_DataManager__c>) tp.newMap);
	}

	private void process(List<CBK_DataManager__c> listNewObj, Map<Id, CBK_DataManager__c> mapNewObj) {

		/* for(CBK_DataManager__c dm : listNewObj){
			if (dm.RecordTypeId == FIELD_RT_ID){
				dm.Name = dm.Field_Name__c;

			}else if (dm.RecordTypeId == OBJECT_RT_ID){
				dm.Name = dm.Object_Name__c;
			}
		} */

		if (listNewObj != null && listNewObj.size() > 0) {
			CBK_DataManagerTriggerHelper.checkDataManager(listNewObj);
		}
	}
}