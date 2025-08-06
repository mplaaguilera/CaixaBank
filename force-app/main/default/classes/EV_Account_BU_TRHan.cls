public with sharing class EV_Account_BU_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Account>)tp.newList, (Map<Id, Account>)tp.newMap, (List<Account>) tp.oldList, (Map<Id, Account>) tp.oldMap);
    }
    
    private void process(List<Account> listNewObj, Map<Id, Account> mapNewObj, List<Account> listOldObj, Map<Id, Account> mapOldObj) {
  
			EV_AccountTriggerHelper.updateLastModifiedDate(listNewObj, mapOldObj);
	}
}