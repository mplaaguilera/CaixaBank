trigger CBK_DataManagerTrigger on CBK_DataManager__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	CC_TriggerFactory.createTriggerDispatcher(CBK_DataManager__c.sObjectType);
}