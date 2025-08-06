trigger CBK_GestorGrupoTrigger on SEG_Gestor_Grupo__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(SEG_Gestor_Grupo__c.sObjectType);
}