trigger SAC_TMECasoTrigger on SAC_TMECaso__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(SAC_TMECaso__c.sObjectType);
}