/*****************************************************************
 Name:  SIR_LCMP_EnviarFormulario
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase controladora externa del LWC Sir_lwc_EnviarFormulario                                                                                                                 
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249675         Atmira         05/08/2021     	 Created    

*****************************************************************/
public with sharing class SIR_LCMP_EnviarFormulario {

    
    /*****************************************************************
        Proposito:  Realizamos query para buscar todos los procesos del cliente                                                      
        Parameters: String idFormulario
        Returns: String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249675         Atmira         05/08/2021     	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static String comprobarCampos(String idFormulario){
        if(SIR_FormularioRefinanciacion__c.SObjectType.getDescribe().isAccessible()){
            List<SIR_FormularioRefinanciacion__c> formulario = [SELECT id, SIR_TotalIngresosTrabajo__c, SIR_TotalIngresosBienes__c, SIR_OtrosDatosInteres__c,
                                                                SIR_MiembrosUnidadFamiliar__c, SIR_IngresosAdicionalesUnidFam__c, SIR_ImporteMinSubsistencia__c, 
                                                                SIR_AlquilerViviendaHabitual__c, SIR_PensionAlimenticia__c, SIR_Otros__c, SIR_TotalGastos__c, 
                                                                SIR_JustificarOtrosGastos__c, SIR_deudaTotalGarantiaReal__c, SIR_deudaTotalGarantiaPersonal__c, 
                                                                SIR_deudaTotalTarjeta__c, SIR_deudaTotalEmpresasGrupo__c, SIR_deudaTotalOtros__c, 
                                                                SIR_cuotaGarantiaReal__c, SIR_CuotaGarantiaPersonal__c, SIR_CuotaMensualTarjetas__c, 
                                                                SIR_CuotaMensualEmpresasGrupo__c, SIR_CuotaMensualOtros__c, SIR_deudaTotalGarantiaRealEnt__c, 
                                                                SIR_deudaTotalGarantiaPersonalEnt__c, SIR_deudaTotalTarjetaEnt__c, SIR_deudaTotalEmpresasGrupoEnt__c, 
                                                                SIR_deudaTotalOtrosEnt__c, SIR_cuotaGarantiaRealEnt__c, SIR_CuotaGarantiaPersonalEnt__c, 
                                                                SIR_CuotaMensualTarjetasEnt__c, SIR_CuotaMensualEmpresasGrupoEnt__c, SIR_CuotaMensualOtrosEnt__c, 
                                                                SIR_TotalDeudaCaixabank__c, SIR_TotalCuotaCaixabank__c, SIR_TotalDeudaOtraEntidad__c, 
                                                                SIR_TotalCuotaOtraEntidad__c, SIR_prestamoDeudaCaixa__c, SIR_prestamoCuotaCaixa__c, 
                                                                SIR_prestamoDeudaNoCaixa__c, SIR_prestamoCuotaNoCaixa__c, SIR_DeudaOperacionRefCaixa__c, 
                                                                SIR_CuotaOperacionRefCaixa__c, SIR_DeudaOperacionRefNoCaixa__c, SIR_CuotaOperacionRefNoCaixa__c, 
                                                                SIR_TotalDeudaRefCaixa__c, SIR_TotalCuotaRefCaixa__c, SIR_TotalDeudaRefNoCaixa__c, 
                                                                SIR_TotalCuotaRefNoCaixa__c, SIR_OtrosDatosInteresCargas__c, SIR_capActualImporteCuota__c, 
                                                                SIR_capActualRatioEndeudamiento__c, SIR_SolucionFinalista__c, SIR_capActualImporteFinanciacion__c, 
                                                                SIR_capActualRatioTotal__c, SIR_capActualPagoCliente__c, SIR_ingresosFuturo__c, 
                                                                SIR_ratioEndeudamientoFuturo__c, SIR_importeCuotaActual__c, SIR_textIngresosFuturo__c, 
                                                                SIR_ratioAdmision__c, SIR_ratioActual__c, SIR_ratioFuturo__c, SIR_tipoDificultad__c, 
                                                                SIR_solucionAplicar__c, SIR_solucionCortoPlazo__c, SIR_solucionLargoPlazo__c, 
                                                                SIR_capacidadDevolucion__c, SIR_cargaFinancieraCaixa__c, SIR_solucionDeuda__c,
                                                                SIR_Proceso__r.OwnerId
                                                                FROM SIR_FormularioRefinanciacion__c WHERE id=:idFormulario];  
            if(UserInfo.getUserId() == formulario[0].SIR_Proceso__r.OwnerId){      
                String resultado = '';        
                if(formulario[0].SIR_MiembrosUnidadFamiliar__c == null){
                    resultado = resultado + '- El campo "Miembros unidad familiar" (Gastos Intervinientes) es obligatorio.</br>';
                }
                if(formulario[0].SIR_CuotaOperacionRefCaixa__c == 0 || formulario[0].SIR_CuotaOperacionRefCaixa__c == null){
                    resultado = resultado + '- El campo "Operación de refinanciación cuota Caixa" (Cargas financieras) es obligatorio.</br>';
                } 
                if(formulario[0].SIR_DeudaOperacionRefCaixa__c == 0 || formulario[0].SIR_DeudaOperacionRefCaixa__c == null){
                    resultado = resultado + '- El campo "Operación de refinanciación deuda Caixa" (Cargas financieras) es obligatorio.</br>';
                }
                if(formulario[0].SIR_ingresosFuturo__c == 0 || formulario[0].SIR_ingresosFuturo__c == null){
                    resultado = resultado + '- El campo "Ingresos disponibles futuro" (Capacidad y solución) es obligatorio.</br>';
                }
                if(resultado == ''){           
                    return 'OK';
                    
                } else {
                    // Hay algun campo obligatorio no informado, por lo que devolvemos la variable con el mensaje de que campo concreto es.
                    return resultado;
                }
            }else{
                return 'No puede enviar un formulario de refinanciación del que No es propietario.';
            }
        } return ''; 
    }


    /*****************************************************************
        Proposito:  Realizamos la logica para enviar el proceso                                                      
        Parameters: String idFormulario
        Returns: String []                                                     
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249675         Atmira         05/08/2021     	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static String[] enviarProceso(String idFormulario){
        // Estan todos los campos obligatorios bien informados, se puede llamar al WS
        String[] resultado = new String[]{''}; 
        if(SIR_FormularioRefinanciacion__c.SObjectType.getDescribe().isAccessible() 
            && SIR_IntervinienteFormulario__c.SObjectType.getDescribe().isAccessible()
            && SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible() ){
            // Comprobamos si disponemos de ID_PROCESO_SIREC (SIREC__SIREC_fld_masterRecordId__c) para determinar si enviamos o no el Proceso primero antes que el Formulario
            SIR_FormularioRefinanciacion__c formulario = [SELECT SIR_Proceso__c, SIR_Proceso__r.SIREC__SIREC_fld_masterRecordId__c
                                                          FROM SIR_FormularioRefinanciacion__c WHERE id=:idFormulario LIMIT 1];
            String[] resultadoWS;
            String idProcesoSirec;
            if(String.isEmpty(formulario.SIR_Proceso__r.SIREC__SIREC_fld_masterRecordId__c)){
                // Enviamos el Proceso
                 resultadoWS = SIR_cls_WS_altaProcRefinanciacion.altaProcRefinanciacion(formulario.SIR_Proceso__c);
                if(resultadoWS.size() > 0){
                    if(resultadoWS[0] == 'OK'){
                        idProcesoSirec = resultadoWS[1];
                    } else {
                        return resultadoWS;
                    }
                }                
            } 
            if(!String.isEmpty(formulario.SIR_Proceso__r.SIREC__SIREC_fld_masterRecordId__c) || !String.isEmpty(idProcesoSirec)){
                // Modificamos el proceso
                String resultadoUpdateProceso = updateProceso(formulario.SIR_Proceso__c, idProcesoSirec);
                if(resultadoUpdateProceso != 'OK'){
                    resultado[1] = resultadoUpdateProceso;
                    return resultado;  
                }    
            } 
            resultado[0] = 'OK';                  
            return resultado;             
        }   
        return resultado;    
    }
        
    
    /*****************************************************************
        Proposito:  Realizamos la logica para enviar el formulario a SIREC                                                     
        Parameters: String idFormulario
        Returns: String []                                                      
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249675         Atmira         05/08/2021     	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static String[] enviarForm(String idFormulario){
        // Ya se ha enviado el WS de Proceso, por lo que podemos enviar el WS de Formulario
        String[] resultado = new String[]{''}; 
        if(SIR_FormularioRefinanciacion__c.SObjectType.getDescribe().isAccessible() 
            && SIR_IntervinienteFormulario__c.SObjectType.getDescribe().isAccessible()){            
            String[] resultadoWS;
            // Enviamos el Formulario
            resultadoWS = SIR_SendFormulario_WS.sendFormulario(idFormulario);
            if(resultadoWS.size() > 0){
                if(resultadoWS[0] == 'OK'){                        
                    // Modificamos el formulario
                    String resultadoUpdateFormulario = updateFormulario(idFormulario, 'OK'); 
                    if(resultadoUpdateFormulario != 'OK'){
                        resultado[1] = resultadoUpdateFormulario;
                        return resultado;  
                    }          
                    resultado[0] = 'OK';                  
                    return resultado; 
                } else {
                    String resultadoUpdateFormulario = updateFormulario(idFormulario, 'KO'); 
                    if(resultadoUpdateFormulario != 'OK'){
                        resultado[1] = resultadoUpdateFormulario;
                        return resultado;  
                    }    
                    return resultadoWS;
                }
            }   
        }
        return resultado;    
    }   
        
    
    /*****************************************************************
        Proposito:  Realizamos query para buscar todos los intervinientes formulario del formulario                                                      
        Parameters: String idFormulario
        Returns: List<SIR_IntervinienteFormulario__c>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249675         Atmira         06/08/2021     	  Created    
        
	*****************************************************************/
    public static List<SIR_IntervinienteFormulario__c> getIntervinientesFormulario(String idFormulario){
        List<SIR_IntervinienteFormulario__c> interFormulario = [SELECT id, SIR_Bienes__c, SIR_IngresosBienes__c, SIR_IngresosTrabajo__c
                                                                FROM SIR_IntervinienteFormulario__c WHERE SIR_FormularioRefinanciacion__c =: idFormulario];
        return interFormulario;
    }
    
    
    /*****************************************************************
        Proposito:  Modificamos el estado del formulario                                                      
        Parameters: String idFormulario
        Returns: List<SIR_IntervinienteFormulario__c>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249675         Atmira         06/08/2021     	  Created    
        
	*****************************************************************/
    public static String updateFormulario(String idFormulario, String resultadoWS){
        try {
            if(SIR_FormularioRefinanciacion__c.SObjectType.getDescribe().isUpdateable()){
                SIR_FormularioRefinanciacion__c formUpdate = [SELECT SIR_Estado__c FROM SIR_FormularioRefinanciacion__c WHERE id=:idFormulario LIMIT 1];                
                if(resultadoWS == 'OK'){
                    formUpdate.SIR_Estado__c = SIR_Constantes.FORMULARIOREFINANCIACION_ESTADO_ENVIADO; 
                } else {
                    formUpdate.SIR_Estado__c = SIR_Constantes.FORMULARIOREFINANCIACION_ESTADO_PENDIENTE_ENVIO;
                }               
                update formUpdate;
                // Devolvemos un OK para mostrar en Front que todo ha ido bien.
                return 'OK';
            }
        } catch (Exception e) {
            CBK_log.error(e, 'Error : SIR_LCMP_EnviarFormulario - ' + e.getTypeName() + ': ' + e.getMessage());
            return 'Ha ocurrido un error: ' + e.getMessage();
        } 
        return '';
    }    
    
    
    /*****************************************************************
        Proposito:  Cambiamos el campo Situacion de Proceso                                                      
        Parameters: 
        Returns: String                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249675         Atmira         06/08/2021     	  Created    
        
	*****************************************************************/
    public static String updateProceso(String idProceso, String idProcesoSirec){
        try {
            if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isUpdateable()){
                SIREC__SIREC_obj_proceso__c procesoUpdate = [SELECT SIREC__SIREC_fld_situacion__c, SIR_fld_Situacion_SF__c FROM SIREC__SIREC_obj_proceso__c WHERE id=:idProceso LIMIT 1];                
                procesoUpdate.SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_REFINANCIACION;
                procesoUpdate.SIR_fld_Situacion_SF__c = SIR_Constantes.PROCESO_SITUACION_REFINANCIACION;
                if(!String.isEmpty(idProcesoSirec)){
                    procesoUpdate.SIREC__SIREC_fld_masterRecordId__c = idProcesoSirec;
                }                
                update procesoUpdate;
                // Devolvemos un OK para mostrar en Front que todo ha ido bien.
                return 'OK';
            }
        } catch (Exception e) {
            CBK_log.error(e, 'Error : SIR_LCMP_EnviarFormulario - ' + e.getTypeName() + ': ' + e.getMessage());
            return 'Ha ocurrido un error: ' + e.getMessage();
        } 
        return '';
    }    
    
}