trigger CIBE_AccountTeamMember_Trigger on AccountTeamMember (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(AccountTeamMember.sObjectType);
}