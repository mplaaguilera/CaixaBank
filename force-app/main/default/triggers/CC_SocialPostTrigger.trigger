trigger CC_SocialPostTrigger on SocialPost (before insert) {
    
    // Llamada a la trigger factory.
    CC_TriggerFactory.createTriggerDispatcher(SocialPost.sObjectType);
}