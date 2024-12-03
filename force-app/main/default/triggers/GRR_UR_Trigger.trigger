trigger GRR_UR_Trigger on GRR_UR__c (after update, after delete) {
   CC_TriggerFactory.createTriggerDispatcher(GRR_UR__c.sObjectType);
}