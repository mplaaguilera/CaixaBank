trigger SAC_ParametrizacionSLATME on SAC_ParametrizacionSLATME__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(SAC_ParametrizacionSLATME__c.sObjectType);
}