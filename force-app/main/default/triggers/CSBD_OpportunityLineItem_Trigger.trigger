trigger CSBD_OpportunityLineItem_Trigger on OpportunityLineItem (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(OpportunityLineItem.sObjectType);
}