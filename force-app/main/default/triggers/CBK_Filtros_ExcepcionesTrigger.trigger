trigger CBK_Filtros_ExcepcionesTrigger on SEG_Filtros_Excepciones__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(SEG_Filtros_Excepciones__c.sObjectType);
}