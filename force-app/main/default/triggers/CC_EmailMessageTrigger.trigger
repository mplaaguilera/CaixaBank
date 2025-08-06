trigger CC_EmailMessageTrigger on EmailMessage (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	CC_TriggerFactory.createTriggerDispatcher(EmailMessage.sObjectType);
}