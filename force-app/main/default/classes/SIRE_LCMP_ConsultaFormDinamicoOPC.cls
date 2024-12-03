/*****************************************************************
 Name:  SIRE_LCMP_ConsultaFormDinamicoOPC
 Copyright © 2024  CaixaBank

 @description Clase controladora externa del LWC Sire_lwc_FormularioDinamicoOPC                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         23/01/2024     	  Created    

*****************************************************************/
public with sharing class SIRE_LCMP_ConsultaFormDinamicoOPC {

    /*****************************************************************
        @description Realizamos query para obtener todos los datos de la tarea pendiente a partir del proceso.                                                      
        Parameters: procesoId
        @returns SIREC__SIREC_obj_tarea__c                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         23/01/2024     	  Created    
        
	*****************************************************************/     
    @AuraEnabled(Cacheable=true)
    public static SIREC__SIREC_obj_tarea__c getTarea(String tareaId){
        SIREC__SIREC_obj_tarea__c tarea = new SIREC__SIREC_obj_tarea__c(); 
        if(Schema.SObjectType.SIREC__SIREC_obj_tarea__c.isAccessible()){
            tarea = [SELECT Id, SIREC__SIREC_fld_tipo_tarea__c, SIREC__SIREC_fld_estado__c, SIREC__SIREC_fld_tituloInfo__c, Name, 
                        SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_codigo_tarea__c, SIR_FormularioOPC__c, SIR_FormularioOPCResp__c 
                    FROM  SIREC__SIREC_obj_tarea__c WHERE Id =: tareaId LIMIT 1];
            return tarea;
        }
        return null;
    } 
}