/*****************************************************************
 Name:  SIRE_LCMP_HomeGestorFlujo
 Copyright © 2023  CaixaBank

 Proposito:   Clase controladora externa del LWC Sire_lwc_HomeGestorFlujo                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            			        Atmira         21/02/2023     	  Created    

*****************************************************************/
public with sharing class SIRE_LCMP_HomeGestorFlujo {
    /*****************************************************************
        @description  Realizamos query para saber el ID                                             
        @param  Ninguno
        @return List<SIREC__SIREC_obj_proceso__c>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         21/02/2023      	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static Id getQueryRecordTypeProceso(){
        String idRecordType = '';
        if(RecordType.SObjectType.getDescribe().isAccessible()){
            List<RecordType> procesos = new List<RecordType>();
            procesos = [SELECT id FROM RecordType WHERE SobjectType ='SIREC__SIREC_obj_proceso__c' AND RecordType.Name = : SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_FLUJO LIMIT 1];
            idRecordType = procesos[0].id;
        }
        return idRecordType;
    }

    /*****************************************************************
        @description  Realizamos query para buscar los procesos Flujo del usuario logueado                                             
        @param  Ninguno
        @return List<SIREC__SIREC_obj_proceso__c>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         21/02/2023      	  Created    
        
	*****************************************************************/

    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> getQueryProcesos(){
        List<SIREC__SIREC_obj_proceso__c> procesos = new List<SIREC__SIREC_obj_proceso__c>();
        if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible()){
            procesos = [SELECT id, Name, SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_cliente__r.Name, SIREC__SIREC_fld_estrategia__c, 
                        toLabel(SIREC__SIREC_fld_estrategia__c) estrategia, SIR_FechaInicioEstrategia__c, toLabel(SIR_fld_Situacion_SF__c) situacion, 
                        SIR_fld_Situacion_SF__c, SIREC__SIREC_fld_fechaInicio__c, SIR_DeudaTotal__c, SIR_MaximoDiasImpago__c, SIR_GrupoEconomico__c,
                        SIREC__SIREC_fld_fechaSituacion__c, SIR_AlertaSIREC__c, SIR_DeudaVencidaImpagada__c, Owner.Name, SIR_PropuestaNegocio__c,
                        SIR_AnalistaRiesgo__c, SIR_AnalistaRiesgo__r.Name, SIR_PropuestaRiesgo__c, SIR_PropuestaProceso__c, SIR_TipoGestionPREVEMP__c,
                        SIREC__SIREC_fld_tarea__c, SIREC__SIREC_fld_tarea__r.Name, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_estado__c, 
                        SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tipo_tarea__c                        
                        FROM SIREC__SIREC_obj_proceso__c
                        WHERE OwnerId =: UserInfo.getUserId() AND RecordType.Name = : SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_FLUJO
                        AND SIR_fld_Situacion_SF__c != : SIR_Constantes.PROCESO_SITUACION_FINALIZADO
                        AND SIR_ObjetivoProceso__c != : SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO
                        ORDER BY SIREC__SIREC_fld_estrategia__c ASC];
        }
        return procesos;
    }

    /*****************************************************************
        @description  Realizamos query para buscar los Reports de IMPA                                            
        @param  Ninguno
        @return List<Report>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira        21/02/2023      	  Created   
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<Report> getQueryReports(){
        List<Report> informes = new List<Report>();
        if(Report.SObjectType.getDescribe().isAccessible()){
            informes = [SELECT id, name, DeveloperName, FolderName  
                        FROM Report 
                        WHERE FolderName = 'Impagado 1-90' AND
                        DeveloperName in ('SIRE_ProcesosActivos', 'SIRE_ProcesosEstrategias', 'SIRE_TareasPendientesDeSincronizar','SIRE_ProcesosPendientesdeGestion')
                        ORDER BY DeveloperName];
        }
        return informes;
    }
}