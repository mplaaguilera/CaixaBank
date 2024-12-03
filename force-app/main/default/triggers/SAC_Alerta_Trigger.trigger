trigger SAC_Alerta_Trigger on SAC_Alerta__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(SAC_Alerta__c.sObjectType);
}