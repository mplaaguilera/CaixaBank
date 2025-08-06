/*****************************************************************
    Name:  SIR_WrapperEnviarFormulario
    Copyright © 2021  CaixaBank
    ============================================================
    Proposito:   WS0005 - Wrapper Enviar Formulario                                                                                                          
    ============================================================
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249675         Atmira         17/09/2021     	  Created    

    *****************************************************************/
public with sharing class SIR_WrapperEnviarFormulario {
     @AuraEnabled
     public String idProcesoGestion;          			// SIR_Proceso__r.SIREC__SIREC_fld_masterRecordId__c
     @AuraEnabled
     public Double totalRentasTrabajo;					// SIR_TotalIngresosTrabajo__c
     @AuraEnabled
     public Double totalRentasCapital;					// SIR_TotalIngresosBienes__c
	 @AuraEnabled
     public String numeroMiembrosUnidad { get; set; }   // SIR_MiembrosUnidadFamiliar__c
	 @AuraEnabled
     public Double ingresosAdicionalesUnidad;       	// SIR_IngresosAdicionalesUnidFam__c
	 @AuraEnabled
     public Double importeMinimoSubsistencia; 			// SIR_ImporteMinSubsistencia__c
	 @AuraEnabled
     public Double alquilerViviendaHabitual; 			// SIR_AlquilerViviendaHabitual__c
	 @AuraEnabled
     public Double pensionAlimenticia; 				    // SIR_PensionAlimenticia__c
	 @AuraEnabled
     public Double otrosGastos; 					    // SIR_Otros__c
	 @AuraEnabled
     public Double totalGastos; 						// SIR_TotalGastos__c
	 @AuraEnabled
     public String gastosComentario;					// SIR_JustificarOtrosGastos__c
	 @AuraEnabled
     public Double cargasDeudaTotalEntidad; 			// SIR_TotalDeudaCaixabank__c
	 @AuraEnabled
     public Double cargasCuotaMensualEntidad; 			// SIR_TotalCuotaCaixabank__c
	 @AuraEnabled
     public Double cargasDeudaTotalOtras; 				// SIR_TotalDeudaOtraEntidad__c
	 @AuraEnabled
     public Double cargasCuotaTotalOtras; 				// SIR_TotalCuotaOtraEntidad__c
	 @AuraEnabled
     public String cargasComentario; 					// SIR_OtrosDatosInteresCargas__c
	 @AuraEnabled
     public Double capacidadIngresosDisp; 				// SIR_capActualIngresosDisponibles__c
	 @AuraEnabled
     public Double capacidadGastosNeces; 				// SIR_capActualGastosNecesarios__c
	 @AuraEnabled
     public Double capacidadImpCuotasAct; 				// SIR_capActualImporteCuota__c
	 @AuraEnabled
     public Double capacidadPorcEndeudaAct; 			// SIR_capActualRatioEndeudamiento__c
	 @AuraEnabled
     public Double capacidadImpCuotasRefin; 			// SIR_capActualImporteFinanciacion__c
	 @AuraEnabled
     public Double capacidadPorcEndeudaTotal; 			// SIR_capActualRatioTotal__c
	 @AuraEnabled
     public Double capacidadPagoCliente; 				// SIR_capActualPagoCliente__C
	 @AuraEnabled
     public String capacidadIndViabilidad; 				// SIR_capActualTipoSolucion__c ?
	 @AuraEnabled
     public Double endeudaIngresosFuturos; 				// SIR_ingresosFuturo__c
     @AuraEnabled
     public Double endeudaImpCuotasActuales; 			// SIR_importeCuotaActual__c
     @AuraEnabled
     public Double endeudaRatioEndeudaFuturo; 			// SIR_ratioEndeudamientoFuturo__c
     @AuraEnabled
     public String endeudaComentario; 					// SIR_textIngresosFuturo__c
	 @AuraEnabled
     public String solucionComentario; 					// SIR_solucionDeudaAplicar__c
	 @AuraEnabled
     public String solucionOtrosDatos;					// SIR_textSolucionAplicar__c
	 @AuraEnabled
     public Double solucionRatioAdmision; 				// SIR_ratioAdmision__c
     @AuraEnabled
     public Double solucionRatioActual; 				// SIR_ratioActual__c
     @AuraEnabled
     public Double solucionRatioFuturo;					// SIR_ratioEndeudamientoFuturo__c
	 @AuraEnabled
     public List<String> codigoSolucion;  			    // SIR_solucionCortoPlazo__c OR SIR_SolucionFinalista__c OR SIR_solucionLargoPlazo__c
     @AuraEnabled
     public List<Double> idPersona;
     @AuraEnabled
     public List<String> profesion;
     @AuraEnabled
     public List<Double> ingresosActividad;
	 @AuraEnabled
     public List<String> bienes;
     @AuraEnabled
     public List<Double> ingresosBienes;
	 @AuraEnabled
     public List<String> codigoCarga;
	 @AuraEnabled
     public List<Double> deudaTotalEntidad;
     @AuraEnabled
     public List<Double> cuotaMensualEntidad;
	 @AuraEnabled
     public List<Double> deudaTotalOtras;
  	 @AuraEnabled
     public List<Double> cuotaMensualOtras;
}