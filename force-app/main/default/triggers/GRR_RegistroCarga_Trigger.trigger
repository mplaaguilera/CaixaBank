trigger GRR_RegistroCarga_Trigger on GRR_RegistroCarga__c (after insert) {
    CC_TriggerFactory.createTriggerDispatcher(GRR_RegistroCarga__c.sObjectType);
}