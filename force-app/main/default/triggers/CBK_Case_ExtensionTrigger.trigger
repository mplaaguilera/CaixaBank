trigger CBK_Case_ExtensionTrigger on CBK_Case_Extension__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(CBK_Case_Extension__c.sObjectType);
}