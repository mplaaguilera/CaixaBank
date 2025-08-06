trigger AV_NotifyMeTrigger on AV_NotifyMe__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(AV_NotifyMe__c.sObjectType);
}