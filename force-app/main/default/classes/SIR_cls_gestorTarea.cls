/*****************************************************************
 Name: SIR_cls_gestorTarea
 Copyright © 2021 CaixaBank

Proposito: Clase en la que se gestionarán toda las acciones relacionados con tareas.

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         28/09/2022	      Created    

*****************************************************************/

public with sharing class SIR_cls_gestorTarea {

    /*****************************************************************
        @description Inserta una Tarea al Proceso.                                            
        @param  Ninguno
        @return List<String>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US               Atmira         28/07/2023      	  Created    
        
	*****************************************************************/
    Public static List<String> insertTarea(Map<String, Object> respuestaSirec){
        List<String> response = new List<String>();

        try{
            SIREC__SIREC_obj_proceso__c proceso = deserializarProceso(respuestaSirec);
            SIREC__SIREC_obj_tarea__c tarea = deserializarTarea(respuestaSirec);

            List<SIREC__SIREC_obj_proceso__c> lstProceso = [SELECT Id, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_codigo_tarea__c,  SIREC__SIREC_fld_tarea__r.Name, 
                                                                    SIREC__SIREC_fld_tarea__r.SIR_EmpleadoPREVEMP__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_SEL_respuestas_text__c, 
                                                                    SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_fecha__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tipo_tarea__c,SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_seleccion__c,
                                                                    SIREC__SIREC_fld_situacion__c,
                                                                    SIR_PropuestaProceso__c, SIR_PropuestaRiesgo__c, SIR_PropuestaNegocio__c, SIR_Colectivo__c, SIR_FechaPropuestaProceso__c 
                                                            FROM SIREC__SIREC_obj_proceso__c 
                                                            WHERE SIREC__SIREC_fld_masterRecordId__c =: proceso.SIREC__SIREC_fld_masterRecordId__c];

            if (tarea.SIREC__SIREC_fld_masterRecordId__c != null){
               tarea.SIREC__SIREC_fld_proceso__c = lstProceso[0].Id;                       
               insert tarea;
               proceso.SIREC__SIREC_fld_tarea__c = tarea.Id;  
            }else{   
               proceso.SIREC__SIREC_fld_tarea__c = null;
            } 
            proceso.Id = lstProceso[0].Id; 
            proceso = evaluarInformarTareasProcesos(lstProceso[0], proceso);
            update proceso;
        }catch(Exception ex){
            response.add('KO');
            response.add('Error ' + ex.getMessage());
            return response;
        }
        response.add('OK');
        return response;
    }

    /*****************************************************************
        @description Evaluar las Tareas e informar los Procesos.                                          
        @param  Ninguno
        @return SIREC__SIREC_obj_proceso__c                                                      
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US               Atmira         17/10/2023      	  Updated    
        
	*****************************************************************/
    Public static SIREC__SIREC_obj_proceso__c evaluarInformarTareasProcesos(SIREC__SIREC_obj_proceso__c procesoOld, SIREC__SIREC_obj_proceso__c procesoNew){
        if(procesoOld.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_codigo_tarea__c == Sir_Constantes.CODIGO_PROPUESTA_NEGOCIO 
        || procesoOld.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_codigo_tarea__c == Sir_Constantes.CODIGO_PROPUESTA_RIESGO
        || procesoOld.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_codigo_tarea__c == Sir_Constantes.CODIGO_PROPUESTA_CONJUNTA 
        || procesoOld.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_codigo_tarea__c == Sir_Constantes.CODIGO_PROPUESTA_CONJUNTA_RIE 
        || procesoOld.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_codigo_tarea__c == Sir_Constantes.CODIGO_PROPUESTA_CONJUNTA_CON) {
            procesoNew.SIR_PropuestaProceso__c = procesoOld.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_SEL_respuestas_text__c;
            procesoNew.SIR_FechaPropuestaProceso__c = date.today();
            switch on procesoOld.SIREC__SIREC_fld_tarea__r.SIR_EmpleadoPREVEMP__c {
                when 'RIESGOS' {
                    procesoNew.SIR_PropuestaRiesgo__c = procesoOld.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_SEL_respuestas_text__c;
                }
                when 'NEGOCIO' {
                    procesoNew.SIR_PropuestaNegocio__c = procesoOld.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_SEL_respuestas_text__c;
                }
            }
        }

        switch on procesoNew.SIR_fld_Situacion_SF__c {
            when 'SF_PVNRAP' {
                procesoNew.SIR_Colectivo__c = 'No requiere acción preventiva';
            }
            when 'SF_PVCAPR' {
                procesoNew.SIR_Colectivo__c = 'Con Acción preventiva';
            }
            when 'SF_PVCAP4' {
                procesoNew.SIR_Colectivo__c = 'Con acción restrictiva pendiente';
            }
            when 'SF_PVACAP' {
                procesoNew.SIR_Colectivo__c = 'Acción restrictiva aplicada';
            }
            when 'SF_INIGEST'{
                procesoNew.SIR_Colectivo__c = null;
            }
        }
        
        //Al reabrir el proceso, reiniciar fecha propuesta.
        if(procesoOld.SIREC__SIREC_fld_situacion__c != procesoNew.SIREC__SIREC_fld_situacion__c && procesoNew.SIREC__SIREC_fld_situacion__c == Sir_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION){
            procesoNew.SIR_FechaPropuestaProceso__c = null;
            procesoNew.SIR_PropuestaProceso__c = '';
            procesoNew.SIR_PropuestaRiesgo__c = '';
            procesoNew.SIR_PropuestaNegocio__c = '';
        }

        if(procesoOld.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_codigo_tarea__c == Sir_Constantes.CODIGO_PROPUESTA_ORG_RESOLUTOR){
            procesoNew.SIR_OrganoResolutor__c = procesoOld.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_SEL_respuestas_text__c;
        }

        return procesoNew;
    }
    
    /*****************************************************************
        @description Actualiza e inserta las Tareas para el Proceso.                                       
        @param  Ninguno
        @return List<String>                                                    
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US               Atmira         28/07/2023         Created    
        
	*****************************************************************/
    Public static List<String> upsertTarea(Map<String, Object> respuestaSirec, SIREC__SIREC_obj_proceso__c procesoOld){
        List<String> response = new List<String>();
        try{
            SIREC__SIREC_obj_proceso__c proceso = deserializarProceso(respuestaSirec);               
            SIREC__SIREC_obj_tarea__c tarea = deserializarTarea(respuestaSirec);

            proceso = evaluarInformarTareasProcesos(procesoOld, proceso);
          
            if (tarea.SIREC__SIREC_fld_masterRecordId__c!=null){
               tarea.SIREC__SIREC_fld_proceso__c = procesoOld.Id;   
               tarea.SIREC__SIREC_fld_estado__c = SIR_Constantes.TAREA_ESTADO_EN_CURSO;               
               upsert tarea SIREC__SIREC_fld_masterRecordId__c;     

               proceso.SIREC__SIREC_fld_tarea__c = tarea.Id;                               
            }else{   
               proceso.SIREC__SIREC_fld_tarea__c = null;               
            }
            proceso.Id = procesoOld.Id;                       
            update proceso;
        }catch(Exception ex){            
            response.add('KO');
            response.add('Error ' + ex.getMessage());
            return response;
        }
        response.add('OK');
        return response;
    }
  
    /*****************************************************************
        @description Deserializar la Tarea con la respuesta de SIREC.                                      
        @param  Ninguno
        @return SIREC__SIREC_obj_tarea__c                                                    
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US               Atmira                       	  Created    
        
	*****************************************************************/
    public static SIREC__SIREC_obj_tarea__c deserializarTarea(Map<String, Object> desearilazedTarea ){
        SIREC__SIREC_obj_tarea__c tarea = new SIREC__SIREC_obj_tarea__c();
        tarea.SIREC__SIREC_fld_masterRecordId__c = desearilazedTarea.containsKey('idActividad') ? String.valueof((Integer)desearilazedTarea.get('idActividad')) : '';
        tarea.SIREC__SIREC_fld_codigo_tarea__c = desearilazedTarea.containsKey('codigoAct') ? (String)desearilazedTarea.get('codigoAct') : '';
        tarea.SIREC__SIREC_fld_tipo_tarea__c = desearilazedTarea.containsKey('tipoDialogoDim') ? (String)desearilazedTarea.get('tipoDialogoDim') : '';        
        tarea.SIREC__SIREC_fld_tituloInfo__c  = desearilazedTarea.containsKey('descripcion') ? (String)desearilazedTarea.get('descripcion') : '';
        tarea.Name  = desearilazedTarea.containsKey('descripcion') ? (String)desearilazedTarea.get('descripcion') : '';

        tarea.SIREC__SIREC_fld_seleccion__c = '';
        if (tarea.SIREC__SIREC_fld_tipo_tarea__c == Sir_Constantes.CODIGO_TAREA_SEL){
            tarea.SIREC__SIREC_fld_seleccion__c = Sir_Constantes.CODIGO_SELECCION_UNICA;
        } else if(tarea.SIREC__SIREC_fld_tipo_tarea__c == Sir_Constantes.CODIGO_TAREA_DAT){
                Object lstVariables = desearilazedTarea.containsKey('variables') ? desearilazedTarea.get('variables') : '';                  
                // es un arrar pero esperamos que llegue solo un item
                for(Object variables : (List<Object>)lstVariables){       
                    Map<String, Object> var = (Map<String, Object>)variables;             
                    tarea.SIREC__SIREC_fld_seleccion__c = (String)var.get('tipoVariable') ;
                    tarea.SIREC__SIREC_fld_tituloInfo__c = (String)var.get('descripcion') ;
                    // descomentar al crear el campo para guardar el codigoVar
                    // tarea.SIREC__SIREC_fld_codigoVar__c = (String)variables.get('codigoVar');                      
                }                                
        } 
        tarea.SIR_EmpleadoPREVEMP__c = desearilazedTarea.containsKey('empleadoPrevemp') ? (String)desearilazedTarea.get('empleadoPrevemp') : '';   
        tarea.SIREC__SIREC_fld_fechaLimite__c = desearilazedTarea.containsKey('fechaVencimiento') ? SIR_cls_WS_Wrapper.formatDateSF((String)desearilazedTarea.get('fechaVencimiento')) : null;
        tarea.SIREC__SIREC_fld_accessToken__c = desearilazedTarea.containsKey('accessToken') ? (String)desearilazedTarea.get('accessToken') : '';
        tarea.SIREC__SIREC_fld_insertWS__c = true; 
        tarea.SIREC__SIREC_fld_estado__c = SIR_Constantes.TAREA_ESTADO_EN_CURSO;         
        
        if(tarea.SIREC__SIREC_fld_tipo_tarea__c == Sir_Constantes.CODIGO_TAREA_SEL){
            if(!desearilazedTarea.containsKey('seleccion')){                
                throw new GestorTareaException('No se ha recibido el campo de la selección desde Sirec');
            }   
            Map<String,String> mapSeleccion = concatenaSeleccion(desearilazedTarea.get('seleccion'));            
            tarea.SIREC__SIREC_fld_SEL_opciones_cod__c = mapSeleccion.get('idSeleccion');
            tarea.SIREC__SIREC_fld_SEL_opciones_codModela__c = mapSeleccion.get('respuestaUsu');
            tarea.SIREC__SIREC_fld_SEL_opciones_desc__c = mapSeleccion.get('descripcionRes');
        }

        return tarea;
    }

    /*****************************************************************
        @description Deserializar el Proceso con la respuesta de SIREC.                                      
        @param  Ninguno
        @return SIREC__SIREC_obj_proceso__c                                                    
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US               Atmira                      	  Created    
        
	*****************************************************************/
    public static SIREC__SIREC_obj_proceso__c  deserializarProceso(Map<String, Object> desearilazedProceso){
        SIREC__SIREC_obj_proceso__c  proceso = new SIREC__SIREC_obj_proceso__c ();
        proceso.SIREC__SIREC_fld_masterRecordId__c = String.valueof((Integer)desearilazedProceso.get('idProceso'));        
        proceso.SIREC__SIREC_fld_situacion__c = (String)desearilazedProceso.get('codigoProcesoSituacion');
        proceso.SIR_fld_Situacion_SF__c = (String)desearilazedProceso.get('codigoProcesoSituacion');        
        proceso.SIREC__SIREC_fld_fechaSituacion__c = SIR_cls_WS_Wrapper.formatDateSF((String)desearilazedProceso.get('fechaProcesoSituacion'));
        proceso.SIR_FechaRevisionAccion__c = desearilazedProceso.containsKey('fechaRevisionAccion') ? SIR_cls_WS_Wrapper.formatDateSF((String)desearilazedProceso.get('fechaRevisionAccion')) : null;
        proceso.SIR_FechaFinEspera__c = desearilazedProceso.containsKey('fechaFinEspera') ? SIR_cls_WS_Wrapper.formatDateSF((String)desearilazedProceso.get('fechaFinEspera')) : null;
        proceso.SIR_MarcaRevisionRiesgo__c = desearilazedProceso.containsKey('marcaRevisionRiesgo') ? (String)desearilazedProceso.get('marcaRevisionRiesgo') : '';
        proceso.SIR_PropuestaNivelGrupo__c = desearilazedProceso.containsKey('propuestaNivelGrupo') ? (String)desearilazedProceso.get('propuestaNivelGrupo') : '';
        proceso.SIR_EmpleadoPREVEMP__c = desearilazedProceso.containsKey('empleadoPrevemp') ? (String)desearilazedProceso.get('empleadoPrevemp') : '';   
        return proceso;
    }

    /*****************************************************************
        @description Concatena la selección.                                   
        @param  Ninguno
        @return Map<String,String>                                              
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US               Atmira                      	  Created    
        
	*****************************************************************/
    public static Map<String,String> concatenaSeleccion(Object lstSeleccion){
        Map<String,String> mapSeleccion = new  Map<String,String>();
        mapSeleccion.put('idSeleccion', '');
        mapSeleccion.put('respuestaUsu', '');
        mapSeleccion.put('descripcionRes', '');

        for(Object seleccion : (List<Object>)lstSeleccion){
            Map<String, Object> sel = (Map<String, Object>)seleccion;
            mapSeleccion.put('idSeleccion', mapSeleccion.get('idSeleccion') + (String)sel.get('idSeleccion') + '|');
            mapSeleccion.put('respuestaUsu', mapSeleccion.get('respuestaUsu') + (String)sel.get('respuestaUsu') + '|');
            mapSeleccion.put('descripcionRes',  mapSeleccion.get('descripcionRes') + (String)sel.get('descripcionRes') + '|');
        }
        mapSeleccion.put('idSeleccion', mapSeleccion.get('idSeleccion').substring(0, mapSeleccion.get('idSeleccion').length()-1));
        mapSeleccion.put('respuestaUsu', mapSeleccion.get('respuestaUsu').substring(0, mapSeleccion.get('respuestaUsu').length()-1));
        mapSeleccion.put('descripcionRes', mapSeleccion.get('descripcionRes').substring(0, mapSeleccion.get('descripcionRes').length()-1));
        return mapSeleccion; 
    }
    
    /*****************************************************************
        @description Actualiza la Tarea Pendiente de Sincronizar.                             
        @param  Ninguno                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US               Atmira                      	  Created    
        
	*****************************************************************/
    public static void  updateTareaPteSincro(String idTarea){
        try{          
            SIREC__SIREC_obj_tarea__c tarea = new SIREC__SIREC_obj_tarea__c(Id=idTarea, SIREC__SIREC_fld_estado__c = SIR_Constantes.TAREA_ESTADO_PENDIENTE);
            update tarea;
        }catch(Exception e) {        
            throw new GestorTareaException('updateTareaPteSincro ' + e.getMessage());           
        }
    }  

    /*****************************************************************
        @description Actualiza la Tarea.                             
        @param  Ninguno                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US               Atmira                       	  Created    
        
	*****************************************************************/
    public static void  updateTarea(SIREC__SIREC_obj_tarea__c tarea){
        try{          
            update tarea;
        }catch(Exception e) {        
            throw new GestorTareaException('updateTarea ' + e.getMessage());           
        }
    }

    public virtual class GestorTareaException extends Exception {}

}