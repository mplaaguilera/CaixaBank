trigger CIBE_OpportunityTeamMember_Trigger on OpportunityTeamMember (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(OpportunityTeamMember.sObjectType);
}