/*****************************************************************
 Name:  sir_LCMP_FormSELDAT
 Copyright © 2022  CaixaBank

 Proposito:   Clase controladora externa del LWC sir_lwc_FormSELDAT                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         18/05/2022     	  Created    

*****************************************************************/
public with sharing class sir_LCMP_FormSELDAT {

   
    /*****************************************************************
        Proposito: Realizamos query para obtener todos los datos de la tarea pendiente a partir del proceso.                                                      
        Parameters: procesoId
        Returns: SIREC__SIREC_obj_proceso__c                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         18/05/2022     	  Created     
        
	*****************************************************************/     
    @AuraEnabled(Cacheable=true)
    public static SIREC__SIREC_obj_proceso__c getTarea(String procesoId){
        /*
        -DAT/SEL -> tipo tarea SIREC__SIREC_fld_tipo_tarea__c
        -S,M,F,N,A -> seleccion SIREC__SIREC_fld_seleccion__c
        -Pregunta -> SIREC__SIREC_fld_tituloInfo__c
        -Codigo opciones -> SIREC__SIREC_fld_SEL_opciones_cod__c
        -Descripcion opciones -> SIREC__SIREC_fld_SEL_opciones_desc__c
        -selecciones(opciones escogidos SEL) -> SIREC__SIREC_fld_SEL_respuestas_cod__c
        -Estado(Sincronización)? -> SIREC__SIREC_fld_estado__c
         */
        SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(); 

        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible()){
            proceso = [SELECT Id, SIREC__SIREC_fld_tarea__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tipo_tarea__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_seleccion__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tituloInfo__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_SEL_opciones_cod__c,
                    SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_SEL_opciones_desc__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_SEL_respuestas_cod__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_estado__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_fecha__c,
                    SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_importe__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_textoLargo__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_codigo_tarea__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_comentarios__c
                    FROM  SIREC__SIREC_obj_proceso__c 
                    WHERE Id =: procesoId LIMIT 1];

            return proceso;
        }
        return null;
    }    
  
    /*****************************************************************
        Proposito: Se actualizar la tarea con los datos introducidos por el usuario y se llama al WS para enviar a SIREC                                                     
        Parameters: tareaId, seleccion, send
        Returns: String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         18/05/2022     	  Created     
        
	*****************************************************************/
    @AuraEnabled 
    public static List<String> updateTarea(String tareaId, String seleccion, String comentario, Boolean send){
        
        List<String> resp = new List<String>();
        String[] resultado = new String[]{''}; 

            List<SIREC__SIREC_obj_tarea__c> lstTarea = [SELECT Id, Name, SIREC__SIREC_fld_tipo_tarea__c, SIREC__SIREC_fld_seleccion__c, SIREC__SIREC_fld_tituloInfo__c, SIREC__SIREC_fld_SEL_opciones_cod__c,
                                                            SIREC__SIREC_fld_SEL_opciones_desc__c, SIREC__SIREC_fld_SEL_respuestas_cod__c, SIR_RespuestaTarea__c, SIREC__SIREC_fld_DAT_fecha__c,
                                                            SIREC__SIREC_fld_DAT_importe__c, SIREC__SIREC_fld_DAT_textoLargo__c, SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c,
                                                            SIREC__SIREC_fld_codigo_tarea__c, SIREC__SIREC_fld_comentarios__c, SIREC__SIREC_fld_accessToken__c, SIREC__SIREC_fld_SEL_respuestas_text__c
                                                            FROM  SIREC__SIREC_obj_tarea__c 
                                                            WHERE Id =: tareaId];

            if(lstTarea.get(0).SIREC__SIREC_fld_tipo_tarea__c.equals(SIR_Constantes.CODIGO_TAREA_SEL)){
                lstTarea.get(0).SIREC__SIREC_fld_SEL_respuestas_cod__c = seleccion;
                lstTarea.get(0).SIREC__SIREC_fld_SEL_respuestas_text__c = respTextTarea(lstTarea.get(0), seleccion);
                lstTarea.get(0).SIR_RespuestaTarea__c = respTextTarea(lstTarea.get(0), seleccion);

            } else {
                if(lstTarea.get(0).SIREC__SIREC_fld_seleccion__c.equals(SIR_Constantes.CODIGO_SELECCION_FECHA)){
                    lstTarea.get(0).SIREC__SIREC_fld_DAT_fecha__c = Date.valueof(seleccion);
                    Date fechaDAT = Date.valueof(seleccion);
                    lstTarea.get(0).SIR_RespuestaTarea__c = String.valueof(fechaDAT.format());

                } else if (lstTarea.get(0).SIREC__SIREC_fld_seleccion__c.equals(SIR_Constantes.CODIGO_SELECCION_NUMERO)) {
                    lstTarea.get(0).SIREC__SIREC_fld_DAT_importe__c = Decimal.valueof(seleccion);
                    Decimal importeDAT = Decimal.valueof(seleccion);
                    lstTarea.get(0).SIR_RespuestaTarea__c = String.valueof(importeDAT.format());

                } else if (lstTarea.get(0).SIREC__SIREC_fld_seleccion__c.equals(SIR_Constantes.CODIGO_SELECCION_ALFANUMERICO)) {
                    lstTarea.get(0).SIREC__SIREC_fld_DAT_textoLargo__c = seleccion;
                    lstTarea.get(0).SIR_RespuestaTarea__c = seleccion;
                }

                if(comentario != '' && comentario != null){
                    lstTarea.get(0).SIREC__SIREC_fld_comentarios__c = comentario;
                    lstTarea.get(0).SIR_RespuestaTarea__c = comentario;
                }
            }                      
               
            if(send && !Test.isRunningTest()){              
                // pasar la tarea a enviar, actualiza la tarea y el proceso y crea siguiente tarea 
                resp =  SIR_cls_gestorMotor.avanzaMotor(lstTarea[0]);
                resultado = resp;
            }else{
                SIR_cls_gestorTarea.updateTarea(lstTarea.get(0));
            }
        return resultado;

        } 
                
        public static String respTextTarea(SIREC__SIREC_obj_tarea__c tarea, String seleccion){
            List<String> codigo = tarea.SIREC__SIREC_fld_SEL_opciones_cod__c.split('\\|');
            List<String> descripciones = tarea.SIREC__SIREC_fld_SEL_opciones_desc__c.split('\\|');
            String valor = null;
            if (!String.isBlank(seleccion)) {
                for (Integer i = 0; i < codigo.size() ; i++) {
                    if (codigo.get(i).equals(seleccion)) {
                        valor = descripciones.get(i);
                    }
                }
            }
            
            return valor;
    }
    
}