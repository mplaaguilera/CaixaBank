trigger SEG_Contratos_Trigger on SEG_Contratos__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(SEG_Contratos__c.sObjectType);
}