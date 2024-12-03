trigger CC_ListaValoresTrigger on CC_Lista_Valores__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(CC_Lista_Valores__c.sObjectType);
}