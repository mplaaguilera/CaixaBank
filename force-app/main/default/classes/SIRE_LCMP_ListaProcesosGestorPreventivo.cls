/*****************************************************************
 Name: SIRE_LCMP_ListaProcesosGestorPreventivo
 Copyright © 2021 CaixaBank
============================================================
Proposito: Clase controladora externa del LWC Sire_lwc_ListaProcesosGestorPreventivo                                                                                                                
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            00000000         Atmira         23/06/2023     	  Created    
*****************************************************************/
public with sharing class SIRE_LCMP_ListaProcesosGestorPreventivo {

    /*****************************************************************
        Proposito:  Realizamos query para buscar todos los procesos del cliente                                                      
        Parameters: No
        Returns: List<SIREC__SIREC_obj_proceso__c>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            00000000         Atmira         23/06/2023     	  Created    
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> getProcesos(){
        Set<String> setSituaciones = new Set<String>{SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION};
        Id recordTypeIdAmistoso = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_PREVENTIVO).getRecordTypeId();
        List<SIREC__SIREC_obj_proceso__c> procesos = new List<SIREC__SIREC_obj_proceso__c>();

        if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible()){
            procesos = [SELECT id, SIREC__SIREC_fld_cliente__r.Name, SIREC__SIREC_fld_cliente__r.Id, name, toLabel(SIREC__SIREC_fld_estrategia__c), toLabel(SIREC__SIREC_fld_situacion__c), 
                        SIREC__SIREC_fld_fechaSituacion__c, SIREC__SIREC_fld_fechaInicio__c, Owner.Name
                        FROM SIREC__SIREC_obj_proceso__c 
                        WHERE SIREC__SIREC_fld_situacion__c IN :setSituaciones 
                        AND OwnerId = :UserInfo.getUserId()
                        AND RecordTypeId =: recordTypeIdAmistoso
                        AND SIR_ObjetivoProceso__c != :SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO
                        ORDER BY SIREC__SIREC_fld_fechaSituacion__c ];
        }
        return procesos;
    }

    /*****************************************************************
        Proposito:  Creamos la URL que hara la navegacion hacia la home de la app 'Mis Clientes Solutions Empresas'                                                      
        Parameters: No
        Returns: URL                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            00000000         Atmira         23/06/2023     	  Created    
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static String getURL(){
        String url = 'https://' + Url.getSalesforceBaseUrl().getHost() + '/lightning/app/c__SIRE_MisClientesSolucionesEMP/n/SIRE_Inicio_Preventivo?_vmcNewtab=true';
        return url;
    }
}