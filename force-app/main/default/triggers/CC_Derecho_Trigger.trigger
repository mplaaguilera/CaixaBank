trigger CC_Derecho_Trigger on CC_Derecho__c (after insert) {
	CC_TriggerFactory.createTriggerDispatcher(CC_Derecho__c.sObjectType);
}