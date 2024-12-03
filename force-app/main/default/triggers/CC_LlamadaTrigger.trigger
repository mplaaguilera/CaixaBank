trigger CC_LlamadaTrigger on CC_Llamada__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(CC_Llamada__c.sObjectType);
}