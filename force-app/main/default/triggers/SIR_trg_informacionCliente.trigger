trigger SIR_trg_informacionCliente on SIREC__SIREC_obj_informacionCliente__c (after update) {
    if(SIR_mdt_TriggerControl__mdt.getInstance('SIR_trg_informacionCliente').SIR_fld_isActive__c){
        if(Trigger.isUpdate){
            SIR_cls_informacionClienteHandler.sendComentario(trigger.new,trigger.oldMap);
        }
    }
}