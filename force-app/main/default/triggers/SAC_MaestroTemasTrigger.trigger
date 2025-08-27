trigger SAC_MaestroTemasTrigger on SAC_MaestroTemas__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	CC_TriggerFactory.createTriggerDispatcher(SAC_MaestroTemas__c.sObjectType);
}