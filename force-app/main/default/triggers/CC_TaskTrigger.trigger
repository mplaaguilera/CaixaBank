trigger CC_TaskTrigger on Task (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(Task.sObjectType);
}