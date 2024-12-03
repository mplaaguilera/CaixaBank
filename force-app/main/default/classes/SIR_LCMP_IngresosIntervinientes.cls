/*****************************************************************
 Name:  SIR_LCMP_IngresosIntervinientes
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase controladora externa del LWC Sir_lwc_IngresosIntervinientes                                                                                                                    
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249657         Atmira         06/07/2021     	  Created    

*****************************************************************/
public with sharing class SIR_LCMP_IngresosIntervinientes {


    /*****************************************************************
        Proposito: Query para obtener valores de variables de formulario
        Parameters: String idFormulario
        Returns: List<SIR_IntervinienteFormulario__c>                                                      
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
		1.0            US249657         Atmira         10/02/2022	      Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIR_FormularioRefinanciacion__c> getValoresForm(String idFormulario) {
        List<SIR_FormularioRefinanciacion__c> formulario = new  List<SIR_FormularioRefinanciacion__c>();
        if(SIR_FormularioRefinanciacion__c.SObjectType.getDescribe().isAccessible()){
            formulario = [SELECT SIR_TotalGastos__c, SIR_capActualRatioEndeudamiento__c, SIR_importeCuotaActual__c, SIR_capActualImporteFinanciacion__c,
                            SIR_capActualRatioTotal__c, SIR_capActualPagoCliente__c,  SIR_capacidadDevolucion__c, SIR_capActualTipoSolucion__c,
                            SIR_ingresosFuturo__c, SIR_ratioFuturo__c, SIR_ratioAdmision__c, SIR_solucionAplicar__c, SIR_tipoDificultad__c,
                            SIR_cargaFinancieraCaixa__c, SIR_ratioActual__c, SIR_TotalCuotaRefCaixa__c
                            FROM SIR_FormularioRefinanciacion__c WHERE Id =: idFormulario]; 
        }
        return formulario;
    }

    
    
    /*****************************************************************
        Proposito: Query para obtener todos los intervinientes de ese formulario
        Parameters: String idFormulario
        Returns: List<SIR_IntervinienteFormulario__c>                                                      
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
		1.0            US249657         Atmira         06/07/2021	      Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIR_IntervinienteFormulario__c> getIntervininientes(String idFormulario) {
        List<SIR_IntervinienteFormulario__c> intervinientes = new  List<SIR_IntervinienteFormulario__c>();
        if(SIR_IntervinienteFormulario__c.SObjectType.getDescribe().isAccessible()){
            intervinientes = [SELECT id, SIR_Cliente__c, SIR_Cliente__r.Name, SIR_Relacion__c, SIR_Profesion__c, SIR_IngresosTrabajo__c, SIR_Bienes__c, SIR_IngresosBienes__c
                                FROM SIR_IntervinienteFormulario__c WHERE SIR_FormularioRefinanciacion__c =: idFormulario AND SIR_Relacion__c != 'B' order by SIR_Relacion__c desc];     
            for(SIR_IntervinienteFormulario__c inter: intervinientes){
                if(inter.SIR_IngresosTrabajo__c == null){
                    inter.SIR_IngresosTrabajo__c = 0;
                }
                if(inter.SIR_IngresosBienes__c == null){
                    inter.SIR_IngresosBienes__c = 0;
                }
            }
        }
        return intervinientes;
    }
    
    
    /*****************************************************************
        Proposito: Query para obtener los datos de ese formulario
        Parameters: String idFormulario
        Returns: List<SIR_FormularioRefinanciacion__c>                                                      
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
		1.0            US249657         Atmira         06/07/2021	      Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIR_FormularioRefinanciacion__c> getFormulario(String idFormulario) {
        List<SIR_FormularioRefinanciacion__c> formulario = new List<SIR_FormularioRefinanciacion__c>();
        if(SIR_FormularioRefinanciacion__c.SObjectType.getDescribe().isAccessible()){
            formulario = [SELECT id, SIR_TotalIngresosTrabajo__c, SIR_TotalIngresosBienes__c, SIR_OtrosDatosInteres__c, SIR_IngresosAdicionalesUnidFam__c
                            FROM SIR_FormularioRefinanciacion__c WHERE id =: idFormulario]; 
            for(SIR_FormularioRefinanciacion__c formRefi: formulario){
                if(formRefi.SIR_IngresosAdicionalesUnidFam__c == null){
                    formRefi.SIR_IngresosAdicionalesUnidFam__c = 0;
                }
                if(formRefi.SIR_TotalIngresosTrabajo__c == null){
                    formRefi.SIR_TotalIngresosTrabajo__c = 0;
                }
                if(formRefi.SIR_TotalIngresosBienes__c == null){
                    formRefi.SIR_TotalIngresosBienes__c = 0;
                }
            }
        }
        return formulario;        
    }
    
        
    /*****************************************************************
        Proposito: Realiza el update de los intervinientes
        Parameters: Object data
        Returns: String                                                 
        Throws [Exceptions]: Se controla las Exceptions devolviendo el mensaje al LWC para que se muestre por pantalla

        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
		1.0            US249657         Atmira         06/07/2021	      Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static string updateIntervinientes(Object data) {
        List<SIR_IntervinienteFormulario__c> intervinientesForUpdate = new List<SIR_IntervinienteFormulario__c>();
        if(SIR_IntervinienteFormulario__c.SObjectType.getDescribe().isUpdateable()){
            intervinientesForUpdate = (List<SIR_IntervinienteFormulario__c>) JSON.deserialize(
                JSON.serialize(data),
                List<SIR_IntervinienteFormulario__c>.class
            );
            try {
                update intervinientesForUpdate;
                return 'OK';
            } catch (Exception e) {
                CBK_log.error(e, 'Error : Sir_lwc_IngresosIntervinientes - ' + e.getTypeName() + ': ' + e.getMessage());
                return 'Ha ocurrido un error: ' + e.getMessage();
            }
        }
        return null;
    }
    
    
    /*****************************************************************
        Proposito: Realiza el update del Formulario
        Parameters: 
        Returns: String                                                 
        Throws [Exceptions]: Se controla las Exceptions devolviendo el mensaje al LWC para que se muestre por pantalla

        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
		1.0            US249657         Atmira         06/07/2021	      Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static string updateFormulario(String idFormulario, Decimal totalTrabajo, Decimal totalBienes, String otrosDatos, Decimal ingresosAdicionales) {  
        List<SIR_FormularioRefinanciacion__c> formulario = new List<SIR_FormularioRefinanciacion__c>(); 
        if(SIR_FormularioRefinanciacion__c.SObjectType.getDescribe().isUpdateable()){    
            try {
                formulario = [SELECT id, SIR_TotalIngresosTrabajo__c, SIR_TotalIngresosBienes__c, SIR_OtrosDatosInteres__c
                                FROM SIR_FormularioRefinanciacion__c WHERE id =: idFormulario]; 
                for(SIR_FormularioRefinanciacion__c formRefi: formulario){
                    formRefi.SIR_TotalIngresosTrabajo__c = totalTrabajo;
                    formRefi.SIR_TotalIngresosBienes__c = totalBienes;
                    formRefi.SIR_OtrosDatosInteres__c = otrosDatos;
                    formRefi.SIR_IngresosAdicionalesUnidFam__c = ingresosAdicionales;
                }
                update formulario;
                return 'OK';
            } catch (Exception e) {
                CBK_log.error(e, 'Error : Sir_lwc_IngresosIntervinientes - ' + e.getTypeName() + ': ' + e.getMessage());
                return 'Ha ocurrido un error:: ' + e.getMessage();
            }
        }
        return null;
    }
    
}