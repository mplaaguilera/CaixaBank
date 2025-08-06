trigger CC_User_Trigger on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(User.sObjectType);
}