/*****************************************************************
 Name:  SIR_LCMP_HomeImpaAutoRefresh
 Copyright © 2022  CaixaBank

@description   Clase controladora externa del LWC Sir_lwc_HomeImpaAutoRefresh                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR          DATE               Description
    1.0            US424098         Atmira          01/08/2022         Created    

*****************************************************************/
public with sharing class SIR_LCMP_HomeImpaAutoRefresh {

    /*****************************************************************
        @description  Realizamos query para recoger todos las Agrupaciones de Estrategias activas para IMPA                                          
        @param  Ninguno
        @return List<SIREC__SIREC_obj_Catalogo__c>                                                     
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         18/07/2024      	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_Catalogo__c> getAgrupacionesEstrategias(){
        List<SIREC__SIREC_obj_Catalogo__c> agrupaciones = new List<SIREC__SIREC_obj_Catalogo__c>();
        if(Schema.SObjectType.SIREC__SIREC_obj_Catalogo__c.isAccessible()){
            agrupaciones = [SELECT SIREC__SIREC_fld_CodigoAgrupador__c, SIREC__SIREC_fld_DescAgrupador__c , SIREC__SIREC_fld_OrdenAgrupador__c 
                        FROM SIREC__SIREC_obj_Catalogo__c 
                        WHERE SIREC__SIREC_fld_CodigoNegocio__c = 'IMPA' AND SIREC__SIREC_fld_CodigoActivo__c = 'S' 
                        ORDER BY SIREC__SIREC_fld_OrdenAgrupador__c ];
            // Parte para recoger y poner en la lista, el max de cajas por linea para el forntal
            SIR_Parametros__c maxCajas = SIR_Parametros__c.getInstance('maxCajas_IMPA');               
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
        1.0            US424098         Atmira         01/08/2022      	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> getQueryProcesos(){
        List<SIREC__SIREC_obj_proceso__c> procesos = new List<SIREC__SIREC_obj_proceso__c>();
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible()){
            procesos = [SELECT id, Name, SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_cliente__r.Name, SIR_FechaInicioEstrategia__c, 
                        toLabel(SIR_fld_Situacion_SF__c) situacion, SIR_fld_Situacion_SF__c, SIREC__SIREC_fld_fechaInicio__c, 
                        SIR_DeudaTotal__c, SIR_MaximoDiasImpago__c, SIREC__SIREC_fld_fechaSituacion__c, SIR_AlertaSIREC__c, 
                        SIR_DeudaVencidaImpagada__c, SIR_FechaCompromisoPago__c, SIR_CompromisoPagoIncumplido__c, SIR_FechaPaseContable__c, 
                        SIR_ObjetivoProceso__c, SIR_agrupacionSituacion__c, SIREC__SIREC_fld_codigoAgrupador__c, format(SIREC__SIREC_fld_descEstrategiaCatalogo__c) estrategia
                        FROM SIREC__SIREC_obj_proceso__c 
                        WHERE OwnerId =: UserInfo.getUserId() AND RecordType.Name = : SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO
                        AND SIR_fld_Situacion_SF__c != : SIR_Constantes.PROCESO_SITUACION_FINALIZADO
                        AND SIR_ObjetivoProceso__c != 'SIN GESTION'
                        ORDER BY SIREC__SIREC_fld_estrategiaCatalogo__r.SIREC__SIREC_fld_OrdenAgrupador__c ASC LIMIT 49999];
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
        if(Schema.SObjectType.SIR_FormularioRefinanciacion__c.isAccessible()){
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
        if(Schema.SObjectType.SIREC__SIREC_obj_acciones__c.isAccessible()){
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
        if(Schema.SObjectType.Report.isAccessible()){
            informes = [SELECT id, name, DeveloperName  
                        FROM Report 
                        WHERE DeveloperName in ('Formularios_pendientes_de_Sincronizar_pHk', 'Nuevo_informe_de_Procesos_con_Acciones_38D', 
                        'Procesos_Pendientes_de_Iniciar_IMPA','SIR_Formularios_pendientes_gestor', 'SIR_procesosEstrategias', 'SIR_ProcesosPendientesGestion')
                        ORDER BY DeveloperName ];
        }
        return informes;
    }
    
}