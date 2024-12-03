trigger SIR_trg_tarea on SIREC__SIREC_obj_tarea__c (before insert, after insert, before update, after update, before delete, after delete) {
    if(SIR_mdt_TriggerControl__mdt.getInstance('SIR_trg_tarea').SIR_fld_isActive__c){
        if(Trigger.isInsert){
            if(Trigger.isBefore){ 
                //Asignar el cliente con el está relacionado la tarea
                SIR_cls_tareaHandler.asignarCliente(Trigger.new);
            } 
            if(Trigger.isAfter){
                //Cuando se inserta una nueva tarea CTL a traves de WS, se actualiza el estado de las tareas antiguas a "Finalizado"
                SIR_cls_tareaHandler.updateEstadoFinalizada(Trigger.new);
                //Cuando se crea una nueva tarea se actualiza el proceso
                SIR_cls_tareaHandler.updateTareaProceso(Trigger.new);
            } 
        }
        /*if(Trigger.isUpdate){
            if(Trigger.isBefore){

            }
            if(Trigger.isAfter){
                
            }    
        }*/

    }
}