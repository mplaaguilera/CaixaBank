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

    static public String funcionEje;
    static public String procesoName='';
    static public String procesoRT='';
    static public String procesoDescripcion='';

    /*****************************************************************
        @description Inserta o actualiza una Tarea al Proceso. Cuando venimos del avanzarMotor siempre será un insert. 
        El update se puede realizar en el sincroniza proceso                                           
        @param  respuestaSirec = Json con la respuesta recibida desde SIREC
        @param  tareaAnterior = datos de la tarea que está vinculada al proceso 
        @return List<String> devuelve OK si se ha podido actualizar el proceso y la tarea enviada desde SIREc. 
                                      NOK si algo ha fallado y en la segunda linea de la lista se envía el detalle del error

        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US               Atmira         28/07/2023      	  Created    
        
	*****************************************************************/
    Public static List<String> upsertTarea(Map<String, Object> respuestaSirec, SIREC__SIREC_obj_tarea__c tareaAnterior){
    List<String> response = new List<String>();
    SIREC__SIREC_obj_proceso__c procesoHijo;
    SIREC__SIREC_obj_tarea__c tareaHija;
    List<SIREC__SIREC_obj_proceso__c> updProcesos = new List<SIREC__SIREC_obj_proceso__c>();

    try{
        SIREC__SIREC_obj_proceso__c proceso = deserializarProceso(respuestaSirec);
        SIREC__SIREC_obj_tarea__c tarea = deserializarTarea(respuestaSirec);
    
        // si llega informada la estructura infoProcesoHijo informamos procesoHijo y TareaPadre con el contenido de esta estructura
        // llegara en los casos donde el gestor haya contestado los campos del AP/PP y el proceso padre y el hijo avanzan tarea            
        if(respuestaSirec.containsKey('infoProcesoHijo') && respuestaSirec.get('infoProcesoHijo')!=null) {        
            Map<String, Object> infoProcesoHijo = (Map<String, Object>)respuestaSirec.get('infoProcesoHijo');                
            if(infoProcesoHijo.containsKey('idProceso')){
               procesoHijo = deserializarProceso(infoProcesoHijo);
               tareaHija = deserializarTarea(infoProcesoHijo);
            }   
        }           
        
        // si la tarea que nos ha enviado SIREC es una OPC el tratamiento es especial
        // se creará un nuevo proceso para el Acuerdo/Plan de Pago y se relaciona con el proceso padre
        if(tarea.SIREC__SIREC_fld_tipo_tarea__c == Sir_Constantes.CODIGO_TAREA_OPC && funcionEje == SIR_Constantes.FUNCION_EJE_PLANPAGO){ 
            // Proceso hijo --> proceso
            // Tarea hija --> tarea
            // Proceso padre --> lstProcesoPadre
            // Tarea normal (procesoPadre) --> tareaAnterior
            
            // Query para encontrar el proceso padre de la tarea anterior
            List<SIREC__SIREC_obj_proceso__c> lstProcesoPadre = [SELECT Id, SIREC__SIREC_fld_tareaOPCPendiente__c, OwnerId, SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_estrategia__c, SIREC__SIREC_fld_estrategiaCatalogo__c, SIREC__SIREC_fld_informacionCliente__c FROM SIREC__SIREC_obj_proceso__c WHERE SIREC__SIREC_fld_masterRecordId__c = :tareaAnterior.SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c];
            // Informar en el proceso hijo el proceso padre 
            proceso.SIREC__SIREC_fld_procesoSuperior__c = lstProcesoPadre[0].Id;
            // informar los valores con las variables que hemos guardado en el deserializarProceso
            proceso.recordtypeId = procesoRT;
            proceso.Name = procesoName;
            proceso.SIREC__SIREC_fld_descripcion__c = procesoDescripcion;

            // Mapear/calcular los campos especificos del proceso hijo que no estan en el metodo deserializarProceso
            proceso = copiarCamposProcesoPadre(proceso,lstProcesoPadre[0], tarea.SIREC__SIREC_fld_codigo_tarea__c);
            // proceso hijo 
            upsert proceso proceso.SIREC__SIREC_fld_masterRecordId__c;
                        
            // Vinculamos la tarea hija con el ID del proceso hijo que se ha insertado
            tarea.SIREC__SIREC_fld_proceso__c = proceso.ID;				
            // tarea hija
            upsert tarea tarea.SIREC__SIREC_fld_masterRecordId__c;
                        
            // Ponemos el id de la tarea en el campo tarea del proceso hijo y actualizamos el proceso
            proceso.SIREC__SIREC_fld_tarea__c = tarea.Id;            
            // Ponemos el id de la tareaHija en el campo nuevo de lookup del proceso padre
            lstProcesoPadre[0].SIREC__SIREC_fld_tareaOPCPendiente__c = tarea.Id;                		
        
            updProcesos.add(proceso);
            updProcesos.add(lstProcesoPadre[0]);
            // actualiza proceso padre e hijo
            update updProcesos;
            
        } else  {
            // sino es OPC lo que llega en respuesta es una tarea y su proceso de gestion
            List<SIREC__SIREC_obj_proceso__c> lstProceso = [SELECT Id, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_codigo_tarea__c,  SIREC__SIREC_fld_tarea__r.Name, 
                                                                    SIREC__SIREC_fld_tarea__r.SIR_EmpleadoPREVEMP__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_SEL_respuestas_text__c, 
                                                                    SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_fecha__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tipo_tarea__c,SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_seleccion__c,
                                                                    SIREC__SIREC_fld_situacion__c, SIREC__SIREC_fld_tareaOPCPendiente__c,
                                                                    SIR_PropuestaProceso__c, SIR_PropuestaRiesgo__c, SIR_PropuestaNegocio__c, SIR_Colectivo__c, SIR_FechaPropuestaProceso__c 
                                                            FROM SIREC__SIREC_obj_proceso__c 
                                                            WHERE SIREC__SIREC_fld_masterRecordId__c =: proceso.SIREC__SIREC_fld_masterRecordId__c];

            if (tarea.SIREC__SIREC_fld_masterRecordId__c != null){
               tarea.SIREC__SIREC_fld_proceso__c = lstProceso[0].Id;                       
               upsert tarea tarea.SIREC__SIREC_fld_masterRecordId__c;
               proceso.SIREC__SIREC_fld_tarea__c = tarea.Id;                   
            }else{   
               proceso.SIREC__SIREC_fld_tarea__c = null;                   
            } 
            //si viene informado la estructura infoProcesoHijo significa que ha avanzado la OPC y hay que eliminar la relacion del padre
            if(procesoHijo != null && tareaHija != null){
               proceso.SIREC__SIREC_fld_tareaOPCPendiente__c = null;
            }   
            proceso.Id = lstProceso[0].Id; 
            proceso = evaluarInformarTareasProcesos(lstProceso[0], proceso);                
            updProcesos.add(proceso);
        
            if(procesoHijo != null && tareaHija != null){
               // Query para conseguir el proceso Hijo
               List<SIREC__SIREC_obj_proceso__c> lstProcesoHijo = [SELECT Id FROM SIREC__SIREC_obj_proceso__c 
                                                                   WHERE SIREC__SIREC_fld_masterRecordId__c =: procesoHijo.SIREC__SIREC_fld_masterRecordId__c];				
               
               if (tareaHija.SIREC__SIREC_fld_masterRecordId__c != null){
                   // Vinculamos la tarea hija con el proceso hijo
                   tareaHija.SIREC__SIREC_fld_proceso__c = lstProcesoHijo[0].Id;
                   upsert tareaHija tareaHija.SIREC__SIREC_fld_masterRecordId__c;
                   procesoHijo.SIREC__SIREC_fld_tarea__c = tareaHija.Id;                   
                }else{   
                   procesoHijo.SIREC__SIREC_fld_tarea__c = null;                   
                }
                
                procesoHijo.Id = lstProcesoHijo[0].Id;                     
                updProcesos.add(procesoHijo);                   
            }
            // actualiza  proceso padre y si ha llegado proceso hijo
            update updProcesos;
       }
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
        if(SIR_Constantes.LISTA_CODIGOS_PROPUESTA.contains(procesoOld.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_codigo_tarea__c)){ 
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

        procesoNew.SIR_Colectivo__c = SIR_Constantes.MAP_SITUACION_COLECTIVO.get(procesoNew.SIR_fld_Situacion_SF__c);
           
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
        funcionEje = '';
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

        if(tarea.SIREC__SIREC_fld_tipo_tarea__c == Sir_Constantes.CODIGO_TAREA_OPC && desearilazedTarea.containsKey('opc')){   
            Object lstOpc = desearilazedTarea.get('opc');                  
            // es un arrar pero esperamos que llegue solo un item
            for(Object opc : (List<Object>)lstOpc){       
                Map<String, Object> mapOpc = (Map<String, Object>)opc;             
                tarea.SIR_IdPropuestaOPC__c = mapOpc.containsKey('idPrimaria') ? (String)mapOpc.get('idPrimaria') : '' ;    
                funcionEje = mapOpc.containsKey('funcionEje') ? (String)mapOpc.get('funcionEje') : '' ;    
            }                 	
		 
            if(desearilazedTarea.containsKey('camposOpc')){
                Map<String, Object> camposOpc = (Map<String, Object>)desearilazedTarea.get('camposOpc');   
                // en la OPC de acuerdo de pago/plan de pago llegara un campo llamado columnas que contendrá la estructura con los campos de formulario de AP/PP
                if(camposOpc.containsKey('columnas') && camposOpc.get('columnas')!=null) {   
                    tarea.SIR_FormularioOPC__c = JSON.serialize(camposOpc.get('columnas'));
                }      
                // en la OPC de contratos llegara un campo llamado contratos que contendrá la lista de los contratos del proceso
                if(camposOpc.containsKey('contratos') && camposOpc.get('contratos')!=null) {   
                    tarea.SIR_FormularioOPC__c = JSON.serialize(camposOpc.get('contratos'));
                }        
            }
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

        // guardamos los datos del posible proceso hijo si es una OPC de tipo AP/PP 
        // no lo informamos en este punto en las variables del proceso para no preguntar por los codigos de las OPC, porque podria ser una OPC de otro tipo 
        procesoName='';
        procesoRT='';
        procesoDescripcion='';
        // Si lo que ha llegado es una tarea OPC, debemos informar mas campos en el proceso ya que se ha de crear 
        String tipoTarea = desearilazedProceso.containsKey('tipoDialogoDim') ? (String)desearilazedProceso.get('tipoDialogoDim') : '';   
        if(tipoTarea  == Sir_Constantes.CODIGO_TAREA_OPC){            
           // guardar los datos en variables de la clase para utilizarlos al crear el proceso hijo
            procesoRT = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName().get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_AP_PP).getRecordTypeId();
            procesoDescripcion = desearilazedProceso.containsKey('procesoDescripcion') ? (String)desearilazedProceso.get('procesoDescripcion') : '';   
            procesoName = desearilazedProceso.containsKey('procesoDescripcion') ? (String)desearilazedProceso.get('procesoDescripcion') : '';   
        }
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
        @description informa campos del proceso hijo recibido desde SIREC con algunos campos del padre 
        @param  Ninguno                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US               Atmira                      	  Created    
        
	*****************************************************************/
    public static SIREC__SIREC_obj_proceso__c  copiarCamposProcesoPadre(SIREC__SIREC_obj_proceso__c procesoHijo, SIREC__SIREC_obj_proceso__c procesoPadre, String codigoTarea){
        try{          
          //  procesoHijo.OwnerId = procesoPadre.OwnerId;
            procesoHijo.SIREC__SIREC_fld_cliente__c = procesoPadre.SIREC__SIREC_fld_cliente__c;
            procesoHijo.SIREC__SIREC_fld_informacionCliente__c = procesoPadre.SIREC__SIREC_fld_informacionCliente__c;
            procesoHijo.SIREC__SIREC_fld_estrategia__c = procesoPadre.SIREC__SIREC_fld_estrategia__c;
            procesoHijo.SIREC__SIREC_fld_estrategiaCatalogo__c = procesoPadre.SIREC__SIREC_fld_estrategiaCatalogo__c;
            procesoHijo.SIREC__SIREC_fld_codProceso__c = SIR_Constantes.MAP_CODIGO_PDM_ACT_AP_PP.get(codigoTarea);
            procesoHijo.SIREC__SIREC_fld_fechaInicio__c = Date.today();

            return procesoHijo;
        }catch(Exception e) {        
            throw new GestorTareaException('copiarCamposProcesoPadre ' + e.getMessage());           
        }
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