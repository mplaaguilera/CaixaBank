trigger CSBD_GestorOportunidadTrigger on CSBD_Gestor_Oportunidad__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(CSBD_Gestor_Oportunidad__c.sObjectType);
}