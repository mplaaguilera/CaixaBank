/*****************************************************************
 Name: SIR_LCMP_ViewOnlineAcuPagoPlanPago
 Copyright © 2024  CaixaBank

 Proposito: Clase controladora externa del LWC Sir_lwc_ViewOnlineAcuPagoPlanPago                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            			        Atmira         26/03/2024     	  Created    

*****************************************************************/
public with sharing class SIR_LCMP_ViewOnlineAcuPagoPlanPago {
    /*****************************************************************
        @description  Realizamos query para recuperar el idPropuesta y otros datos                                            
        @param  isTarea
        @return String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         26/03/2024      	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static String obtenerDatos(String idTarea){
        List<SIREC__SIREC_obj_tarea__c> tarea = new List<SIREC__SIREC_obj_tarea__c>();
        String idPropuesta = '';
        if(Schema.SObjectType.SIREC__SIREC_obj_tarea__c.isAccessible()){
            tarea = [SELECT SIR_IdPropuestaOPC__c, SIR_Cliente__r.Name, SIR_Cliente__r.CC_Numero_Documento__c, SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_fechaSituacion__c
                        FROM SIREC__SIREC_obj_tarea__c WHERE Id = :idTarea LIMIT 1];                        
            if(!tarea.isEmpty()){
                idPropuesta = tarea[0].SIR_IdPropuestaOPC__c;
            }
        }     
        return idPropuesta;
    }
    
    /*****************************************************************
        @description  Realizamos la llamada al WS                                           
        @param  String
        @return List<Object>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         26/03/2024      	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static List<Object> callWsInfoApPp(String idPropuesta){  
        List<Object> resultado = new List<Object>();        
        resultado = SIR_cls_WS_consultaPropuesta.consultaPropuesta(idPropuesta);
        return resultado;
    }
}