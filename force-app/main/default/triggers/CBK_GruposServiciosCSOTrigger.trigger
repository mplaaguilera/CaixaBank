trigger CBK_GruposServiciosCSOTrigger on SEG_GruposServiciosCSO__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(SEG_GruposServiciosCSO__c.sObjectType);
}