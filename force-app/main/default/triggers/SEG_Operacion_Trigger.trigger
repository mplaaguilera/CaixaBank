trigger SEG_Operacion_Trigger on SEG_Operacion__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	CC_TriggerFactory.createTriggerDispatcher(SEG_Operacion__c.sObjectType);
}