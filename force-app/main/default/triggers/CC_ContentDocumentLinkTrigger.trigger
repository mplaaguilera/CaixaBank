trigger CC_ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    CC_TriggerFactory.createTriggerDispatcher(ContentDocumentLink.sObjectType);
}