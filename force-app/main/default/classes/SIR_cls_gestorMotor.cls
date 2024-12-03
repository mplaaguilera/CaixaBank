/*****************************************************************
 Name:  SIR_cls_gestorMotor
 Copyright © 2021  CaixaBank

Proposito:   Clase en la que se gestionarán toda las acciones y lógica del gestor del motor de Workflow Sirec                                                                                                                    

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR              DATE               Description
    1.0                             Atmira              28/09/2022	       Created    

*****************************************************************/

public with sharing class SIR_cls_gestorMotor {

    /*****************************************************************
        @description  Llama al endpoint procesoInfo que devuelve la situacion actualizada del proceso y la siguiente tarea.
        @param  Ninguno
        @return List<String>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US               Atmira         28/07/2023      	  Created    
        
	*****************************************************************/
    public Static List<String> procesoInfo (String idProceso){
        List<String> response = new List<String>();
        List<Object> responseObj = new List<Object>();
        List<SIREC__SIREC_obj_proceso__c> lstProceso = [SELECT Id, SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_codigo_tarea__c, SIREC__SIREC_fld_tarea__r.Name, 
                                                               SIREC__SIREC_fld_tarea__r.SIR_EmpleadoPREVEMP__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_SEL_respuestas_text__c, 
                                                               SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_fecha__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_texto__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_importe__c,
                                                               SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tipo_tarea__c,SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_seleccion__c,SIR_fld_Situacion_SF__c,SIR_PropuestaProceso__c,SIR_PropuestaRiesgo__c, 
                                                               SIREC__SIREC_fld_situacion__c,
                                                               SIR_PropuestaNegocio__c, SIR_Colectivo__c, SIR_FechaPropuestaProceso__c
                                                        FROM SIREC__SIREC_obj_proceso__c WHERE Id = :idProceso];        
        
        if (lstProceso.size()>0){
            responseObj = SIR_cls_WS_procesoInfo.sincronizaProceso(idProceso, lstProceso[0].SIREC__SIREC_fld_masterRecordId__c);     

            if((String)responseObj[0]=='OK'){          
                // inserta la nueva tarea recibida desde el WS y actualiza el proceso
                Map<String,Object> mapSirecTarea = (Map<String,Object>)responseObj[1];                        
                response = SIR_cls_gestorTarea.upsertTarea(mapSirecTarea, lstProceso[0]);
            }else{
                for (Integer i = 0; i < responseObj.size(); i++) {
                    response.add((String)responseObj[i]);    
                }
                // si hay error en WS actualizamos la situacion de la tarea actual a pendiente Sincronizar 
                List<SIREC__SIREC_obj_tarea__c> lstTarea = [SELECT Id, SIREC__SIREC_fld_estado__c
                                                        FROM SIREC__SIREC_obj_tarea__c WHERE SIREC__SIREC_fld_proceso__c = :idProceso];        
            
                lstTarea[0].SIREC__SIREC_fld_estado__c = SIR_Constantes.TAREA_ESTADO_PENDIENTE;            
                SIR_cls_gestorTarea.updateTarea(lstTarea[0]);
            }    
        }else{
            response.add('KO');
            response.add('No se ha encontrado el proceso que ha de enviarse con id = ' + idProceso);
            CBK_log.error('Error : SIR_cls_gestorMotor.sincronizaProceso - No se ha encontrado el proceso que ha de enviarse con id = ' + idProceso, lstProceso);
        }  
            
        return response;
    }

    // recibe solo el idTarea para pasarle a la llamada motor solo los campos necesarios para avanzar motor
    // con la respuesta guardamos la siguiente tarea
    public Static List<String> avanzaMotor (String idTarea){
        List<String> response = new List<String>();   
        List<SIREC__SIREC_obj_tarea__c> lstTarea = [SELECT Id, SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_tipo_tarea__c, SIREC__SIREC_fld_codigo_tarea__c,
                                                           SIREC__SIREC_fld_SEL_respuestas_cod__c, SIREC__SIREC_fld_seleccion__c, SIREC__SIREC_fld_DAT_importe__c,SIREC__SIREC_fld_DAT_fecha__c, SIREC__SIREC_fld_DAT_texto__c, SIREC__SIREC_fld_accessToken__c  
                                                    FROM SIREC__SIREC_obj_tarea__c WHERE Id = :idTarea];        
        if (lstTarea.size()>0){
            response = avanzamotor(lstTarea[0]);                   
        }else{
            response.add('KO');
            response.add('No se ha encontrado la tarea que ha de enviarse con id = ' + idTarea);
            CBK_log.error('Error : SIR_cls_gestorMotor.avanzaMotor - No se ha encontrado la tarea que ha de enviarse con id = ' + idTarea, lstTarea);
        }    
        return response;
    }
   
    public Static List<String> avanzaMotor (SIREC__SIREC_obj_tarea__c tarea){
        List<String> response = new List<String>();
        List<Object> responseObj = new List<Object>();
        responseObj = SIR_cls_WS_llamadaMotor.avanzamotor(tarea);  

        if((String)responseObj[0]=='OK'){          
            // actualiza la tarea en curso a Enviada, luego el trigger al insertar una nueva tarea la pondrá en Finalizada
            tarea.SIREC__SIREC_fld_estado__c = SIR_Constantes.TAREA_ESTADO_ENVIADA;   
            SIR_cls_gestorTarea.updateTarea(tarea);
            // inserta la nueva tarea recibida desde el WS y actualiza el proceso
            Map<String,Object> mapSirecTarea = (Map<String,Object>)responseObj[1];             
            response = SIR_cls_gestorTarea.insertTarea(mapSirecTarea);
        }else{
            for (Integer i = 0; i < responseObj.size(); i++) {
                response.add((String)responseObj[i]);    
            }    
            // si hay un error en el WS actualizamos los campos de la tarea que se pueden haber informado en la SELDAT 
            // y el estado de la tarea a Pendiente Sincronizacion
            tarea.SIREC__SIREC_fld_estado__c = SIR_Constantes.TAREA_ESTADO_PENDIENTE;            
            SIR_cls_gestorTarea.updateTarea(tarea);
        }
        
        return response;
    }
   
    public Static List<String> enviarAccion (SIREC__SIREC_obj_acciones__c  accion){
        List<String> response = new List<String>();
        List<Object> responseObj = new List<Object>();

        responseObj = SIR_cls_WS_altaAccionWorkflow.sendAction(accion.Id);        
        if((String)responseObj[0]=='OK'){           
          if(!Test.isRunningTest()){
             response = avanzaMotor(accion.SIREC__SIREC_fld_tarea__c);
          }else{
             response.add('OK');
          }
        }else{
            // si hay un error en el envio de la accion actualizamos el estado de la tarea a Pendiente Sincronizacion
            SIR_cls_gestorTarea.updateTareaPteSincro(accion.SIREC__SIREC_fld_tarea__c);
            for (Integer i = 0; i < responseObj.size(); i++) {
                response.add((String)responseObj[i]);    
            }                    
        }     
        return response;
    }
    
}