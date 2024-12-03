trigger CBK_MCC_Grupo_ColaboradorTrigger on CC_MCC_Grupo_Colaborador__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
CC_TriggerFactory.createTriggerDispatcher(CC_MCC_Grupo_Colaborador__c.sObjectType);
}