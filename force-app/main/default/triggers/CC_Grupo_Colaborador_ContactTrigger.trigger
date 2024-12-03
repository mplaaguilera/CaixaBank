trigger CC_Grupo_Colaborador_ContactTrigger on CC_Grupo_Colaborador_Contact__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(CC_Grupo_Colaborador_Contact__c.sObjectType);

}