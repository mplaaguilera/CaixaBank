/*****************************************************************
    Name:  SIR_SendFormulario_WS
    Copyright © 2021  CaixaBank
      
    Proposito:   WS0005 - Envio Formulario                                                                                                          
      
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249675         Atmira         17/09/2021     	  Created    

    *****************************************************************/
public with sharing class SIR_SendFormulario_WS {
 /***************************************************************** 
    Proposito:  Send Formulario                                                      
    Parameters: formularioId
    Returns: N/A                                                       
    
    Historial
    -------- 
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249675         Atmira         05/08/2021     	  Created    
    
    *****************************************************************/
    public static List<String> sendFormulario(String formularioId){
        String metodo = 'sendFormulario';
        List<String> lstResponse = new List<String>();

        SIR_WrapperEnviarFormulario wrapper = new SIR_WrapperEnviarFormulario();
        if(	SIR_FormularioRefinanciacion__c.SObjectType.getDescribe().isAccessible() && SIREC__SIREC_obj_informacionCliente__c.SObjectType.getDescribe().isAccessible() && SIR_IntervinienteFormulario__c.SObjectType.getDescribe().isAccessible()){
                      
            // Recuperamos los datos del formulario
            List<SIR_FormularioRefinanciacion__c> formulario = [SELECT id , SIR_Proceso__r.SIREC__SIREC_fld_masterRecordId__c, SIR_TotalIngresosTrabajo__c, SIR_TotalIngresosBienes__c,
                                                      SIR_MiembrosUnidadFamiliar__c, SIR_IngresosAdicionalesUnidFam__c, SIR_ImporteMinSubsistencia__c,  SIR_AlquilerViviendaHabitual__c,
                                                      SIR_PensionAlimenticia__c, SIR_Otros__c,  SIR_TotalGastos__c, SIR_JustificarOtrosGastos__c, SIR_TotalDeudaCaixabank__c, SIR_TotalCuotaCaixabank__c,
                                                      SIR_TotalDeudaOtraEntidad__c,  SIR_TotalCuotaOtraEntidad__c, SIR_OtrosDatosInteresCargas__c, SIR_capActualIngresosDisponibles__c, SIR_capActualGastosNecesarios__c,
                                                      SIR_capActualImporteCuota__c, SIR_capActualRatioEndeudamiento__c, SIR_capActualImporteFinanciacion__c, SIR_capActualRatioTotal__c, SIR_capActualPagoCliente__C,
                                                      SIR_capActualTipoSolucion__c, SIR_ingresosFuturo__c, SIR_importeCuotaActual__c, SIR_ratioEndeudamientoFuturo__c, SIR_textIngresosFuturo__c, SIR_solucionDeudaAplicar__c,
                                                      SIR_textSolucionAplicar__c, SIR_ratioAdmision__c, SIR_ratioActual__c, SIR_solucionCortoPlazo__c, SIR_SolucionFinalista__c, SIR_solucionLargoPlazo__c,
                                                      SIR_deudaTotalGarantiaReal__c, SIR_deudaTotalGarantiaPersonal__c, SIR_deudaTotalTarjeta__c, SIR_deudaTotalEmpresasGrupo__c, SIR_deudaTotalOtros__c, SIR_prestamoDeudaCaixa__c,
                                                      SIR_DeudaOperacionRefCaixa__c, SIR_cuotaGarantiaReal__c, SIR_CuotaGarantiaPersonal__c, SIR_CuotaMensualTarjetas__c, SIR_CuotaMensualEmpresasGrupo__c, SIR_CuotaMensualOtros__c,
                                                      SIR_prestamoCuotaCaixa__c, SIR_CuotaOperacionRefCaixa__c, SIR_deudaTotalGarantiaRealEnt__c, SIR_deudaTotalGarantiaPersonalEnt__c, SIR_deudaTotalTarjetaEnt__c, SIR_deudaTotalEmpresasGrupoEnt__c,
                                                      SIR_deudaTotalOtrosEnt__c, SIR_prestamoDeudaNoCaixa__c, SIR_DeudaOperacionRefNoCaixa__c, SIR_cuotaGarantiaRealEnt__c, SIR_CuotaGarantiaPersonalEnt__c, SIR_CuotaMensualTarjetasEnt__c,
                                                      SIR_CuotaMensualEmpresasGrupoEnt__c, SIR_CuotaMensualOtrosEnt__c, SIR_prestamoCuotaNoCaixa__c, SIR_CuotaOperacionRefNoCaixa__c
                                                      FROM SIR_FormularioRefinanciacion__c 
                                                      WHERE Id = :formularioId 
                                                      LIMIT 1];
            // Creamos las listas de datos dependientes del formulario para mandar a sirec
            List<String> codigoCarga        = new List<String> {'01','02','03','04','05','06','07'};
            List<Double> deudaTotalEntidad  = new List<Double>();
            List<Double> cuotaTotalEntidad  = new List<Double>();
            List<Double> deudaTotalOtras    = new List<Double>();
            List<Double> cuotaMensualOtras  = new List<Double>();
            List<String> listCodigoSolucion = new List<String>();
            // Agregamos los valores del formulario a la lista
            for(SIR_FormularioRefinanciacion__c item : formulario){
                // Campos correspondientes a Deuda Total Entidad
                deudaTotalEntidad.add(checkFieldDouble(double.valueof(item.SIR_deudaTotalGarantiaReal__c)));
                deudaTotalEntidad.add(checkFieldDouble(double.valueof(item.SIR_deudaTotalGarantiaPersonal__c)));
                deudaTotalEntidad.add(checkFieldDouble(double.valueof(item.SIR_deudaTotalTarjeta__c)));
                deudaTotalEntidad.add(checkFieldDouble(double.valueof(item.SIR_deudaTotalEmpresasGrupo__c)));
                deudaTotalEntidad.add(checkFieldDouble(double.valueof(item.SIR_deudaTotalOtros__c)));
                deudaTotalEntidad.add(checkFieldDouble(double.valueof(item.SIR_prestamoDeudaCaixa__c)));
                deudaTotalEntidad.add(checkFieldDouble(double.valueof(item.SIR_DeudaOperacionRefCaixa__c)));

                // Campos correspondientes a Cuota Total Entidad
                cuotaTotalEntidad.add(checkFieldDouble(double.valueof(item.SIR_cuotaGarantiaReal__c)));
                cuotaTotalEntidad.add(checkFieldDouble(double.valueof(item.SIR_CuotaGarantiaPersonal__c)));
                cuotaTotalEntidad.add(checkFieldDouble(double.valueof(item.SIR_CuotaMensualTarjetas__c)));
                cuotaTotalEntidad.add(checkFieldDouble(double.valueof(item.SIR_CuotaMensualEmpresasGrupo__c)));
                cuotaTotalEntidad.add(checkFieldDouble(double.valueof(item.SIR_CuotaMensualOtros__c)));
                cuotaTotalEntidad.add(checkFieldDouble(double.valueof(item.SIR_prestamoCuotaCaixa__c)));
                cuotaTotalEntidad.add(checkFieldDouble(double.valueof(item.SIR_CuotaOperacionRefCaixa__c)));

                // Campos correspondientes a Deuda Total Otras Entidad
                deudaTotalOtras.add(checkFieldDouble(double.valueof(item.SIR_deudaTotalGarantiaRealEnt__c)));
                deudaTotalOtras.add(checkFieldDouble(double.valueof(item.SIR_deudaTotalGarantiaPersonalEnt__c)));
                deudaTotalOtras.add(checkFieldDouble(double.valueof(item.SIR_deudaTotalTarjetaEnt__c)));
                deudaTotalOtras.add(checkFieldDouble(double.valueof(item.SIR_deudaTotalEmpresasGrupoEnt__c)));
                deudaTotalOtras.add(checkFieldDouble(double.valueof(item.SIR_deudaTotalOtrosEnt__c)));
                deudaTotalOtras.add(checkFieldDouble(double.valueof(item.SIR_prestamoDeudaNoCaixa__c)));
                deudaTotalOtras.add(checkFieldDouble(double.valueof(item.SIR_DeudaOperacionRefNoCaixa__c)));
                
                // Campos correspondientes a Cuota Total Otras Entidad
                cuotaMensualOtras.add(checkFieldDouble(double.valueof(item.SIR_cuotaGarantiaRealEnt__c)));
                cuotaMensualOtras.add(checkFieldDouble(double.valueof(item.SIR_CuotaGarantiaPersonalEnt__c)));
                cuotaMensualOtras.add(checkFieldDouble(double.valueof(item.SIR_CuotaMensualTarjetasEnt__c)));
                cuotaMensualOtras.add(checkFieldDouble(double.valueof(item.SIR_CuotaMensualEmpresasGrupoEnt__c)));
                cuotaMensualOtras.add(checkFieldDouble(double.valueof(item.SIR_CuotaMensualOtrosEnt__c)));
                cuotaMensualOtras.add(checkFieldDouble(double.valueof(item.SIR_prestamoCuotaNoCaixa__c)));
                cuotaMensualOtras.add(checkFieldDouble(double.valueof(item.SIR_CuotaOperacionRefNoCaixa__c)));
                
                // rellenamos el wrapper con las listas rellenas de datos 
                wrapper.codigoCarga         = codigoCarga;
                wrapper.deudaTotalEntidad   = deudaTotalEntidad;
                wrapper.cuotaMensualEntidad = cuotaTotalEntidad;
                wrapper.deudaTotalOtras     = deudaTotalOtras;
                wrapper.cuotaMensualOtras   = cuotaMensualOtras;

                // Otros campos de mapeo del wrapper 

                wrapper.idProcesoGestion            = item.SIR_Proceso__r.SIREC__SIREC_fld_masterRecordId__c;
                wrapper.totalRentasTrabajo          = checkFieldDouble(double.valueof(item.SIR_TotalIngresosTrabajo__c));
                wrapper.totalRentasCapital          = checkFieldDouble(double.valueof(item.SIR_TotalIngresosBienes__c));
                wrapper.numeroMiembrosUnidad        = checkFieldString(item.SIR_MiembrosUnidadFamiliar__c);
                wrapper.ingresosAdicionalesUnidad   = checkFieldDouble(double.valueof(item.SIR_IngresosAdicionalesUnidFam__c));
                wrapper.importeMinimoSubsistencia   = checkFieldDouble(double.valueof(item.SIR_ImporteMinSubsistencia__c));
                wrapper.alquilerViviendaHabitual    = checkFieldDouble(double.valueof(item.SIR_AlquilerViviendaHabitual__c));
                wrapper.pensionAlimenticia          = checkFieldDouble(double.valueof(item.SIR_PensionAlimenticia__c));
                wrapper.otrosGastos                 = checkFieldDouble(double.valueof(item.SIR_Otros__c));
                wrapper.totalGastos                 = checkFieldDouble(double.valueof(item.SIR_TotalGastos__c));
                wrapper.gastosComentario            = checkFieldString(item.SIR_JustificarOtrosGastos__c);
                wrapper.cargasDeudaTotalEntidad     = checkFieldDouble(double.valueof(item.SIR_TotalDeudaCaixabank__c));
                wrapper.cargasCuotaMensualEntidad   = checkFieldDouble(double.valueof(item.SIR_TotalCuotaCaixabank__c));
                wrapper.cargasDeudaTotalOtras       = checkFieldDouble(double.valueof(item.SIR_TotalDeudaOtraEntidad__c));
                wrapper.cargasCuotaTotalOtras       = checkFieldDouble(double.valueof(item.SIR_TotalCuotaOtraEntidad__c));
                wrapper.cargasComentario            = checkFieldString(item.SIR_OtrosDatosInteresCargas__c);
                wrapper.capacidadIngresosDisp       = checkFieldDouble(double.valueof(item.SIR_capActualIngresosDisponibles__c));
                wrapper.capacidadGastosNeces        = checkFieldDouble(double.valueof(item.SIR_capActualGastosNecesarios__c));
                wrapper.capacidadImpCuotasAct       = checkFieldDouble(double.valueof(item.SIR_capActualImporteCuota__c));
                wrapper.capacidadPorcEndeudaAct     = checkFieldDouble(double.valueof(item.SIR_capActualRatioEndeudamiento__c));
                wrapper.capacidadImpCuotasRefin     = checkFieldDouble(double.valueof(item.SIR_capActualImporteFinanciacion__c));
                wrapper.capacidadPorcEndeudaTotal   = checkFieldDouble(double.valueof(item.SIR_capActualRatioTotal__c));
                wrapper.capacidadPagoCliente        = checkFieldDouble(double.valueof(item.SIR_capActualPagoCliente__c));
                wrapper.capacidadIndViabilidad      = checkFieldString(item.SIR_capActualTipoSolucion__c);
                wrapper.endeudaIngresosFuturos      = checkFieldDouble(double.valueof(item.SIR_ingresosFuturo__c));
                wrapper.endeudaImpCuotasActuales    = checkFieldDouble(double.valueof(item.SIR_importeCuotaActual__c));
                wrapper.endeudaRatioEndeudaFuturo   = checkFieldDouble(double.valueof(item.SIR_ratioEndeudamientoFuturo__c));
                wrapper.endeudaComentario           = checkFieldString(item.SIR_textIngresosFuturo__c);
                wrapper.solucionComentario          = checkFieldString(item.SIR_solucionDeudaAplicar__c);
                wrapper.solucionOtrosDatos          = checkFieldString(item.SIR_textSolucionAplicar__c);
                wrapper.solucionRatioAdmision       = checkFieldDouble(double.valueof(item.SIR_ratioAdmision__c));
                wrapper.solucionRatioActual         = checkFieldDouble(double.valueof(item.SIR_ratioActual__c));
                wrapper.solucionRatioFuturo         = checkFieldDouble(double.valueof(item.SIR_ratioEndeudamientoFuturo__c));
                // Añadimos los diferentes codigos solucion CodigoSolucion
                if(item.SIR_solucionCortoPlazo__c != null){
                    listCodigoSolucion.add(item.SIR_solucionCortoPlazo__c);
                }
                if(item.SIR_SolucionFinalista__c != null){
                    listCodigoSolucion.add(item.SIR_SolucionFinalista__c);
                }
                if(item.SIR_solucionLargoPlazo__c != null){
                    listCodigoSolucion.add(item.SIR_solucionLargoPlazo__c);
                }
                // añado los codigos solucion al wrapper
                wrapper.codigoSolucion               = listCodigoSolucion;
            }
            // Recuperamos los datos de los intervinientes asociados al formulario.
            List<SIR_IntervinienteFormulario__c> intervinientes = [SELECT Id, SIR_Relacion__c, SIR_Cliente__r.Name, SIR_Cliente__c, SIR_Profesion__c, SIR_IngresosTrabajo__c, SIR_Bienes__c, SIR_IngresosBienes__c
                                                                   FROM SIR_IntervinienteFormulario__c
                                                                   WHERE SIR_FormularioRefinanciacion__c =: formularioId AND SIR_Relacion__c != 'B'
                                                                   LIMIT 50000];
            // Creamos una lista de Id para recuperar los ListIdPersonas
            List<Id> listId = new List<Id>();
            // Creamos las listas de datos de los intervinientes que enviaremos a sirec
            List<Integer> listIdPersonas    = new List<Integer>(); 
            List<String> profesion          = new List<String> ();
            List<Double> ingresosActividad  = new List<Double>();
            List<String> bienes             = new List<String> ();
            List<Double> ingresosBienes     = new List<Double>();

            // Recorremos los intervinientes para formar las listas que enviaremos a sirec
            for(SIR_IntervinienteFormulario__c item : intervinientes){
                // Rellenamos los Id personas 
                listId.add(item.SIR_Cliente__c);
                // Relleamos los siguientes valores que enviaremos a SIREC
                // Miramos si el campo SIR_Profesion__c tiene mas de 25 caracteres en caso de que tenga mas se corta.
                if(item.SIR_Profesion__c != '' && item.SIR_Profesion__c.length() > 25){
                    profesion.add(item.SIR_Profesion__c.substring(0, 24));
                } else {
                    profesion.add(item.SIR_Profesion__c);
                }             
                ingresosActividad.add(checkFieldDouble(double.valueof(item.SIR_IngresosTrabajo__c)));
                bienes.add(item.SIR_Bienes__c);
                ingresosBienes.add(checkFieldDouble(double.valueof(item.SIR_IngresosBienes__c)));

            }
            // Rellenamos los datos de las listas de intervinientes en el wrapper 
            wrapper.ingresosBienes         = ingresosBienes;
            wrapper.bienes                 = bienes;
            wrapper.ingresosActividad      = ingresosActividad;
            wrapper.profesion              = profesion;

            // Recuperamos los idPersonas 
            List<SIREC__SIREC_obj_informacionCliente__c> lstPersonaProceso = [SELECT  SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_masterRecordId__c
                                                                                FROM SIREC__SIREC_obj_informacionCliente__c
                                                                                WHERE SIREC__SIREC_fld_cliente__c IN : listId];
            for (SIREC__SIREC_obj_informacionCliente__c personaProceso : lstPersonaProceso){
                listIdPersonas.add(integer.valueOf(personaProceso.SIREC__SIREC_fld_masterRecordId__c));
            }
            // Asignamos la lista de IdPersonas
            wrapper.idPersona              = listIdPersonas;
            if(SIR_WS_Configuration__mdt.getInstance('SendFormulario').SIR_fld_isActive__c ){
                if(wrapper != null){
                    Map<String,string> mHeaders =  new  Map<String,string>();
                    mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
                    String body = JSON.serialize(wrapper);
                    try {
                        // Framework Integration
                        HttpRequest req = CBK_HttpServiceIntegration.getRequest(body, 'updateFormRefinanciacion', 'POST', mHeaders);
                        HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req);
                        if(res.getStatusCode() == 200){
                            FormularioResponse resp = (FormularioResponse)JSon.deserialize(res.getBody(), FormularioResponse.class);        
                            if( resp.codigoSalida == '1'){
                                lstResponse.add('OK');
                            }else{
                                lstResponse = SIR_cls_WS_Wrapper.responseError(res.getStatusCode(),resp.errorResponseDto);
                                List<SObject> lstobjects = new List<SObject>();
                                lstobjects.addall(formulario);
                                lstobjects.addall(intervinientes);
                                lstobjects.addall(lstPersonaProceso);
                                CBK_log.error(lstResponse.toString(), lstobjects);
                            }
                        }
                        else{
                            lstResponse = SIR_cls_WS_Wrapper.responseError(res.getStatusCode(),null);
                            List<SObject> lstobjects = new List<SObject>();
                            lstobjects.addall(formulario);
                            lstobjects.addall(intervinientes);
                            lstobjects.addall(lstPersonaProceso);
                            CBK_log.error(lstResponse.toString(), lstobjects);
                        }
                    } catch (Exception ex) {
                        List<SObject> lstobjects = new List<SObject>();
                        lstobjects.addall(formulario);
                        lstobjects.addall(intervinientes);
                        lstobjects.addall(lstPersonaProceso);
                        CBK_log.error(ex, 'Error : SIR_SendFormulario_WS - ' + ex.getTypeName() + ': ' + ex.getMessage(), lstobjects);
                    }
                }
                return lstResponse;
            }else{
                lstResponse.add('KO');
                lstResponse.add('El interface de envio de formulario está desactivado');
                lstResponse.add('');
                return lstResponse;
            }
        }
        lstResponse.add('KO');
        lstResponse.add('No tiene permisos para poder enviar este formulario');
        lstResponse.add('');
        return lstResponse;
    }
    /***************************************************************** 
    Proposito:  Response Formulario                                                      
    Parameters: formularioId
    Returns: N/A                                                       
    
    Historial
    -------- 
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249675         Atmira         05/08/2021     	  Created    
    
    *****************************************************************/
    public class FormularioResponse{
        public String codigoSalida;
        public SIR_cls_WS_Wrapper.ErrorResponseDto errorResponseDto;
    }
    /***************************************************************** 
    Proposito:  Check campos String Formulario                                                      
    Parameters: formularioId
    Returns: N/A                                                       
    
    Historial
    -------- 
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249675         Atmira         05/08/2021     	  Created    
    
    *****************************************************************/
    public static String checkFieldString (String campoString){
        String valor = '';

        if(campoString != null){
            valor = campoString;
        }
        return valor;
    }
    /***************************************************************** 
    Proposito:  Check Campos Double Formulario                                                      
    Parameters: formularioId
    Returns: N/A                                                       
    
    Historial
    -------- 
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249675         Atmira         05/08/2021     	  Created    
    
    *****************************************************************/
    public static Double checkFieldDouble (Double campoDouble){
        
        Double valor = 0;

        if(campoDouble != null){
            valor = campoDouble;
        }
        return valor;
    }
}