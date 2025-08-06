trigger CBK_Promotion on copado__Promotion__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(copado__Promotion__c.sObjectType); 
}