trigger CC_ServiceResourceSkillTrigger on ServiceResourceSkill (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(ServiceResourceSkill.sObjectType);
}