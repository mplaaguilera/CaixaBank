import {LightningElement, api, wire, track} from 'lwc';
import generaDocumento from '@salesforce/apex/GestorDocumentalController.generaDocumento';
import obtenerPlantillas from '@salesforce/apex/GestorDocumentalController.obtenerPlantillas';
import getCamposPlantilla from '@salesforce/apex/GestorDocumentalController.obtenerCamposPlantilla';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import TIEMPO_ESPERA from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Tiempo_Espera__c';
import IDIOMA from '@salesforce/schema/Case.CC_Idioma__c';
import TONO_IRRESPETUOSO from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Tono_Irrespetuoso__c';
import CONTACTO_CLIENTE from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Contacto_Cliente__c';
import INTERVENCION_FUERZAS_SEGURIDAD from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Intervencion_Fuerzas_Seguridad__c';
import ALL_IN_ONE from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_All_In_One__c';
import SEXO from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Sexo__c';
import CAMBIO_OFICINA from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Cambio_Oficina__c';
import FALTA_ENTREGA from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Falta_Entrega__c';
import FRAUDE from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Fraude__c';
import MOVIMIENTO_CUENTA from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Movimiento_En_Cuenta__c';
import USUARIO_NOW from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Usuario_Now__c';
import CUENTA_A_MI_NOMBRE from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Cuenta_A_Mi_Nombre__c';
import RESPUESTA_CLIENTE from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Respuesta_Cliente__c';

/////////////
import SOLICITUD from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Solicitud__c';
import SOLICITUD_DOCUMENTACION from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Solicitud_Documentacion__c';
import INFORMACION_DOCUMENTACION_ADICIONAL from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Informacion_Documentacion_Adicional__c';
import HELLO_LETTER from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Hello_Letter__c';
import CODIGO_PRESTAMO from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Codigo_Prestamo__c';
import FECHA_FINAL_CALCULO from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Fecha_Final_Calculo__c';
import CUADRO_AMORTIZACION from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Cuadro_amortizacion__c';
import PARTE_DOCUMENTACION from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Parte_Documentacion__c';
import DOCUMENTACION_ADICIONAL from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Documentacion_Adicional__c';
import DOCUMENTACION_NO_LOCALIZADA from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Documentacion_No_Localizada__c';
import DOCUMENTACION_NO_LOCALIZADA_CLIENTE from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Documentacion_No_Localizada_Cliente__c';
import TASACION_INMUEBLE_HIPOTECADO from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Tasacion_Inmueble_Hipotecado__c';
import PRESTAMO_TITULIZADO from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Prestamo_Titulizado__c';
import PRESTAMO_VENDIDO_TERCERO from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Prestamo_Vendido_Tercero__c';
import SOLICITUD_FACTURAS_GASTOS from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Solicitud_Facturas_Gastos__c';
import CONTRATO_TARJETA_CLIENTE from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Contrato_Tarjeta_Cliente__c';
import EXTRACTOS_LIQUIDACION from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Extractos_Liquidacion__c';
import COPIA_PARCIAL_ESCRITURA from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Copia_Parcial_Escritura__c';
import DETALLE_INFORMACION_ENVIAR from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Detalle_Informacion_Enviar__c';
import NO_LOCALIZA_CONTRATO_CUENTA from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_No_Localiza_Contrato_Cuenta__c';

import QUEJA_COBRO_TARIFA_TELEFONICA from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Queja_Cobro_Tarifa_Telefonica__c';
import SOLICITUD_INFO_PRESTAMO from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Solicitud_Info_Prestamo__c';
import QUEJA_LIMPIEZA from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Queja_Limpieza__c';
import QUEJA_PERSONA_SIN_HOGAR from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Queja_Persona_Sin_Hogar__c';
import CIERRE_RECINTO_CAJERO from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Cierre_Recinto_Cajero__c';

import SOLICITUD_INFORMACION_REQUISITOS from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Solicitud_Informacion_Requisitos__c';
import SOLICITUD_INFORMACION_APORTAR from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Solicitud_Informacion_Aportar__c';
import INFORMACION_CONDICIONES_FINANCIACION from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Informacion_Condiciones_Financiacion__c';
import OFRECIO_SOLUCIONES_REFINANCIACION from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Ofrecio_Soluciones_Refinanciacion__c';



////////////////

import BLOQUEO_RETENCION_SALDO from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Bloqueo_Retencion_Saldo__c';
import SOLICITUD_CANCELACION_SEGURO from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Solicitud_Cancelacion_Seguro__c';
import SOLICITUD_CANCELACION_CONTRATOS from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Solicitud_Cancelacion_Contratos__c';
import SOLICITUD_TESTAMENTARIA from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Solicitud_Testamentaria__c';

