trigger CC_Knowledge_Trigger on Knowledge__kav (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(Knowledge__kav.sObjectType);
}