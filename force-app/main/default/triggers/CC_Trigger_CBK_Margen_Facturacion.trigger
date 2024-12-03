/**
 * @description       : 
 * @author            : Adrian Mariscal
 * @group             : 
 * @last modified on  : 06-08-2022
 * @last modified by  : Adrian Mariscal 
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   06-08-2022   Adrian Mariscal   Initial Version
**/
trigger CC_Trigger_CBK_Margen_Facturacion on CBK_Margen_Facturacion__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(CBK_Margen_Facturacion__c.sObjectType);
}