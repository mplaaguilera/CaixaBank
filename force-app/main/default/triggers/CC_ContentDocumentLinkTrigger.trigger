trigger CC_ContentDocumentLinkTrigger on ContentDocumentLink (after insert, before delete) {
    CC_TriggerFactory.createTriggerDispatcher(ContentDocumentLink.sObjectType);
}