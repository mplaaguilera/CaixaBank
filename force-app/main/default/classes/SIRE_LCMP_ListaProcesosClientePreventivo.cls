/*****************************************************************
 Name: SIRE_LCMP_ListaProcesosClientePreventivo
 Copyright © 2021 CaixaBank

 Proposito: Clase Test de la clase controladora externa del LWC Sire_lwc_ListaProcesosClientePreventivo                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            00000000         Atmira         23/06/2023     	  Created    

*****************************************************************/
public with sharing class SIRE_LCMP_ListaProcesosClientePreventivo {

    /*****************************************************************
        Proposito:  Realizamos query para buscar todos los procesos del cliente                                                      
        Parameters: String idCliente
        Returns: List<SIREC__SIREC_obj_proceso__c>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            00000000         Atmira         23/06/2023     	  Created    
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> getProcesos(String idCliente){
        Set<String> setSituaciones = new Set<String>{SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION};
        Id recordTypeIdPreventivo = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_PREVENTIVO).getRecordTypeId();
        List<SIREC__SIREC_obj_proceso__c> procesos = new List<SIREC__SIREC_obj_proceso__c>();
        
        if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible()){
            procesos = [SELECT id, name, toLabel(SIREC__SIREC_fld_estrategia__c), toLabel(SIREC__SIREC_fld_situacion__c), SIREC__SIREC_fld_fechaSituacion__c,
                        SIREC__SIREC_fld_fechaInicio__c, Owner.Name
                        FROM SIREC__SIREC_obj_proceso__c 
                        WHERE SIREC__SIREC_fld_cliente__c =: idCliente 
                        AND SIREC__SIREC_fld_situacion__c IN :setSituaciones
                        AND SIR_ObjetivoProceso__c != :SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO
                        AND RecordTypeId =: recordTypeIdPreventivo];
        }
        return procesos;
    }

    /*****************************************************************
        Proposito:  Creamos la URL que hara la navegacion hacia la home de la app 'Mis Clientes Solutions Empresas'                                                      
        Parameters: String idCliente
        Returns: URL                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            00000000         Atmira         23/06/2023     	  Created    
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static String getURL(String idCliente){
        String url = 'https://' + Url.getSalesforceBaseUrl().getHost() + '/lightning/app/c__SIRE_MisClientesSolucionesEMP/r/Account/'+ idCliente + '/view?_vmcNewtab=true';
        return url;
    } 
}