trigger AV_SalesTrigger on AV_Sales__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(AV_Sales__c.sObjectType);
}