trigger CC_CanalCom_Trigger on CC_Canal_Com__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(CC_Canal_Com__c.sObjectType);
}