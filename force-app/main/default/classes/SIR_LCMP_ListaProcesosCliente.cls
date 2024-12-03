/*****************************************************************
 Name:  SIR_LCMP_ListaProcesosCliente
 Copyright © 2021  CaixaBank

 Proposito:   Clase Test de la clase controladora externa del LWC Sir_lwc_ListaProcesosCliente                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249685         Atmira         28/07/2021     	 Created    

*****************************************************************/
public with sharing class SIR_LCMP_ListaProcesosCliente {

    
    /*****************************************************************
        Proposito:  Realizamos query para buscar todos los procesos del cliente                                                      
        Parameters: String idCliente
        Returns: List<SIREC__SIREC_obj_proceso__c>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249685         Atmira         28/07/2021     	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> getProcesos(String idCliente){
        Set<String> setSituaciones = new Set<String>{SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION};
        Id recordTypeIdAmistoso = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO).getRecordTypeId();
        List<SIREC__SIREC_obj_proceso__c> procesos = new List<SIREC__SIREC_obj_proceso__c>();
        
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible()){
            procesos = [SELECT id, name, SIREC__SIREC_fld_descEstrategiaCatalogo__c, toLabel(SIR_fld_Situacion_SF__c), SIREC__SIREC_fld_fechaSituacion__c,
                        SIREC__SIREC_fld_fechaInicio__c, Owner.Name
                        FROM SIREC__SIREC_obj_proceso__c 
                        WHERE SIREC__SIREC_fld_cliente__c =: idCliente 
                        AND SIR_fld_Situacion_SF__c IN :setSituaciones
                        AND SIR_ObjetivoProceso__c != :SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO
                        AND RecordTypeId =: recordTypeIdAmistoso];
          
        }
        return procesos;
    }
    
    
    
    /*****************************************************************
        Proposito:  Creamos la URL que hara la navegacion hacia la home de la app 'Mis Clientes Solutions'                                                      
        Parameters: String idCliente
        Returns: URL                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249685         Atmira         28/07/2021     	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static String getURL(String idCliente){
        String url = 'https://' + Url.getSalesforceBaseUrl().getHost() + '/lightning/app/c__SIR_misClientesSolutions/r/Account/'+ idCliente + '/view?_vmcNewtab=true';
        return url;
    }
    
}