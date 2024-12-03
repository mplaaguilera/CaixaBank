trigger CBK_Release on copado__Release__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(copado__Release__c.sObjectType);
}