trigger CBK_LeadOpportunityTrigger on AV_LeadOpportunity__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    //System.debug('CBK_LeadTOpportunityrigger');
    CC_TriggerFactory.createTriggerDispatcher(AV_LeadOpportunity__c.sObjectType);
}