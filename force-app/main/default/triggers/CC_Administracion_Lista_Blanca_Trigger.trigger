trigger CC_Administracion_Lista_Blanca_Trigger on CC_Administracion_Lista_Blanca__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(CC_Administracion_Lista_Blanca__c.sObjectType);
}