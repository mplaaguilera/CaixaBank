trigger EV_CampaignMemberStagingTrigger on EV_CampaingMemeberStaging__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(EV_CampaingMemeberStaging__c.sObjectType);
}