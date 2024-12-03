trigger AV_UserTrigger on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(User.sObjectType);
}