trigger CC_Agrupador_ReclamacionTrigger on CC_Agrupador_Reclamacion__c (after insert) {
    CC_TriggerFactory.createTriggerDispatcher(CC_Agrupador_Reclamacion__c.sObjectType);
}