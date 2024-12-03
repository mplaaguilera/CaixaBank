/*****************************************************************
 Name:  SIR_LCMP_ListaProcesosGestor
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase controladora externa del LWC SIR_LCMP_ListaProcesosGestor                                                                                                                 
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249684         Atmira         28/07/2021     	 Created    

*****************************************************************/
public with sharing class SIR_LCMP_ListaProcesosGestor {

    
    /*****************************************************************
        Proposito:  Realizamos query para buscar todos los procesos del cliente                                                      
        Parameters: No
        Returns: List<SIREC__SIREC_obj_proceso__c>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249684         Atmira         28/07/2021     	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> getProcesos(){
        Set<String> setSituaciones = new Set<String>{SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION};
        Id recordTypeIdAmistoso = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO).getRecordTypeId();
        List<SIREC__SIREC_obj_proceso__c> procesos = new List<SIREC__SIREC_obj_proceso__c>();

        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible()){
            procesos = [SELECT id, SIREC__SIREC_fld_cliente__r.Name, SIREC__SIREC_fld_cliente__r.Id, name, SIREC__SIREC_fld_descEstrategiaCatalogo__c, toLabel(SIR_fld_Situacion_SF__c), 
                        SIREC__SIREC_fld_fechaSituacion__c, SIREC__SIREC_fld_fechaInicio__c, Owner.Name
                        FROM SIREC__SIREC_obj_proceso__c 
                        WHERE SIR_fld_Situacion_SF__c IN :setSituaciones 
                        AND OwnerId = :UserInfo.getUserId()
                        AND RecordTypeId =: recordTypeIdAmistoso
                        AND SIR_ObjetivoProceso__c != :SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO
                        ORDER BY SIREC__SIREC_fld_fechaSituacion__c ];
        }
        return procesos;
    }
    
    
    
    /*****************************************************************
        Proposito:  Creamos la URL que hara la navegacion hacia la home de la app 'Mis Clientes Solutions'                                                      
        Parameters: No
        Returns: URL                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249684         Atmira         28/07/2021     	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static String getURL(){
        //String url = 'https://' + Url.getSalesforceBaseUrl().getHost() + '/lightning/app/c__SIR_misClientesSolutions/page/home?_vmcNewtab=true';
        String url = 'https://' + Url.getSalesforceBaseUrl().getHost() + '/lightning/app/c__SIR_misClientesSolutions/n/SIR_InicioIMPA?_vmcNewtab=true';
        return url;
    }
    
}