trigger AV_CustomActivityOppTrigger on AV_CustomActivityOpportunity__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(AV_CustomActivityOpportunity__c.sObjectType);
}