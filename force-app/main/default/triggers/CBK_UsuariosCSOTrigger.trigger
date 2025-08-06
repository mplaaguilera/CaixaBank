trigger CBK_UsuariosCSOTrigger on SEG_UsuariosCSO__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(SEG_UsuariosCSO__c.sObjectType);
}