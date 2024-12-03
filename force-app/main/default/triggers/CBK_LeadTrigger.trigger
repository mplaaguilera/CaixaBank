trigger CBK_LeadTrigger on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    //System.debug('CBK_LeadTrigger');
    CC_TriggerFactory.createTriggerDispatcher(Lead.sObjectType);
}