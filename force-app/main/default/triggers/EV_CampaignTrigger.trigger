trigger EV_CampaignTrigger on Campaign (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(Campaign.sObjectType);
}