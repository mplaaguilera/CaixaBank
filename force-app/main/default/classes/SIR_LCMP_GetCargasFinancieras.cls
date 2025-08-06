/*****************************************************************
 Name:  SIR_LCMP_GetCapacidadYsolucion
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase controladora externa del LWC sir_lwc_GetCargasFinancieras                                                                                                                   
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US US249658      Atmira         15/07/2021     	  Created    

*****************************************************************/
public with sharing class SIR_LCMP_GetCargasFinancieras {
    public static string clase = 'SIR_LCMP_GetCargasFinancieras';

    /*****************************************************************
        Proposito: Query para obtener los datos de ese formulario
        Parameters: String idFormulario
        Returns: List<SIR_WrapperFormulario>                                                      
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
		1.0            US US249658     Atmira          15/07/2021	      Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIR_FormularioRefinanciacion__c> getCargasFormulario(String idFormulario) {
        String metodo = 'getCargasFormulario';
        List<SIR_FormularioRefinanciacion__c> formulario = new  List<SIR_FormularioRefinanciacion__c>();
        if(Schema.SObjectType.SIR_FormularioRefinanciacion__c.isAccessible()){
            formulario = [SELECT SIR_deudaTotalGarantiaReal__c, SIR_deudaTotalGarantiaPersonal__c, SIR_deudaTotalTarjeta__c, SIR_deudaTotalEmpresasGrupo__c, SIR_deudaTotalOtros__c,
                          SIR_cuotaGarantiaReal__c, SIR_CuotaGarantiaPersonal__c, SIR_CuotaMensualTarjetas__c, SIR_CuotaMensualEmpresasGrupo__c, SIR_CuotaMensualOtros__c,
                          SIR_deudaTotalGarantiaRealEnt__c, SIR_deudaTotalGarantiaPersonalEnt__c, SIR_deudaTotalTarjetaEnt__c, SIR_deudaTotalEmpresasGrupoEnt__c, SIR_deudaTotalOtrosEnt__c,
                          SIR_cuotaGarantiaRealEnt__c, SIR_CuotaGarantiaPersonalEnt__c, SIR_CuotaMensualTarjetasEnt__c, SIR_CuotaMensualEmpresasGrupoEnt__c, SIR_CuotaMensualOtrosEnt__c,
                          SIR_TotalDeudaCaixabank__c, SIR_TotalCuotaCaixabank__c, SIR_TotalDeudaOtraEntidad__c, SIR_TotalCuotaOtraEntidad__c, SIR_prestamoDeudaCaixa__c, SIR_prestamoCuotaCaixa__c, SIR_prestamoDeudaNoCaixa__c,
                          SIR_prestamoCuotaNoCaixa__c, SIR_DeudaOperacionRefCaixa__c, SIR_CuotaOperacionRefCaixa__c, SIR_DeudaOperacionRefNoCaixa__c, SIR_CuotaOperacionRefNoCaixa__c, SIR_TotalDeudaRefCaixa__c,
                          SIR_TotalCuotaRefCaixa__c, SIR_TotalDeudaRefNoCaixa__c, SIR_TotalCuotaRefNoCaixa__c, SIR_OtrosDatosInteresCargas__c 
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
		1.0            US US249658      Atmira         15/07/2021	      Created    
    *****************************************************************/
    @AuraEnabled
    public static String guardarFormulario(String idFormulario , List<String> data) {
        String metodo = 'guardarFormulario';
        try {
           if(Schema.SObjectType.SIR_FormularioRefinanciacion__c.isUpdateable()){          
                SIR_FormularioRefinanciacion__c updateForm = [SELECT id, SIR_deudaTotalGarantiaRealEnt__c, SIR_cuotaGarantiaRealEnt__c, SIR_deudaTotalGarantiaPersonalEnt__c,
                                                    SIR_CuotaGarantiaPersonalEnt__c ,SIR_deudaTotalTarjetaEnt__c ,SIR_CuotaMensualTarjetasEnt__c ,SIR_deudaTotalEmpresasGrupoEnt__c ,
                                                    SIR_CuotaMensualEmpresasGrupoEnt__c ,SIR_deudaTotalOtrosEnt__c ,SIR_CuotaMensualOtrosEnt__c , SIR_TotalDeudaOtraEntidad__c ,
                                                    SIR_TotalCuotaOtraEntidad__c , SIR_OtrosDatosInteresCargas__c , SIR_DeudaOperacionRefCaixa__c , SIR_CuotaOperacionRefCaixa__c ,
                                                    SIR_prestamoDeudaNoCaixa__c , SIR_DeudaOperacionRefNoCaixa__c , SIR_prestamoCuotaNoCaixa__c , SIR_CuotaOperacionRefNoCaixa__c ,
                                                    SIR_TotalDeudaRefNoCaixa__c , SIR_TotalCuotaRefNoCaixa__c , SIR_TotalDeudaRefCaixa__c , SIR_TotalCuotaRefCaixa__c,
                                                    SIR_deudaTotalGarantiaReal__c, SIR_cuotaGarantiaReal__c, SIR_deudaTotalGarantiaPersonal__c, SIR_CuotaGarantiaPersonal__c,
                                                    SIR_deudaTotalTarjeta__c, SIR_CuotaMensualTarjetas__c, SIR_deudaTotalEmpresasGrupo__c, SIR_CuotaMensualEmpresasGrupo__c,
                                                    SIR_deudaTotalOtros__c, SIR_CuotaMensualOtros__c, SIR_TotalDeudaCaixabank__c, SIR_TotalCuotaCaixabank__c,
                                                    SIR_prestamoDeudaCaixa__c, SIR_prestamoCuotaCaixa__c
                                                    FROM SIR_FormularioRefinanciacion__c WHERE Id =:idFormulario LIMIT 1];
                updateForm.SIR_deudaTotalGarantiaRealEnt__c          = decimal.valueOf(data[0]);
                updateForm.SIR_cuotaGarantiaRealEnt__c               = decimal.valueOf(data[1]);
                updateForm.SIR_deudaTotalGarantiaPersonalEnt__c      = decimal.valueOf(data[2]);
                updateForm.SIR_CuotaGarantiaPersonalEnt__c           = decimal.valueOf(data[3]);
                updateForm.SIR_deudaTotalTarjetaEnt__c               = decimal.valueOf(data[4]);
                updateForm.SIR_CuotaMensualTarjetasEnt__c            = decimal.valueOf(data[5]);        
                updateForm.SIR_deudaTotalEmpresasGrupoEnt__c         = decimal.valueOf(data[6]);
                updateForm.SIR_CuotaMensualEmpresasGrupoEnt__c       = decimal.valueOf(data[7]);
                updateForm.SIR_deudaTotalOtrosEnt__c                 = decimal.valueOf(data[8]);
                updateForm.SIR_CuotaMensualOtrosEnt__c               = decimal.valueOf(data[9]);
                updateForm.SIR_TotalDeudaOtraEntidad__c              = decimal.valueOf(data[10]);
                updateForm.SIR_TotalCuotaOtraEntidad__c              = decimal.valueOf(data[11]);
                updateForm.SIR_OtrosDatosInteresCargas__c            = data[12];
                updateForm.SIR_DeudaOperacionRefCaixa__c             = decimal.valueOf(data[13]);
                updateForm.SIR_CuotaOperacionRefCaixa__c             = decimal.valueOf(data[14]);
                updateForm.SIR_prestamoDeudaNoCaixa__c               = decimal.valueOf(data[15]);
                updateForm.SIR_DeudaOperacionRefNoCaixa__c           = decimal.valueOf(data[16]);
                updateForm.SIR_prestamoCuotaNoCaixa__c               = decimal.valueOf(data[17]);
                updateForm.SIR_CuotaOperacionRefNoCaixa__c           = decimal.valueOf(data[18]);
                updateForm.SIR_TotalDeudaRefNoCaixa__c               = decimal.valueOf(data[19]);
                updateForm.SIR_TotalCuotaRefNoCaixa__c               = decimal.valueOf(data[20]);
                updateForm.SIR_TotalDeudaRefCaixa__c                 = decimal.valueOf(data[21]);
                updateForm.SIR_TotalCuotaRefCaixa__c                 = decimal.valueOf(data[22]);
                // 10/02/2023 - Se añaden los campos que ahora son editables
                updateForm.SIR_deudaTotalGarantiaReal__c             = decimal.valueOf(data[23]);
                updateForm.SIR_cuotaGarantiaReal__c                  = decimal.valueOf(data[24]);
                updateForm.SIR_deudaTotalGarantiaPersonal__c         = decimal.valueOf(data[25]);
                updateForm.SIR_CuotaGarantiaPersonal__c              = decimal.valueOf(data[26]);
                updateForm.SIR_deudaTotalTarjeta__c                  = decimal.valueOf(data[27]);
                updateForm.SIR_CuotaMensualTarjetas__c               = decimal.valueOf(data[28]);
                updateForm.SIR_deudaTotalEmpresasGrupo__c            = decimal.valueOf(data[29]);
                updateForm.SIR_CuotaMensualEmpresasGrupo__c          = decimal.valueOf(data[30]);
                updateForm.SIR_deudaTotalOtros__c                    = decimal.valueOf(data[31]);
                updateForm.SIR_CuotaMensualOtros__c                  = decimal.valueOf(data[32]);
                updateForm.SIR_TotalDeudaCaixabank__c                = decimal.valueOf(data[33]);
                updateForm.SIR_TotalCuotaCaixabank__c                = decimal.valueOf(data[34]);
                updateForm.SIR_prestamoDeudaCaixa__c                 = decimal.valueOf(data[35]);
                updateForm.SIR_prestamoCuotaCaixa__c                 = decimal.valueOf(data[36]);
                update updateForm;
            }
            return 'OK';
        } catch (Exception e) {
            CBK_log.error(e, 'Error : Sir_lwc_CargasFinancieras - ' + e.getTypeName() + ': ' + e.getMessage());
            return 'Ha ocurrido un error: ' + e.getMessage();
        }
        
    }

    @AuraEnabled(Cacheable=true)
    public static string getCaluladoraLink(){
        try { 
            return SIR_LinksOperativosMCS__mdt.getInstance('Calculadora').SIR_Url2__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}