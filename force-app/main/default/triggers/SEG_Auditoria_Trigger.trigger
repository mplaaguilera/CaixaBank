trigger SEG_Auditoria_Trigger on SEG_Auditoria__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(SEG_Auditoria__c.sObjectType);
}