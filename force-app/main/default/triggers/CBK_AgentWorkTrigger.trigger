trigger CBK_AgentWorkTrigger on AgentWork (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(AgentWork.sObjectType);
}