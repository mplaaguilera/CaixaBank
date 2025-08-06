trigger CC_AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(Account.sObjectType);

}