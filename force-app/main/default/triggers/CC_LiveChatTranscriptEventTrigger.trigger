trigger CC_LiveChatTranscriptEventTrigger on LiveChatTranscriptEvent (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    CC_TriggerFactory.createTriggerDispatcher(LiveChatTranscriptEvent.sObjectType);
}