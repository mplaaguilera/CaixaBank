trigger CBK_RegladeclasificacionTrigger on SEG_Regladeclasificacion__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(SEG_Regladeclasificacion__c.sObjectType);
}