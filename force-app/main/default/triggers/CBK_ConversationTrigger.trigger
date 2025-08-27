trigger CBK_ConversationTrigger on unblusuite__Conversation__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	CC_TriggerFactory.createTriggerDispatcher(unblusuite__Conversation__c.sObjectType);
}