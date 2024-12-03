/*****************************************************************
 Name:  SIR_LCMP_Comunicaciones
 Copyright © 2022  CaixaBank

@description   Clase controladora externa del LWC Sir_lwc_HomeImpaAutoRefresh                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR          DATE               Description
    1.0            US424098         Atmira          01/08/2022         Created    

*****************************************************************/
public with sharing class SIR_LCMP_HomeImpaAutoRefresh {

    /*****************************************************************
        @description  Realizamos query para buscar los procesos IMPA del usuario logueado                                             
        @param  Ninguno
        @return List<SIREC__SIREC_obj_proceso__c>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US424098         Atmira         01/08/2022      	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> getQueryProcesos(){
        List<SIREC__SIREC_obj_proceso__c> procesos = new List<SIREC__SIREC_obj_proceso__c>();
        if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible()){
            procesos = [SELECT id, Name, SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_cliente__r.Name, SIREC__SIREC_fld_estrategia__c, 
                        toLabel(SIREC__SIREC_fld_estrategia__c) estrategia, SIR_FechaInicioEstrategia__c, toLabel(SIR_fld_Situacion_SF__c) situacion, 
                        SIR_fld_Situacion_SF__c, SIREC__SIREC_fld_fechaInicio__c, SIR_DeudaTotal__c, SIR_MaximoDiasImpago__c, 
                        SIREC__SIREC_fld_fechaSituacion__c, SIR_AlertaSIREC__c, SIR_DeudaVencidaImpagada__c, SIR_FechaCompromisoPago__c, 
                        SIR_CompromisoPagoIncumplido__c, SIR_FechaPaseContable__c, SIR_ObjetivoProceso__c
                        FROM SIREC__SIREC_obj_proceso__c 
                        WHERE OwnerId =: UserInfo.getUserId() AND RecordType.Name = : SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO
                        AND SIR_fld_Situacion_SF__c != : SIR_Constantes.PROCESO_SITUACION_FINALIZADO
                        AND SIR_ObjetivoProceso__c != 'SIN GESTION'
                        ORDER BY SIR_AlertaSIREC__c DESC];
        }
        return procesos;
    }
    
    /*****************************************************************
        @description  Realizamos query para buscar los formularios del usuario logueado                                             
        @param  Ninguno
        @return List<SIR_FormularioRefinanciacion__c>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US424098         Atmira        01/08/2022      	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIR_FormularioRefinanciacion__c> getQueryFormularios(){
        List<SIR_FormularioRefinanciacion__c> formulario = new List<SIR_FormularioRefinanciacion__c>();
        if(SIR_FormularioRefinanciacion__c.SObjectType.getDescribe().isAccessible()){
            formulario = [SELECT id, Name, SIR_Persona__c, SIR_Persona__r.Name, SIR_fechaSituacion__c, SIR_Estado__c, LastModifiedDate, SIR_deudaTotal__c,
                        RecordType.Name
                        FROM SIR_FormularioRefinanciacion__c 
                        WHERE OwnerId =: UserInfo.getUserId() 
                        AND RecordType.Name = : SIR_Constantes.FORMULARIOREFINANCIACION_RECORDTYPE_NAME_FORMULARIO_REFINANCIACION
                        AND (SIR_Estado__c = : SIR_Constantes.FORMULARIOREFINANCIACION_ESTADO_EN_CURSO 
                            OR SIR_Estado__c = : SIR_Constantes.FORMULARIOREFINANCIACION_ESTADO_PENDIENTE_ENVIO)
                        ];
        }
        return formulario;
    }
    
    /*****************************************************************
        @description  Realizamos query para buscar los acciones del usuario logueado                                             
        @param  Ninguno
        @return List<SIREC__SIREC_obj_acciones__c>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US424098         Atmira        01/08/2022      	  Created     
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_acciones__c> getQueryAcciones(){
        List<SIREC__SIREC_obj_acciones__c> acciones = new List<SIREC__SIREC_obj_acciones__c>();
        if(SIREC__SIREC_obj_acciones__c.SObjectType.getDescribe().isAccessible()){
            acciones = [SELECT id, Name, SIREC__SIREC_fld_interviniente__c, SIREC__SIREC_fld_interviniente__r.Name, toLabel(SIREC__SIREC_fld_resultado__c), 
                        toLabel(SIREC__SIREC_fld_tipo__c), toLabel(SIREC__SIREC_fld_proceso__r.SIR_fld_Situacion_SF__c), 
                        SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_fechaSituacion__c
                        FROM SIREC__SIREC_obj_acciones__c 
                        WHERE SIREC__SIREC_fld_responsable__c =: UserInfo.getUserId() 
                        AND SIREC__SIREC_fld_proceso__r.RecordType.Name = :SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO
                        AND RecordType.Name = : SIR_Constantes.ACCION_RECORDTYPE_NAME_AMISTOSO
                        AND SIREC__SIREC_fld_estado__c = : SIR_Constantes.ACCION_ESTADO_PENDIENTE 
                        AND SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_situacion__c != :SIR_Constantes.PROCESO_SITUACION_FINALIZADO
                        ];
        }
        return acciones;
    }
    
    /*****************************************************************
        @description  Realizamos query para buscar los Reports de IMPA                                            
        @param  Ninguno
        @return List<Report>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US424098         Atmira        01/08/2022      	  Created   
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<Report> getQueryReports(){
        List<Report> informes = new List<Report>();
        if(Report.SObjectType.getDescribe().isAccessible()){
            informes = [SELECT id, name, DeveloperName  
                        FROM Report 
                        WHERE DeveloperName in ('Formularios_pendientes_de_Sincronizar_pHk', 'Nuevo_informe_de_Procesos_con_Acciones_38D',
                                                'SIR_estrategia1', 'SIR_estrategia2', 'SIR_estrategia3', 'SIR_estrategia4', 'SIR_estrategia5',  
                                                'SIR_estrategia6', 'SIR_Formularios_pendientes_gestor', 'SIR_procesosEstrategias', 'SIR_ProcesosPendientesGestion')
                        ORDER BY DeveloperName ];
        }
        return informes;
    }

  /////////////////////////////////////////
    
    @AuraEnabled(Cacheable=true)
    public static String runReport(){
        Report rep = [SELECT Id, DeveloperName FROM Report WHERE DeveloperName ='SIR_procesosEstrategias' LIMIT 1];
        return JSON.serialize(Reports.ReportManager.runReport(rep.Id, true));
    }
    
    
    /* @AuraEnabled(cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> getProcesos(){
        List<SIREC__SIREC_obj_proceso__c> lstProcesos = [SELECT Id, Name, RecordType.DeveloperName, SIR_DeudaTotal__c, toLabel(SIR_fld_Situacion_SF__c), toLabel(SIREC__SIREC_fld_estrategia__c) 
                    FROM SIREC__SIREC_obj_proceso__c 
                    WHERE RecordType.DeveloperName =: 'SIREC_rt_procesoAmistoso' 
                    AND SIR_fld_Situacion_SF__c NOT IN ('SF_ILOCALI','SF_NORECOBRO','SF_FINALIZ')
                    AND SIREC__SIREC_fld_estrategia__c NOT IN ('10000','10007')
                    AND OwnerId =:UserInfo.getUserId()];

        return lstProcesos;
    }*/
    

    @AuraEnabled(cacheable=true)
    public static List<ProcesoInfo> getProcesos(){

        List<ProcesoInfo> lstProcesoInfo = new List<ProcesoInfo>();
        AggregateResult[] groupedResults = [SELECT sum(SIR_DeudaTotal__c), toLabel(SIR_fld_Situacion_SF__c), toLabel(SIREC__SIREC_fld_estrategia__c), count(Id)
                                                FROM SIREC__SIREC_obj_proceso__c 
                                                WHERE RecordType.DeveloperName =: 'SIREC_rt_procesoAmistoso' 
                                                AND SIR_fld_Situacion_SF__c NOT IN ('SF_ILOCALI','SF_NORECOBRO','SF_FINALIZ')
                                                AND SIR_ObjetivoProceso__c != 'SIN GESTION'
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