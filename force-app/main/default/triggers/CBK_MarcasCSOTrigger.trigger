trigger CBK_MarcasCSOTrigger on SEG_MarcasCSO__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(SEG_MarcasCSO__c.sObjectType);
}