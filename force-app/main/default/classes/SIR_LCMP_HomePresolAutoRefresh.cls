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
        @description  Realizamos query para saber el ID                                             
        @param  Ninguno
        @return List<SIREC__SIREC_obj_proceso__c>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         17/03/2023      	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static Id getQueryRecordTypeProceso(){
        String idRecordType = '';
        if(RecordType.SObjectType.getDescribe().isAccessible()){
            List<RecordType> procesos = new List<RecordType>();
            procesos = [SELECT id FROM RecordType WHERE SobjectType ='SIREC__SIREC_obj_proceso__c' AND DeveloperName ='SIREC_rt_Anticipacion' LIMIT 1];
            idRecordType = procesos[0].id;
        }
        return idRecordType;
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
        if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible()){
            procesos = [SELECT id, Name, SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_cliente__r.Name, SIREC__SIREC_fld_estrategia__c, 
                        toLabel(SIREC__SIREC_fld_estrategia__c) estrategia, SIR_FechaInicioEstrategia__c, toLabel(SIR_fld_Situacion_SF__c) situacion, 
                        SIR_fld_Situacion_SF__c, SIREC__SIREC_fld_fechaSituacion__c, SIREC__SIREC_fld_fechaInicio__c, SIR_DeudaTotal__c, SIR_SegmentoPRESOL__c, 
                        SIR_PrioridadPRESOL__c, SIR_AlertaPRESOL__c, toLabel(SIR_TenenciaICO__c) tenencia, SIR_FechaVencimientoICO__c, toLabel(SIR_AvisoCentralizado__c) aviso, 
                        SIR_RatingScoring__c, SIR_MotivoInclusion__c, SIR_AccionActual__c, SIR_saldActivo__c, SIR_agrupacionSituacion__c
                        FROM SIREC__SIREC_obj_proceso__c 
                        WHERE OwnerId =: UserInfo.getUserId() 
                        AND RecordType.Name = : SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL
                        AND SIR_AccionActual__c =: true
                        AND SIR_fld_Situacion_SF__c != : SIR_Constantes.PROCESO_SITUACION_FINALIZADO
                        ORDER BY SIREC__SIREC_fld_fechaSituacion__c DESC];
        }
        return procesos;
    }

    /*****************************************************************
        @description  Realizamos query para buscar los acciones del usuario logueado. 
        Solo se mostraran aquellas que no pertezcan al workflow, es decir, que no tenga tarea asociada                                        
        @param  Ninguno
        @return List<SIREC__SIREC_obj_acciones__c>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US463464         Atmira         07/10/2022      	  Created     
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_acciones__c> getQueryAcciones(){
        List<SIREC__SIREC_obj_acciones__c> acciones = new List<SIREC__SIREC_obj_acciones__c>();
        if(SIREC__SIREC_obj_acciones__c.SObjectType.getDescribe().isAccessible()){
            acciones = [SELECT id, Name, SIREC__SIREC_fld_interviniente__c, SIREC__SIREC_fld_interviniente__r.Name, toLabel(SIREC__SIREC_fld_resultado__c) resultado, 
                        toLabel(SIREC__SIREC_fld_tipo__c) tipo, toLabel(SIREC__SIREC_fld_accion__c) accion, SIR_estrategia__c, SIREC__SIREC_fld_fechaContacto__c, SIREC__SIREC_fld_tarea__c,
                        SIREC__SIREC_fld_proceso__c, SIREC__SIREC_fld_proceso__r.Id, SIREC__SIREC_fld_proceso__r.Name, toLabel(SIREC__SIREC_fld_proceso__r.SIR_fld_Situacion_SF__c), 
                        SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_fechaSituacion__c
                        FROM SIREC__SIREC_obj_acciones__c 
                        WHERE SIREC__SIREC_fld_responsable__c =: UserInfo.getUserId() 
                        AND (SIREC__SIREC_fld_proceso__c !=: '' OR SIREC__SIREC_fld_proceso__c !=: null)
                        AND SIREC__SIREC_fld_proceso__r.RecordType.Name = :SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL
                        AND SIREC__SIREC_fld_proceso__r.SIR_AccionActual__c =: true
                        AND RecordType.Name = : SIR_Constantes.ACCION_RECORDTYPE_NAME_PRESOL
                        AND SIREC__SIREC_fld_estado__c = : SIR_Constantes.ACCION_ESTADO_PENDIENTE
                        AND SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_situacion__c != :SIR_Constantes.PROCESO_SITUACION_FINALIZADO 
                        AND (SIREC__SIREC_fld_tarea__c =: '' OR SIREC__SIREC_fld_tarea__c =: null)
                        ];
        }
        return acciones;
    }

    /*****************************************************************
        @description  Realizamos query para buscar los tareas del usuario logueado. 
        Se obtienen las tareas de workflow, es decir, las que están relacionadas con Procesos                                             
        @param  Ninguno
        @return List<SIREC__SIREC_obj_tarea__c>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US463464         Atmira         07/10/2022      	  Created     
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_tarea__c> getQueryTareas(){
        List<SIREC__SIREC_obj_tarea__c> tareas = new List<SIREC__SIREC_obj_tarea__c>();
        if(SIREC__SIREC_obj_tarea__c.SObjectType.getDescribe().isAccessible()){
            tareas = [SELECT id, Name, SIREC__SIREC_fld_tipo_tarea__c, SIREC__SIREC_fld_proceso__c, SIREC__SIREC_fld_proceso__r.Id, SIREC__SIREC_fld_proceso__r.Name, 
                        toLabel(SIREC__SIREC_fld_proceso__r.SIR_fld_Situacion_SF__c), toLabel(SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_estrategia__c),
                        SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_fechaSituacion__c, SIREC__SIREC_fld_estado__c, SIREC__SIREC_fld_proceso__r.OwnerId
                        FROM SIREC__SIREC_obj_tarea__c 
                        WHERE SIREC__SIREC_fld_proceso__r.OwnerId =: UserInfo.getUserId() 
                        AND (SIREC__SIREC_fld_proceso__c !=: '' OR SIREC__SIREC_fld_proceso__c !=: null) 
                        AND SIREC__SIREC_fld_proceso__r.RecordType.Name = :SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL
                        AND SIREC__SIREC_fld_proceso__r.SIR_AccionActual__c =: true
                        AND SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_situacion__c != :SIR_Constantes.PROCESO_SITUACION_FINALIZADO
                        AND (SIREC__SIREC_fld_estado__c = : SIR_Constantes.TAREA_ESTADO_PENDIENTE OR SIREC__SIREC_fld_estado__c = : SIR_Constantes.TAREA_ESTADO_ENVIADA)
                        ];
        }
        return tareas;
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
        if(Report.SObjectType.getDescribe().isAccessible()){
            informes = [SELECT id, name, DeveloperName  
                        FROM Report 
                        WHERE DeveloperName in ('SIR_Procesos_Pendientes_de_gestion', 'SIR_Procesos_activos_PRESOL', 'SIR_Procesos_gestionado_PRESOL', 
                                                'SIR_ProcesosEstrategias_PRESOL', 'SIR_Acciones_pendientes_de_Sincronizar_PRESOL', 'Tareas_pendientes_de_Sincronizar_2jw')
                        ORDER BY DeveloperName ];
        }
        return informes;
    }

    /*****************************************************************
        @description  Realizamos query para buscar los Procesos que se mostraran en el grafico                                            
        @param  Ninguno
        @return List<ProcesoInfo>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US463464         Atmira         07/10/2022      	  Created   
        
	*****************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<ProcesoInfo> getProcesos(){

        List<ProcesoInfo> lstProcesoInfo = new List<ProcesoInfo>();
        AggregateResult[] groupedResults = [SELECT sum(SIR_DeudaTotal__c), toLabel(SIR_fld_Situacion_SF__c), toLabel(SIREC__SIREC_fld_estrategia__c), count(Id)
                                                FROM SIREC__SIREC_obj_proceso__c 
                                                WHERE RecordType.Name =: SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL
                                                AND SIR_AccionActual__c =: true
                                                AND (SIR_fld_Situacion_SF__c =: SIR_Constantes.PROCESO_SITUACION_REPLANIFICAR_CONTACTO OR SIR_fld_Situacion_SF__c =: SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION OR SIR_fld_Situacion_SF__c =:  SIR_Constantes.PROCESO_SITUACION_ANALISIS_PREVIO OR SIR_fld_Situacion_SF__c =: SIR_Constantes.PROCESO_SITUACION_CLI_NO_LOCALIZADO OR SIR_fld_Situacion_SF__c =: SIR_Constantes.PROCESO_SITUACION_PTE_CONTACTAR)
                                                AND OwnerId =:UserInfo.getUserId()
                                                Group by SIREC__SIREC_fld_estrategia__c, SIR_fld_Situacion_SF__c
                                                Order by SIREC__SIREC_fld_estrategia__c, SIR_fld_Situacion_SF__c];
        for (AggregateResult ar : groupedResults){
            lstProcesoInfo.add(new ProcesoInfo(ar));
        }        
        return lstProcesoInfo;
    }
    

    public class ProcesoInfo{
        @AuraEnabled public String situacion;
        @AuraEnabled public String estrategia;
        @AuraEnabled public Integer numProcesos;
        @AuraEnabled public Double cantidad;
        ProcesoInfo(AggregateResult procesoAgregado){
            List<Schema.PicklistEntry> valuesSituacion = SIREC__SIREC_obj_proceso__c.SIR_fld_Situacion_SF__c.getDescribe().getPicklistValues();
            Map<String,String> situacionMap = new Map<String,String>();
            for(Schema.PicklistEntry sp : valuesSituacion){
                situacionMap.put(sp.getValue(), sp.getLabel());
            }
            List<Schema.PicklistEntry> valuesEstrategia= SIREC__SIREC_obj_proceso__c.SIREC__SIREC_fld_estrategia__c.getDescribe().getPicklistValues();
            Map<String,String> estrategiaMap = new Map<String,String>();
            for(Schema.PicklistEntry sp : valuesEstrategia){
                estrategiaMap.put(sp.getValue(), sp.getLabel());
            }

            this.situacion = situacionMap.get((String)procesoAgregado.get('SIR_fld_Situacion_SF__c'));
            this.estrategia = estrategiaMap.get((String)procesoAgregado.get('SIREC__SIREC_fld_estrategia__c'));
            this.numProcesos = (Integer)procesoAgregado.get('expr1');
            this.cantidad = (Double)procesoAgregado.get('expr0');
        }
    }
    
}