trigger CIBE_FeedComment_Trigger on FeedComment (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(FeedComment.sObjectType);
}