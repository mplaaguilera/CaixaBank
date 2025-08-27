trigger CC_AgrupadorTrigger on CC_Agrupador__c (before update, before insert, after insert, after update) {
	CC_TriggerFactory.createTriggerDispatcher(CC_Agrupador__c.sObjectType);
}