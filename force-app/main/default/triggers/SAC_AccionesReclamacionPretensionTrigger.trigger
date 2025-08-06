trigger  SAC_AccionesReclamacionPretensionTrigger on SAC_Accion__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(SAC_Accion__c.sObjectType);
}