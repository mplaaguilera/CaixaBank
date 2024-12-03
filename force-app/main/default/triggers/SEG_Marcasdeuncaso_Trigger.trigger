trigger SEG_Marcasdeuncaso_Trigger on SEG_Marcasdeuncaso__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	CC_TriggerFactory.createTriggerDispatcher(SEG_Marcasdeuncaso__c.sObjectType);
}