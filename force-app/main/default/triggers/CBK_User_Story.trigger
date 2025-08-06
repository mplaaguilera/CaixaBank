trigger CBK_User_Story on copado__User_Story__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(copado__User_Story__c.sObjectType); 
}