trigger SIR_trg_personaAsociada on SIREC__SIREC_obj_personaAsociada__c (after insert, after update) {
    if(SIR_mdt_TriggerControl__mdt.getInstance('SIR_trg_personaAsociada').SIR_fld_isActive__c){
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            SIR_cls_personaAsociadaHandler.relacionarProcesoCliente(Trigger.newMap);
        }
    }
    
}