import CONTESTAR_RESPUESTA_CLIENTE from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Contestar_Respuesta_Cliente__c';
import INDICAR_GASTOS from '@salesforce/schema/Case.CC_Gestor_Documental__r.CC_Indicar_Gastos__c';
import ID_DOC from '@salesforce/schema/Case.CC_Gestor_Documental__c';
import DOC_NAME from '@salesforce/schema/Case.CC_MCC_Motivo__r.CC_Id_SDOC_Plantilla__c';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class Cc_LCMP_Gestor_Documental extends LightningElement {
	@api recordId;

	@track CC_Tiempo_Espera__c = '';

	@track CC_Tono_Irrespetuoso__c = '';

	@track CC_Solicitud_Cancelacion_Seguro__c = '';

	@track CC_Solicitud_Cancelacion_Contratos__c = '';

	@track CC_Solicitud_Testamentaria__c = '';

	@track CC_Contacto_Cliente__c = '';

	@track CC_Intervencion_Fuerzas_Seguridad__c = '';

	@track CC_All_In_One__c = '';

	@track CC_Usuario_Now__c = '';

	@track CC_Cambio_Oficina__c = '';

	@track CC_Falta_Entrega__c = '';

	@track CC_Sexo__c = '';

	@track CC_Bloqueo_Retencion_Saldo__c = '';

	@track CC_Fraude__c = '';

	@track CC_Movimiento_En_Cuenta__c = '';

	@track CC_Cuenta_A_Mi_Nombre__c = '';

	@track CC_Respuesta_Cliente__c = '';

	@track CC_Contestar_Respuesta_Cliente__c = '';

	@track CC_Indicar_Gastos__c = '';

	@track CC_Solicitud__c = '';

	@track CC_Solicitud_Documentacion__c = '';

	@track CC_Informacion_Documentacion_Adicional__c = '';

	@track CC_Hello_Letter__c = '';

	@track CC_Codigo_Prestamo__c = '';

	@track CC_Fecha_Final_Calculo__c = '';

	@track CC_Cuadro_amortizacion__c = '';

	@track CC_Parte_Documentacion__c = '';

	@track CC_Documentacion_Adicional__c = '';

	@track CC_Documentacion_No_Localizada__c = '';

	@track CC_Documentacion_No_Localizada_Cliente__c = '';

	@track CC_Tasacion_Inmueble_Hipotecado__c = '';

	@track CC_Prestamo_Titulizado__c = '';

	@track CC_Prestamo_Vendido_Tercero__c = '';

	@track CC_Solicitud_Facturas_Gastos__c = '';

	@track CC_Contrato_Tarjeta_Cliente__c = '';

	@track CC_Extractos_Liquidacion__c = '';

	@track CC_Copia_Parcial_Escritura__c = '';

	@track CC_Detalle_Informacion_Enviar__c = '';

	@track CC_No_Localiza_Contrato_Cuenta__c = '';

	@track CC_Queja_Cobro_Tarifa_Telefonica__c = '';

	@track CC_Solicitud_Info_Prestamo__c = '';

	@track CC_Queja_Limpieza__c = '';

	@track CC_Queja_Persona_Sin_Hogar__c = '';

	@track CC_Cierre_Recinto_Cajero__c = '';

	@track CC_Solicitud_Informacion_Requisitos__c = '';

	@track CC_Solicitud_Informacion_Aportar__c = '';

	@track CC_Informacion_Condiciones_Financiacion__c = '';

	@track CC_Ofrecio_Soluciones_Refinanciacion__c = '';


	//Campos para mostrar o no dependiendo de la plantilla seleccionada
	//@track nombresPlantillas = [];
	@track plantillaAtencionDeficienteOficina = false;

	@track plantillaAtencionDeficientTelefonoContact = false;

	@track plantillaAtencionDeficienteCasoConflictivo = false;

	@track plantillaBloqueoRetencionSaldos = false;

	@track plantillaCambioOficina = false;

	@track plantillaCierreOficina = false;

	@track plantillaCierreOficinasPeriodoEstival = false;

	@track plantillaDerivacionSAC = false;

	@track plantillaDobleConfirmacionIdentidadEnNOW = false;

	@track plantillaFallosTecnicosEnCajeros = false;

	@track plantillaFallosOperativosEnNOW = false;

	@track plantillaFallosTecnicosAveriaEnOficina = false;

	@track plantillaFaltaEntrega = false;

	@track plantillaFraude = false;

	@track plantillaInformacionPrestamos = false;

	@track plantillaInformacionSobreMovimientoEnCuenta = false;

	@track plantillaInstalacionesDeficientesCajeros = false;

	@track plantillaNoHayInformacionEnNuestraBaseDeDatos = false;

	@track plantillaOperacionTarjeta = false;

	@track plantillaRespuestaGenerica = false;

	@track plantillaDeRespuestaJUNTAOMIC = false;

	@track plantillaPrestamosICOAlquileres = false;

	@track plantillaSolicitudCancelacionCuenta = false;

	@track plantillaSolicitudCancelacionSeguros = false;

	@track plantillaIntegracionBankia = false;

	@track plantillaSolicitudACuentasAMiNombre = false;

	@track plantillaSolicitudDatosContactoOficina = false;

	@track plantillaSolicitudDeRenegociacionDeDeuda = false;

	@track plantillaSolicitudDocumentacion = false;

	@track plantillaSolicitudesdeTestamentaria = false;

	@track plantillaTiempoDeEspera = false;



	//Campos a mostrar dependiendo de la visibilidad de los propios campos
	@track vAllInOne = false;

	@track vBloqueoRetencionSaldo = false;

	@track vCambioOficina = false;

	@track vContactoCliente = false;

	@track vIntervencionFuerzasSeguridad = false;

	@track vContestarRespuestaCliente = false;

	@track vIndicarGastos = false;

	@track vFaltaEntrega = false;

	@track vFraude = false;

	@track vInfoMovimientoCuenta = false;

	@track vResumenRespuestaCliente = false;

	@track vSexo = false;

	@track vSolicitudCancelacionSeguro = false;

	@track vSolicitudCuentaAMiNombre = false;

	@track vSolicitudTestamentaria = false;

	@track vTiempoEspera = false;

	@track vTonoIrrespetuoso = false;

	@track vValorUsuarioNow = false;

	/////////////////////////
	@track vSolicitud = false;

	@track vSolicitudDocumentacion = false;

	@track vInformacionAdicional = false;

	@track vHelloLetter = false;

	@track vCodigoPrestamo = false;

	@track vFechaFinalCalculo = false;

	@track vCuadroAmortizacion = false;

	@track vParteDocumentacion = false;

	@track vDocumentacionAdicional = false;

	@track vDocumentacionNoLocalizada = false;

	@track vDocumentacionNoLocalizadaCliente = false;

	@track vTasacionInmuebleHipotecado = false;

	@track vPrestamoTitulizado = false;

	@track vPrestamoVendidoTercero = false;

	@track vSolicitudFacturasGastos = false;

	@track vContratoTarjetaCliente = false;

	@track vExtractosLiquidacion = false;

	@track vCopiaParcialEscritura = false;

	@track vDetalleInformacionEnviar = false;

	@track vNoLocalizaContratoCuenta = false;

	@track vQuejaCobroTarifaTelefonica = false;

	@track vSolicitudInfoPrestamo = false;

	@track vQuejaLimpieza = false;

	@track vQuejaPersonaSinHogar = false;

	@track vCierreRecintoCajero = false;

	@track vSolicitudInformacionRequisitos = false;

	@track vSolicitudInformacionAportar = false;

	@track vInformacionCondicionesFinanciacion = false;

	@track vOfrecioSolucionesRefinanciacion = false;


	/////////////////////////////

	//@track plantillasSDOCNAMES = '';
	plantillasSDOCNAMES = '';

	@track ListOfValues = [];

	@wire(getRecord, {recordId: '$recordId', fields: [
		IDIOMA, BLOQUEO_RETENCION_SALDO, SOLICITUD_CANCELACION_SEGURO, SOLICITUD_CANCELACION_CONTRATOS, SOLICITUD_TESTAMENTARIA,
		SEXO, TIEMPO_ESPERA, TONO_IRRESPETUOSO, CONTACTO_CLIENTE, INTERVENCION_FUERZAS_SEGURIDAD, ALL_IN_ONE, CAMBIO_OFICINA, FALTA_ENTREGA,
		ID_DOC, DOC_NAME, FRAUDE, MOVIMIENTO_CUENTA, USUARIO_NOW, CUENTA_A_MI_NOMBRE, CONTESTAR_RESPUESTA_CLIENTE,
		RESPUESTA_CLIENTE, INDICAR_GASTOS,
		SOLICITUD, SOLICITUD_DOCUMENTACION,
		INFORMACION_DOCUMENTACION_ADICIONAL, HELLO_LETTER, CODIGO_PRESTAMO, FECHA_FINAL_CALCULO,
		CUADRO_AMORTIZACION, PARTE_DOCUMENTACION, DOCUMENTACION_ADICIONAL, DOCUMENTACION_NO_LOCALIZADA, DOCUMENTACION_NO_LOCALIZADA_CLIENTE,
		TASACION_INMUEBLE_HIPOTECADO, PRESTAMO_TITULIZADO, PRESTAMO_VENDIDO_TERCERO, SOLICITUD_FACTURAS_GASTOS, CONTRATO_TARJETA_CLIENTE,
		EXTRACTOS_LIQUIDACION, COPIA_PARCIAL_ESCRITURA, DETALLE_INFORMACION_ENVIAR, NO_LOCALIZA_CONTRATO_CUENTA,
		QUEJA_COBRO_TARIFA_TELEFONICA, SOLICITUD_INFO_PRESTAMO, QUEJA_LIMPIEZA, QUEJA_PERSONA_SIN_HOGAR, CIERRE_RECINTO_CAJERO,
		SOLICITUD_INFORMACION_REQUISITOS, SOLICITUD_INFORMACION_APORTAR, INFORMACION_CONDICIONES_FINANCIACION, OFRECIO_SOLUCIONES_REFINANCIACION
	]})case;

	handleCargarPlantillas() {
		this.plantillasSDOCNAMES = getFieldValue(this.case.data, DOC_NAME);

		obtenerPlantillas({
			ids: this.plantillasSDOCNAMES
		})
			.then(result => {
			//this.nombresPlantillas = result;
				for (let i = 0; i < result.length; i++) {
					let templateName = result[i].Name;
					templateName = templateName.slice(0, -3);

					//dar visibilidad a las plantillas
					if (templateName != '') {
						this.darVisibilidadPlantilla(templateName);
					}

					//llamar apex y revisar campos
					getCamposPlantilla({plantillas: templateName})
						.then(result2 => {
							this.ListOfValues = result2;
							//Dar visibilidad a los campos
							for (let i = 0; i < result2.length; i++) {
								if (result2[i] == 'CC_All_In_One__c') {
									this.vAllInOne = true;
								} else if (result2[i] == 'CC_Bloqueo_Retencion_Saldo__c') {
									this.vBloqueoRetencionSaldo = true;
								} else if (result2[i] == 'CC_Cambio_Oficina__c') {
									this.vCambioOficina = true;
								} else if (result2[i] == 'CC_Contacto_Cliente__c') {
									this.vContactoCliente = true;
								} else if (result2[i] == 'CC_Intervencion_Fuerzas_Seguridad__c') {
									this.vIntervencionFuerzasSeguridad = true;
								} else if (result2[i] == 'CC_Contestar_Respuesta_Cliente__c') {
									this.vContestarRespuestaCliente = true;
								} else if (result2[i] == 'CC_Falta_Entrega__c') {
									this.vFaltaEntrega = true;
								} else if (result2[i] == 'CC_Fraude__c') {
									this.vFraude = true;
								} else if (result2[i] == 'CC_Movimiento_En_Cuenta__c') {
									this.vInfoMovimientoCuenta = true;
								} else if (result2[i] == 'CC_Respuesta_Cliente__c') {
									this.vResumenRespuestaCliente = true;
								} else if (result2[i] == 'CC_Sexo__c') {
									this.vSexo = true;
								} else if (result2[i] == 'CC_Solicitud_Cancelacion_Seguro__c') {
									this.vSolicitudCancelacionSeguro = true;
								} else if (result2[i] == 'CC_Solicitud_Cancelacion_Contratos__c') {
									this.vSolicitudCancelacionContratos = true;
								} else if (result2[i] == 'CC_Cuenta_A_Mi_Nombre__c') {
									this.vSolicitudCuentaAMiNombre = true;
								} else if (result2[i] == 'CC_Solicitud_Testamentaria__c') {
									this.vSolicitudTestamentaria = true;
								} else if (result2[i] == 'CC_Tiempo_Espera__c') {
									this.vTiempoEspera = true;
								} else if (result2[i] == 'CC_Tono_Irrespetuoso__c') {
									this.vTonoIrrespetuoso = true;
								} else if (result2[i] == 'CC_Usuario_Now__c') {
									this.vValorUsuarioNow = true;
								} else if (result2[i] == 'CC_Solicitud__c') {
									this.vSolicitud = true;
								} else if (result2[i] == 'CC_Solicitud_Documentacion__c') {
									this.vSolicitudDocumentacion = true;
								} else if (result2[i] == 'CC_Informacion_Documentacion_Adicional__c') {
									this.vInformacionAdicional = true;
								} else if (result2[i] == 'CC_Hello_Letter__c') {
									this.vHelloLetter = true;
								} else if (result2[i] == 'CC_Codigo_Prestamo__c') {
									this.vCodigoPrestamo = true;
								} else if (result2[i] == 'CC_Fecha_Final_Calculo__c') {
									this.vFechaFinalCalculo = true;
								} else if (result2[i] == 'CC_Cuadro_Amortizacion__c') {
									this.vCuadroAmortizacion = true;
								} else if (result2[i] == 'CC_Parte_Documentacion__c') {
									this.vParteDocumentacion = true;
								} else if (result2[i] == 'CC_Documentacion_Adicional__c') {
									this.vDocumentacionAdicional = true;
								} else if (result2[i] == 'CC_Documentacion_No_Localizada__c') {
									this.vDocumentacionNoLocalizada = true;
								} else if (result2[i] == 'CC_Documentacion_No_Localizada_Cliente__c') {
									this.vDocumentacionNoLocalizadaCliente = true;
								} else if (result2[i] == 'CC_Tasacion_Inmueble_Hipotecado__c') {
									this.vTasacionInmuebleHipotecado = true;
								} else if (result2[i] == 'CC_Prestamo_Titulizado__c') {
									this.vPrestamoTitulizado = true;
								} else if (result2[i] == 'CC_Prestamo_Vendido_Tercero__c') {
									this.vPrestamoVendidoTercero = true;
								} else if (result2[i] == 'CC_Solicitud_Facturas_Gastos__c') {
									this.vSolicitudFacturasGastos = true;
								} else if (result2[i] == 'CC_Contrato_Tarjeta_Cliente__c') {
									this.vContratoTarjetaCliente = true;
								} else if (result2[i] == 'CC_Extractos_Liquidacion__c') {
									this.vExtractosLiquidacion = true;
								} else if (result2[i] == 'CC_Copia_Parcial_Escritura__c') {
									this.vCopiaParcialEscritura = true;
								} else if (result2[i] == 'CC_Detalle_Informacion_Enviar__c') {
									this.vDetalleInformacionEnviar = true;
								} else if (result2[i] == 'CC_No_Localiza_Contrato_Cuenta__c') {
									this.vNoLocalizaContratoCuenta = true;
								} else if (result2[i] == 'CC_Queja_Cobro_Tarifa_Telefonica__c') {
									this.vQuejaCobroTarifaTelefonica = true;
								} else if (result2[i] == 'CC_Solicitud_Info_Prestamo__c') {
									this.vSolicitudInfoPrestamo = true;
								} else if (result2[i] == 'CC_Queja_Limpieza__c') {
									this.vQuejaLimpieza = true;
								} else if (result2[i] == 'CC_Queja_Persona_Sin_Hogar__c') {
									this.vQuejaPersonaSinHogar = true;
								} else if (result2[i] == 'CC_Cierre_Recinto_Cajero__c') {
									this.vCierreRecintoCajero = true;
								} else if (result2[i] == 'CC_Solicitud_Informacion_Requisitos__c') {
									this.vSolicitudInformacionRequisitos = true;
								} else if (result2[i] == 'CC_Solicitud_Informacion_Aportar__c') {
									this.vSolicitudInformacionAportar = true;
								} else if (result2[i] == 'CC_Informacion_Condiciones_Financiacion__c') {
									this.vInformacionCondicionesFinanciacion = true;
								} else if (result2[i] == 'CC_Ofrecio_Soluciones_Refinanciacion__c') {
									this.vOfrecioSolucionesRefinanciacion = true;
								} else if (result2[i] == 'CC_Indicar_Gastos__c') {
									this.vIndicarGastos = true;
								}

							}
						})
						.catch(error => {
							//console.log(error);
						});
				}
			})
			.catch(error => {
			//console.log(error);
			});
		this.botonPlantillas = true;
	}


	darVisibilidadPlantilla(nombrePlantilla) {
		if (nombrePlantilla.toLowerCase() == 'atención deficiente en oficina') {
			this.plantillaAtencionDeficienteOficina = true;

		} else if (nombrePlantilla.toLowerCase() == 'atención deficiente en teléfono contact') {
			this.plantillaAtencionDeficientTelefonoContact = true;

		} else if (nombrePlantilla.toLowerCase() == 'atención deficiente: caso conflictivo') {
			this.plantillaAtencionDeficienteCasoConflictivo = true;

		} else if (nombrePlantilla.toLowerCase() == 'bloqueo retencion de saldos') {
			this.plantillaBloqueoRetencionSaldos = true;

		} else if (nombrePlantilla.toLowerCase() == 'cambio de oficina') {
			this.plantillaCambioOficina = true;

		} else if (nombrePlantilla.toLowerCase() == 'cierre de oficina') {
			this.plantillaCierreOficina = true;

		} else if (nombrePlantilla.toLowerCase() == 'cierre de oficinas periodo estival') {
			this.plantillaCierreOficinasPeriodoEstival = true;

		} else if (nombrePlantilla.toLowerCase() == 'derivación sac') {
			this.plantillaDerivacionSAC = true;

		} else if (nombrePlantilla.toLowerCase() == 'doble confirmacion identidad en now') {
			this.plantillaDobleConfirmacionIdentidadEnNOW = true;

		} else if (nombrePlantilla.toLowerCase() == 'fallos técnicos en cajeros') {
			this.plantillaFallosTecnicosEnCajeros = true;

		} else if (nombrePlantilla.toLowerCase() == 'fallos tecnicos operativos en now') {
			this.plantillaFallosOperativosEnNOW = true;

		} else if (nombrePlantilla.toLowerCase() == 'fallos tecnicos/averia en oficina') {
			this.plantillaFallosTecnicosAveriaEnOficina = true;

		} else if (nombrePlantilla.toLowerCase() == 'falta entrega') {
			this.plantillaFaltaEntrega = true;

		} else if (nombrePlantilla.toLowerCase() == 'fraude') {
			this.plantillaFraude = true;

		} else if (nombrePlantilla.toLowerCase() == 'información préstamos') {
			this.plantillaInformacionPrestamos = true;

		} else if (nombrePlantilla.toLowerCase() == 'información sobre movimiento en cuenta') {
			this.plantillaInformacionSobreMovimientoEnCuenta = true;

		} else if (nombrePlantilla.toLowerCase() == 'instalaciones deficientes cajeros') {
			this.plantillaInstalacionesDeficientesCajeros = true;

		} else if (nombrePlantilla.toLowerCase() == 'no hay informacion en nuestra base de datos') {
			this.plantillaNoHayInformacionEnNuestraBaseDeDatos = true;

		} else if (nombrePlantilla.toLowerCase() == 'operacion tarjeta') {
			this.plantillaOperacionTarjeta = true;

		} else if (nombrePlantilla.toLowerCase() == 'plantilla de respuesta genérica') {
			this.plantillaRespuestaGenerica = true;

		} else if (nombrePlantilla.toLowerCase() == 'plantilla de respuesta junta/omic') {
			this.plantillaDeRespuestaJUNTAOMIC = true;

		} else if (nombrePlantilla.toLowerCase() == 'prestamos ico alquileres') {
			this.plantillaPrestamosICOAlquileres = true;

		} else if (nombrePlantilla.toLowerCase() == 'solicitud cancelacion contratos') {
			this.plantillaSolicitudCancelacionContratos = true;

		} else if (nombrePlantilla.toLowerCase() == 'solicitud cancelacion seguros') {
			this.plantillaSolicitudCancelacionSeguros = true;

		} else if (nombrePlantilla.toLowerCase() == 'integracion bankia') {
			this.plantillaIntegracionBankia = true;

		} else if (nombrePlantilla.toLowerCase() == 'solicitud cuentas a mi nombre') {
			this.plantillaSolicitudACuentasAMiNombre = true;

		} else if (nombrePlantilla.toLowerCase() == 'solicitud datos contacto oficina') {
			this.plantillaSolicitudDatosContactoOficina = true;

		} else if (nombrePlantilla.toLowerCase() == 'solicitud de renegociación de deuda') {
			this.plantillaSolicitudDeRenegociacionDeDeuda = true;

		} else if (nombrePlantilla.toLowerCase() == 'solicitud documentación') {
			this.plantillaSolicitudDocumentacion = true;

		} else if (nombrePlantilla.toLowerCase() == 'solicitudes de testamentaria') {
			this.plantillaSolicitudesdeTestamentaria = true;

		} else if (nombrePlantilla.toLowerCase() == 'tiempo de espera') {
			this.plantillaTiempoDeEspera = true;

		}


	}

	/*handleCargarPlantillas (){
		this.plantillasSDOCNAMES = getFieldValue(this.case.data, DOC_NAME);
		//console.log(this.plantillasSDOCNAMES);
		obtenerPlantillas({
			Ids: this.plantillasSDOCNAMES
		})
		.then(result => {
			this.nombresPlantillas = result;

			for(var i = 0; i < result.length; i++){
				if((result[i].Name.toLowerCase() == 'atención deficiente en oficina es' && result[i].SDOC__Language__c == 'Castellano') ||
				(result[i].Name.toLowerCase() == 'atención deficiente en oficina ca' && result[i].SDOC__Language__c == 'Catalan') ||
				(result[i].Name.toLowerCase() == 'atención deficiente en oficina en' && result[i].SDOC__Language__c == 'Ingles')){
					this.oficina = true;
				} else if((result[i].Name.toLowerCase() == "solicitud datos contacto oficina es" && result[i].SDOC__Language__c == 'Castellano') ||
				(result[i].Name.toLowerCase() == "solicitud datos contacto oficina ca" && result[i].SDOC__Language__c == 'Catalan')){
					this.solicitudDatosContOfi = true;
				} else if((result[i].Name.toLowerCase() == "cambio de oficina es" && result[i].SDOC__Language__c == 'Castellano') ||
				(result[i].Name.toLowerCase() == "cambio de oficina ca" && result[i].SDOC__Language__c == 'Catalan')){
					this.cambioOficinaPlantilla = true;
				} else if((result[i].Name.toLowerCase() == "falta entrega es" && result[i].SDOC__Language__c == 'Castellano') ||
				(result[i].Name.toLowerCase() == "falta entrega ca" && result[i].SDOC__Language__c == 'Catalan')){
					this.faltaEntregaPlantilla = true;
				} else if((result[i].Name.toLowerCase() == "fraude es" && result[i].SDOC__Language__c == 'Castellano') ||
				(result[i].Name.toLowerCase() == "fraude ca" && result[i].SDOC__Language__c == 'Catalan')){
					this.plantillaFraude = true;
				} else if((result[i].Name.toLowerCase() == "informacion sobre movimiento en cuenta es" && result[i].SDOC__Language__c == 'Castellano') ||
				(result[i].Name.toLowerCase() == "informacion sobre movimiento en cuenta ca" && result[i].SDOC__Language__c == 'Catalan')){
					this.plantillaMovimientoCuenta = true;
				} else if((result[i].Name.toLowerCase() == "operacion tarjeta es" && result[i].SDOC__Language__c == 'Castellano') ||
				(result[i].Name.toLowerCase() == "operacion tarjeta ca" && result[i].SDOC__Language__c == 'Catalan')){
					this.plantillaOperacionTarjeta = true;
				} else if((result[i].Name.toLowerCase() == "solicitud cuentas a mi nombre es" && result[i].SDOC__Language__c == 'Castellano') ||
				(result[i].Name.toLowerCase() == "solicitud cuentas a mi nombre ca" && result[i].SDOC__Language__c == 'Catalan')){
					this.plantillaSolicitudAMiNombre = true;
				} else if((result[i].Name.toLowerCase() == "plantilla de respuesta genérica es" && result[i].SDOC__Language__c == 'Castellano') ||
				(result[i].Name.toLowerCase() == "plantilla de respuesta genérica ca" && result[i].SDOC__Language__c == 'Catalan')){
					this.plantillaRespuestaGenerica = true;
				} else if((result[i].Name.toLowerCase() == "bloqueo retencion de saldos es" && result[i].SDOC__Language__c == 'Castellano') ||
				(result[i].Name.toLowerCase() == "bloqueo retencion de saldos ca" && result[i].SDOC__Language__c == 'Catalan')){
					this.plantillaBloqueoRetencionSaldos = true;
				} else if((result[i].Name.toLowerCase() == "solicitud cancelacion seguros es" && result[i].SDOC__Language__c == 'Castellano') ||
				(result[i].Name.toLowerCase() == "solicitud cancelacion seguros ca" && result[i].SDOC__Language__c == 'Catalan')){
					this.plantillaCancelacionSeguros = true;
				} else if((result[i].Name.toLowerCase() == "solicitudes de testamentaria es" && result[i].SDOC__Language__c == 'Castellano') ||
				(result[i].Name.toLowerCase() == "solicitudes de testamentaria ca" && result[i].SDOC__Language__c == 'Catalan')){
					this.plantillaSolicitudesTestamentaria = true;
				}
			}
		})
		.catch(error => {
		});
		this.botonPlantillas = true;
	}*/

	get nombrePlantilla() {
		return getFieldValue(this.case.data, DOC_NAME);
	}

	get sexoElegir() {
		return getFieldValue(this.case.data, SEXO);
	}

	get cambioOficina() {
		return getFieldValue(this.case.data, CAMBIO_OFICINA);
	}

	get faltaEntrega() {
		return getFieldValue(this.case.data, FALTA_ENTREGA);
	}

	get contactoCliente() {
		return getFieldValue(this.case.data, CONTACTO_CLIENTE);
	}

	get intervencionFuerzasSeguridad() {
		return getFieldValue(this.case.data, INTERVENCION_FUERZAS_SEGURIDAD);
	}

	get allInOne() {
		return getFieldValue(this.case.data, ALL_IN_ONE);
	}

	get tiempoEspera() {
		return getFieldValue(this.case.data, TIEMPO_ESPERA);
	}

	get tonoIrrespetuoso() {
		return getFieldValue(this.case.data, TONO_IRRESPETUOSO);
	}

	get valorFraude() {
		return getFieldValue(this.case.data, FRAUDE);
	}

	get valorMovimientoCuenta() {
		return getFieldValue(this.case.data, MOVIMIENTO_CUENTA);
	}

	get valorUsuarioNow() {
		return getFieldValue(this.case.data, USUARIO_NOW);
	}

	get valorCuentaAMiNombre() {
		return getFieldValue(this.case.data, CUENTA_A_MI_NOMBRE);
	}

	get valorRespuestaCliente() {
		return getFieldValue(this.case.data, RESPUESTA_CLIENTE);
	}

	get valorContestarRespuestaCliente() {
		return getFieldValue(this.case.data, CONTESTAR_RESPUESTA_CLIENTE);
	}

	get valorBloqueoRetencionSaldo() {
		return getFieldValue(this.case.data, BLOQUEO_RETENCION_SALDO);
	}

	get valorSolicitudCancelacionSeguro() {
		return getFieldValue(this.case.data, SOLICITUD_CANCELACION_SEGURO);
	}

	get valorSolicitudCancelacionContratos() {
		return getFieldValue(this.case.data, SOLICITUD_CANCELACION_CONTRATOS);
	}

	get valorSolicitudTestamentaria() {
		return getFieldValue(this.case.data, SOLICITUD_TESTAMENTARIA);
	}

	get valorSolicitud() {
		return getFieldValue(this.case.data, SOLICITUD);
	}

	get valorSolicitudDocumentacion() {
		return getFieldValue(this.case.data, SOLICITUD_DOCUMENTACION);
	}

	get valorInformacionAdicional() {
		return getFieldValue(this.case.data, INFORMACION_DOCUMENTACION_ADICIONAL);
	}

	get valorHelloLetter() {
		return getFieldValue(this.case.data, HELLO_LETTER);
	}

	get valorCodigoPrestamo() {
		return getFieldValue(this.case.data, CODIGO_PRESTAMO);
	}

	get valorFechaFinalCalculo() {
		return getFieldValue(this.case.data, FECHA_FINAL_CALCULO);
	}

	get valorCuadroAmortizacion() {
		return getFieldValue(this.case.data, CUADRO_AMORTIZACION);
	}

	get valorParteDocumentacion() {
		return getFieldValue(this.case.data, PARTE_DOCUMENTACION);
	}

	get valorDocumentacionAdicional() {
		return getFieldValue(this.case.data, DOCUMENTACION_ADICIONAL);
	}

	get valorDocumentacionNoLocalizada() {
		return getFieldValue(this.case.data, DOCUMENTACION_NO_LOCALIZADA);
	}

	get valorDocumentacionNoLocalizadaCliente() {
		return getFieldValue(this.case.data, DOCUMENTACION_NO_LOCALIZADA_CLIENTE);
	}

	get valorTasacionInmuebleHipotecado() {
		return getFieldValue(this.case.data, TASACION_INMUEBLE_HIPOTECADO);
	}

	get valorPrestamoTitulizado() {
		return getFieldValue(this.case.data, PRESTAMO_TITULIZADO);
	}

	get valorPrestamoVendidoTercero() {
		return getFieldValue(this.case.data, PRESTAMO_VENDIDO_TERCERO);
	}

	get valorSolicitudFacturasGastos() {
		return getFieldValue(this.case.data, SOLICITUD_FACTURAS_GASTOS);
	}

	get valorContratoTarjetaCliente() {
		return getFieldValue(this.case.data, CONTRATO_TARJETA_CLIENTE);
	}

	get valorIndicarGastos() {
		return getFieldValue(this.case.data, INDICAR_GASTOS);
	}

	get valorExtractosLiquidacion() {
		return getFieldValue(this.case.data, EXTRACTOS_LIQUIDACION);
	}

	get valorCopiaParcialEscritura() {
		return getFieldValue(this.case.data, COPIA_PARCIAL_ESCRITURA);
	}

	get valorDetalleInformacionEnviar() {
		return getFieldValue(this.case.data, DETALLE_INFORMACION_ENVIAR);
	}

	get valorNoLocalizaContratoCuenta() {
		return getFieldValue(this.case.data, NO_LOCALIZA_CONTRATO_CUENTA);
	}

	get valorQuejaCobroTarifaTelefonica() {
		return getFieldValue(this.case.data, QUEJA_COBRO_TARIFA_TELEFONICA);
	}

	get valorSolicitudInfoPrestamo() {
		return getFieldValue(this.case.data, SOLICITUD_INFO_PRESTAMO);
	}

	get valorQuejaLimpieza() {
		return getFieldValue(this.case.data, QUEJA_LIMPIEZA);
	}

	get valorQuejaPersonaSinHogar() {
		return getFieldValue(this.case.data, QUEJA_PERSONA_SIN_HOGAR);
	}

	get valorCierreRecintoCajero() {
		return getFieldValue(this.case.data, CIERRE_RECINTO_CAJERO);
	}

	get valorSolicitudInformacionRequisitos() {
		return getFieldValue(this.case.data, SOLICITUD_INFORMACION_REQUISITOS);
	}

	get valorSolicitudInformacionAportar() {
		return getFieldValue(this.case.data, SOLICITUD_INFORMACION_APORTAR);
	}

	get valorInformacionCondicionesFinanciacion() {
		return getFieldValue(this.case.data, INFORMACION_CONDICIONES_FINANCIACION);
	}

	get valorOfrecioSolucionesRefinanciacion() {
		return getFieldValue(this.case.data, OFRECIO_SOLUCIONES_REFINANCIACION);
	}


	//Llama al metodo apex para recuperar las plantillas
	get docId() {
		this.plantillasSDOCNAMES = getFieldValue(this.case.data, DOC_NAME);

		if (getFieldValue(this.case.data, DOC_NAME) != null) {
			this.handleCargarPlantillas();
		}
		return getFieldValue(this.case.data, ID_DOC);
	}

	handleTiempoEsperaChange(event) {
		this.CC_Tiempo_Espera__c = event.target.value;
	}

	handleTonoIrrespetuosoChange(event) {
		this.CC_Tono_Irrespetuoso__c = event.target.value;
	}

	handleContactoClienteChange(event) {
		this.CC_Contacto_Cliente__c = event.target.value;
	}

	handleIntervencionFuerzasSeguridadChange(event) {
		this.CC_Intervencion_Fuerzas_Seguridad__c = event.target.value;
	}

	handleAllInOneChange(event) {
		this.CC_All_In_One__c = event.target.value;
	}

	handleCambioOficinaChange(event) {
		this.CC_Cambio_Oficina__c = event.target.value;
	}

	handleFaltaEntregaChange(event) {
		this.CC_Falta_Entrega__c = event.target.value;
	}

	handleSexoChange(event) {
		this.CC_Sexo__c = event.target.value;
	}

	handleBloqueoRetencionSaldoChange(event) {
		this.CC_Bloqueo_Retencion_Saldo__c = event.target.value;
	}

	handleSolicitudCancelacionSeguroChange(event) {
		this.CC_Solicitud_Cancelacion_Seguro__c = event.target.value;
	}

	handleSolicitudCancelacionContratosChange(event) {
		this.CC_Solicitud_Cancelacion_Contratos__c = event.target.value;
	}

	handleSolicitudTestamentariaChange(event) {
		this.CC_Solicitud_Testamentaria__c = event.target.value;
	}

	handleFraudeChange(event) {
		this.CC_Fraude__c = event.target.value;
	}

	handleMovimientoCuentaChange(event) {
		this.CC_Movimiento_En_Cuenta__c = event.target.value;
	}

	handleUsuarioNowChange(event) {
		this.CC_Usuario_Now__c = event.target.value;
	}

	handleCuentaAMiNombreChange(event) {
		this.CC_Cuenta_A_Mi_Nombre__c = event.target.value;
	}

	handleRespuestaClienteChange(event) {
		this.CC_Respuesta_Cliente__c = event.target.value;
	}

	handleContestarRespuestaClienteChange(event) {
		this.CC_Contestar_Respuesta_Cliente__c = event.target.value;
	}

	handleIndicarGastosChange(event) {
		this.CC_Indicar_Gastos__c = event.target.value;
	}

	handleSolicitudChange(event) {
		this.CC_Solicitud__c = event.target.value;
	}

	handleSolicitudDocumentacionChange(event) {
		this.CC_Solicitud_Documentacion__c = event.target.value;
	}

	handleInformacionAdicionalChange(event) {
		this.CC_Informacion_Documentacion_Adicional__c = event.target.value;
	}

	handleHelloLetterChange(event) {
		this.CC_Hello_Letter__c = event.target.value;
	}

	handleCodigoPrestamoChange(event) {
		this.CC_Codigo_Prestamo__c = event.target.value;
	}

	handleFechaFinalCalculoChange(event) {
		this.CC_Fecha_Final_Calculo__c = event.target.value;
	}

	handleCuadroAmortizacionChange(event) {
		this.CC_Cuadro_Amortizacion__c = event.target.value;
	}

	handleParteDocumentacionChange(event) {
		this.CC_Parte_Documentacion__c = event.target.value;
	}

	handleDocumentacionAdicionalChange(event) {
		this.CC_Documentacion_Adicional__c = event.target.value;
	}

	handleDocumentacionNoLocalizadaChange(event) {
		this.CC_Documentacion_No_Localizada__c = event.target.value;
	}

	handleDocumentacionNoLocalizadaClienteChange(event) {
		this.CC_Documentacion_No_Localizada_Cliente__c = event.target.value;
	}

	handleTasacionInmuebleHipotecadoChange(event) {
		this.CC_Tasacion_Inmueble_Hipotecado__c = event.target.value;
	}

	handlePrestamoTitulizadoChange(event) {
		this.CC_Prestamo_Titulizado__c = event.target.value;
	}

	handlePrestamoVendidoTerceroChange(event) {
		this.CC_Prestamo_Vendido_Tercero__c = event.target.value;
	}

	handleSolicitudFacturasGastosChange(event) {
		this.CC_Solicitud_Facturas_Gastos__c = event.target.value;
	}

	handleContratoTarjetaClienteChange(event) {
		this.CC_Contrato_Tarjeta_Cliente__c = event.target.value;
	}

	handleExtractosLiquidacionChange(event) {
		this.CC_Extractos_Liquidacion__c = event.target.value;
	}

	handleCopiaParcialEscrituraChange(event) {
		this.CC_Copia_Parcial_Escritura__c = event.target.value;
	}

	handleDetalleInformacionEnviarChange(event) {
		this.CC_Detalle_Informacion_Enviar__c = event.target.value;
	}

	handleNoLocalizaContratoCuentaChange(event) {
		this.CC_No_Localiza_Contrato_Cuenta__c = event.target.value;
	}

	handleQuejaCobroTarifaTelefonicaChange(event) {
		this.CC_Queja_Cobro_Tarifa_Telefonica__c = event.target.value;
	}

	handleSolicitudInfoPrestamoChange(event) {
		this.CC_Solicitud_Info_Prestamo__c = event.target.value;
	}

	handleQuejaLimpiezaChange(event) {
		this.CC_Queja_Limpieza__c = event.target.value;
	}

	handleQuejaPersonaSinHogarChange(event) {
		this.CC_Queja_Persona_Sin_Hogar__c = event.target.value;
	}

	handleCierreRecintoCajeroChange(event) {
		this.CC_Cierre_Recinto_Cajero__c = event.target.value;
	}

	handleSolicitudInformacionRequisitosChange(event) {
		this.CC_Solicitud_Informacion_Requisitos__c = event.target.value;
	}

	handleSolicitudInformacionAportarChange(event) {
		this.CC_Solicitud_Informacion_Aportar__c = event.target.value;
	}

	handleInformacionCondicionesFinanciacionChange(event) {
		this.CC_Informacion_Condiciones_Financiacion__c = event.target.value;
	}

	handleOfrecioSolucionesRefinanciacionChange(event) {
		this.CC_Ofrecio_Soluciones_Refinanciacion__c = event.target.value;
	}


	handleSave() {
		if (this.CC_Tiempo_Espera__c === '' || this.CC_Tiempo_Espera__c === undefined) {
			this.CC_Tiempo_Espera__c = getFieldValue(this.case.data, TIEMPO_ESPERA);
		}

		if (this.CC_Tono_Irrespetuoso__c === '' || this.CC_Tono_Irrespetuoso__c === undefined) {
			if (getFieldValue(this.case.data, TONO_IRRESPETUOSO) != null) {
				this.CC_Tono_Irrespetuoso__c = getFieldValue(this.case.data, TONO_IRRESPETUOSO);
			} else {
				this.CC_Tono_Irrespetuoso__c = false;
			}
		}

		if (this.CC_Contacto_Cliente__c === '' || this.CC_Contacto_Cliente__c === undefined) {
			if (getFieldValue(this.case.data, CONTACTO_CLIENTE) != null) {
				this.CC_Contacto_Cliente__c = getFieldValue(this.case.data, CONTACTO_CLIENTE);
			} else {
				this.CC_Contacto_Cliente__c = false;
			}
		}

		if (this.CC_Intervencion_Fuerzas_Seguridad__c === '' || this.CC_Intervencion_Fuerzas_Seguridad__c === undefined) {
			if (getFieldValue(this.case.data, INTERVENCION_FUERZAS_SEGURIDAD) != null) {
				this.CC_Intervencion_Fuerzas_Seguridad__c = getFieldValue(this.case.data, INTERVENCION_FUERZAS_SEGURIDAD);
			} else {
				this.CC_Intervencion_Fuerzas_Seguridad__c = false;
			}
		}

		if (this.CC_All_In_One__c === '' || this.CC_All_In_One__c === undefined) {
			if (getFieldValue(this.case.data, ALL_IN_ONE) != null) {
				this.CC_All_In_One__c = getFieldValue(this.case.data, ALL_IN_ONE);
			} else {
				this.CC_All_In_One__c = false;
			}
		}

		if (this.CC_Usuario_Now__c === '' || this.CC_Usuario_Now__c === undefined) {
			if (getFieldValue(this.case.data, USUARIO_NOW) != null) {
				this.CC_Usuario_Now__c = getFieldValue(this.case.data, USUARIO_NOW);
			} else {
				this.CC_Usuario_Now__c = false;
			}
		}

		if (this.CC_Solicitud_Cancelacion_Seguro__c === '' || this.CC_Solicitud_Cancelacion_Seguro__c === undefined) {
			if (getFieldValue(this.case.data, SOLICITUD_CANCELACION_SEGURO) != null) {
				this.CC_Solicitud_Cancelacion_Seguro__c = getFieldValue(this.case.data, SOLICITUD_CANCELACION_SEGURO);
			} else {
				this.CC_Solicitud_Cancelacion_Seguro__c = false;
			}
		}

		if (this.CC_Solicitud_Cancelacion_Contratos__c === '' || this.CC_Solicitud_Cancelacion_Contratos__c === undefined) {
			if (getFieldValue(this.case.data, SOLICITUD_CANCELACION_CONTRATOS) != null) {
				this.CC_Solicitud_Cancelacion_Contratos__c = getFieldValue(this.case.data, SOLICITUD_CANCELACION_CONTRATOS);
			} else {
				this.CC_Solicitud_Cancelacion_Contratos__c = false;
			}
		}

		if (this.CC_Solicitud_Testamentaria__c === '' || this.CC_Solicitud_Testamentaria__c === undefined) {
			if (getFieldValue(this.case.data, SOLICITUD_TESTAMENTARIA) != null) {
				this.CC_Solicitud_Testamentaria__c = getFieldValue(this.case.data, SOLICITUD_TESTAMENTARIA);
			} else {
				this.CC_Solicitud_Testamentaria__c = false;
			}
		}

		if (this.CC_Cuadro_Amortizacion__c === '' || this.CC_Cuadro_Amortizacion__c === undefined) {
			if (getFieldValue(this.case.data, CUADRO_AMORTIZACION) != null) {
				this.CC_Cuadro_Amortizacion__c = getFieldValue(this.case.data, CUADRO_AMORTIZACION);
			} else {
				this.CC_Cuadro_Amortizacion__c = false;
			}
		}

		if (this.CC_Parte_Documentacion__c === '' || this.CC_Parte_Documentacion__c === undefined) {
			if (getFieldValue(this.case.data, PARTE_DOCUMENTACION) != null) {
				this.CC_Parte_Documentacion__c = getFieldValue(this.case.data, PARTE_DOCUMENTACION);
			} else {
				this.CC_Parte_Documentacion__c = false;
			}
		}

		if (this.CC_Documentacion_Adicional__c === '' || this.CC_Documentacion_Adicional__c === undefined) {
			if (getFieldValue(this.case.data, DOCUMENTACION_ADICIONAL) != null) {
				this.CC_Documentacion_Adicional__c = getFieldValue(this.case.data, DOCUMENTACION_ADICIONAL);
			} else {
				this.CC_Documentacion_Adicional__c = false;
			}
		}

		if (this.CC_Documentacion_No_Localizada__c === '' || this.CC_Documentacion_No_Localizada__c === undefined) {
			if (getFieldValue(this.case.data, DOCUMENTACION_NO_LOCALIZADA) != null) {
				this.CC_Documentacion_No_Localizada__c = getFieldValue(this.case.data, DOCUMENTACION_NO_LOCALIZADA);
			} else {
				this.CC_Documentacion_No_Localizada__c = false;
			}
		}

		if (this.CC_Documentacion_No_Localizada_Cliente__c === '' || this.CC_Documentacion_No_Localizada_Cliente__c === undefined) {
			if (getFieldValue(this.case.data, DOCUMENTACION_NO_LOCALIZADA_CLIENTE) != null) {
				this.CC_Documentacion_No_Localizada_Cliente__c = getFieldValue(this.case.data, DOCUMENTACION_NO_LOCALIZADA_CLIENTE);
			} else {
				this.CC_Documentacion_No_Localizada_Cliente__c = false;
			}
		}

		if (this.CC_Tasacion_Inmueble_Hipotecado__c === '' || this.CC_Tasacion_Inmueble_Hipotecado__c === undefined) {
			if (getFieldValue(this.case.data, TASACION_INMUEBLE_HIPOTECADO) != null) {
				this.CC_Tasacion_Inmueble_Hipotecado__c = getFieldValue(this.case.data, TASACION_INMUEBLE_HIPOTECADO);
			} else {
				this.CC_Tasacion_Inmueble_Hipotecado__c = false;
			}
		}

		if (this.CC_Prestamo_Titulizado__c === '' || this.CC_Prestamo_Titulizado__c === undefined) {
			if (getFieldValue(this.case.data, PRESTAMO_TITULIZADO) != null) {
				this.CC_Prestamo_Titulizado__c = getFieldValue(this.case.data, PRESTAMO_TITULIZADO);
			} else {
				this.CC_Prestamo_Titulizado__c = false;
			}
		}

		if (this.CC_Prestamo_Vendido_Tercero__c === '' || this.CC_Prestamo_Vendido_Tercero__c === undefined) {
			if (getFieldValue(this.case.data, PRESTAMO_VENDIDO_TERCERO) != null) {
				this.CC_Prestamo_Vendido_Tercero__c = getFieldValue(this.case.data, PRESTAMO_VENDIDO_TERCERO);
			} else {
				this.CC_Prestamo_Vendido_Tercero__c = false;
			}
		}

		if (this.CC_Solicitud_Facturas_Gastos__c === '' || this.CC_Solicitud_Facturas_Gastos__c === undefined) {
			if (getFieldValue(this.case.data, SOLICITUD_FACTURAS_GASTOS) != null) {
				this.CC_Solicitud_Facturas_Gastos__c = getFieldValue(this.case.data, SOLICITUD_FACTURAS_GASTOS);
			} else {
				this.CC_Solicitud_Facturas_Gastos__c = false;
			}
		}

		if (this.CC_Contrato_Tarjeta_Cliente__c === '' || this.CC_Contrato_Tarjeta_Cliente__c === undefined) {
			if (getFieldValue(this.case.data, CONTRATO_TARJETA_CLIENTE) != null) {
				this.CC_Contrato_Tarjeta_Cliente__c = getFieldValue(this.case.data, CONTRATO_TARJETA_CLIENTE);
			} else {
				this.CC_Contrato_Tarjeta_Cliente__c = false;
			}
		}

		if (this.CC_Extractos_Liquidacion__c === '' || this.CC_Extractos_Liquidacion__c === undefined) {
			if (getFieldValue(this.case.data, EXTRACTOS_LIQUIDACION) != null) {
				this.CC_Extractos_Liquidacion__c = getFieldValue(this.case.data, EXTRACTOS_LIQUIDACION);
			} else {
				this.CC_Extractos_Liquidacion__c = false;
			}
		}

		if (this.CC_Copia_Parcial_Escritura__c === '' || this.CC_Copia_Parcial_Escritura__c === undefined) {
			if (getFieldValue(this.case.data, COPIA_PARCIAL_ESCRITURA) != null) {
				this.CC_Copia_Parcial_Escritura__c = getFieldValue(this.case.data, COPIA_PARCIAL_ESCRITURA);
			} else {
				this.CC_Copia_Parcial_Escritura__c = false;
			}
		}

		if (this.CC_No_Localiza_Contrato_Cuenta__c === '' || this.CC_No_Localiza_Contrato_Cuenta__c === undefined) {
			if (getFieldValue(this.case.data, NO_LOCALIZA_CONTRATO_CUENTA) != null) {
				this.CC_No_Localiza_Contrato_Cuenta__c = getFieldValue(this.case.data, NO_LOCALIZA_CONTRATO_CUENTA);
			} else {
				this.CC_No_Localiza_Contrato_Cuenta__c = false;
			}
		}

		if (this.CC_Queja_Cobro_Tarifa_Telefonica__c === '' || this.CC_Queja_Cobro_Tarifa_Telefonica__c === undefined) {
			if (getFieldValue(this.case.data, QUEJA_COBRO_TARIFA_TELEFONICA) != null) {
				this.CC_Queja_Cobro_Tarifa_Telefonica__c = getFieldValue(this.case.data, QUEJA_COBRO_TARIFA_TELEFONICA);
			} else {
				this.CC_Queja_Cobro_Tarifa_Telefonica__c = false;
			}
		}

		if (this.CC_Solicitud_Info_Prestamo__c === '' || this.CC_Solicitud_Info_Prestamo__c === undefined) {
			if (getFieldValue(this.case.data, SOLICITUD_INFO_PRESTAMO) != null) {
				this.CC_Solicitud_Info_Prestamo__c = getFieldValue(this.case.data, SOLICITUD_INFO_PRESTAMO);
			} else {
				this.CC_Solicitud_Info_Prestamo__c = false;
			}
		}

		if (this.CC_Queja_Limpieza__c === '' || this.CC_Queja_Limpieza__c === undefined) {
			if (getFieldValue(this.case.data, QUEJA_LIMPIEZA) != null) {
				this.CC_Queja_Limpieza__c = getFieldValue(this.case.data, QUEJA_LIMPIEZA);
			} else {
				this.CC_Queja_Limpieza__c = false;
			}
		}

		if (this.CC_Queja_Persona_Sin_Hogar__c === '' || this.CC_Queja_Persona_Sin_Hogar__c === undefined) {
			if (getFieldValue(this.case.data, QUEJA_PERSONA_SIN_HOGAR) != null) {
				this.CC_Queja_Persona_Sin_Hogar__c = getFieldValue(this.case.data, QUEJA_PERSONA_SIN_HOGAR);
			} else {
				this.CC_Queja_Persona_Sin_Hogar__c = false;
			}
		}


		if (this.CC_Cierre_Recinto_Cajero__c === '' || this.CC_Cierre_Recinto_Cajero__c === undefined) {
			if (getFieldValue(this.case.data, CIERRE_RECINTO_CAJERO) != null) {
				this.CC_Cierre_Recinto_Cajero__c = getFieldValue(this.case.data, CIERRE_RECINTO_CAJERO);
			} else {
				this.CC_Cierre_Recinto_Cajero__c = false;
			}
		}


		if (this.CC_Solicitud_Informacion_Requisitos__c === '' || this.CC_Solicitud_Informacion_Requisitos__c === undefined) {
			if (getFieldValue(this.case.data, SOLICITUD_INFORMACION_REQUISITOS) != null) {
				this.CC_Solicitud_Informacion_Requisitos__c = getFieldValue(this.case.data, SOLICITUD_INFORMACION_REQUISITOS);
			} else {
				this.CC_Solicitud_Informacion_Requisitos__c = false;
			}
		}

		if (this.CC_Solicitud_Informacion_Aportar__c === '' || this.CC_Solicitud_Informacion_Aportar__c === undefined) {
			if (getFieldValue(this.case.data, SOLICITUD_INFORMACION_APORTAR) != null) {
				this.CC_Solicitud_Informacion_Aportar__c = getFieldValue(this.case.data, SOLICITUD_INFORMACION_APORTAR);
			} else {
				this.CC_Solicitud_Informacion_Aportar__c = false;
			}
		}

		if (this.CC_Informacion_Condiciones_Financiacion__c === '' || this.CC_Informacion_Condiciones_Financiacion__c === undefined) {
			if (getFieldValue(this.case.data, INFORMACION_CONDICIONES_FINANCIACION) != null) {
				this.CC_Informacion_Condiciones_Financiacion__c = getFieldValue(this.case.data, INFORMACION_CONDICIONES_FINANCIACION);
			} else {
				this.CC_Informacion_Condiciones_Financiacion__c = false;
			}
		}

		if (this.CC_Ofrecio_Soluciones_Refinanciacion__c === '' || this.CC_Ofrecio_Soluciones_Refinanciacion__c === undefined) {
			if (getFieldValue(this.case.data, OFRECIO_SOLUCIONES_REFINANCIACION) != null) {
				this.CC_Ofrecio_Soluciones_Refinanciacion__c = getFieldValue(this.case.data, OFRECIO_SOLUCIONES_REFINANCIACION);
			} else {
				this.CC_Ofrecio_Soluciones_Refinanciacion__c = false;
			}
		}



		if (this.CC_Bloqueo_Retencion_Saldo__c === '' || this.CC_Bloqueo_Retencion_Saldo__c === undefined) {
			this.CC_Bloqueo_Retencion_Saldo__c = getFieldValue(this.case.data, BLOQUEO_RETENCION_SALDO);
		}

		if (this.CC_Cambio_Oficina__c === '' || this.CC_Cambio_Oficina__c === undefined) {
			this.CC_Cambio_Oficina__c = getFieldValue(this.case.data, CAMBIO_OFICINA);
		}

		if (this.CC_Falta_Entrega__c === '' || this.CC_Falta_Entrega__c === undefined) {
			this.CC_Falta_Entrega__c = getFieldValue(this.case.data, FALTA_ENTREGA);
		}

		if (this.CC_Sexo__c === '' || this.CC_Sexo__c === undefined) {
			this.CC_Sexo__c = getFieldValue(this.case.data, SEXO);
		}

		if (this.CC_Fraude__c === '' || this.CC_Fraude__c === undefined) {
			this.CC_Fraude__c = getFieldValue(this.case.data, FRAUDE);
		}

		if (this.CC_Movimiento_En_Cuenta__c === '' || this.CC_Movimiento_En_Cuenta__c === undefined) {
			this.CC_Movimiento_En_Cuenta__c = getFieldValue(this.case.data, MOVIMIENTO_CUENTA);
		}

		if (this.CC_Cuenta_A_Mi_Nombre__c === '' || this.CC_Cuenta_A_Mi_Nombre__c === undefined) {
			this.CC_Cuenta_A_Mi_Nombre__c = getFieldValue(this.case.data, CUENTA_A_MI_NOMBRE);
		}

		if (this.CC_Respuesta_Cliente__c === '' || this.CC_Respuesta_Cliente__c === undefined) {
			this.CC_Respuesta_Cliente__c = getFieldValue(this.case.data, RESPUESTA_CLIENTE);
		}

		if (this.CC_Contestar_Respuesta_Cliente__c === '' || this.CC_Contestar_Respuesta_Cliente__c === undefined) {
			this.CC_Contestar_Respuesta_Cliente__c = getFieldValue(this.case.data, CONTESTAR_RESPUESTA_CLIENTE);
		}

		if (this.CC_Indicar_Gastos__c === '' || this.CC_Indicar_Gastos__c === undefined) {
			this.CC_Indicar_Gastos__c = getFieldValue(this.case.data, INDICAR_GASTOS);
		}

		if (this.CC_Solicitud__c === '' || this.CC_Solicitud__c === undefined) {
			this.CC_Solicitud__c = getFieldValue(this.case.data, SOLICITUD);
		}

		if (this.CC_Solicitud_Documentacion__c === '' || this.CC_Solicitud_Documentacion__c === undefined) {
			this.CC_Solicitud_Documentacion__c = getFieldValue(this.case.data, SOLICITUD_DOCUMENTACION);
		}

		if (this.CC_Informacion_Documentacion_Adicional__c === '' || this.CC_Informacion_Documentacion_Adicional__c === undefined) {
			this.CC_Informacion_Documentacion_Adicional__c = getFieldValue(this.case.data, INFORMACION_DOCUMENTACION_ADICIONAL);
		}

		if (this.CC_Hello_Letter__c === '' || this.CC_Hello_Letter__c === undefined) {
			this.CC_Hello_Letter__c = getFieldValue(this.case.data, HELLO_LETTER);
		}

		if (this.CC_Codigo_Prestamo__c === '' || this.CC_Codigo_Prestamo__c === undefined) {
			this.CC_Codigo_Prestamo__c = getFieldValue(this.case.data, CODIGO_PRESTAMO);
		}

		if (this.CC_Fecha_Final_Calculo__c === '' || this.CC_Fecha_Final_Calculo__c === undefined) {
			this.CC_Fecha_Final_Calculo__c = getFieldValue(this.case.data, FECHA_FINAL_CALCULO);
		}

		if (this.CC_Detalle_Informacion_Enviar__c === '' || this.CC_Detalle_Informacion_Enviar__c === undefined) {
			this.CC_Detalle_Informacion_Enviar__c = getFieldValue(this.case.data, DETALLE_INFORMACION_ENVIAR);
		}

		generaDocumento({recordId: this.recordId,
			docId: getFieldValue(this.case.data, ID_DOC),
			idioma: getFieldValue(this.case.data, IDIOMA),
			sexo: getFieldValue(this.case.data, SEXO),
			cambioficina: this.CC_Cambio_Oficina__c,
			faltaentrega: this.CC_Falta_Entrega__c,
			espera: this.CC_Tiempo_Espera__c,
			contactocliente: this.CC_Contacto_Cliente__c,
			allinone: this.CC_All_In_One__c,
			fraude: this.CC_Fraude__c,
			movimientoCuenta: this.CC_Movimiento_En_Cuenta__c,
			usuarioNow: this.CC_Usuario_Now__c,
			cuentaminombre: this.CC_Cuenta_A_Mi_Nombre__c,
			respuestacliente: this.CC_Respuesta_Cliente__c,
			contestarrespuestacliente: this.CC_Contestar_Respuesta_Cliente__c,
			bloqueoretencionsaldo: this.CC_Bloqueo_Retencion_Saldo__c,
			solicitudcancelacionseguro: this.CC_Solicitud_Cancelacion_Seguro__c,
			solicitudtestamentaria: this.CC_Solicitud_Testamentaria__c,
			irrespetuoso: this.CC_Tono_Irrespetuoso__c,
			solicitud: this.CC_Solicitud__c,
			solicitudDocumentacion: this.CC_Solicitud_Documentacion__c,
			informaciondocumentacionadicional: this.CC_Informacion_Documentacion_Adicional__c,
			helloletter: this.CC_Hello_Letter__c,
			codigoprestamo: this.CC_Codigo_Prestamo__c,
			fechafinalcalculo: this.CC_Fecha_Final_Calculo__c,
			cuadroamortizacion: this.CC_Cuadro_Amortizacion__c,
			partedocumentacion: this.CC_Parte_Documentacion__c,
			documentacionadicional: this.CC_Documentacion_Adicional__c,
			documentacionnolocalizada: this.CC_Documentacion_No_Localizada__c,
			detalleinformacionenviar: this.CC_Detalle_Informacion_Enviar__c,
			camposBoleanos: {'documentacionnolocalizadacliente': this.CC_Documentacion_No_Localizada_Cliente__c,
				'tasacioninmueblehipotecado': this.CC_Tasacion_Inmueble_Hipotecado__c,
				'prestamotitulizado': this.CC_Prestamo_Titulizado__c,
				'prestamovendidotercero': this.CC_Prestamo_Vendido_Tercero__c,
				'solicitudfacturasgastos': this.CC_Solicitud_Facturas_Gastos__c,
				'contratotarjetacliente': this.CC_Contrato_Tarjeta_Cliente__c,
				'extractosliquidacion': this.CC_Extractos_Liquidacion__c,
				'copiaparcialescritura': this.CC_Copia_Parcial_Escritura__c,
				'nolocalizacontratocuenta': this.CC_No_Localiza_Contrato_Cuenta__c,
				'quejacobrotarifatelefonica': this.CC_Queja_Cobro_Tarifa_Telefonica__c,
				'solicitudinfoprestamo': this.CC_Solicitud_Info_Prestamo__c,
				'quejalimpieza': this.CC_Queja_Limpieza__c,
				'quejapersonasinhogar': this.CC_Queja_Persona_Sin_Hogar__c,
				'cierrerecintocajero': this.CC_Cierre_Recinto_Cajero__c,
				'solicitudinformacionrequisitos': this.CC_Solicitud_Informacion_Requisitos__c,
				'solicitudinformacionaportar': this.CC_Solicitud_Informacion_Aportar__c,
				'informacioncondicionesfinanciacion': this.CC_Informacion_Condiciones_Financiacion__c,
				'ofreciosolucionesrefinanciacion': this.CC_Ofrecio_Soluciones_Refinanciacion__c,
				'solicitudcancelacioncontratos': this.CC_Solicitud_Cancelacion_Contratos__c,
				'intervencionFuerzasSeguridad': this.CC_Intervencion_Fuerzas_Seguridad__c,
			},
			camposTexto: {'indicargastos': this.CC_Indicar_Gastos__c
			},
		})

			.then(result => {
				//Clear the user enter values
				//this.accRecord = {};
				//window.console.log('result ===> '+result);
				//Show success messsage
				this.dispatchEvent(new ShowToastEvent({
					title: 'S-Docs',
					message: 'Datos guardados con éxito.',
					variant: 'success'
				}));
			})
			.catch(error => {
				console.log(error);
				this.error = error.message;
			});
	}
}