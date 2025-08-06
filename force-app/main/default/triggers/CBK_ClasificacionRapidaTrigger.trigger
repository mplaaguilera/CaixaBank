trigger CBK_ClasificacionRapidaTrigger on SEG_ClasificacionRapida__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(SEG_ClasificacionRapida__c.sObjectType);
}