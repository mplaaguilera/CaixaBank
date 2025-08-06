trigger SAC_CaseReclamante on SAC_CaseReclamante__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(SAC_CaseReclamante__c.sObjectType);
}