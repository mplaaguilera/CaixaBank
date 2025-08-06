trigger CBK_MCCServiciosCSOTrigger on SEG_MCCServiciosCSO__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(SEG_MCCServiciosCSO__c.sObjectType);
}