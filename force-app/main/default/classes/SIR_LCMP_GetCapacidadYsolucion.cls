/*****************************************************************
 Name:  SIR_LCMP_GetCapacidadYsolucion
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase controladora externa del LWC sir_lwc_GetCapacidadYsolucion                                                                                                                    
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US US249658      Atmira         05/07/2021     	  Created    

*****************************************************************/
public with sharing class SIR_LCMP_GetCapacidadYsolucion {
    public static string clase = 'SIR_LCMP_GetCapacidadYsolucion';

 /*****************************************************************
        Proposito: Query para obtener los datos de ese formulario
        Parameters: String idFormulario
        Returns:  List<SIR_FormularioRefinanciacion__c>                                                      
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US US249658      Atmira         05/07/2021     	  Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIR_FormularioRefinanciacion__c> getCapacidadFormulario(String idFormulario) {
        String metodo = 'getCapacidadFormulario';
        List<SIR_FormularioRefinanciacion__c> formulario = new  List<SIR_FormularioRefinanciacion__c>();
        if(SIR_FormularioRefinanciacion__c.SObjectType.getDescribe().isAccessible()){
            formulario = [SELECT SIR_capActualImporteCuota__c ,SIR_capActualRatioEndeudamiento__c ,SIR_SolucionFinalista__c
                          ,SIR_capActualImporteFinanciacion__c ,SIR_capActualRatioTotal__c ,SIR_capActualPagoCliente__c ,SIR_capActualTipoSolucion__c , SIR_TotalIngresosTrabajo__c ,SIR_TotalGastos__c ,
                          SIR_ingresosFuturo__c , SIR_ratioEndeudamientoFuturo__c ,SIR_importeCuotaActual__c , SIR_textIngresosFuturo__c , SIR_ratioAdmision__c , SIR_ratioActual__c , SIR_ratioFuturo__c,
                          SIR_tipoDificultad__c , SIR_solucionAplicar__c , SIR_solucionCortoPlazo__c , SIR_solucionLargoPlazo__c , SIR_capacidadDevolucion__c , SIR_cargaFinancieraCaixa__c , SIR_solucionDeuda__c
                          ,SIR_solucionDeudaAplicar__c ,SIR_textSolucionAplicar__c , SIR_TotalIngresosBienes__c
                          FROM SIR_FormularioRefinanciacion__c 
                          WHERE id =: idFormulario
                          LIMIT 1];
        }
        return formulario;        
    }
      /*****************************************************************
        Proposito: Query para obtener los datos de ese formulario
        Parameters: String idFormulario
        Returns: List<SIR_WrapperFormulario>                                                      
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US US249658      Atmira         05/07/2021     	  Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static String guardarFormulario(String idFormulario , List<String> data) {
        String metodo = 'guardarFormulario';
        try {
           if(SIR_FormularioRefinanciacion__c.SObjectType.getDescribe().isUpdateable()){          
                SIR_FormularioRefinanciacion__c updateForm = [SELECT SIR_SolucionFinalista__c, SIR_ingresosFuturo__c , SIR_textIngresosFuturo__c ,
                                                    SIR_ratioAdmision__c ,SIR_solucionCortoPlazo__c , SIR_solucionLargoPlazo__c , SIR_tipoDificultad__c,
                                                    SIR_solucionAplicar__c ,SIR_solucionDeudaAplicar__c ,SIR_textSolucionAplicar__c
                                                    FROM SIR_FormularioRefinanciacion__c 
                                                    WHERE Id =:idFormulario 
                                                    LIMIT 1];
                updateForm.SIR_SolucionFinalista__c                       = data[0];                            // SIR_SolucionFinalista__c
                updateForm.SIR_ingresosFuturo__c                          = decimal.valueof(data[1]);           // SIR_ingresosFuturo__c
                updateForm.SIR_textIngresosFuturo__c                      = data[2];                            // SIR_textIngresosFuturo__c
                updateForm.SIR_ratioAdmision__c                           = decimal.valueof(data[3]);           // SIR_ratioAdmision__c
                updateForm.SIR_solucionCortoPlazo__c                      = data[4];                            // SIR_solucionCortoPlazo__c
                updateForm.SIR_solucionLargoPlazo__c                      = data[5];                            // SIR_solucionLargoPlazo__c
                updateForm.SIR_tipoDificultad__c                          = data[6];                            // SIR_tipoDificultad__c
                updateForm.SIR_solucionAplicar__c                         = data[7];                            // SIR_solucionAplicar__c
                updateForm.SIR_solucionDeudaAplicar__c                    = data[8];                            // SIR_solucionDeudaAplicar__c
                updateForm.SIR_textSolucionAplicar__c                     = data[9];                            // SIR_textSolucionAplicar__c
                update updateForm;
            }
            return 'OK';
        } catch (Exception e) {
            CBK_log.error(e, 'Error : Sir_lwc_CapacidadYSolucion - ' + e.getTypeName() + ': ' + e.getMessage());
            return 'Ha ocurrido un error: ' + e.getMessage();
        }    
    }  
}