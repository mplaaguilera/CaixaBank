trigger AV_CampaignMemberTrigger on CampaignMember (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(CampaignMember.sObjectType,'AV_CampaignMember_TRDisp');
}