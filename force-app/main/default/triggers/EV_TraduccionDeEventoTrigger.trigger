trigger EV_TraduccionDeEventoTrigger on EV_TraduccionDeEvento__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	CC_TriggerFactory.createTriggerDispatcher(EV_TraduccionDeEvento__c.sObjectType);
}