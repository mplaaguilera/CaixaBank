trigger CIBE_FeedItem_Trigger on FeedItem (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(FeedItem.sObjectType);
}