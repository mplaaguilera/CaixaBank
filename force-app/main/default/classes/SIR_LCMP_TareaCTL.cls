/*****************************************************************
 Name:  sir_LCMP_TareaCTL
 Copyright © 2022  CaixaBank

Proposito:   Clase controladora externa del LWC sir_lwc_TareaCTL                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         21/09/2022     	  Created    

*****************************************************************/
public with sharing class SIR_LCMP_TareaCTL {
    /*****************************************************************
        Proposito: Realizamos query para obtener todos los datos de la tarea pendiente a partir del proceso.                                                      
        Parameters: procesoId
        Returns: SIREC__SIREC_obj_proceso__c                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         21/09/2022     	  Created     
        
	*****************************************************************/  
    @AuraEnabled(Cacheable=false)
    public static SIREC__SIREC_obj_proceso__c getTarea(String procesoId){
        SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(); 

        if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible()){
            proceso = [SELECT Id, SIREC__SIREC_fld_tarea__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tipo_tarea__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_seleccion__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tituloInfo__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_SEL_opciones_cod__c,
                    SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_SEL_opciones_desc__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_SEL_respuestas_cod__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_estado__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_fecha__c,
                    SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_importe__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_texto__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_codigo_tarea__c
                    FROM  SIREC__SIREC_obj_proceso__c 
                    WHERE Id =: procesoId LIMIT 1];

            return proceso;
        }
        return null;
    }

    @AuraEnabled(Cacheable=false)
    public static List<String> llamadaWS(String tareaId){
        List<String> resultadoWS = new List<String>();

        // Llamar al WS de avanza Motor               
        resultadoWS = SIR_cls_gestorMotor.avanzaMotor(tareaId);

        return resultadoWS;
        
    }
}