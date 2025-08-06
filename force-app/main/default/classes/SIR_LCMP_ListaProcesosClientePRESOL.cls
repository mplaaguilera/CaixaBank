/*****************************************************************
 Name:  SIR_LCMP_ListaProcesosClientePRESOL
 Copyright © 2022  CaixaBank

Proposito:   Clase controladora externa del LWC Sir_lwc_ListaProcesosClientePRESOL                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         01/04/2022     	 Created    

*****************************************************************/
public with sharing class SIR_LCMP_ListaProcesosClientePRESOL {

    
    /*****************************************************************
        Proposito:  Realizamos query para buscar todos los procesos del cliente                                                      
        Parameters: String idCliente
        Returns: List<SIREC__SIREC_obj_proceso__c>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         01/04/2022     	 Created   
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> getProcesos(String idCliente){
        //Set<String> setSituaciones = new Set<String>{SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION};
        Id recordTypeIdPRESOL = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL).getRecordTypeId();
        List<SIREC__SIREC_obj_proceso__c> procesos = new List<SIREC__SIREC_obj_proceso__c>();
        
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible()){
            // 02/01/2023 Modificacion -- P2253-997  --  Se retrocede el cambio realizado en las cajitas. Se muestran solo los procesos Pendientes
            procesos = [SELECT id, name, SIREC__SIREC_fld_descEstrategiaCatalogo__c, toLabel(SIREC__SIREC_fld_situacion__c), SIREC__SIREC_fld_fechaSituacion__c,
                        SIREC__SIREC_fld_fechaInicio__c, Owner.Name, RecordTypeId
                        FROM SIREC__SIREC_obj_proceso__c 
                        WHERE SIREC__SIREC_fld_cliente__c =: idCliente 
                        AND SIR_AccionActual__c =: true                         
                        AND /*SIREC__SIREC_fld_situacion__c IN :setSituaciones*/ (SIR_agrupacionSituacion__c =: SIR_Constantes.PROCESO_PENDIENTE)
                        AND RecordTypeId =: recordTypeIdPRESOL];
          
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
        1.0                             Atmira         01/04/2022     	 Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static String getURL(String idCliente){
        String url = 'https://' + Url.getSalesforceBaseUrl().getHost() + '/lightning/app/c__SIR_misClientesSolutions/r/Account/'+ idCliente + '/view?_vmcNewtab=true';
        return url;
    }
    
}