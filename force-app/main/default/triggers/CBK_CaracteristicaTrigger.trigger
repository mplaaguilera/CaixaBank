trigger CBK_CaracteristicaTrigger on CC_Caracteristica__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(CC_Caracteristica__c.sObjectType);
}