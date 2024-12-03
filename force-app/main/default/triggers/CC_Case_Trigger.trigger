trigger CC_Case_Trigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(Case.sObjectType);
}