/*****************************************************************
 Name:  SIR_LCMP_ListaContratosOPC
 Copyright © 2024  CaixaBank

 @description Clase controladora externa del LWC Sir_lwc_ListaContratosOPC                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         04/07/2024     	  Created    

*****************************************************************/
public with sharing class SIR_LCMP_ListaContratosOPC {

    /*****************************************************************
        @description Realizamos query para obtener todos los datos de la tarea pendiente a partir del proceso.                                                      
        Parameters: procesoId
        @returns SIREC__SIREC_obj_proceso__c                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         04/07/2024     	  Created         
        
	*****************************************************************/     
    @AuraEnabled(Cacheable=true)
    public static SIREC__SIREC_obj_proceso__c getTarea(String procesoId){
        SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(); 
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible()){
            proceso = [SELECT Id, SIREC__SIREC_fld_tarea__r.Name, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tipo_tarea__c, 
                        SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tituloInfo__c, SIREC__SIREC_fld_tarea__r.SIR_FormularioOPC__c, SIREC__SIREC_fld_tarea__r.SIR_FormularioOPCResp__c
                    FROM  SIREC__SIREC_obj_proceso__c
                    WHERE Id =: procesoId LIMIT 1];
            return proceso;
        }
        return null;
    } 
    
    /*****************************************************************
        @description Se actualizar la tarea con los datos introducidos por el usuario y se llama al WS para enviar a SIREC                                                     
        Parameters: tareaId, respuesta
        @returns String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         04/07/2024     	  Created      
        
	*****************************************************************/
    @AuraEnabled 
    public static List<String> updateTarea(String tareaId, String respuesta, String respuestaParaFront){   
        List<SIREC__SIREC_obj_tarea__c> lstTarea = new List<SIREC__SIREC_obj_tarea__c>(); 
        List<String> resp = new List<String>();
        String[] resultado = new String[]{''}; 
        if(Schema.SObjectType.SIREC__SIREC_obj_tarea__c.isAccessible() && Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible()){
            lstTarea = [SELECT Id, Name, SIREC__SIREC_fld_tipo_tarea__c, SIREC__SIREC_fld_seleccion__c, SIREC__SIREC_fld_tituloInfo__c, SIREC__SIREC_fld_SEL_opciones_cod__c,
                        SIREC__SIREC_fld_SEL_opciones_desc__c, SIREC__SIREC_fld_SEL_respuestas_cod__c, SIR_RespuestaTarea__c, SIREC__SIREC_fld_DAT_fecha__c,
                        SIREC__SIREC_fld_DAT_importe__c, SIREC__SIREC_fld_DAT_textoLargo__c, SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c,
                        SIREC__SIREC_fld_codigo_tarea__c, SIREC__SIREC_fld_comentarios__c, SIREC__SIREC_fld_accessToken__c, SIREC__SIREC_fld_SEL_respuestas_text__c,
                        SIR_FormularioOPCResp__c, SIR_IdPropuestaOPC__c, SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_procesoSuperior__r.SIREC__SIREC_fld_masterRecordId__c
                        FROM  SIREC__SIREC_obj_tarea__c 
                        WHERE Id =: tareaId];
            // Aqui habra que montar o la respuesta bien ya que nos piden mas campos o dejarlo asi y se hace mas adelante
            lstTarea.get(0).SIR_FormularioOPCResp__c = respuesta; 
            lstTarea.get(0).SIR_RespuestaTarea__c = respuestaParaFront;                       
        
            if(!Test.isRunningTest()){          
                // pasar la tarea a enviar, actualiza la tarea y el proceso y crea siguiente tarea 
                resp =  SIR_cls_gestorMotor.avanzaMotor(lstTarea[0]);
                resultado = resp;
            } else {
                SIR_cls_gestorTarea.updateTarea(lstTarea.get(0));
            }
        }  
        return resultado;
    } 
}