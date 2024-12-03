trigger OB_ParametrizacionTrigger on OB_Parametrizacion__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(OB_Parametrizacion__c.sObjectType);
}