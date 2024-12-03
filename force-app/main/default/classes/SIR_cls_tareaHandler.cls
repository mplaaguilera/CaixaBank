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
        if(Schema.SObjectType.SIREC__SIREC_obj_tarea__c.isUpdateable()){ 
            Set<Id> setIdProceso = new Set<Id>();            
            Set<Id> setIdTareas = new Set<Id>();
            List<SIREC__SIREC_obj_tarea__c> lstTareasToUpdate = new List<SIREC__SIREC_obj_tarea__c>();

            for(SIREC__SIREC_obj_tarea__c tarea : listNewTareas){ 
                setIdProceso.add(tarea.SIREC__SIREC_fld_proceso__c);                   
                setIdTareas.add(tarea.Id);     
            } 

            if(!setIdProceso.isEmpty()){
                lstTareasToUpdate = [SELECT Id, SIREC__SIREC_fld_estado__c
                             FROM SIREC__SIREC_obj_tarea__c
                             WHERE Id NOT IN: setIdTareas
                             AND SIREC__SIREC_fld_proceso__c IN: setIdProceso 
                             AND SIREC__SIREC_fld_estado__c !=: SIR_Constantes.TAREA_ESTADO_FINALIZADA 
                        ]; 
            
                for(SIREC__SIREC_obj_tarea__c tarea : lstTareasToUpdate){
                    tarea.SIREC__SIREC_fld_estado__c = SIR_Constantes.TAREA_ESTADO_FINALIZADA;               
                }           

                if(!lstTareasToUpdate.isEmpty()){
                    update lstTareasToUpdate;
                }
            }
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
    public static void updateTareaProceso(Map<Id,SIREC__SIREC_obj_tarea__c> mapNewTareas) {
        
        if(Schema.SObjectType.SIREC__SIREC_obj_tarea__c.isUpdateable() && Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isUpdateable()){ 
            Set<Id> setIdProceso = new Set<Id>();
            Set<Id> setIdProcesoPadre = new Set<Id>();
            SIREC__SIREC_obj_tarea__c tareaProceso;
            SIREC__SIREC_obj_tarea__c tareaPadre;
            SIREC__SIREC_obj_proceso__c procesoAux;
            Map<Id,SIREC__SIREC_obj_proceso__c> mapProcesosToUpdate = new Map<Id,SIREC__SIREC_obj_proceso__c>();
            Map<Id,SIREC__SIREC_obj_tarea__c> mapProcesoTarea = new Map<Id,SIREC__SIREC_obj_tarea__c>();
    
            // solo se actualizaran procesos cuando la tarea se inserta en el batch, ya que desde el online ya se actualiza la relacion
            for(SIREC__SIREC_obj_tarea__c tarea : mapNewTareas.values()){ 
                if(tarea.SIREC__SIREC_fld_insertWS__c == false){
                    setIdProceso.add(tarea.SIREC__SIREC_fld_proceso__c); 
                    mapProcesoTarea.put(tarea.SIREC__SIREC_fld_proceso__c, tarea);     
                }      
            } 

            if(!setIdProceso.isEmpty()){                                   
                for(SIREC__SIREC_obj_proceso__c proceso : [SELECT Id, SIREC__SIREC_fld_tarea__c, SIREC__SIREC_fld_tareaOPCPendiente__c, SIREC__SIREC_fld_procesoSuperior__r.SIREC__SIREC_fld_tareaOPCPendiente__c  FROM SIREC__SIREC_obj_proceso__c WHERE Id IN: setIdProceso]){
                    tareaProceso = mapProcesoTarea.get(proceso.id); 
                    // actualiza la tarea actual del proceso con esta nueva tarea que ha llegado
                    proceso.SIREC__SIREC_fld_tarea__c = tareaProceso.Id;
                    //mapa con los procesos a actualizar, el id del proceso es la clave
                    mapProcesosToUpdate.put(proceso.Id,proceso);      

                    // si ha llegado una tarea de tipo CTL-Seguimiento debemos eliminar la relacion del proceso padre con la tarea de la OPC                          
                    if(tareaProceso.SIREC__SIREC_fld_codigo_tarea__c == SIR_Constantes.CODIGO_TAREA_CTL_SEGUIMIENTO
                    && proceso.SIREC__SIREC_fld_procesoSuperior__r.SIREC__SIREC_fld_tareaOPCPendiente__c != null)   { 
                       setIdProcesoPadre.add(proceso.SIREC__SIREC_fld_procesoSuperior__c);  
                    }                                        
                }
            }    

            // leer los procesos padre a los que se le ha de inicializar el campo SIREC__SIREC_fld_tareaOPCPendiente__c
            if(!setIdProcesoPadre.isEmpty()){
                for(SIREC__SIREC_obj_proceso__c procesoPadre : [SELECT Id, SIREC__SIREC_fld_tarea__c, SIREC__SIREC_fld_tareaOPCPendiente__c, SIREC__SIREC_fld_procesoSuperior__r.SIREC__SIREC_fld_tareaOPCPendiente__c  FROM SIREC__SIREC_obj_proceso__c WHERE Id IN: setIdProcesoPadre]){
                    // si el proceso ya estaba en el mapa de procesos a actualizar lo cogemos del mapa y actualizamos el campo   SIREC__SIREC_fld_tareaOPCPendiente__c a null                  
                    procesoAux = mapProcesosToUpdate.containsKey(procesoPadre.Id) ? mapProcesosToUpdate.get(procesoPadre.Id) : procesoPadre; 
                    procesoAux.SIREC__SIREC_fld_tareaOPCPendiente__c = null;    
                    mapProcesosToUpdate.put(procesoPadre.Id,procesoAux);
                }    
            }                    
       
            if(mapProcesosToUpdate.keyset().size() > 0){
                Database.SaveResult[] srList = Database.update(mapProcesosToUpdate.values(), false);
                for (Integer i = 0; i < mapProcesosToUpdate.values().size(); i++) {
                    Database.SaveResult sr = srList[i];
                    SIREC__SIREC_obj_proceso__c origRecord = mapProcesosToUpdate.values()[i];
                    if (!sr.isSuccess()) {
                        for(Database.Error objErr : sr.getErrors()) {
                            mapNewTareas.get(origRecord.SIREC__SIREC_fld_tarea__c).addError('SIR_cls_tareaHandler ' + objErr.getStatusCode() + ': ' + objErr.getMessage());
                            CBK_log.error('Error : SIR_cls_tareaHandler - updateTareaProceso -  ' + objErr.getStatusCode() + ': ' + objErr.getMessage());
                        }
                    } 
                }        
            }       
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

        if(Schema.SObjectType.SIREC__SIREC_obj_tarea__c.isUpdateable() && Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isUpdateable()){ 
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

  /*****************************************************************
    Name:  pendienteSincro
    Copyright © 2022  CaixaBank
    
    Proposito:  Cuando se inserta una tarea tipo BAT desde el BATCH esto es un ERROR, porque deberíamos haber insertado la tarea al responder la OPC de AP/PP desde el WS
                En este caso ponemos la tarea que llega en pendiente sincro para poder mostrar el boton de Sincronizar en el proceso
    
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             atmira         23/05/2023	      Created    

    *****************************************************************/    
    public static void pendienteSincro(List<SIREC__SIREC_obj_tarea__c> lstTareas) {

        if(Schema.SObjectType.SIREC__SIREC_obj_tarea__c.isUpdateable() && Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isUpdateable()){ 
            for(SIREC__SIREC_obj_tarea__c tarea : lstTareas){
                if (tarea.SIREC__SIREC_fld_insertWS__c == false && tarea.SIREC__SIREC_fld_tipo_tarea__c == SIR_Constantes.CODIGO_TAREA_BAT && SIR_Constantes.LISTA_CODIGOS_BAT_AC_PP.contains(tarea.SIREC__SIREC_fld_codigo_tarea__c)){
                   tarea.SIREC__SIREC_fld_estado__c = SIR_Constantes.TAREA_ESTADO_PENDIENTE;                  
                }
            }
            
        }
    }
}