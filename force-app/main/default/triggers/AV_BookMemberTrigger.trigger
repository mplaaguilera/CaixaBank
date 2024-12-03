trigger AV_BookMemberTrigger on AV_BookMember__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(AV_BookMember__c.sObjectType);
}