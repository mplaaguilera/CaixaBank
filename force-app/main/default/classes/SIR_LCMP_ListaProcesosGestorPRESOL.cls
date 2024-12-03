/*****************************************************************
 Name:  SIR_LCMP_ListaProcesosGestorPRESOL
 Copyright © 2021  CaixaBank

Proposito:   Clase controladora externa del LWC sir_lwc_ListaProcesosGestorPRESOL                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         04/04/2022     	 Created    

*****************************************************************/
public with sharing class SIR_LCMP_ListaProcesosGestorPRESOL {

    
    /*****************************************************************
        Proposito:  Realizamos query para buscar todos los procesos del cliente                                                      
        Parameters: No
        Returns: List<SIREC__SIREC_obj_proceso__c>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         04/04/2022     	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> getProcesos(){
        Set<String> setSituaciones = new Set<String>{SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION};
        Id recordTypeIdPRESOL = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL).getRecordTypeId();
        List<SIREC__SIREC_obj_proceso__c> procesos = new List<SIREC__SIREC_obj_proceso__c>();

        if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible()){
            // 02/01/2023 Modificacion -- P2253-997  --  Se retrocede el cambio realizado. Se muestran solo los procesos Pendientes
            procesos = [SELECT id, SIREC__SIREC_fld_cliente__r.Name, SIREC__SIREC_fld_cliente__r.Id, Name, toLabel(SIREC__SIREC_fld_estrategia__c), toLabel(SIR_fld_Situacion_SF__c), 
                        SIREC__SIREC_fld_fechaSituacion__c, SIREC__SIREC_fld_fechaInicio__c, Owner.Name, SIR_agrupacionSituacion__c, SIR_AccionActual__c
                        FROM SIREC__SIREC_obj_proceso__c 
                        WHERE SIR_fld_Situacion_SF__c IN :setSituaciones
                        AND SIR_AccionActual__c =: true
                        AND OwnerId = :UserInfo.getUserId()
                        AND RecordTypeId =: recordTypeIdPRESOL
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
        1.0                             Atmira         04/04/2022     	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static String getURL(){
        //String url = 'https://' + Url.getSalesforceBaseUrl().getHost() + '/lightning/app/c__SIR_misClientesSolutions/page/home?_vmcNewtab=true';
        String url = 'https://' + Url.getSalesforceBaseUrl().getHost() + '/lightning/app/c__SIR_misClientesSolutions/n/SIR_InicioPRESOL?_vmcNewtab=true';
        return url;
    }
    
}