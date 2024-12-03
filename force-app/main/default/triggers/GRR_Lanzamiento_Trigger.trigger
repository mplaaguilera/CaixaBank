trigger GRR_Lanzamiento_Trigger on GRR_Lanzamiento__c (before insert,after insert, after delete) {
    CC_TriggerFactory.createTriggerDispatcher(GRR_Lanzamiento__c.sObjectType);
}