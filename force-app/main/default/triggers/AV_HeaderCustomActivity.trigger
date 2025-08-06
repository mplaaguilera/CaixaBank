trigger AV_HeaderCustomActivity on AV_HeaderCustomActivity__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(AV_HeaderCustomActivity__c.sObjectType);
}