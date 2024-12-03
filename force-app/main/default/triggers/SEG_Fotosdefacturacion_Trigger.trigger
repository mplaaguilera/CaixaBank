trigger SEG_Fotosdefacturacion_Trigger on SEG_Fotosdefacturacion__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  { 
CC_TriggerFactory.createTriggerDispatcher(SEG_Fotosdefacturacion__c.sObjectType);
}