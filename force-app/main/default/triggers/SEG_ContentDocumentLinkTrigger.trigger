trigger SEG_ContentDocumentLinkTrigger on ContentDocumentLink(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(ContentDocumentLink.sObjectType);
}