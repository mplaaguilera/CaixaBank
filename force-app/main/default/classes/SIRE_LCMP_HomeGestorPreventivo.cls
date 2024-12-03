/*****************************************************************
 Name:  SIR_LCMP_ReassignOwner
 Copyright © 2023  CaixaBank

 Proposito:   Clase controladora externa del LWC Sire_lwc_HomeGestorPreventivo                                                                                                                    

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            			        Atmira         24/03/2022     	  Created    
*****************************************************************/
public with sharing class SIRE_LCMP_HomeGestorPreventivo {
    /*****************************************************************
        @description  Realizamos query para saber el ID                                             
        @param  Ninguno
        @return List<SIREC__SIREC_obj_proceso__c>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         24/03/2022      	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static Boolean getUsuarioLogeado(Id usuarioLogeado){
        Boolean usuarioTGA = false;
        if(Schema.SObjectType.User.isAccessible()){
            List<User> usuario = [SELECT id, AV_tipoGestor__c FROM User WHERE Id =: usuarioLogeado LIMIT 1];            
            if(usuario[0].AV_tipoGestor__c == SIR_CONSTANTES.TIPO_ANALISTA_RIESGOS){
                usuarioTGA = true;
            } else {
                usuarioTGA = false;
            }
        }
        return usuarioTGA;
    }

    /*****************************************************************
        @description  Realizamos query para recoger todos las Agrupaciones de Estrategias activas para PRESOL                                          
        @param  Ninguno
        @return List<SIREC__SIREC_obj_Catalogo__c>                                                     
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         08/08/2024      	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_Catalogo__c> getAgrupacionesEstrategias(){
        List<SIREC__SIREC_obj_Catalogo__c> agrupaciones = new List<SIREC__SIREC_obj_Catalogo__c>();
        if(Schema.SObjectType.SIREC__SIREC_obj_Catalogo__c.isAccessible()){
            agrupaciones = [SELECT SIREC__SIREC_fld_CodigoAgrupador__c, SIREC__SIREC_fld_DescAgrupador__c , SIREC__SIREC_fld_OrdenAgrupador__c 
                        FROM SIREC__SIREC_obj_Catalogo__c 
                        WHERE SIREC__SIREC_fld_CodigoNegocio__c = 'Preventivo' AND SIREC__SIREC_fld_CodigoActivo__c = 'S' 
                        ORDER BY SIREC__SIREC_fld_OrdenAgrupador__c ];
            // Parte para recoger y poner en la lista, el max de cajas por linea para el forntal
            SIR_Parametros__c maxCajas = SIR_Parametros__c.getInstance('maxCajas_PREVENTIVO');               
            SIREC__SIREC_obj_Catalogo__c cat = new SIREC__SIREC_obj_Catalogo__c(
                Name = 'maxCajas',
                SIREC__SIREC_fld_Codigo__c = maxCajas.SIR_Valor__c
            );            
            agrupaciones.add(cat);
        }
        return agrupaciones;
    }

    
    /*****************************************************************
        @description  Realizamos query para buscar los procesos Preventivo del usuario logueado                                             
        @param  Ninguno
        @return List<SIREC__SIREC_obj_proceso__c>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         24/03/2022      	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> getQueryProcesos(){
        List<SIREC__SIREC_obj_proceso__c> procesos = new List<SIREC__SIREC_obj_proceso__c>();
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible()){
            procesos = [SELECT id, Name, SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_cliente__r.Name, SIR_FechaInicioEstrategia__c, toLabel(SIR_fld_Situacion_SF__c) situacion, 
                        SIR_fld_Situacion_SF__c, SIREC__SIREC_fld_fechaInicio__c, SIR_DeudaTotal__c, SIR_MaximoDiasImpago__c, SIR_GrupoEconomico__c,
                        SIREC__SIREC_fld_fechaSituacion__c, SIR_AlertaSIREC__c, SIR_DeudaVencidaImpagada__c, Owner.Name, SIR_PropuestaNegocio__c,
                        SIR_AnalistaRiesgo__c, SIR_AnalistaRiesgo__r.Name, SIR_PropuestaRiesgo__c, SIR_PropuestaProceso__c, toLabel(SIR_TipoGestionPREVEMP__c),
                        SIREC__SIREC_fld_tarea__c, SIREC__SIREC_fld_tarea__r.Name, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_estado__c, 
                        SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tipo_tarea__c, SIR_agrupacionSituacion__c, SIR_fechaCarga__c, SIR_RatingScoring__c,
                        SIREC__SIREC_fld_codigoAgrupador__c, format(SIREC__SIREC_fld_descEstrategiaCatalogo__c) estrategia                        
                        FROM SIREC__SIREC_obj_proceso__c 
                        WHERE (OwnerId =: UserInfo.getUserId() OR SIR_AnalistaRiesgo__c =: UserInfo.getUserId())
                        AND RecordType.Name = : SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_PREVENTIVO
                        AND SIR_AccionActual__c = true
                        AND SIR_fld_Situacion_SF__c != : SIR_Constantes.PROCESO_SITUACION_FINALIZADO
                        AND SIR_ObjetivoProceso__c != : SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO
                        ORDER BY SIREC__SIREC_fld_estrategiaCatalogo__r.SIREC__SIREC_fld_OrdenAgrupador__c ASC LIMIT 49999];
        }
        return procesos;
    }

    /*****************************************************************
        @description  Realizamos query para buscar los Reports de Preventivo                                            
        @param  Ninguno
        @return List<Report>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         27/03/2023      	  Created  
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<Report> getQueryReports(){
        List<Report> informes = new List<Report>();
        if(Schema.SObjectType.Report.isAccessible()){
            informes = [SELECT id, name, DeveloperName, FolderName  
                        FROM Report 
                        WHERE FolderName = 'Preventivo' AND
                        DeveloperName in ('SIRE_FechaRevisionVencida_PREVEMP', 'SIRE_IncrementoRiesgo_PREVEMP', 'SIRE_PeriodoEspera_PREVEMP',
                        'SIRE_ProcesosEstrategias_PREVEMP', 'SIRE_ProcesosGestionadosCargaActual_PREVEMP', 'SIRE_ProcesosPendienteConsenso_PREVEMP',
                        'SIRE_ProcesosPendienteRiesgo_PREVEMP','SIRE_ProcesosPendientesdeIniciar_PREVEMP','SIRE_TareasPendientesSincronizar_PREVEMP')
                        ORDER BY DeveloperName];
        }
        return informes;
    }

   
}