trigger CBK_CaracteristicaDetalleTrigger on CC_Caracteristica_Detalle__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(CC_Caracteristica_Detalle__c.sObjectType);
}