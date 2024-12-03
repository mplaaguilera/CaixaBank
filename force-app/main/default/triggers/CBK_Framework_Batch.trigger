trigger CBK_Framework_Batch on CBK_Framework_Batch__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(CBK_Framework_Batch__c.sObjectType);
}