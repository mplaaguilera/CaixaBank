trigger CC_AccountContactRelationTrigger on AccountContactRelation (after insert, after update) {
    CC_TriggerFactory.createTriggerDispatcher(AccountContactRelation.sObjectType);
}