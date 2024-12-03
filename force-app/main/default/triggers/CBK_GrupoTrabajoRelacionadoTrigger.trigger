trigger CBK_GrupoTrabajoRelacionadoTrigger on SEG_GrupoTrabajoRelacionado__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(SEG_GrupoTrabajoRelacionado__c.sObjectType);
}