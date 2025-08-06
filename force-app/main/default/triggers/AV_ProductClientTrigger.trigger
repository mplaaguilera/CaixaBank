trigger AV_ProductClientTrigger on AV_ProductClient__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(AV_ProductClient__c.sObjectType);
}