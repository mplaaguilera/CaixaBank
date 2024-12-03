trigger CC_MCC_Knowledge_Trigger on CBK_MCC_Knowledge__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(CBK_MCC_Knowledge__c.sObjectType);
}