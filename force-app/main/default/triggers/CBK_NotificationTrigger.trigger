trigger CBK_NotificationTrigger on CBK_Notification__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(CBK_Notification__c.sObjectType);
}