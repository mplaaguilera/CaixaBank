/*****************************************************************
 Name:  SIR_LCMP_HomePresolAutoRefresh
 Copyright © 2022  CaixaBank

@description   Clase controladora externa del LWC Sir_lwc_HomePresolAutoRefresh                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR          DATE               Description
    1.0            US463464         Atmira          05/10/2022         Created    

*****************************************************************/
public with sharing class SIR_LCMP_HomePresolAutoRefresh {
    /*****************************************************************
        @description  Realizamos query para recoger todos las Agrupaciones de Estrategias activas para PRESOL                                          
        @param  Ninguno
        @return List<SIREC__SIREC_obj_Catalogo__c>                                                     
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         01/08/2024      	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_Catalogo__c> getAgrupacionesEstrategias(){
        List<SIREC__SIREC_obj_Catalogo__c> agrupaciones = new List<SIREC__SIREC_obj_Catalogo__c>();
        if(Schema.SObjectType.SIREC__SIREC_obj_Catalogo__c.isAccessible()){
            agrupaciones = [SELECT SIREC__SIREC_fld_CodigoAgrupador__c, SIREC__SIREC_fld_DescAgrupador__c , SIREC__SIREC_fld_OrdenAgrupador__c 
                        FROM SIREC__SIREC_obj_Catalogo__c 
                        WHERE SIREC__SIREC_fld_CodigoNegocio__c = 'PRESOL' AND SIREC__SIREC_fld_CodigoActivo__c = 'S' 
                        ORDER BY SIREC__SIREC_fld_OrdenAgrupador__c ];
            // Parte para recoger y poner en la lista, el max de cajas por linea para el forntal
            SIR_Parametros__c maxCajas = SIR_Parametros__c.getInstance('maxCajas_PRESOL');               
            SIREC__SIREC_obj_Catalogo__c cat = new SIREC__SIREC_obj_Catalogo__c(
                Name = 'maxCajas',
                SIREC__SIREC_fld_Codigo__c = maxCajas.SIR_Valor__c
            );            
            agrupaciones.add(cat);
        }
        return agrupaciones;
    }

    /*****************************************************************
        @description  Realizamos query para buscar los procesos IMPA del usuario logueado                                             
        @param  Ninguno
        @return List<SIREC__SIREC_obj_proceso__c>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US463464         Atmira         05/10/2022      	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> getQueryProcesos(){
        List<SIREC__SIREC_obj_proceso__c> procesos = new List<SIREC__SIREC_obj_proceso__c>();
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible()){            
            procesos = [SELECT id, Name, SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_cliente__r.Name, SIR_FechaInicioEstrategia__c, toLabel(SIR_fld_Situacion_SF__c) situacion, 
                        SIR_fld_Situacion_SF__c, SIREC__SIREC_fld_fechaSituacion__c, SIREC__SIREC_fld_fechaInicio__c, SIR_DeudaTotal__c, SIR_SegmentoPRESOL__c, 
                        SIR_PrioridadPRESOL__c, SIR_AlertaPRESOL__c, toLabel(SIR_TenenciaICO__c) tenencia, SIR_FechaVencimientoICO__c, toLabel(SIR_AvisoCentralizado__c) aviso,
                        SIREC__SIREC_fld_tarea__c, SIREC__SIREC_fld_tarea__r.Name, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_estado__c, 
                        SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tipo_tarea__c, 
                        SIR_RatingScoring__c, SIR_MotivoInclusion__c, SIR_AccionActual__c, SIR_saldActivo__c, SIR_agrupacionSituacion__c,
                        SIREC__SIREC_fld_codigoAgrupador__c, format(SIREC__SIREC_fld_descEstrategiaCatalogo__c) estrategia
                        FROM SIREC__SIREC_obj_proceso__c 
                        WHERE OwnerId =: UserInfo.getUserId() 
                        AND RecordType.Name = : SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL
                        AND SIR_AccionActual__c =: true
                        AND SIR_fld_Situacion_SF__c != : SIR_Constantes.PROCESO_SITUACION_FINALIZADO
                        ORDER BY SIREC__SIREC_fld_estrategiaCatalogo__r.SIREC__SIREC_fld_OrdenAgrupador__c ASC LIMIT 49999];
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
        1.0            US463464         Atmira         05/10/2022      	  Created   
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<Report> getQueryReports(){
        List<Report> informes = new List<Report>();
        if(Schema.SObjectType.Report.isAccessible()){
            informes = [SELECT id, name, DeveloperName  
                        FROM Report 
                        WHERE DeveloperName in ('SIR_Procesos_Pendientes_de_gestion', 'SIR_Procesos_activos_PRESOL', 'SIR_Procesos_gestionado_PRESOL', 
                                                'SIR_ProcesosEstrategias_PRESOL', 'SIR_Acciones_pendientes_de_Sincronizar_PRESOL', 'Tareas_pendientes_de_Sincronizar_2jw')
                        ORDER BY DeveloperName ];
        }
        return informes;
    }
    
}