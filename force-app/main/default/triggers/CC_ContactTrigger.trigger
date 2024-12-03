trigger CC_ContactTrigger on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(Contact.sObjectType);
}