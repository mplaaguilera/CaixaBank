trigger CC_MCC_Trigger on CC_MCC__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
  CC_TriggerFactory.createTriggerDispatcher(CC_MCC__c.sObjectType);
}