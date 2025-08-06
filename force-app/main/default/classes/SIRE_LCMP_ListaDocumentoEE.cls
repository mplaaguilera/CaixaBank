/*****************************************************************
 Name: SIRE_LCMP_ListaDocumentoEE
 Copyright © 2023  CaixaBank

 Proposito: Clase controladora externa del LWC Sire_lwc_ListaDocumentoEE                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            			        Atmira         30/10/2023     	  Created    

*****************************************************************/
public with sharing class SIRE_LCMP_ListaDocumentoEE {
    /*****************************************************************
        @description  Realizamos query para recuperar el numperso del Cliente asociado al Proceso                                            
        @param  Ninguno
        @return List<SIREC__SIREC_obj_proceso__c>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         30/10/2023      	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> getQueryProceso(String recordId){
        List<SIREC__SIREC_obj_proceso__c> proceso = new List<SIREC__SIREC_obj_proceso__c>();
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible()){
            proceso = [SELECT SIREC__SIREC_fld_cliente__r.AV_NumPerso__c, SIREC__SIREC_fld_tarea__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tituloInfo__c,
                        SIREC__SIREC_fld_tarea__r.SIR_IdDocumentoEE__c, SIREC__SIREC_fld_tarea__r.Name, TYPEOF Owner WHEN User THEN EmployeeNumber END
                        FROM SIREC__SIREC_obj_proceso__c WHERE Id = :recordId LIMIT 1];                        
        }
        return proceso;
    }

    /*****************************************************************
        @description  Realizamos la llamada al WS                                           
        @param  String
        @return List<Object>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         30/10/2023      	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static List<Object> callWsDocumentoEE(String numperso){   
        List<Object> resultado = new List<Object>();
        resultado = SIRE_cls_WS_listaDocumentoEE.listaDocumentoEE(numperso);
        return resultado;
    }

    /*****************************************************************
        @description  Realizamos la llamada al WS para poder descargar el documento                                          
        @param  String
        @return List<Object>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         30/10/2023      	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static List<Object> callWsDownloadDocumentoEE(String idDocumento){   
        List<Object> resultado = new List<Object>();
        Integer idIntDocu = Integer.valueOf(idDocumento);
        resultado = SIRE_cls_WS_detalleDocumentoEE.detalleDocumentoEE(idIntDocu); //Cambiar la llamada por el ws correcto
        return resultado;
    }
    

    /*****************************************************************
        @description  Realizamos la llamada para enviar el documento de EE a Sirec                                          
        @param  Object, String
        @return List<Object>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         02/11/2023      	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static List<Object> sendDocumentoEE(String infoDocumento, String tareaId){ 
    //public static List<Object> sendDocumentoEE(Object documento, String infoDocumento, String tareaId){         
        List<String> resp = new List<String>();
        String[] resultado = new String[]{''};  
     
        String[] infoDocumentoSplit = infoDocumento.split('@');
        // Guardamos en SF los campos necesarios
        if(Schema.SObjectType.SIREC__SIREC_obj_tarea__c.isUpdateable()){
            List<SIREC__SIREC_obj_tarea__c> tarea = [ SELECT Id, Name, SIREC__SIREC_fld_tipo_tarea__c, SIREC__SIREC_fld_seleccion__c, SIREC__SIREC_fld_tituloInfo__c, SIREC__SIREC_fld_SEL_opciones_cod__c,
                                                        SIREC__SIREC_fld_SEL_opciones_desc__c, SIREC__SIREC_fld_SEL_respuestas_cod__c, SIR_RespuestaTarea__c, SIREC__SIREC_fld_DAT_fecha__c,
                                                        SIREC__SIREC_fld_DAT_importe__c, SIREC__SIREC_fld_DAT_textoLargo__c, SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c,
                                                        SIREC__SIREC_fld_codigo_tarea__c, SIREC__SIREC_fld_comentarios__c, SIREC__SIREC_fld_accessToken__c, SIREC__SIREC_fld_SEL_respuestas_text__c,
                                                        SIR_IdDocumentoEE__c, SIR_NombreDocumentoEE__c, SIR_TipoDocumentoEE__c
                                                        FROM SIREC__SIREC_obj_tarea__c WHERE Id = :tareaId LIMIT 1];           
            tarea[0].SIR_IdDocumentoEE__c = infoDocumentoSplit[0];
            tarea[0].SIR_NombreDocumentoEE__c = infoDocumentoSplit[1];
            tarea[0].SIR_TipoDocumentoEE__c = infoDocumentoSplit[2];  
            tarea[0].SIR_RespuestaTarea__c = infoDocumentoSplit[3];    
            if(!Test.isRunningTest()){          
                // pasar la tarea a enviar, actualiza la tarea y el proceso y crea siguiente tarea 
                resp = SIR_cls_gestorMotor.avanzaMotor(tarea[0]);
                resultado = resp;
            } else {
                SIR_cls_gestorTarea.updateTarea(tarea.get(0));
            }                                         
        }
        return resultado;
    }

 
}