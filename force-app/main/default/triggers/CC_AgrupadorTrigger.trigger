trigger CC_AgrupadorTrigger on CC_Agrupador__c (before update, before insert, after insert) {
	CC_TriggerFactory.createTriggerDispatcher(CC_Agrupador__c.sObjectType);
}