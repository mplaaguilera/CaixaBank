trigger SIR_trg_proceso on SIREC__SIREC_obj_proceso__c (before insert, after insert, before update, after update) {
    if(SIR_mdt_TriggerControl__mdt.getInstance('SIR_trg_proceso').SIR_fld_isActive__c){
       if(Trigger.isInsert){
            if(Trigger.isBefore){
                SIR_cls_procesoHandler.setFechaInicioEstrategia(Trigger.new);
                SIR_cls_procesoHandler.igualarCampoSituacion(Trigger.new);
                SIR_cls_procesoHandler.quitarPipeAlerta(Trigger.new);
           }  
        } 
        if(Trigger.isUpdate){
            if(Trigger.isBefore){
                SIR_cls_procesoHandler.setFechaInicioEstrategia(Trigger.oldMap, Trigger.new);
                SIR_cls_procesoHandler.setProcessOwner(Trigger.oldMap, Trigger.newMap); 
                SIR_cls_procesoHandler.setSituacionSF(Trigger.oldMap, Trigger.new);
                SIR_cls_procesoHandler.setMatricula(Trigger.new,Trigger.oldMap);
                SIR_cls_procesoHandler.quitarPipeAlerta(Trigger.oldMap, Trigger.new);
            }
            if(Trigger.isAfter){
                SIR_cls_procesoHandler.finalizarProcesoRefi(Trigger.oldMap, Trigger.newMap);
                SIR_cls_procesoHandler.crearHistoricoProceso(Trigger.oldMap, Trigger.new);
                SIR_cls_procesoHandler.setEstrategiaEnProcRefi(Trigger.oldMap, Trigger.new);
                SIR_cls_procesoHandler.setTareaCliente(Trigger.oldMap, Trigger.new);                
            }    
        }

   }
}