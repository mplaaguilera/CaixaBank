trigger CC_Derecho on CC_Derecho__c (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        CC_Derecho_TriggerHandler.handleAfterInsert(Trigger.new);
    }
}
