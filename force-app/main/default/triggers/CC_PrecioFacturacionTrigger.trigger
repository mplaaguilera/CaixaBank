trigger CC_PrecioFacturacionTrigger on CBK_Precio_Facturacion__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(CBK_Precio_Facturacion__c.sObjectType);
}