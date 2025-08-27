trigger CBK_Context_SACTrigger on CBK_Context_SAC__e (after insert) {
   CC_TriggerFactory.createTriggerDispatcher(CBK_Context_SAC__e.sObjectType);
}