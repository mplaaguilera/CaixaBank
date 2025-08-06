trigger CBK_EventTrigger on Event (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(Event.sObjectType);
}