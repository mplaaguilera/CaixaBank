trigger CC_LiveChatTranscriptTrigger on LiveChatTranscript (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    CC_TriggerFactory.createTriggerDispatcher(LiveChatTranscript.sObjectType);
}