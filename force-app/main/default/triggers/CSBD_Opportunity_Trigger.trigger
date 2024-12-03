trigger CSBD_Opportunity_Trigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(Opportunity.sObjectType);
}