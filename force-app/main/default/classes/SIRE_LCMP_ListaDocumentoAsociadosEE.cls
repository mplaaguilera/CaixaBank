/*****************************************************************
 Name: SIRE_LCMP_ListaDocumentoAsociadosEE
 Copyright © 2023  CaixaBank

 Proposito: Clase controladora externa del LWC Sire_lwc_ListaDocumentosAsociadosEE                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            			        Atmira         09/11/2023     	  Created    

*****************************************************************/
public with sharing class SIRE_LCMP_ListaDocumentoAsociadosEE {
    /*****************************************************************
        @description  Realizamos query para recuperar las Tareas de tipo DAT-EE que estan asociadas al Proceso                                           
        @param  String
        @return List<SIREC__SIREC_obj_tarea__c>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         09/11/2023     	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_tarea__c> getQueryTareasDoc(String recordId){
        List<SIREC__SIREC_obj_tarea__c> tareas = new List<SIREC__SIREC_obj_tarea__c>();
        if(Schema.SObjectType.SIREC__SIREC_obj_tarea__c.isAccessible()){
            if(recordId.startsWith('001')){
                tareas = [SELECT SIR_IdDocumentoEE__c, SIR_NombreDocumentoEE__c, SIR_TipoDocumentoEE__c, LastModifiedDate, LastModifiedBy.name
                        FROM SIREC__SIREC_obj_tarea__c WHERE SIR_Cliente__c = :recordId AND SIREC__SIREC_fld_codigo_tarea__c like '%DAT-EE%'
                        order by CreatedDate desc]; 
            } else {
                tareas = [SELECT SIR_IdDocumentoEE__c, SIR_NombreDocumentoEE__c, SIR_TipoDocumentoEE__c, LastModifiedDate, LastModifiedBy.name
                        FROM SIREC__SIREC_obj_tarea__c WHERE SIREC__SIREC_fld_proceso__c = :recordId AND SIREC__SIREC_fld_codigo_tarea__c like '%DAT-EE%'
                        order by CreatedDate desc]; 
            }     
        }
        return tareas;
    }

    
    /*****************************************************************
        @description  Realizamos la llamada al WS para poder descargar el documento                                          
        @param  String
        @return List<Object>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         09/11/2023     	  Created   
        
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static List<Object> callWsDownloadDocumentoEE(String idDocumento){   
        List<Object> resultado = new List<Object>();
        Integer idIntDocu = Integer.valueOf(idDocumento);
        resultado = SIRE_cls_WS_detalleDocumentoEE.detalleDocumentoEE(idIntDocu);       
        return resultado;
    }    
}