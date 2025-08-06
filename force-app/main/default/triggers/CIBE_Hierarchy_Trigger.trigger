trigger CIBE_Hierarchy_Trigger on CIBE_Hierarchy__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(CIBE_Hierarchy__c.sObjectType);
}