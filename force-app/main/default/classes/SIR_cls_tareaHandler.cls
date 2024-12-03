/*****************************************************************
 Name:  SIR_cls_tareaHandler
 Copyright © 2022  CaixaBank

Proposito:   Clase handler para alojar los metodos que se invocan desde SIR_cls_tarea                                                                                                                    

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US449066         atmira         03/10/2022	      Created    

*****************************************************************/
public with sharing class SIR_cls_tareaHandler {

    /*****************************************************************
     Name:  updateEstadoFinalizado
    Copyright © 2022  CaixaBank
    
    Proposito:   Metodo que actualiza el estado de las tareas antiguas a "Finalizada"
                 Se ejecutará cuando se recibe una nueva tarea
    
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US449066         atmira         03/10/2022	      Created    

    *****************************************************************/
    public static void updateEstadoFinalizada(List<SIREC__SIREC_obj_tarea__c> listNewTareas) {
        try{
            if(SIREC__SIREC_obj_tarea__c.SObjectType.getDescribe().isUpdateable()){ 
                Set<Id> setIdProceso = new Set<Id>();
                List<SIREC__SIREC_obj_tarea__c> lstTareas = new List<SIREC__SIREC_obj_tarea__c>();
                List<SIREC__SIREC_obj_tarea__c> lstTareasToUpdate = new List<SIREC__SIREC_obj_tarea__c>();
                Set<Id> setIdTareas = new Set<Id>();

                for(SIREC__SIREC_obj_tarea__c tarea : listNewTareas){ 
                    setIdProceso.add(tarea.SIREC__SIREC_fld_proceso__c);                   
                    setIdTareas.add(tarea.Id);     
                } 

                if(!setIdProceso.isEmpty()){
                    lstTareas = [SELECT Id, SIREC__SIREC_fld_insertWS__c, SIREC__SIREC_fld_tipo_tarea__c, SIREC__SIREC_fld_estado__c, SIREC__SIREC_fld_proceso__c
                            FROM SIREC__SIREC_obj_tarea__c
                            WHERE Id NOT IN: setIdTareas
                            AND SIREC__SIREC_fld_proceso__c IN: setIdProceso 
                            AND SIREC__SIREC_fld_estado__c !=: SIR_Constantes.TAREA_ESTADO_FINALIZADA 
                            ]; 
            
                    for(SIREC__SIREC_obj_tarea__c tarea : lstTareas){
                        tarea.SIREC__SIREC_fld_estado__c = SIR_Constantes.TAREA_ESTADO_FINALIZADA;
                
                        lstTareasToUpdate.add(tarea);
                    }
                }

                if(!lstTareasToUpdate.isEmpty()){
                    update lstTareasToUpdate;
                }
            }
        } catch (Exception e) {
            CBK_log.error(e, 'Error : SIR_cls_tareaHandler - updateEstadoFinalizada -  ' + e.getTypeName() + ': ' + e.getMessage());
            throw new AuraHandledException('Clase SIR_cls_tareaHandler - Método updateEstadoFinalizada:  ' + e.getMessage());
        }
    }

    /*****************************************************************
     Name:  updateTareaProceso
    Copyright © 2022  CaixaBank
    
    Proposito:   Metodo que actualiza el proceso con el id de la nueva tarea creada.                                                                                                                    
    
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US449066         atmira         03/10/2022	      Created    

    *****************************************************************/
    public static void updateTareaProceso(List<SIREC__SIREC_obj_tarea__c> listNewTareas) {
        try{
            if(SIREC__SIREC_obj_tarea__c.SObjectType.getDescribe().isUpdateable() && SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isUpdateable()){ 
                Set<Id> setIdProceso = new Set<Id>();
                List<SIREC__SIREC_obj_proceso__c> lstprocesos = new List<SIREC__SIREC_obj_proceso__c>();
                List<SIREC__SIREC_obj_proceso__c> lstProcesosToUpdate = new List<SIREC__SIREC_obj_proceso__c>();

                for(SIREC__SIREC_obj_tarea__c tarea : listNewTareas){ 
                    if(tarea.SIREC__SIREC_fld_insertWS__c == false){
                        setIdProceso.add(tarea.SIREC__SIREC_fld_proceso__c);      
                    }      
                } 

                if(!setIdProceso.isEmpty()){
                    lstprocesos = [SELECT Id, SIREC__SIREC_fld_tarea__c
                            FROM SIREC__SIREC_obj_proceso__c
                            WHERE Id IN: setIdProceso  
                            ]; 
                    
                    for(SIREC__SIREC_obj_proceso__c proceso : lstprocesos){
                        for(SIREC__SIREC_obj_tarea__c tarea : listNewTareas){
                            if(tarea.SIREC__SIREC_fld_proceso__c == proceso.Id){
                                proceso.SIREC__SIREC_fld_tarea__c = tarea.Id;

                                lstProcesosToUpdate.add(proceso);
                            }
                        }   
                    }
                }
                
                if(!lstProcesosToUpdate.isEmpty()){
                    update lstProcesosToUpdate;
                }
            }
        } catch (Exception e) {
            CBK_log.error(e, 'Error : SIR_cls_tareaHandler - updateTareaProceso -  ' + e.getTypeName() + ': ' + e.getMessage());
            throw new AuraHandledException('Clase SIR_cls_tareaHandler - Método updateTareaProceso:  ' + e.getMessage());
        }

    }

    /*****************************************************************
     Name:  asignarCliente
    Copyright © 2022  CaixaBank
    
    Proposito:  Cuando se crea una tarea se ha de informar el campo Cliente con el cliinte con el que está relacionado el proceso con el que está relacionada.                                                                                                                    
    
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             atmira         15/03/2023	      Created    

    *****************************************************************/    
    public static void asignarCliente(List<SIREC__SIREC_obj_tarea__c> lstTareas) {

        if(SIREC__SIREC_obj_tarea__c.SObjectType.getDescribe().isUpdateable() && SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isUpdateable()){ 
            Set<Id> setProcesoIds = new Set<Id>();
            
            for(SIREC__SIREC_obj_tarea__c tarea : lstTareas){
                setProcesoIds.add(tarea.SIREC__SIREC_fld_proceso__c);
            }
            Map<Id,SIREC__SIREC_obj_proceso__c> mapProcesos = new Map<Id,SIREC__SIREC_obj_proceso__c>([SELECT Id, SIREC__SIREC_fld_cliente__c FROM SIREC__SIREC_obj_proceso__c WHERE Id IN :setProcesoIds]);
            for(SIREC__SIREC_obj_tarea__c tarea : lstTareas){
                tarea.SIR_Cliente__c = mapProcesos.get(tarea.SIREC__SIREC_fld_proceso__c).SIREC__SIREC_fld_cliente__c;
            }
        
        }


    }
}