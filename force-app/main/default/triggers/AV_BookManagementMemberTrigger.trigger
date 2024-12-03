trigger AV_BookManagementMemberTrigger on AV_BookManagementMember__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(AV_BookManagementMember__c.sObjectType);
}