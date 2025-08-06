trigger CC_Servicio_GenesysTrigger on CC_Servicio_Genesys__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(CC_Servicio_Genesys__c.sObjectType);
}