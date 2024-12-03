trigger CBK_SCH_PendingProcess on CBK_SCH_PendingProcess__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(CBK_SCH_PendingProcess__c.sObjectType);
}