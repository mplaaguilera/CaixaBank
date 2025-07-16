import {LightningElement, api, track, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';
import getDatos from '@salesforce/apex/CC_Operativa_Oficina_Controller.getDatos';
import crearTarea from '@salesforce/apex/CC_Operativa_Oficina_Controller.crearTarea';
import buscarOficinas from '@salesforce/apex/CC_Operativa_Oficina_Controller.buscarOficinas';
// import buscarEmpleados from '@salesforce/apex/CC_Operativa_Oficina_Controller.buscarEmpleados';
import altaCitaGestor from '@salesforce/apex/CC_Operativa_Oficina_Controller.altaCitaGestor';
import esClienteDigital from '@salesforce/apex/CC_Operativa_Oficina_Controller.esClienteDigital';
import dniTestamentaria from '@salesforce/apex/CC_Operativa_Oficina_Controller.dniTestamentaria';
import crearOportunidad from '@salesforce/apex/CC_Operativa_Oficina_Controller.crearOportunidad';
import realizarTraslado3N from '@salesforce/apex/CC_Operativa_Oficina_Controller.realizarTraslado3N';
import buscarGestoresGlobal from '@salesforce/apex/CC_Operativa_Oficina_Controller.buscarGestoresGlobal';
import getUrlNumeroOficinaApex from '@salesforce/apex/CC_Operativa_Oficina_Controller.getUrlNumeroOficina';
import obtenerGestoresBackup from '@salesforce/apex/CC_Operativa_Oficina_Controller.obtenerGestoresBackup';
import recuperarCampoDerivar from '@salesforce/apex/CC_Operativa_Oficina_Controller.recuperarCampoDerivar';
import obtenerFechasDisponiblidadGestor from '@salesforce/apex/CC_Operativa_Oficina_Controller.obtenerFechasDisponiblidadGestor';
import obtenerHorasDisponiblidadGestor from '@salesforce/apex/CC_Operativa_Oficina_Controller.obtenerHorasDisponiblidadGestor';
import crearNuevoCasoDocumentacion from '@salesforce/apex/CC_Operativa_Oficina_Controller.crearNuevoCasoDocumentacion';
import altaCitaRapida from '@salesforce/apex/CC_WS_Alta_Citas.crearAltaCita';
import crearCasoFraude from '@salesforce/apex/CC_Gestion_Derivar_Fraude.crearCasoFraude';
import llamarOnboarding from '@salesforce/apex/CC_WS_Onboarding.recuperarCliente';
import crearTareaRellamadaApex from '@salesforce/apex/CC_Gestion_Derivar_CSBD.crearTareasRellamada';
import crearOportunidadCSBDApex from '@salesforce/apex/CC_Gestion_Derivar_CSBD.crearOportunidadCSBD';
import crearActividadPhishingSinRiesgo from '@salesforce/apex/CC_Activity.crearActividadPhishingSinRiesgo';
import crearActividadComunidadesPropietarios from '@salesforce/apex/CC_Activity.crearActividadComunidadesPropietarios'; 
import crearActividadCSBDTelefonoNoCoincidente from '@salesforce/apex/CC_Activity.crearActividadCSBDTelefonoNoCoincidente';
import rellenarPreguntasArgos from '@salesforce/apex/CC_Gestion_Derivar_Global.rellenarPreguntasArgos';
import derivarSACApex from '@salesforce/apex/CC_Operativa_Oficina_Controller.derivarSAC';
import devolverSACApex from '@salesforce/apex/CC_Operativa_Oficina_Controller.devolverSAC';
// import emailsAutoEmail from '@salesforce/apex/CC_Gestion_Derivar_Emails_Auto.operativasEmail';
import actualizarDatosCashBack from '@salesforce/apex/CC_Operativa_Oficina_Controller.actualizarDatosCashBack';

import calculoKPI from '@salesforce/apex/CC_Activity.rellenarCalculoKPITareas';
import crearActividadCajeros from '@salesforce/apex/CC_Activity.crearActividadCajeros';
import updateCasoOperativaDerivar from '@salesforce/apex/CC_Operativa_Oficina_Controller.updateCasoOperativaDerivar';
import crearCasoMecanismoFirma from '@salesforce/apex/CC_Gestion_Derivar_Mecanismo_Firma.crearCasoMecanismoFirma';
import elegirCircuitoMecanismoFirma from '@salesforce/apex/CC_Gestion_Derivar_Mecanismo_Firma.elegirCircuitoMecanismoFirma';
import comprobarCasoCreadoMecanismoFirma from '@salesforce/apex/CC_Gestion_Derivar_Mecanismo_Firma.comprobarCasoCreadoMecanismoFirma';
import recuperarArgosMecanismoFirma from '@salesforce/apex/CC_Gestion_Derivar_Mecanismo_Firma.recuperarArgos';
//import recuperarArgosMecanismoFirmaDenied from '@salesforce/apex/CC_Gestion_Derivar_Mecanismo_Firma.recuperarArgosDenied';
//import recuperarArgosMecanismoFirmaRestricted from '@salesforce/apex/CC_Gestion_Derivar_Mecanismo_Firma.recuperarArgosRestricted';

import crearActividadOficinaSinTarea from '@salesforce/apex/CC_Activity.crearActividadOficinaSinTarea';
import envioCorreoOnboarding from '@salesforce/apex/CC_Gestion_Derivar_Onboarding.envioCorreoAutomatico';
import cerrarCasoOnboarding from '@salesforce/apex/CC_Gestion_Derivar_Onboarding.cerrarCaso';

import { createMessageContext} from 'lightning/messageService';

import { CloseActionScreenEvent } from 'lightning/actions';
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";

//agregar al canal de comunicacion entre aura botonera y LWC derivar
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext, publish } from 'lightning/messageService';
import derivarInteraccionChannel from "@salesforce/messageChannel/CC_DerivarInteraccionChannel__c";



//import preguntaEnrollmentDatosSi from '@salesforce/apex/CC_Operativa_Oficina_Controller.preguntaEnrollmentDatosSi';

export default class ccOperativaOficina extends NavigationMixin(LightningElement) {
	
	@api recordId;

	@api oportunidadCreadaAPI;

	@api otpDerivar = null;

	@api derivarB = false;
	
	@track gestores = [];

	//Manejo de mensaje de derivar interaccion
	//@wire(MessageContext)
	//messageContext;
	messageContext = createMessageContext();

	subscription = null;
	//FIN Manejo de mensaje de derivar interaccion
	ambitoMotivo;
	
	showSpinner = false;
		
	mostrarBuscadorOficina = false;

	mostrarModalDNITestamentaria = false;

	textoTestamentariaDocumentacion;

	textoOperativaDerivarOficina;

	textoOperativaDerivarGestor;

	mostrarModalCita;
	
	alertaTexto;
	
	esClienteDigital;
	
	tieneGestor;
	
	numeroGestor;
	
	numeroGestorKO = false;
	
	nombreGestor;

	fecha;
	
	gestorGenerico = false;
	
	oficinaGestor;
	
	nombreGestorAsignado;
	
	gestorAsignadoCoincide = true;
	
	mensajeErrorInt;
	
	cargandoGestor;
	
	gestor;

	dni;
	
	motivoVentas;
	
	cambioOficina = false;
	
	cambioGestor = false;
	
	mostrarModalGestionGestorAsignado;
	
	mostrarModalGestionGestorGenerico;
	
	mostrarModalCreacionTarea;
	
	ocultarOpcionCitaGestor;
	
	fechasDisponibilidad;
	
	horasDisponibilidad;
	
	disponibilidadConsultada;
	
	sinFechasDisponibles = false;
	
	mensajeSinDisponibilidadGestor;
	
	existeBackup = true;

	botonBackupDesactivado = true;

	botonConsultarDisponibilidadDesactivado = true
	
	gestorBackupActivoDos;

	@track gestorBackupActivo = false;
	
	gestorElegido;
	
	nombreGestorElegido;

	fechaElegida;
	
	lookupOficinaResultadoSeleccionado = '';
	
	lookupOficinaInputValue = '';
	
	// lookupEmpleadoInputValue = '';
	
	lookupOficinaResultados = [];
	
	// lookupEmpleadoResultados = [];
	
	oficinaPrincipal;
	
	lookupOficinaTimeout;
	
	lookupGestorResultadoSeleccionado = '';
	
	lookupGestorInputValue = '';
	
	lookupGestorResultados = [];
	
	lookupGestorTimeout;
	
	enviarTareaOficinaCliente = false;
	
	mostrarTareaModalCitaGestor = false;
	
	mostrarBuscadorGestor = false;
	
	crearTareaCitaGestor = false;
	
	tipoCita;
	
	clienteTieneGestor = false;
	
	ocultarBotonCita = true;
	
	horaCitaSelecionada;
	
	grupoColaborador;
	
	preguntaGrupoColaborador;
	
	comentariosTarea;
	
	realizarRemitido;
		
	preguntaCajeros;
	
	preguntaCajerosExternos;
	
	preguntaRealizarRemitido;

	preguntaSenal;

	preguntaSenalAntigua;

	toastRemitir;

	toastCajerosExternos;

	toastDniInvalido;

	urlCajeros;

	_wiredDatosResult;

	toastTrasladarDesdeDerivar;

	derivar = false;

	archivos = [];

	mostrarModalPreguntaRealizarRemitido = false;

	mostrarModalPreguntaEnrollmentDatos= false;

	flowDerivar = false;

	mostrarFlowDerivar = false;

	toastNoClienteError;
	
	//preguntaEnrollment;

	//preguntaEnrollmentDatos;

	toastEnrollmentNo;

	//toastEnrollmentDatosSi;

	//toastEnrollmentDatosNo;

	preguntaCSBDContratar;

	preguntaCSBDContratar2;

	toastCrearOportunidad;

	toastCSBDNoContratar;

	textoMotivoCSBDNoContratar;

	mostrarModalCSBDNoContratar;

	urlTF;

	ambitoFraude;

	realizarRemitidoDesdeMetodo;

	toastCajerosIncidencias;

	tituloCajerosIncidencias;

	toastNoCliente;

	gestorGenericoName;

	citaRapida = false;

	imagin;

	fechaSeleccionada;

	franjaSeleccionada;

	citaRapidaPresencialToast;

	textoOportunidadExistente;

	textoRellamadaCSBDFormalizada;

	textoRellamadaCSBDEnGestion;

	existeOppFormalizada = false; 

	existeOppEnGestion = false;

	existeTareaRellamada = false;

	textoTareaRellamada;

	comentarioTareaRellamada;

	procesandoCreacionTarea = false;

	textoOppTareasCSBD;

	existeOppTareasCSBD = false;

	hubImagin;

	hubGestion;

	gestorSeleccionado;

	numOficina;

	toastRemitirDesdeDerivar;

	textoDocumentacionCertificado;

	documentacionDecisionCaixa;

	mostrarModalResponderCliente;

	toastDocumentacionCasoCreado;

	modalDocumentacionCasoCreado;

	casoCreadoDocumentacion;

	preguntaInformacionCompletaDocumentacion;

	documentacionCaseExtension;

	toastDocumentacionCasoYaCreado;

	motivoDevolucionTemaFraude;

	grupoColaboradorFraudeSI;

	grupoColaboradorFraudeNO;

	//Onboarding/Desistir
	ambitoOnboarding;
	casoAutenticado;
	empresaONB;
	estadoONB;
	fechaEstadoONB;
	motivoCierreONB;
	subestadoONB;
	numSR;
	codigONB;
	textoModalOnboarding;
	textoModalDesistir;
	derivadoBPO;
	textoCorreoEnviado;
	textoModalOnboardingCodigos;
	//Onboarding/Desistir

	casoDerivadoAFraude;

	pulsadoGenerarCasoFraude = false;

	entroCatch = false;

	textoTareaCitaCreada;

	existeTareaCitaCreada= false;

	//Argos

	fraudeANivelDeMotivo;

	operacionMFAArgos;

	grupoColaboradorCyberFraude;

	preguntasArgos;

	diarioMFAArgos;

	preguntaConfirmacionArgos;

	cabeceraPreguntasMFAArgos;

	respuestasPreguntasArgos = [];

	preguntasCompletasArgos = true;

	preguntasArgosActivas = false;

	preguntaConfirmacionArgosActiva = false;

	preguntaConfirmacionArgos;

	cyberfraude;

	cybersoc;

	trasladarDocumentacion;

	//Argos

	//Success Toast 

	mostrarModalToast = false;
	mensajeMostrarModalToast = '';
	
	mostrarModalToastUrl = false;
	mensajeMostrarModalToastUrl = '';

	urlOficina;

	numeroOficina;
	//Success Toast

	//CSBD
	ambitoCSBD;

	preguntaTelefonoCSBD;

	preguntaTelefonoCSBDNoEncontrado;

	botonDesabilitado = false;
	
	//CSBD

	//Phising/Smishing/Malware
	PhisingSmishingMalware1;
	PhisingSmishingMalware2;
	PhisingSmishingMalware3;
	PhisingSmishingMalware5;
	PhisingSmishingMalware6;
	@track mostrarPregunta = false;
	procesandoCreacionTareaPhishingSinRiesgo = false;
	//Phising/Smishing/Malware

	//CashBack
	CashBack1;
	CashBack2;
	CashBack3;
	CashBack4;
	CashBack5;
	fechaCompra;
	nombreComercio;
	idCliente;
	//CashBack

	//Refinanciación Deudas
	RefinanciacionDeudas1;
	RefinanciacionDeudas2;
	RefinanciacionDeudas3;
	RefinanciacionDeudas4;
	//Refinanciación Deudas

	// // //Amenazas
	// mensajeSolicitudDatosAmenazasEmpleados;

	// oficinaAmenazadaSeleccionada;

	// empleadoAmenazadoSeleccionado;

	// motivoAmenazaInputValue = '';

	// detalllesAmenazaInputValue = '';

	// motivoAmenazaSuicidiosInputValue = '';

	// direccionAmenazasSuicidiosInputValue = '';

	// mensajeSolicitudDatosAmenazasSuicidios;

	// emailSuccess;

	// nombrePlantilla;

	// parametrizacionesMensaje = [];

	// grupoCol;

	// nameOWA;
	// // //Amenazas

	//MECANISMO FIRMA
	
	preguntaMecanismoFirma;

	preguntaMecanismoFirmaDatos;

	preguntaMecanismoFirmaDatosValores;
	
	preguntaMecanismoFirmaIdentificador;

	toastMecanismoFirmaDatosIncompletos;

	toastMecanismoFirmaIdentificadorBloqueado;

	toastMecanismoFirmaIdentificadorSinBloquear;

	toastMecanismoFirmaArgosCorrecto;

	preguntaMecanismoFirmaClienteAutenticado;

	toastMecanismoFirmaAsuntoEnvioCodigo;

	respuestasMecanismoFirmaDatos = [];

	preguntasCompletasMecanismoFirma = false;

	circuitoExtranjero;

	circuitoCodigoFirma;

	cybersocMF;

	toastMecanismoFirmaCasoCreado;

	mostrarModalTrasladarGrupoColaborador = false;
	
	//MECANISMO FIRMA

	//Oficina sin tarea
	mensajeOficinaSinTarea;

	//Oficina sin tarea

	//Accionistas

	mensajeDerivarAccionistas;

	//Accionistas

	//Colectivo vulnerable
	
	//mensajeColectivosVulnerables;

	//Colectivo vulnerable

	mostrarNoGestor = true;

	//Derivar/Devolver SAC
	mostrarDerivarSAC = false;
	mostrarDevolverSAC = false;
	mostrarCanalProcedenciaErroneo = false;
	mensajeDerivarAlSAC;
	mensajeDerivarAlSACSuccess;
	mensajeDevolverAlSAC;
	mensajeDevolverAlSACSuccess;
	mensajeCanalProcedenciaErroneo;
	motivoSAC;
	casoActual;
	//Derivar/Devolver SAC

	filterGestor = {
		criteria: [
			{
				fieldPath: 'RecordType.DeveloperName',
				operator: 'eq',
				value: 'CC_Empleado'
			},
			{
				fieldPath: 'Account.RecordType.DeveloperName',
				operator: 'eq',
				value: 'CC_CentroCaixaBank'
			}
		]
	};
	
	displayInfoGestor = {
		primaryField: 'Name',
		additionalFields: ['CC_Matricula__c']
	};
	
	opcionesCitaDigital = [{label: 'Cita telefónica', value: '43'}];
	
	opcionesCita = [
		{label: 'Cita presencial', value: '42'},
		{label: 'Cita telefónica', value: '43'}
	];

	opcionesCitaRapida = [];
	
	connectedCallback(){
		this.grupoColaborador = [];
		this.subscribeToMessageChannel();
	}

	//KPI
	//Manejo de mensaje de derivar interaccion
	subscribeToMessageChannel() {
		if (!this.subscription) {
		  this.subscription = subscribe(
			this.messageContext,
			derivarInteraccionChannel,
			(message) => this.procesarMensajeDerivarInteraccion(message),
			{ scope: APPLICATION_SCOPE },
		  );
		}
	}

	unsubscribeToMessageChannel() {
		unsubscribe(this.subscription);
		this.subscription = null;
	}

	procesarMensajeDerivarInteraccion(message) {
	}	

	publicarMensajeDerivarInteraccion(origenDerivacion, destinoDerivacion, datosAdicionales){
		if(this.messageContext){
			const payload = { 
				recordId: this.recordId, 
				origen: origenDerivacion,
				destino: destinoDerivacion,
				datosAdicionales: datosAdicionales
			};
			publish(this.messageContext, derivarInteraccionChannel, payload);
		}
	}
	//FIN Manejo de mensaje de derivar interaccion
	
	@wire(getDatos, {recordId: '$recordId', otpDerivar: '$otpDerivar'})
	wiredDatos(response) {

		let error = response && response.error;
		let data = response && response.data;
		this._wiredDatosResult = response;
		refreshApex(this._wiredDatosResult);
		if (error) {
			this.toast('error', 'Problema recuperando los datos principales', error.body.message);
			this._wiredDatosResult = false;
			
		} else if (data) {
			const resultado = data;
			this.fecha = new Date().toISOString().substring(0, 10);
			this.derivar = resultado.derivar;
			this.toastTrasladarDesdeDerivar = resultado.toastTrasladarDesdeDerivar;
			this.toastRemitirDesdeDerivar = resultado.toastRemitirDesdeDerivar;
			this.ambitoFraude = resultado.ambitoFraude;
			this.ambitoMotivo = resultado.ambitoMotivo;
			this.grupoColaborador = resultado.grupoColaborador;
			this.alertaTexto = resultado.alerta;
			this.toastCSBDNoContratar = resultado.toastCSBDNoContratar;
			this.textoMotivoCSBDNoContratar = resultado.textoMotivoCSBDNoContratar;
			this.toastNoClienteError = resultado.toastNoClienteError;
			this.toastTrasladar3N = resultado.toastTrasladar3N;
			this.realizarRemitidoDesdeMetodo = resultado.realizarRemitido;
			this.toastCajerosIncidencias = resultado.toastCajerosIncidencias;
			this.tituloCajerosIncidencias = resultado.tituloCajerosIncidencias;
			this.toastNoCliente = resultado.toastNoCliente;
			this.oficinaPrincipal = resultado.oficinaPrincipal;
			this.numOficina = resultado.numOficina;
			this.gestorGenericoName = resultado.gestorGenericoName;
			this.citaRapida = resultado.citaRapida;
			this.preguntaCSBDContratar = resultado.preguntaCSBDContratar;
			this.preguntaCSBDContratar2 = resultado.preguntaCSBDContratar2;
			this.toastCrearOportunidad = resultado.toastCrearOportunidad;
			this.preguntaCajeros = resultado.preguntaCajeros;
			this.preguntaCajerosExternos = resultado.preguntaCajerosExternos;
			this.toastCajerosExternos = resultado.toastCajerosExternos;
			this.urlCajeros = resultado.urlCajeros;
			this.preguntaSenal = resultado.preguntaSenal;
			this.preguntaSenalAntigua = resultado.preguntaSenalAntigua;
			this.toastRemitir = resultado.toastRemitir;
			this.preguntaRealizarRemitido = resultado.preguntaRealizarRemitido;
			this.preguntaGrupoColaborador = resultado.preguntaGrupoColaborador;
			this.gestor = resultado.gestor;
			this.motivoVentas = resultado.motivoVentas;
			this.mostrarModalGestionGestorAsignado = resultado.mostrarModalGestionGestorAsignado;
			this.mostrarModalGestionGestorGenerico = resultado.mostrarModalGestionGestorGenerico;
			this.mostrarModalCreacionTarea = resultado.mostrarModalCreacionTarea;
			this.mostrarModalDNITestamentaria = resultado.mostrarModalDNITestamentaria;
			this.textoTestamentariaDocumentacion = resultado.textoTestamentariaDocumentacion;
			this.textoOperativaDerivarOficina = resultado.textoOperativaDerivarOficina;	
			this.textoOperativaDerivarGestor = resultado.textoOperativaDerivarGestor;
			this.mostrarModalResponderCliente = resultado.mostrarModalResponderCliente;
			this.textoDocumentacionCertificado = resultado.textoDocumentacionCertificado;
			this.preguntaInformacionRequeridaDocumentacion = resultado.preguntaInformacionRequeridaDocumentacion;
			this.preguntaInformacionCompletaDocumentacion = resultado.preguntaInformacionCompletaDocumentacion;
			this.toastDocumentacionCasoCreado = resultado.toastDocumentacionCasoCreado;
			this.modalDocumentacionCasoCreado = resultado.modalDocumentacionCasoCreado;
			this.toastDocumentacionCasoYaCreado = resultado.toastDocumentacionCasoYaCreado;
			this.documentacionCaseExtension = resultado.documentacionCaseExtension;
			//this.toastDniInvalido = resultado.toastDniInvalido;
			this.cambioOficina = resultado.cambioOficina;
			this.cambioGestor = resultado.cambioGestor;
			this.clienteTieneGestor = resultado.clienteTieneGestor;
			this.flowDerivar = resultado.flowDerivar;
			this.urlTF = resultado.urlTF;
			this.numperso = resultado.numperso;
			this.nif = resultado.nif;
			this.imagin = resultado.imagin;
			this.citaRapidaPresencialToast = resultado.citaRapidaPresencialToast;
			this.oportunidadCreada = resultado.oportunidadCreada;
			this.casoDerivadoAFraude = resultado.casoDerivadoAFraude;
			this.oficinaFisica = resultado.oficinaFisica;
			this.documentacionDecisionCaixa = resultado.documentacionDecisionCaixa;
			this.motivoDevolucionTemaFraude = resultado.motivoDevolucionTemaFraude;
			this.grupoColaboradorFraudeSI = resultado.grupoColaboradorFraudeSI;
			this.grupoColaboradorFraudeNO = resultado.grupoColaboradorFraudeNO;
			
			if(this.oportunidadCreadaAPI || this.oportunidadCreada){
				this.textoOportunidadExistente = resultado.textoOportunidadExistente;
			}
			if(this.casoDerivadoAFraude){
				this.textoOportunidadExistente = resultado.textoOportunidadExistente;
			}
			this.hubImagin = resultado.hubImagin;
			this.hubGestion = resultado.hubGestion;
			
			this.fraudeANivelDeMotivo = resultado.fraudeANivelDeMotivo;
			//Argos
			this.preguntasArgos = resultado.preguntasArgos;
			this.diarioMFAArgos = resultado.diarioMFAArgos;
			this.preguntaConfirmacionArgos = resultado.preguntaConfirmacionArgos;
			this.operacionMFAArgos = resultado.operacionMFAArgos;
			this.cabeceraPreguntasMFAArgos = resultado.cabeceraPreguntasMFAArgos;
			this.cyberfraude = resultado.cyberfraude;
			this.cybersoc = resultado.cybersoc;
			//Argos

			
			//Phising/Smishing/Malware
			this.PhisingSmishingMalware1 = resultado.PhisingSmishingMalware1;
			this.PhisingSmishingMalware2 = resultado.PhisingSmishingMalware2;
			this.PhisingSmishingMalware3 = resultado.PhisingSmishingMalware3;
			this.PhisingSmishingMalware5 = resultado.PhisingSmishingMalware5;
			this.PhisingSmishingMalware6 = resultado.PhisingSmishingMalware6;
			//Phising/Smishing/Malware

			//CashBack
			this.CashBack1 = resultado.CashBack1;
			this.CashBack2 = resultado.CashBack2;
			this.CashBack3 = resultado.CashBack3;
			this.CashBack4 = resultado.CashBack4;
			this.CashBack5 = resultado.CashBack5;
			//CashBack

			//Refinanciación Deudas
			this.RefinanciacionDeudas1 = resultado.RefinanciacionDeudas1;
			this.RefinanciacionDeudas2 = resultado.RefinanciacionDeudas2;
			this.RefinanciacionDeudas3 = resultado.RefinanciacionDeudas3;
			this.RefinanciacionDeudas4 = resultado.RefinanciacionDeudas4;
			//Refinanciación Deudas

			//CSBD
			this.ambitoCSBD = resultado.ambitoCSBD;
			this.preguntaTelefonoCSBD = resultado.preguntaTelefonoCSBD;
			this.preguntaTelefonoCSBDNoEncontrado = resultado.preguntaTelefonoCSBDNoEncontrado;
			//CSBD

			//Migración de toast success 
			this.mensajeMostrarModalToast = resultado.mensajeMostrarModalToast;
			this.mostrarModalToast = resultado.mostrarModalToast;
			//Migración de toast success

			//Accionistas
			this.mensajeDerivarAccionistas = resultado.mensajeDerivarAccionistas;
			//Accionistas

			//Mecanismo firma
			
			this.preguntaMecanismoFirma = resultado.preguntaMecanismoFirma;
			this.preguntaMecanismoFirmaDatos = resultado.preguntaMecanismoFirmaDatos;
			this.preguntaMecanismoFirmaDatosValores = resultado.preguntaMecanismoFirmaDatosValores;
			this.toastMecanismoFirmaIdentificadorBloqueado = resultado.toastMecanismoFirmaIdentificadorBloqueado;		
			this.toastMecanismoFirmaIdentificadorSinBloquear = resultado.toastMecanismoFirmaIdentificadorSinBloquear;		
			this.toastMecanismoFirmaArgosCorrecto = resultado.toastMecanismoFirmaArgosCorrecto;		
			this.preguntaMecanismoFirmaClienteAutenticado = resultado.preguntaMecanismoFirmaClienteAutenticado;		
			this.toastMecanismoFirmaAsuntoEnvioCodigo = resultado.toastMecanismoFirmaAsuntoEnvioCodigo;
			this.preguntaMecanismoFirmaIdentificador = resultado.preguntaMecanismoFirmaIdentificador;
			this.toastMecanismoFirmaDatosIncompletos = resultado.toastMecanismoFirmaDatosIncompletos;
			this.circuitoExtranjero = resultado.circuitoExtranjero;
			this.circuitoCodigoFirma = resultado.circuitoCodigoFirma;
			this.cybersocMF = resultado.cybersocMF;
			this.toastMecanismoFirmaCasoCreado = resultado.toastMecanismoFirmaCasoCreado;
			
			//Mecanismo firma

			//Oficina sin tarea
			this.mensajeOficinaSinTarea = resultado.mensajeOficinaSinTarea;
			//Oficina sin tarea


			//Comunidades de propietarios
			this.detallesConsulta = resultado.detallesConsulta;
			//Comunidades de propietarios
/*
			//Colectivo vulnerable
			this.mensajeColectivosVulnerables = resultado.mensajeColectivosVulnerables;
			//Colectivo vulnerable
*/
			//Cita normal
			this.mensajeSinDisponibilidadGestor = resultado.mensajeSinDisponibilidadGestor;

			// //Amenazas empleados
			// this.mensajeSolicitudDatosAmenazasEmpleados = resultado.mensajeSolicitudDatosAmenazasEmpleados;
			// this.emailSuccess = resultado.emailSuccess;
			// this.nombrePlantilla = resultado.nombrePlantilla;
			// this.grupoCol = resultado.grupoCol;
			// //Amenazas empleados

			// //Amenazas suicidios
			// this.mensajeSolicitudDatosAmenazasSuicidios = resultado.mensajeSolicitudDatosAmenazasSuicidios;
			// this.nameOWA = resultado.nameOWA;
			// //Amenazas suicidios

			//Derivar/Devolver SAC
			this.mostrarDerivarSAC = resultado.mostrarDerivarSAC;
			this.mostrarDevolverSAC = resultado.mostrarDevolverSAC;
			this.mostrarCanalProcedenciaErroneo = resultado.mostrarCanalProcedenciaErroneo;
			this.mensajeDerivarAlSAC = resultado.mensajeDerivarAlSAC;
			this.mensajeDerivarAlSACSuccess = resultado.mensajeDerivarAlSACSuccess;
			this.mensajeDevolverAlSAC = resultado.mensajeDevolverAlSAC;
			this.mensajeDevolverAlSACSuccess = resultado.mensajeDevolverAlSACSuccess;
			this.mensajeCanalProcedenciaErroneo = resultado.mensajeCanalProcedenciaErroneo;
			this.casoActual = resultado.casoActual;
			//Derivar/Devolver SAC

			//Onboarding/Desistir
			this.ambitoOnboarding = resultado.ambitoOnboarding;
			this.casoAutenticado = resultado.casoAutenticado;
			this.empresaONB = resultado.empresaONB;
			this.estadoONB = resultado.estadoONB;
			this.subestadoONB = resultado.subestadoONB;
			this.fechaEstadoONB = resultado.fechaEstadoONB;
			this.motivoCierreONB = resultado.motivoCierreONB;
			this.numSR = resultado.numSR;
			this.codigONB = resultado.codigONB;
			this.textoModalOnboarding = resultado.textoModalOnboarding;
			this.textoModalDesistir = resultado.textoModalDesistir;
			this.derivadoBPO = resultado.derivadoBPO;
			this.textoCorreoEnviado = resultado.textoCorreoEnviado;
			this.textoModalOnboardingCodigos = resultado.textoModalOnboardingCodigos;
			//Onboarding/Desistir

			this.ocultarModalTrasladar = resultado.ocultarModalTrasladar;

			if(this.grupoColaborador && !this.ocultarModalTrasladar){
				this.mostrarModalTrasladarGrupoColaborador = true;
			} else {
				this.mostrarModalTrasladarGrupoColaborador = false;
			}
			
			if(this.imagin) {
				this.tipoCita = 43;
			}
			if(this.oficinaPrincipal) {
				for(let i = 0; i < resultado.gestores.length; i++) {
					this.gestores.push({label: resultado.gestores[i].Name, value: resultado.gestores[i].Id});
				}
			}
			if(this.toastTrasladar3N && !this.alertaTexto && !this.ambitoFraude && !this.grupoColaborador && !this.preguntaTelefonoCSBD) {
				this.realizarTraslado3N();
			}
			if(this.realizarRemitidoDesdeMetodo && !this.alertaTexto && !this.grupoColaborador && !this.ambitoFraude) {
				this.handleRemitir();
			} else if (this.realizarRemitidoDesdeMetodo && (this.alertaTexto || this.grupoColaborador || this.ambitoFraude)) {
				this.abrirModal();
			}
			if(this.toastCSBDNoContratar && !this.alertaTexto && !this.grupoColaborador && !this.ambitoFraude && !this.oportunidadCreadaAPI && !this.textoDocumentacionCertificado) {
				this.crearOportunidad();
			}
			if(this.toastCajerosIncidencias && !this.alertaTexto && !this.grupoColaborador && !this.ambitoFraude) {
				//this.toast('error', this.tituloCajerosIncidencias, resultado.toastCajerosIncidencias);
				this.handleModalToast(this.toastCajerosIncidencias);
				
			} else if (this.toastCajerosIncidencias && (this.alertaTexto || this.grupoColaborador || this.ambitoFraude)) {
				this.abrirModal();
			}

			if(this.toastNoClienteError && !this.alertaTexto && !this.grupoColaborador && !this.ambitoFraude) {
				//this.toast('error', 'Error en los datos', resultado.toastNoClienteError);
				this.handleModalToast(resultado.toastNoClienteError);
				
			} else {
				this.abrirModal();
			}
			/*if(resultado.preguntaEnrollment){
				this.preguntaEnrollment= resultado.preguntaEnrollment;
				this.preguntaEnrollmentDatos= resultado.preguntaEnrollmentDatos;
				//this.toastEnrollmentNo = resultado.toastEnrollmentNo;
				this.toastEnrollmentDatosSi = resultado.toastEnrollmentDatosSi;
				this.toastEnrollmentDatosNo = resultado.toastEnrollmentDatosNo;
			}*/
			if(this.preguntaRealizarRemitido) {
				if(!this.toastCajerosIncidencias && !this.alertaTexto && !this.grupoColaborador && !this.ambitoFraude) {
					this.abrirModal();
				}
			}
			if(resultado.comentarioCambioGestor) {
				this.comentariosTarea = resultado.comentarioCambioGestor;
			} else if(resultado.comentarioCambioOficina) {
				this.comentariosTarea = resultado.comentarioCambioOficina;
			}
			if((this.grupoColaborador === null || this.grupoColaborador === undefined) && this.flowDerivar === true){
				this.mostrarFlowDerivar = this.flowDerivar;
			}
			if(this.comentariosTarea === undefined) {
				this.comentariosTarea = resultado.detallesConsulta;
			}				
			if (!this.alertaTexto && !this.toastTrasladar3N && !this.toastCSBDNoContratar && !this.preguntaTelefonoCSBD) {
				this.handleContinuarProceso();
			}
			this.llamadaIntegracionClienteDigital();
			if(!resultado.toastCajerosIncidencias && !this.alertaTexto && !this.grupoColaborador && !this.ambitoFraude && !this.realizarRemitidoDesdeMetodo) {
				this.abrirModal();
			}
			if(this.nif != null && this.nif.startsWith('H')){ // Comunidades de propietarios
				crearActividadComunidadesPropietarios({recordId: this.recordId, detallesConsulta: this.detallesConsulta, mensaje: this.mensajeMostrarModalToast})
				.catch(error => {
					console.error(error);
					this.cerrarModal();
				});
			}

			if(resultado.opcionesCitaRapida && this.citaRapida){		
				this.opcionesCitaRapida = Object.entries(resultado.opcionesCitaRapida).map(([key, value]) => ({
					label: key, // Cita presencial, o Cita telefonica
					value: value   // 42 o 43
				}));
			}

			//Oficina sin tarea
			if(this.mensajeOficinaSinTarea){
				//this.handleModalToast(this.mensajeOficinaSinTarea);
				this.handleOficinaSinTarea();
			}
			//Oficina sin tarea
/*
			//Colectivo vulnerable
			if(this.mensajeColectivosVulnerables){
				const fechaActividad = new Date().toISOString().slice(0,16);

				this.enviarTareaOficinaCliente = true;

				this.handleModalToast(this.mensajeColectivosVulnerables);
				crearTarea({					
					recordId: this.recordId,
					asunto: 'Solicitud contacto gestor (Contact Center)',
					fechaActividad: fechaActividad,
					enviarTareaOficinaCliente: this.enviarTareaOficinaCliente

				}).then(resultado => {
				/*if (resultado.existeTareaCitaCreada) {
					this.handleModalToast(resultado.textoTareaCitaCreada);
				} 
			}).catch(error => {
				console.error(error);
				this.handleModalToast(error.body.message);
			});
			}
			//Colectivo vulnerable*/

			//TEST MMC
		}
		
		updateCasoOperativaDerivar({recordId: this.recordId})
		.then(resultado => {
		})
		.catch(error => {
		});
		window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('desactivarspinner', { bubbles: true, detail: {data: null}})), 400);
	}

	async recuperarCampoDerivar() {
		let resultado = false;
		recuperarCampoDerivar({recordId: this.recordId})
		.then(retorno => {
			resultado = retorno;
		})
		.catch(error => {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos de campo derivar', error.body.message);
			this.cerrarModal();
		}).finally(() => this.derivar = resultado);
	}
	
	abrirModal() {
		if (this.documentacionCaseExtension) {
			this.toast('error', 'No se puede derivar este caso', this.toastDocumentacionCasoYaCreado);
			this.cerrarModal();
		} else {
			this.template.querySelector('.modal')?.classList.add('slds-fade-in-open');
			this.template.querySelector('.backdrop')?.classList.add('slds-backdrop--open');
		}
		const customEvent = new CustomEvent('abrirmodal', {
            detail: {data: null}
        });
        this.dispatchEvent(customEvent);
	}

	// get backdropClass() {
    //     return this.backgroundblack ? 'fullscreen-backdrop' : 'slds-backdrop slds-backdrop_open';
    // }
	
	cerrarModal() {

		this.template.querySelector('.backdrop')?.classList.remove('slds-backdrop--open');
		this.template.querySelector('.modal')?.classList.remove('slds-fade-in-open');
		this.dispatchEvent(new CloseActionScreenEvent());
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		//window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('modalcerrado', {detail: {data: null}})), 400);
		const customEvent = new CustomEvent('modalcerrado', {
            detail: {data: null}
        });
        this.dispatchEvent(customEvent);
	}
	
	handleContinuarProceso() {
		this.alertaTexto = false;
		if((!this.grupoColaborador || this.toastTrasladar3N) && !this.ambitoFraude && !this.preguntaTelefonoCSBD) {
			this.handleGrupoColaboradorDerivar();
		}
		if (this.mostrarModalCita) {
			this.mostrarModalCita = false;
		}
	}
	
	ocultarModalCitaGestor() {
		this.mostrarModalCita = false;
		this.mostrarModalCreacionTarea = true;
		this.crearTareaCitaGestor = true;
	}

	handleUploadFinished(event) {
		const uploadedFiles = event.detail.files;
		
		this.archivos = uploadedFiles;
	}
	
	handleCrearTareaGestor() {
		if(!this.template.querySelector('.comentariosTarea').value || !this.template.querySelector('.fechaActividad').value) {
			this.toast('warning', 'Campos vacíos', 'Por favor, informe todos los campos del formulario');
		} else if(this.cambioGestor && !this.gestorSeleccionado) {
			this.toast('warning', 'Campos vacíos', 'Por favor, seleccione un gestor');
		} else if(this.cambioOficina && !this.lookupOficinaResultadoSeleccionado) {
			this.toast('warning', 'Campos vacíos', 'Por favor, seleccione una oficina');
		} else {
			this.showSpinner = true;
			crearTarea({
				recordId: this.recordId,
				asunto: 'Solicitud contacto gestor (Contact Center)',
				fechaActividad: this.template.querySelector('.fechaActividad').value,
				comentarios: this.template.querySelector('.comentariosTarea').value,
				archivos : this.archivos == null ? null : this.archivos.map(item => item.contentVersionId),
				oficinaDestino: this.lookupOficinaResultadoSeleccionado.Id,
				enviarTareaOficinaCliente: this.enviarTareaOficinaCliente,
				crearTareaCitaGestor: this.crearTareaCitaGestor,
				gestorSeleccionadoBuscador: this.lookupGestorResultadoSeleccionado,
				otpDerivar : this.otpDerivar
			}).then(resultado => {
				if (resultado.existeTareaCitaCreada) {
					this.showSpinner = false;
					this.mostrarModalCreacionTarea = false;
					this.handleModalToast(resultado.textoTareaCitaCreada);
					
				} else {
					if(resultado.contactoSinAccount){
						this.handleModalToast(resultado.contactoSinAccount);
					} else {
						if (!resultado.cuenta || !resultado.cuenta.Id) {
							this.showSpinner = false;
							this.handleModalToast(resultado.mensaje);
						} else {
							this.mostrarToastOficinaResultado(resultado.mensaje, resultado.cuenta.Id);
						}
						if(resultado.gestorNoEncontradoEnSalesforce) {
							this.toast('warning', 'Gestor no encontrado', resultado.mensajeGestorNoEncontrado);
							this.enviarTareaOficinaCliente = true;
							this.crearTareaCitaGestor = false;
						} 
					}
					
				}

			}).catch(error => {
				console.error(error);
				this.handleModalToast(error.body.message);
				
			});
		}
	}
	
	mostrarToastOficinaResultado(mensajeToast, idCuenta) {
			getUrlNumeroOficinaApex({recordId: idCuenta})
			.then(resultado => {
				if (resultado.url) {
					this.urlOficina = resultado.url;
          			this.numeroOficina = resultado.numeroOficina;
					this.mostrarModalToast = false;
					this.showSpinner = false;

					this.handleModalToastUrl(mensajeToast);
				}
			});
		

		/*
		getUrlNumeroOficinaApex({recordId: idCuenta})
		.then(resultado => {
			if (resultado.url) {
				this.toast('success', tipo + ' creada con éxito', mensajeToast + ' {1}', ['Salesforce', {//duda toast
					url: resultado.url, label: resultado.numeroOficina
				}]);
			}
		});*/
	}
	
	toast(variant, title, message, messageData) {
		
			this.dispatchEvent(new ShowToastEvent({
				variant,
				title,
				message,
				mode: messageData ? 'sticky' : 'dismissable',
				duration: messageData ? null : 9000,
				messageData
			}));
		
	}

	
	async llamadaIntegracionClienteDigital() {
		this.cargandoGestor = true;
		try {
			const resultado = await esClienteDigital({recordId: this.recordId, tipoActividad: ''});
			if (resultado.resultado === 'OK') {
				this.esClienteDigital = resultado.clienteDigital;
				if(this.esClienteDigital) {
					this.tipoCita = 43;
				}
				if (resultado.empleado1) {
					this.tieneGestor = true;
					this.numeroGestor = resultado.empleado1;
					this.nombreGestor = resultado.gestorClienteName;
					this.oficinaGestor = resultado.oficina1;
					if (this.oficinaGestor === '3223' || this.oficinaGestor === '03223') {
						this.ocultarOpcionCitaGestor = true;
						this.tipoCita = 43;
					}
				} else {					
					if (resultado.gestorClienteName === this.gestorGenericoName) {
						this.nombreGestor = resultado.gestorClienteName;
						this.gestorGenerico = true;
						this.nombreGestorAsignado = resultado.nombreGestorAsignado;
					}
				}
				if (resultado.gestorAsignadoCoincide === 'false') {
					this.gestorAsignadoCoincide = false;
					this.nombreGestorAsignado = resultado.nombreGestorAsignado;
				}
			} else if (resultado.resultado === 'KO') {
				this.numeroGestor = 'KO';
				this.numeroGestorKO = true;
				this.mensajeErrorInt = resultado.mensajeError;
			}
		} catch (error) {
			console.error(error);
			this.handleModalToast(error.body.message);
		} finally {
			this.cargandoGestor = false;
			this.gestorBackup();
		}

	}
	
	modalTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.cerrarModal();
		}
	}
	
	handleAbrirModalCita() {
		this.mostrarModalCita = true;
		this.mostrarModalGestionGestorAsignado = false;
	}
	
	handleGestionGestorDistintoSi() {
		if(this.citaRapida) {
			if(this.numOficina === 'carteraVacia'){
				this.mostrarModalCita = false;
				//this.toast('error', 'Cartera no encontrada','No se encuentra la cartera asignada al cliente');
				this.handleModalToast('No se encuentra la cartera asignada al cliente');
				
			} else {
				this.mostrarModalCita = true;
			}
		} else {
			this.mostrarModalCreacionTarea = true;
			this.enviarTareaOficinaCliente = true;
			this.mostrarModalCita = false;
		}
		this.mostrarModalGestionGestorGenerico = false;
	}
	
	handleGestionGestorDistintoNo() {
		this.mostrarModalCreacionTarea = true;
		this.mostrarModalGestionGestorGenerico = false;
		this.enviarTareaOficinaCliente = false;
		this.cambioOficina = true;
		this.mostrarBuscadorOficina = true;
	}
	
	handleGestionGestorAsignadoNo() {
		this.mostrarModalCreacionTarea = true;
		this.mostrarModalGestionGestorAsignado = false;
		this.mostrarBuscadorGestor = true;
	}
	
	resetDisponibilidadConsultada(event) {
		this.disponibilidadConsultada = false;
		this.ocultarBotonCita = true;
		this.tipoCita = event.target.value;
		this.sinFechasDisponibles = false;
	}

	//Backup gestores -> Llamado desde cliente digital
	gestorBackup(){
		//Recoge los gestores backup disponibles, en el caso de que los haya, rellena la variable gestoresBackup y activa el boton
		obtenerGestoresBackup({recordId: this.recordId, employeeId: this.numeroGestor, gestorElegidoId: this.numeroGestor, eventType: this.tipoCita})
			.then(resultado => {
				this.gestoresBackup = resultado;
				if (this.gestoresBackup !== null && this.gestoresBackup !== undefined && this.gestoresBackup.length !== 0) {
					this.existeBackup = true;
					this.botonBackupDesactivado = false;
				}
			})
			.catch(error => {
				this.botonBackupDesactivado = true;
				console.error(error);
			})
	}
	
	//Backup gestores -> Llamado desde el checkbox de 'Otros gestores'
	mostrarGestorBackup(event) {
		this.gestorBackupActivo = event.target.checked;
		//Oculta los elementos que contienen lo necesario para el gestor backup
		if (this.gestorBackupActivo) {
			//se vacían los valores de búsqueda
			//Fechas y horas de disponibilidad
			this.fechasDisponibilidad = null;
			this.horasDisponibilidad = null;
			//Comprobación de si se ha consultado la disponibilidad, oculta y muestra el botón disponibilidad consultada, que muestra las horas de las citas
			this.disponibilidadConsultada = false;
			//Bloquea el botón cita
			this.ocultarBotonCita = true;
			//Determina si se ha devuelto algún gestor backup
			if(this.gestoresBackup !== null && this.gestoresBackup !== undefined && this.gestoresBackup.length !== 0){
				this.existeBackup = true;
				//Muestra los campos referentes al backup
				this.gestorBackupActivoDos = true;
			} else {
				this.existeBackup = false
				this.botonBackupDesactivado = false;
			}
		} else {
			this.gestor
			this.gestorBackupActivoDos = false;
			this.fechasDisponibilidad = null;
			this.horasDisponibilidad = null;
			this.disponibilidadConsultada = false;
			this.ocultarBotonCita = true;
			this.gestorSeleccionado = null;
			this.nombreGestorElegido = null;
			this.gestorElegido = null;
			this.botonConsultarDisponibilidadDesactivado = true
		}
	}

	//Backup gestores ->  Carga los gestores backup en el desplegable
	gestorBackupOnChange(event){
		this.gestorSeleccionado = event.target.value;
		this.gestorElegido = event.target.value;
		this.nombreGestorElegido = this.gestoresBackup.find(el => el.value === this.gestorSeleccionado)?.label ?? null;
		this.botonConsultarDisponibilidadDesactivado = this.gestorSeleccionado !== null && this.gestorSeleccionado !== undefined ? false : true;
		this.disponibilidadConsultada = false;
		//this.consultarFechasDisponibilidadBackup(event);
	}
	
	//Backup gestores -> Carga las fechas de disponibilidad del gestor seleccionado, se realiza al pulsar el boton consultar disponibilidad
	consultarFechasDisponibilidadBackup(event) {
		if(this.gestorSeleccionado !== undefined && this.gestorSeleccionado !== null){
			//Busca las fechas del gestor que se ha seleccionado, referenciando al caso y el tipo de cita que se ha seleccionado
			obtenerFechasDisponiblidadGestor({recordId: this.recordId, employeeId: this.gestorSeleccionado, gestorElegidoId: this.gestorSeleccionado, eventType: this.tipoCita})
			.then(resultado => {
				//Oculta el boton de consultar disponibilidad y asigna las fechas, en caso de no encontrar fechas, se muestra un mensaje
				this.disponibilidadConsultada = true;
				this.ocultarBotonCita = false;
				this.fechasDisponibilidad = resultado;
				if(this.fechasDisponibilidad === null || this.fechasDisponibilidad.length === 0 || this.fechasDisponibilidad === undefined) {
					this.sinFechasDisponibles = true;
					this.ocultarBotonCita = true;
				}
			})
			.catch(error => {
				console.error(error);
				this.handleModalToast(error.body.message);
			});
		}
	}

	//Backup gestores -> Carga las horas de disponibilidad del gestor seleccionado, se realiza al rellenar la fecha de disponibilidad
	consultarHorasDisponibilidadBackup(event) {
		let fechasDisponibilidad = this.template.querySelector('.fechasDisponibilidad').value;
		this.fechaSeleccionada = this.template.querySelector('.fechasDisponibilidad').value;
		obtenerHorasDisponiblidadGestor({recordId: this.recordId, employeeId: this.gestorSeleccionado, gestorElegidoId: this.gestorSeleccionado, eventType: this.tipoCita, fechaElegida: fechasDisponibilidad})
		.then(resultado => {
			//Establece las horas de disponibilidad
			this.horasDisponibilidad = resultado;
		})
		.catch(error => {
			console.error(error);
			this.handleModalToast(error.body.message);
		});	
		
	}
	//Backup gestores
	setHorasDisponibilidadGestorBackup(event){
		this.horaCitaSelecionada = event.target.value;
	}
	
	consultarFechasDisponibilidadGestor() {
		var codigoEvento;
		if(this.tipoCita == 'Cita telefónica') {
			codigoEvento = '43';
		} else {
			codigoEvento = '42';
		}
		obtenerFechasDisponiblidadGestor({recordId: this.recordId, employeeId: this.numeroGestor, gestorElegidoId: this.numeroGestor, eventType: codigoEvento})
		.then(resultado => {
			this.disponibilidadConsultada = true;
			this.ocultarBotonCita = false;
			this.fechasDisponibilidad = resultado;
			if(this.fechasDisponibilidad === null || this.fechasDisponibilidad.length === 0 || this.fechasDisponibilidad === undefined) {
				this.sinFechasDisponibles = true;
				this.ocultarBotonCita = true;
			}
		})
		.catch(error => {
			console.error(error);
			this.handleModalToast(error.body.message);
			
		});
	}
	
	consultarHorasDisponibilidadGestor() {
		var codigoEvento;
		if(this.tipoCita == 'Cita telefónica') {
			codigoEvento = '43';
		} else {
			codigoEvento = '42';
		}
		let fechasDisponibilidad = this.template.querySelector('.fechasDisponibilidad').value;
		obtenerHorasDisponiblidadGestor({recordId: this.recordId, employeeId: this.numeroGestor, gestorElegidoId: this.numeroGestor, eventType: codigoEvento, fechaElegida: fechasDisponibilidad})
		.then(resultado => {
			this.horasDisponibilidad = resultado;
		})
		.catch(error => {
			console.error(error);
			this.handleModalToast(error.body.message);
			
		});
		this.gestorElegido =  this.numeroGestor;
		this.nombreGestorElegido = this.nombreGestor;
	}
	
	guardarHorasDisponibilidad(event) {
		this.horaCitaSelecionada = event.detail.value;
	}
	
	lookupDeseleccionar() {
		if(this.comentariosTarea) {
			const comentariosTareaReplace = this.comentariosTarea.replace(this.lookupOficinaResultadoSeleccionado.Name + '.', '[oficina destino]');
			if(comentariosTareaReplace.includes(this.lookupOficinaResultadoSeleccionado.Name)) {
				let t = 0;
				const regex = new RegExp(this.lookupOficinaResultadoSeleccionado.Name, 'g');
				this.comentariosTarea = this.comentariosTarea.replace(regex, match => ++t === 2 ? '[oficina destino]' : match);
			} else {
				this.comentariosTarea = comentariosTareaReplace;
			}
		}
		this.lookupOficinaResultadoSeleccionado = null;
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			this.lookupOficinaAbrir();
			this.template.querySelector('.lookupOficinaInput').focus();
		}, 200);
	}

	//AMENAZAS
	// lookupDeseleccionarEmpleadoAmenazado() {
	// 	this.empleadoAmenazadoSeleccionado = null;
	// 	//eslint-disable-next-line @lwc/lwc/no-async-operation
	// 	window.setTimeout(() => {
	// 		this.lookupEmpleadoAbrir();
	// 		this.template.querySelector('.lookupEmpleadoInput').focus();
	// 	}, 200);
	// }

	// lookupEmpleadoAbrir() {
	// 	const lookupEmpleadoInput = this.template.querySelector('.lookupEmpleadoInput');
	// 	lookupEmpleadoInput.setCustomValidity('');
	// 	lookupEmpleadoInput.reportValidity();
	// 	if (this.lookupEmpleadoInputValue.length > 1) {
	// 		this.template.querySelector('.lookupEmpleado').classList.add('slds-is-open');
	// 	}
	// }

	// lookupEmpleadoCerrar() {
	// 	//eslint-disable-next-line @lwc/lwc/no-async-operation
	// 	window.setTimeout(() => {
	// 		const lookupEmpleado = this.template.querySelector('.lookupEmpleado');
	// 		if (lookupEmpleado) {
	// 			lookupEmpleado.classList.remove('slds-is-open');
	// 		}
	// 	}, 150);
	// }

	// lookupEmpleadoOnchange(event) {
	// 	this.lookupEmpleadoInputValue = event.detail.value;
	// 	window.clearTimeout(this.lookupOficinaTimeout);
	// 	if (this.lookupEmpleadoInputValue.length > 2) {
	// 		//eslint-disable-next-line @lwc/lwc/no-async-operation
	// 		this.lookupOficinaTimeout = window.setTimeout(() => this.buscarEmpleados(this.lookupEmpleadoInputValue), 500);
	// 	} else {
	// 		event.target.isLoading = false;
	// 		this.template.querySelector('.lookupEmpleado').classList.remove('slds-is-open');
	// 		this.lookupEmpleadoResultados = [];
	// 	}
	// }
	// //AMENAZAS


	lookupOficinaOnchange(event) {
		this.lookupOficinaInputValue = event.detail.value;
		window.clearTimeout(this.lookupOficinaTimeout);
		if (this.lookupOficinaInputValue.length > 2) {
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			this.lookupOficinaTimeout = window.setTimeout(() => this.buscarOficinas(this.lookupOficinaInputValue), 500);
		} else {
			event.target.isLoading = false;
			this.template.querySelector('.lookupOficina').classList.remove('slds-is-open');
			this.lookupOficinaResultados = [];
		}
	}
	
	lookupOficinaAbrir() {
		const lookupOficinaInput = this.template.querySelector('.lookupOficinaInput');
		lookupOficinaInput.setCustomValidity('');
		lookupOficinaInput.reportValidity();
		if (this.lookupOficinaInputValue.length > 1) {
			this.template.querySelector('.lookupOficina').classList.add('slds-is-open');
		}
	}
	
	lookupOficinaCerrar() {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			const lookupOficina = this.template.querySelector('.lookupOficina');
			if (lookupOficina) {
				lookupOficina.classList.remove('slds-is-open');
			}
		}, 150);
	}

	nombreGestorSeleccionado(event) {
		var gestorAnterior;
		if(this.gestorSeleccionado) {
			gestorAnterior = this.gestorSeleccionado;
		}
		this.gestorSeleccionado = this.gestores.find(gestor => gestor.value === event.detail.value);
		if(this.comentariosTarea && this.comentariosTarea.includes('[gestor seleccionado]')) {
			this.comentariosTarea = this.comentariosTarea.replace('[gestor seleccionado]', this.gestorSeleccionado.label);
		} else if(this.comentariosTarea && !this.comentariosTarea.includes('[gestor seleccionado]')) {
			this.comentariosTarea = this.comentariosTarea.replace(gestorAnterior.label , this.gestorSeleccionado.label);
		}
	}
	
	lookupOficinaSeleccionar(event) {
		const oficina = this.lookupOficinaResultados.find(c => c.Id === event.currentTarget.dataset.id);
		this.lookupOficinaResultadoSeleccionado = oficina;
		if(this.comentariosTarea) {
			this.comentariosTarea = this.comentariosTarea.replace('[oficina destino]', this.lookupOficinaResultadoSeleccionado.Name);
		}
	}

	// lookupOficinaAmenazadaSeleccionar(event) {
	// 	const oficina = this.lookupOficinaResultados.find(c => c.Id === event.currentTarget.dataset.id);
	// 	this.oficinaAmenazadaSeleccionada = oficina;
	// }

	// lookupEmpleadoAmenazadoSeleccionar(event) {
	// 	const emp = this.lookupEmpleadoResultados.find(c => c.Id === event.currentTarget.dataset.id);
	// 	this.empleadoAmenazadoSeleccionado = emp;
	// }
	
	lookupGestorDeseleccionar() {		
		this.lookupGestorResultadoSeleccionado = null;
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			this.lookupGestorAbrir();
			this.template.querySelector('.lookupGestorInput').focus();
		}, 200);
	}
	
	lookupGestorOnchange(event) {
		this.lookupGestorInputValue = event.detail.value;
		window.clearTimeout(this.lookupGestorTimeout);
		if (this.lookupGestorInputValue.length > 2) {
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			this.lookupGestorTimeout = window.setTimeout(() => this.buscarGestoresGlobal(this.lookupGestorInputValue), 500);
		} else {
			event.target.isLoading = false;
			this.template.querySelector('.lookupGestor').classList.remove('slds-is-open');
			this.lookupGestorResultados = [];
		}
	}
	
	lookupGestorAbrir() {
		const lookupGestorInput = this.template.querySelector('.lookupGestorInput');
		lookupGestorInput.setCustomValidity('');
		lookupGestorInput.reportValidity();
		if (this.lookupGestorInputValue.length > 1) {
			this.template.querySelector('.lookupGestor').classList.add('slds-is-open');
		}
	}
	
	lookupGestorCerrar() {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			const lookupGestor = this.template.querySelector('.lookupGestor');
			if (lookupGestor) {
				lookupGestor.classList.remove('slds-is-open');
			}
		}, 150);
	}
	
	lookupGestorSeleccionar(event) {
		const gestor = this.lookupGestorResultados.find(c => c.Id === event.currentTarget.dataset.id);
		this.lookupGestorResultadoSeleccionado = gestor;
	}
	
	buscarOficinas(cadenaBusqueda) {
		let lookupOficinaInput = this.template.querySelector('.lookupOficinaInput');
		lookupOficinaInput.isLoading = true;
		buscarOficinas({cadenaBusqueda: cadenaBusqueda})
		.then(oficinas => {
			if (cadenaBusqueda === this.lookupOficinaInputValue) {
				//No se ha modificado la cadena de búsqueda durante la ejecución del Apex
				this.lookupOficinaResultados = oficinas;
				this.template.querySelector('.lookupOficina').classList.add('slds-is-open');
			}
		})
		.catch(error => {
			console.error(error);
			this.handleModalToast(error.body.message);
			
		})
		.finally(() => lookupOficinaInput.isLoading = false);
	}
	
	// buscarEmpleados(cadenaBusqueda) {
	// 	let lookupEmpleadoInput = this.template.querySelector('.lookupEmpleadoInput');
	// 	lookupEmpleadoInput.isLoading = true;
	// 	buscarEmpleados({cadenaBusqueda: cadenaBusqueda})
	// 	.then(empleados => {
	// 		if (cadenaBusqueda === this.lookupEmpleadoInputValue) {
	// 			//No se ha modificado la cadena de búsqueda durante la ejecución del Apex
	// 			this.lookupEmpleadoResultados = empleados;
	// 			this.template.querySelector('.lookupEmpleado').classList.add('slds-is-open');
	// 		}
	// 	})
	// 	.catch(error => {
	// 		console.error(error);
	// 		this.handleModalToast(error.body.message);
	// 	})
	// 	.finally(() => lookupEmpleadoInput.isLoading = false);
	// }
	
	buscarGestoresGlobal(cadenaBusqueda) {
		let lookupGestorInput = this.template.querySelector('.lookupGestorInput');
		lookupGestorInput.isLoading = true;
		buscarGestoresGlobal({cadenaBusqueda: cadenaBusqueda})
		.then(gestores => {
			if (cadenaBusqueda === this.lookupGestorInputValue) {
				//No se ha modificado la cadena de búsqueda durante la ejecución del Apex
				this.lookupGestorResultados = gestores;
				this.template.querySelector('.lookupGestor').classList.add('slds-is-open');
			}
		})
		.catch(error => {
			console.error(error);
			this.handleModalToast(error.body.message);
			
			
		})
		.finally(() => lookupGestorInput.isLoading = false);
	}
	
	//Backup gestores -> Botón Agendar cita gestor
	confirmarCitaGestor() {
		if (!this.template.querySelector('.asuntoEvento').value || 
			(!this.citaRapida && !this.template.querySelector('.fechasDisponibilidad').value) || 
			(!this.citaRapida && !this.horaCitaSelecionada) || 
			(this.citaRapida && !this.fechaSeleccionada) || 
			(this.citaRapida && !this.franjaSeleccionada) || 
			this.tipoCita === undefined
		){
			this.toast('warning', 'Campos vacíos', 'Por favor, informe todos los campos del formulario y seleccione una opción de Tipo de Cita.');
			
		} else {
			if (this.esClienteDigital) {
				this.tipoCita = 43;
			}
			this.cargandoGestor = true;
			this.disponibilidadConsultada = false;
			this.ocultarBotonCita = true;
			if(!this.citaRapida) {
				altaCitaGestor({
					recordId: this.recordId,
					empleadoEx: this.gestorElegido,
					nombreGestor: this.nombreGestorElegido,
					centroEx: this.oficinaGestor,
					asunto: this.template.querySelector('.asuntoEvento').value,
					fecContacto: this.template.querySelector('.fechasDisponibilidad').value,
					horaIni: this.horaCitaSelecionada,
					medio: this.tipoCita})
				.then(resultado => {
					if (!(resultado.existeTareaCitaCreada === 'true')) {
					if (resultado.resultat === 'OK') {
						if(this.tipoCita == '43') {
							//this.toast('success', 'Cita creada con éxito', resultado.mensaje);
							this.handleModalToast(resultado.mensaje);
							this.calculoKPI();
						} else {
							this.handleModalToast(resultado.mensaje);
							//this.mostrarToastOficinaResultado(resultado.mensaje, resultado.cuenta); PRUEBA MODAL MBO
						}
						//this.cerrarModal();
					} else {
						//this.toast('error', 'No es posible crear la cita', resultado.txtError);
						this.handleModalToast(resultado.txtError);
						//this.cerrarModal();
						}
					} else {
						//this.toast('warning', 'No es posible crear la tarea', resultado.textoTareaCitaCreada);
						this.handleModalToast(resultado.textoTareaCitaCreada);
						//this.cerrarModal();		
					}
				})
				.catch(error => {
					console.error(error);
					this.handleModalToast(error.body.message);
				});
			} else {
				altaCitaRapida({
					numOficina: this.numOficina,
					numPer: this.numperso, 
					fechaSeleccionada: this.fechaSeleccionada, 
					franjaSeleccionada: this.franjaSeleccionada,
					asunto: this.template.querySelector('.asuntoEvento').value,
					recordId: this.recordId,
					tipoCita: this.tipoCita
				})
				.then(retorno => {
					if (!(retorno.existeTareaCitaCreada)) {
						if(retorno.resultado == 'OK') {
							if(this.tipoCita == '43') {
								this.handleModalToast(retorno.mensaje);
								this.cargandoGestor = false;	
								this.calculoKPI();
							} else {
								this.handleModalToast(retorno.mensaje);
							}
						} else {
							console.error('Error mensaje ' + retorno.resultadoMensaje);
							this.handleModalToast(retorno.resultadoMensaje);
							this.cargandoGestor = false;
							}
						}else{
							this.handleModalToast(retorno.textoTareaCitaCreada);
						}
				})
				.catch(error => {
					console.error('Error al crear la cita:', error);
					this.handleModalToast(error.body.message);
				})
				.finally(() => {
					this.cargandoGestor = false;
				})
				;
			}
		}
	}
		
	checkCrearTareaOnchange() {
		var checkBoxMostrarTarea = this.template.querySelector('.checkBoxCitaGestor').checked;
		if(checkBoxMostrarTarea) {
			this.mostrarTareaModalCitaGestor = true;
		} else {
			this.mostrarTareaModalCitaGestor = false;
		}
	}
	
	get inputVariables(){
		return [
			{
				name: 'recordId',
				type: 'String',
				value: this.recordId
			}
		];
	}
	
	handleStatusChange(event) {
		this.value = event.detail.status;
		if (this.value === 'FINISHED') {
			if(this.ambitoMotivo != null && this.ambitoMotivo === 'Cajeros Incidencias'){
				this.calculoKPI();
			}			
			this.cerrarModal();
		}
	}
	
	handleGrupoColaboradorDerivar() {
		this.mostrarFlowDerivar = this.flowDerivar;
		this.grupoColaborador = false;
		this.mostrarModalTrasladarGrupoColaborador = false;
		if(this.realizarRemitidoDesdeMetodo) {	
			if(!this.ambitoFraude) {
				this.handleRemitir();
			}
		}
		if(this.toastTrasladar3N && !this.preguntaSenal && !this.preguntaSenalAntigua && !this.preguntaTelefonoCSBD) {
			this.realizarTraslado3N();
		}
		if(this.toastCSBDNoContratar) {
			this.crearOportunidad();
		}
		if(this.toastCajerosIncidencias) {
			//this.toast('error', this.tituloCajerosIncidencias, this.toastCajerosIncidencias);
			this.handleModalToast(this.toastCajerosIncidencias);
			
			
		}
		if(this.toastNoClienteError) {
			//this.toast('error', 'Error en los datos', this.toastNoClienteError);
			this.handleModalToast(this.toastNoClienteError);
			
		}
		if (this.trasladarDocumentacion) {
			this.trasladarDocumentacion = false;
		}
		if(this.preguntaRealizarRemitido || this.textoDocumentacionCertificado || this.preguntaInformacionCompletaDocumentacion) {
			if(!this.toastCajerosIncidencias) {
				this.abrirModal();
			}
		}
	}

	handleDerivarDocumentacion() {
		this.mostrarFlowDerivar = this.flowDerivar;
		if(this.toastTrasladar3N && !this.preguntaSenal && !this.preguntaSenalAntigua && !this.preguntaTelefonoCSBD) {
			this.realizarTraslado3N();
		}
		if(this.toastCSBDNoContratar) {
			this.crearOportunidad();
		}
		if(this.toastCajerosIncidencias) {
			//this.toast('error', this.tituloCajerosIncidencias, this.toastCajerosIncidencias);
			this.handleModalToast(this.toastCajerosIncidencias);
			
		}
		if(this.toastNoClienteError) {
			//this.toast('error', 'Error en los datos', this.toastNoClienteError);
			this.handleModalToast(this.toastNoClienteError);
			
		}
		if(this.preguntaRealizarRemitido || this.textoDocumentacionCertificado || this.preguntaInformacionCompletaDocumentacion) {
			if(!this.toastCajerosIncidencias) {
				this.abrirModal();
			}
		}
	}
	
	handleGrupoColaboradorTrasladar() {
		this.recuperarCampoDerivar();
		//if(!this.derivarB) {
		if(!this.derivarB) {
			
			//this.toast('alert', 'Alerta', this.toastTrasladarDesdeDerivar);
			this.handleModalToast(this.toastTrasladarDesdeDerivar);
			
		} else {
			let datosAdicionales = '';
			let origen = 'operativaDerivar';
			let destino = 'realizartrasladocolaborador';
			this.cerrarModal();
			this.publicarMensajeDerivarInteraccion(origen, destino, datosAdicionales);
			//window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('realizartrasladocolaborador', {detail: {data: null}})), 400);
			
		}
	}

	comprobarDNI() {
		if(this.mostrarModalDNITestamentaria) {
			this.dni = this.template.querySelector('.DNITestamentaria').value;
			if(!this.template.querySelector('.DNITestamentaria').value) {
				this.toast('warning', 'Campos vacíos', 'Por favor, informe un documento');
				
			} else {
				this.showSpinner = true;
				dniTestamentaria({
					dni: this.dni,
					recordId: this.recordId})
				.then(retorno => {
					this.handleRemitir();
				})
				.catch(error => {
					console.error(error);
					this.toast('error', 'Problema estableciendo dni', error.body.message);
					
					return false;
				}).finally(() => {
					this.showSpinner = false;
				});
			}
		}
	}
	
	handleRemitir() {
		//if(!this.derivar) {
		if(!this.derivarB) {	
			this.cerrarModal();
			this.toast('alert', 'Alerta', this.toastRemitirDesdeDerivar);
		} else {
			let datosAdicionales = '';
			let origen = 'operativaDerivar';
			let destino = 'realizarremitido';
			this.cerrarModal();
			this.publicarMensajeDerivarInteraccion(origen, destino, datosAdicionales);
			//window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('realizarremitido', {detail: {data: null}})), 400);
			this.cerrarModal();
		}
	}

	// parametrizacionDatos(){
	// 	this.parametrizacionesMensaje = Object.fromEntries([
	// 		['[Oficina amenazada]', this.oficinaAmenazadaSeleccionada.Name],
	// 		['[Empleado amenazado]', this.empleadoAmenazadoSeleccionado.Name],
	// 		['[Motivo amenaza]', this.template.querySelector('.motivoAmenazaInputValue').value],
	// 		['[Detalles amenaza]', this.template.querySelector('.detalllesAmenazaInputValue').value]
	// 	  ]);
	// 	this.handleRemitirAuto();
	// }

	// parametrizacionDatosAmenazasSuicidios(){
	// 	this.parametrizacionesMensaje = Object.fromEntries([
	// 		['[Motivo amenaza]', this.template.querySelector('.motivoAmenazaSuicidiosInputValue').value],
	// 		['[Direccion amenaza]', this.direccionAmenazasSuicidiosInputValue]
	// 	  ]);
	// 	this.handleRemitirAuto();
	// }

	// handleRemitirAuto() {
	// 	emailsAutoEmail(
	// 		{
	// 			recordId: this.recordId,
	// 			grupoCol: this.grupoCol,
	// 			nombrePlantilla: this.nombrePlantilla,
	// 			parametrizacionesMensaje: this.parametrizacionesMensaje,
	// 			ambito: this.ambitoMotivo,
	// 			nameOWA:this.nameOWA
	// 		}
	// 	).then (retorno =>{
	// 		this.handleModalToast(this.emailSuccess);
	// 	}).catch(error =>{
	// 		this.toast('error', 'Error en la creación de emails', error.body.message);
	// 	}).finally(() =>{
	// 		this.parametrizacionesMensaje = null;
	// 	});
	// }

	handleSolicitarInfo() {
		let datosAdicionales = '';
		let origen = 'operativaDerivar';
		let destino = 'solicitarinfo';
		this.cerrarModal();
		this.publicarMensajeDerivarInteraccion(origen, destino, datosAdicionales);
		//window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('solicitarinfo', {detail: {data: null}})), 400);
		//this.cerrarModal();
	}

	handleMostrarMensajeRemitir() {
		
		//this.toast('warning', 'Atención', this.toastRemitir); prueba
		this.mostrarPhisingSmishingMalware5 = true;
    	this.mostrarPhisingSmishingMalware4 = true;
		this.mostrarPregunta = false;
		this.PhisingSmishingMalware1 = '';
		this.mostrarModalPreguntaRealizarRemitido = false;
		this.handleModalToast(this.toastRemitir);
		/*this.ambitoFraude = false;
		this.fraudeANivelDeMotivo = false;*/
	}

	//Métodos Migración Toast
	handleModalToast(mensajeMostrarModalToast){
		this.mostrarModalToast = true;
		this.mensajeMostrarModalToast = mensajeMostrarModalToast;
	}

	handleModalToastUrl(mensajeMostrarModalToastUrl){
		this.mostrarModalToast = false;
		this.mostrarModalToastUrl = true;
		this.mensajeMostrarModalToastUrl = mensajeMostrarModalToastUrl;
	}

	//Métodos Migración Toast

	preguntaCajerosSi() {
		this.preguntaCajeros = '';
	}
	
	preguntaCajerosNo() {
		
		crearActividadCajeros({recordId: this.recordId});
		this.preguntaCajeros = null; 
		this.preguntaCajerosExternos = null; 
		this.handleModalToast(this.toastCajerosExternos);
		
		
		
		
	}


	
	preguntaCajerosExternosSi() {
		this.cerrarModal();
		crearActividadCajeros({recordId: this.recordId});
	}
	
	preguntaCajerosExternosNo() {
		this[NavigationMixin.GenerateUrl]({
			type: 'standard__webPage',
			attributes: {
				url: ''
			}
		}).then(url => {
			window.open(this.urlCajeros, "_blank");
			crearActividadCajeros({recordId: this.recordId});
		});
	}

	handleMostrarPreguntaRealizarRemitido(){
		if(this.fraudeANivelDeMotivo){
			this.mostrarModalPreguntaRealizarRemitido = true;
			this.preguntaSenal = false;
			this.preguntaSenalAntigua = false;
		} else {
			this.mostrarModalPreguntaRealizarRemitido = true;
			this.preguntaSenal = false;
			this.preguntaSenalAntigua = false;
		}
	}

	/*handleMostrarEnrollmentDatos(){
		this.mostrarModalPreguntaEnrollmentDatos = true;
	}*/

	/*preguntaEnrollmentNo() {
		this.preguntaEnrollment = false;
		this.mostrarModalCreacionTarea = true;
	}*/

	/*preguntaEnrollmentDatosSi(){
		this.showSpinner = true;
		preguntaEnrollmentDatosSi({recordId: this.recordId})
		.then(resultado => {
			this.toast('success','Operativa realizada correctamente', this.toastEnrollmentDatosSi);
		})
		.catch(error => {
			console.error(error);
			this.toast('error', 'Problema al realizar la operativa', error.body.message);
		}).finally(() => {
			this.showSpinner = false;
			this.cerrarModal();
		})
	}*/

	/*preguntaEnrollmentDatosNo(){
		this.cerrarModal();
		this.toast('success','Pendiente', this.toastEnrollmentDatosNo);
	}*/
	
	realizarTraslado3N() {
		this.showSpinner = true;
		realizarTraslado3N({recordId: this.recordId})
		.then(resultado => {
			this.showSpinner = false;
			this.handleModalToast(this.toastTrasladar3N);
		})
		.catch(error => {
			console.error(error);
			this.handleModalToast(error.body.message);
		}).finally(() => {
			this.showSpinner = false;
			
			this.dispatchEvent(new CustomEvent('refrescartab', {detail: {}}));
		});
	}

	crearOportunidadModal() {
		if(this.ambitoMotivo == 'CSBD No Contratar') {
			this.mostrarModalCSBDNoContratar = true;
		} else {
			this.crearOportunidadApex();
		}
	}

	crearOportunidadApex() {
		this.showSpinner = true;	
		let oportunidadSuccess = false;
		let toast;
		crearOportunidadCSBDApex({recordId: this.recordId})
		.then(resultado => {		
			if(resultado.oppCreada !== null && resultado.oppCreada !== undefined && resultado.oppCreada){
				oportunidadSuccess = true;
				if(this.toastCSBDNoContratar) {
					toast = this.toastCSBDNoContratar;
				} else {
					toast = this.toastCrearOportunidad;
				}
				//this.toast('success', 'Oportunidad creada con éxito', toast);
				
				this.dispatchEvent(new CustomEvent('refrescartab', {detail: {data: {'oportunidadSuccess': oportunidadSuccess}}}));
				this.showSpinner = false;
				this.handleModalToast(toast);
				
			}
		})
		.catch(error => {
			this.showSpinner = false;
			console.error(error);
			this.handleModalToast(error.body.message);
			
		})
	}


	crearOportunidad() {
		if(!this.oportunidadCreada) {
			this.showSpinner = true;			
			crearOportunidad({recordId: this.recordId})
			.then(resultado => {
				if(resultado.validacionCrearOportunidad !== null && resultado.validacionCrearOportunidad !== undefined && resultado.validacionCrearOportunidad){
					this.showSpinner = false;
					this.crearOportunidadModal();
				}
				else{
					let oppExiste = (resultado.oportunidadSiExiste !== null && resultado.oportunidadSiExiste !==  undefined) ? resultado.oportunidadSiExiste : false;
					let oppTareasCitas = (resultado.oppTareasCitas !== null && resultado.oppTareasCitas !== undefined) ? resultado.oppTareasCitas : false;
					let tareaRellamada = (resultado.tareasRellamadas !== null && resultado.tareasRellamadas !== undefined) ? resultado.tareasRellamadas : false;

					if(oppTareasCitas){
						this.existeOppTareasCSBD = true;
						this.textoOppTareasCSBD = resultado.mensajeOppTareas;
						this.showSpinner = false;
						this.preguntaCSBDContratar = false;
						this.preguntaCSBDContratar2 = false;
						this.mostrarModalGestionGestorAsignado  = false;
						this.ambitoCSBD = false;//::
					}else if(tareaRellamada){
						this.existeTareaRellamada = true;
						this.textoTareaRellamada = resultado.mensajeTareasRellamadas;
						this.showSpinner = false;
					}else if(oppExiste){						
						if(resultado.tipo !== null && resultado.tipo !==  undefined){
							if(resultado.tipo == 'En curso'){
								this.existeOppEnGestion = true;		
								this.textoRellamadaCSBDEnGestion = resultado.mensaje;
								this.showSpinner = false;				
							}else if(resultado.tipo == 'Formalizada'){
								this.existeOppFormalizada = true;
								this.textoRellamadaCSBDFormalizada = resultado.mensaje;
								this.showSpinner = false;
							}else{
								//this.toast('error', 'Problema al crear la oportunidad', 'Existe una oportunidad, pero no se identifica si esta Formalizada o en Gestión');
								this.handleModalToast('Existe una oportunidad, pero no se identifica si esta Formalizada o en Gestión');
								this.showSpinner = false;	
								
							}
						}else{
							//this.toast('error', 'Problema al crear la oportunidad', 'Existe una oportunidad, pero no se identifica si esta Formalizada o en Gestión');
							this.handleModalToast('Existe una oportunidad, pero no se identifica si esta Formalizada o en Gestión');
							this.showSpinner = false;	
							
						}
					}
				}
			})
			.catch(error => {
				this.showSpinner = false;
				console.error(error);
				this.handleModalToast(error.body.message);
				
			})/*.finally(() => {
				this.dispatchEvent(new CustomEvent('refrescartab', {detail: {data: {'oportunidadSuccess': oportunidadSuccess}}}));
				this.showSpinner = false;
				this.cerrarModal();
			});*/
		}
	}

	actualizarComentario(event) {
		this.comentarioTareaRellamada = event.target.value;
	}

	crearTareaRellamada(){
		this.procesandoCreacionTarea = true;
		crearTareaRellamadaApex({recordId: this.recordId, descriptionTask: this.comentarioTareaRellamada})
		// crearTareaRellamada({recordId: this.recordId, descriptionTask: 'MGT Prueba crearTareaRellamada Descripción'})

		.then(resultado => {
			this.procesandoCreacionTarea = false;
			//this.toast('success', 'Información', 'Las tareas han sido creadas con éxito'); 
			this.handleModalToast('Las tareas han sido creadas con éxito');
			
		})
		.catch(error => {
			console.error(error);
			this.procesandoCreacionTarea = false;
			this.handleModalToast(error.body.message);
			
		});
	}

	preguntaCSBDContratarSi() {
		this.preguntaCSBDContratar = null;
	}

	preguntaCSBDContratarNo() {
		this.crearOportunidad();			
	}

	preguntaCSBDContratar2Si() {
		this.crearOportunidad();
	}

	preguntaCSBDContratar2No() {
		this.toastCrearOportunidad = null;
		this.preguntaCSBDContratar2 = false;
		this.ambitoCSBD = false;
	}

	preguntaDocumentacionCertificadoSi() {
		this.preguntaInformacionRequeridaDocumentacion = null;
		if(this.imagin){
			this.textoDocumentacionCertificado = null;
			this.mostrarModalCreacionTarea = true;
		} else {
			if(this.documentacionDecisionCaixa === 'CSBD'){
				this.crearOportunidad();
			} else {
				this.textoDocumentacionCertificado = null;
			}		
		}
	}

	preguntaDocumentacionCertificadoNo() {
		this.textoDocumentacionCertificado = null;
	}

	preguntaInformacionRequeridaDocumentacionSi() {
		this.handleSolicitarInfo();
	}

	preguntaInformacionRequeridaDocumentacionNo() {
		this.showSpinner = true;
		crearNuevoCasoDocumentacion({recordId: this.recordId})
		.then({
		})
		.catch(error => {
			//this.toast('error', 'Problema al crear el caso', error.body.message);
			this.showSpinner = false;
			this.handleModalToast(error.body.message);
			
		}).finally(() => {
			this.showSpinner = false;
			this.casoCreadoDocumentacion = true;//(puede ser variable booleana de mostrar modal anterior)
			//this.toast('success', 'Caso creado con éxito', this.toastDocumentacionCasoCreado);
			this.handleModalToast(this.toastDocumentacionCasoCreado);
			this.dispatchEvent(new CustomEvent('refrescartab', {detail: {}}));
		});
		this.preguntaInformacionRequeridaDocumentacion = null;
	}

	preguntaInformacionCompletaDocumentacionSi() {
		if(!this.ocultarModalTrasladar && (this.preguntaGrupoColaborador != null || this.preguntaGrupoColaborador != undefined)){
			this.trasladarDocumentacion = true;
			this.mostrarModalGestionGestorGenerico = false;
			this.mostrarModalGestionGestorAsignado = false;
			this.preguntaInformacionCompletaDocumentacion = false;
		} else {
			this.trasladarDocumentacion = false;
			this.preguntaInformacionCompletaDocumentacion = false;
		}
	}

	preguntaInformacionCompletaDocumentacionNo() {
		this.handleSolicitarInfo();
	}

	motivoDevolucionTemaFraudeSi(){
		let datosAdicionales = this.grupoColaboradorFraudeSI;
		let origen = 'operativaDerivar';
		let destino = 'realizarremitido';
		this.cerrarModal();
		this.publicarMensajeDerivarInteraccion(origen, destino, datosAdicionales);
		//window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('realizarremitido', {detail: {data: {'grupoColaboradorFraude': this.grupoColaboradorFraudeSI}}})), 400);
		this.cerrarModal();
	}

	motivoDevolucionTemaFraudeNo(){
		let datosAdicionales = this.grupoColaboradorFraudeNO;
		let origen = 'operativaDerivar';
		let destino = 'realizarremitido';
		this.cerrarModal();
		this.publicarMensajeDerivarInteraccion(origen, destino, datosAdicionales);
		//window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('realizarremitido', {detail: {data: {'grupoColaboradorFraude': this.grupoColaboradorFraudeNO}}})), 400);
		this.cerrarModal();
	}

	linkTF() {
		if(this.ambitoCSBD){
			this[NavigationMixin.GenerateUrl]({
				type: 'standard__webPage',
				attributes: {
					url: ''
				}
			}).then(url => {
				this.urlTF = this.urlTF.replace('{numperso}', '{' + this.numperso + '}');
				this.urlTF = this.urlTF.replace('{nif}', '{' + this.nif + '}');
				window.open(this.urlTF, "_blank");
			});
		}
	}

	handleOficinaFraude(){
		this.preguntaSenal = false;
		this.ambitoFraude = false;
		this.ambitoCSBD = false;
	}

	handlePreguntaSenalSi() {
		this.ambitoFraude = false;
		this.ambitoCSBD = false;
		this.preguntaSenalAntigua = false;
		if(!this.grupoColaborador && !this.ambitoFraude) {
			this.handleGrupoColaboradorDerivar();
		}
	}

	handleFraudeRemitir(){
		this.pulsadoGenerarCasoFraude = true;
		crearCasoFraude({recordId: this.recordId})
		.then(resultado => {
			this.pulsadoGenerarCasoFraude = false;
			if(resultado.casoYaDerivado){
				//this.toast('error', 'No se puede derivar', resultado.comentarioCasoYaDerivado);
				//this.preguntaRealizarRemitido = null;
				this.preguntaRealizarRemitido = null;
				this.mostrarModalPreguntaRealizarRemitido = false;
				this.handleModalToast(resultado.comentarioCasoYaDerivado);
			}else{
				//this.toast('success', 'Caso derivado con éxito.', resultado.comentarioDerivadoExito); 
				
				this.mostrarModalPreguntaRealizarRemitido = false;
				this.preguntaRealizarRemitido = null;
				this.ambitoFraude = false;
				this.ambitoCSBD = false;
				this.handleModalToast(resultado.comentarioDerivadoExito);
				
				
			}
		})
		.catch(error => {
			this.pulsadoGenerarCasoFraude = false;
			//this.toast('error', 'Problema al derivar el caso a fraude', error.body.message);
			this.handleModalToast(error.body.message);
			
		}).finally(() => {
			this.showSpinner = false;
			
		});
	}

	llamadaWSOnboarding() {
		let crearTareaOnboarding = false;
		this.showSpinner = true;
		llamarOnboarding({recordId: this.recordId, nif: this.nif})
		.then(resultado => {
			if (resultado === 'El cliente no esta en proceso de Onboarding') {
				// llamar a tarea oficina
				this.handleGestionGestorDistintoNo();
				crearTareaOnboarding = this;
			} else if (resultado === 'OK' || resultado === 'El cliente esta en proceso de Onboarding') {
				this.handleRemitir();
			}
		})
		.catch(error => {
			this.entroCatch = true;
		})
		.finally(() => {
			this.showSpinner = false;
			if (!crearTareaOnboarding) {
				this.cerrarModal();
			}
		})
	}

	//ARGOS
	trasladoColaboradorArgos(){
		//Traslado a grupo colaborador indicado (CYBERFRAUDE AND CYBERSOC)
		if(this.cyberfraude || this.cybersoc){
			let pass = false;
			this.respuestasPreguntasArgos.forEach((item) => {
				if(item.value === 'Si'){
					pass = true;
					return; 
				}
			})
			if (pass) {
				let datosAdicionales = this.cyberfraude;
				let origen = 'operativaDerivar';
				let destino = 'realizarremitido';
				this.cerrarModal();
				this.publicarMensajeDerivarInteraccion(origen, destino, datosAdicionales);
				//window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('realizarremitido', {detail: {data: {'grupoColaboradorFraude': this.cyberfraude}}})), 400);
			} else {
				let datosAdicionales = this.cybersoc;
				let origen = 'operativaDerivar';
				let destino = 'realizartrasladocolaborador';
				this.cerrarModal();
				this.publicarMensajeDerivarInteraccion(origen, destino, datosAdicionales);
				//window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('realizartrasladocolaborador', {detail: {data: {'grupoColaboradorFraude': this.cybersoc}}})), 400);
			}
		} else {
			let datosAdicionales = '';
			let origen = 'operativaDerivar';
			let destino = 'realizartrasladocolaborador';
			this.cerrarModal();
			this.publicarMensajeDerivarInteraccion(origen, destino, datosAdicionales);
			//window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('realizartrasladocolaborador', {detail: {data: null}})), 400);
		}
		this.operacionMFAArgos = null;
		this.cerrarModal();
	}

	preguntaMFAArgosOficina(){
		//Ambito nulo
		this.operacionMFAArgos = null;
		if(this.diarioMFAArgos){
			this.diarioMFAArgos = null;
			this.preguntaConfirmacionArgosActiva = false;
			this.preguntasArgosActivas = false;
		}
	}

	preguntaMFAArgosSeguridad(){
		this.diarioMFAArgos = null;
		this.preguntaConfirmacionArgosActiva = false;
		this.preguntasArgosActivas = true;
	}

	get options() {
		return [
			{ label: 'SI', value: 'Si' },
			{ label: 'NO', value: 'No' }
		];
	}

	handleChange(event) {
		if(event.target){
			let value = event.target.value;
			let name = event.target.name;
			if (!this.respuestasPreguntasArgos.some(item => item.key === name)) {
				this.respuestasPreguntasArgos.push({ key: name, value: value });
			} else {
				for (let item of this.respuestasPreguntasArgos) {
					if (item.key === name) {
						item.value = value;
						return;
					}
				}
			}
			if (this.respuestasPreguntasArgos.length === this.preguntasArgos.length) { 
				this.preguntasCompletasArgos = false;
			}
		}
	}

	handleSubmit() {
		rellenarPreguntasArgos({recordId: this.recordId, preguntasArgos: JSON.stringify(this.respuestasPreguntasArgos)})
		.then(resultado => {
		})
		.catch(error => {
			console.error(error);
		});
		this.preguntasArgosActivas = false;
		this.preguntaConfirmacionArgosActiva = true;
	}

	returnPreguntasArgosActivas(){
		this.preguntasArgosActivas = true;
		this.preguntaConfirmacionArgosActiva = true;
		this.respuestasPreguntasArgos = [];
		this.preguntasCompletasArgos = true;
	}
	//ARGOS

	//Phising/Smishing/Malware
	get condicion1() {
		return this.PhisingSmishingMalware1 != null && !this.mostrarPregunta && !this.mostrarPhisingSmishingMalware5 && !this.mostrarPhisingSmishingMalware4;
	}

	get condicion2() {
		return this.mostrarPregunta && this.PhisingSmishingMalware1 == null && !this.mostrarPhisingSmishingMalware5 && !this.mostrarPhisingSmishingMalware4;
	}

	get condicion3() {
		return this.mostrarPhisingSmishingMalware5 && this.PhisingSmishingMalware1 == null && !this.mostrarPhisingSmishingMalware4;
	}

	handleSi(){
		//A Mostrar pregunta al agente: ¿Has intentado transferir el caso en online al departamento de fraude?
		this.mostrarPhisingSmishingMalware5 = false;//Prueba limpia de variables
    	this.mostrarPhisingSmishingMalware4 = false;//Prueba limpia de variables
		this.mostrarPregunta = true;
		this.PhisingSmishingMalware1 = null;
	}

	handleNo(){
		// B Mostrar mensaje al agente: "Si el cliente no ha accedido y/o no ha proporcionado información relacionada 
		// con su banca digital o tarjetas, se le debe aconsejar que elimine el mensaje lo antes posible sin realizar 
		// ninguna operativa. No es necesario derivar el caso." (mensaje parametrizable)
		//this.toast('warning', 'Atención', this.PhisingSmishingMalware5);

		
		this.mostrarPregunta = true;
		this.mostrarPhisingSmishingMalware5 = true;
		this.PhisingSmishingMalware1 = null;
    	this.mostrarPhisingSmishingMalware4 = true;
		
		this.handleModalToast(this.PhisingSmishingMalware5)
		crearActividadPhishingSinRiesgo({recordId: this.recordId, descriptionTask: ''})
		
		.then(resultado => {
			//this.cerrarModal();
		})
		.catch(error => {
			console.error(error);
			this.cerrarModal();
		});
	}

	handleSiPregunta() {
		//C Derivar el caso a Fraude
		this.pulsadoGenerarCasoFraude = true;

		/*this.mostrarPregunta = false;//Prueba limpia de variables
		this.mostrarPhisingSmishingMalware5 = false;//Prueba limpia de variables
		this.mostrarPhisingSmishingMalware4 = false;//Prueba limpia de variables*/

		crearCasoFraude({recordId: this.recordId})
		.then(resultado => {
			this.pulsadoGenerarCasoFraude = false;
			if(resultado.casoYaDerivado){
				//this.toast('error', 'No se puede derivar', this.PhisingSmishingMalware3);
				this.handleModalToast(this.PhisingSmishingMalware3);
			}else{
				//this.toast('success', 'Caso derivado con éxito.', this.PhisingSmishingMalware2);
				this.handleModalToast(this.PhisingSmishingMalware2);
			}
		})
		.catch(error => {
			this.pulsadoGenerarCasoFraude = false;
			//this.toast('error', 'Problema al derivar el caso a fraude', error.body.message);
			this.handleModalToast(error.body.message);
		}).finally(() => {
			this.showSpinner = false;
			//this.cerrarModal();
		});
	}

	handleNoPregunta() {
		//D Mostrar mensaje al agente: Debes intentar transferir el caso en online al departamento de fraude.
		this.mostrarPregunta = false;
		this.mostrarPhisingSmishingMalware5 = false;
		this.mostrarPhisingSmishingMalware4 = false;//(variable a resetear)
		;
		//this.toast('warning', 'Atención', PhisingSmishingMalware4);
		this.handleModalToast(this.PhisingSmishingMalware4);
	}

	handleAceptar() {
		// Cerrar el modal
		this.cerrarModal();
	}
	//Phising/Smishing/Malware

	//CashBack
	cancelarCashBack() {
		this.cerrarModal();
	}

	handledetallesConsultaChange(event) {
    	this.detallesConsulta = event.target.value;
	}

	handleNombreComercioChange(event) {
    	this.nombreComercio = event.target.value;
	}

	handleIdClienteChange(event) {
    	this.idCliente = event.target.value;
	}

	handleFechaCompraChange(event) {
    	this.fechaCompra = event.target.value;
	}

	continuarCashBack() {
		if (!this.idCliente || !this.nombreComercio || !this.fechaCompra || !this.detallesConsulta) {
        	this.toast('error', 'Campos vacíos', 'Por favor, informa todos los campos requeridos');
        	return;
    	}
		actualizarDatosCashBack({recordId: this.recordId, detallesConsulta: this.detallesConsulta, idCliente: this.idCliente, nombreComercio: this.nombreComercio, fechaCompra: this.fechaCompra})
		.then(() => {
			this.toast('success', 'Información', 'Se han guardado los datos correctamente'); 
			//Traslado a grupo colaborador Cashback
			let datosAdicionales = '';
			let origen = 'operativaDerivar';
			let destino = 'realizartrasladocolaborador';
			this.cerrarModal();
			this.publicarMensajeDerivarInteraccion(origen, destino, datosAdicionales);
		})
		.catch(error => {
			this.toast('error', 'Problema al derivar el caso a fraude', error.body.message);
		}).finally(() => {
			this.showSpinner = false;
			//this.cerrarModal();
		});
	}
	//CashBack

	//Refinanciación Deudas
	cancelarRefinanciacionDeudas() {
		this.cerrarModal();
	}
	//Refinanciación Deudas
	
	//CSBD Telefono
	handleTelefonoCorrecto(){
		this.preguntaTelefonoCSBD = null;
		if(this.toastTrasladar3N){
			this.realizarTraslado3N();
		}else if(this.ambitoMotivo === 'CSBD No Contratar'){
			crearOportunidad();
		}
	}

	handleTelefonoIncorrecto(){
		this.botonDesabilitado = true;
		crearActividadCSBDTelefonoNoCoincidente({recordId: this.recordId})
		.then(resultado => {
			this.ambitoCSBD = false;
			this.preguntaTelefonoCSBD = null;
			this.toast('warning', 'Teléfono no coincidente', this.preguntaTelefonoCSBDNoEncontrado);
			
			
		})
		.catch(error => {
			console.error(error);
			this.cerrarModal();
		});
	}
	//CSBD Telefono

	//KPI
	calculoKPI(){
		calculoKPI({recordId: this.recordId})
		.then(resultado => {
		})
		.catch(error => {
			//this.toast('error', 'Problema en KPI ', error.body.message);
			this.handleModalToast(error.body.message);
		})
	}
	//KPI

	//Accionistas
	handleDerivarAccionistasNo(){
		this.mensajeDerivarAccionistas = null;
	}
	//Accionistas

	//MECANISMO FIRMA
	
	handleMFClienteEnElExtranjero() {
		this.preguntaMecanismoFirma = false;
	}

	handleMFClienteEnElPais() {
		recuperarArgosMecanismoFirma({recordId: this.recordId}).then(argosMF => {
			comprobarCasoCreadoMecanismoFirma({recordId: this.recordId})
			.then(resultado => {
				if (argosMF) {
					if (resultado) {
						this.handleModalToast(this.toastMecanismoFirmaCasoCreado);
						//this.toast('warning', 'Atención', this.toastMecanismoFirmaCasoCreado);
					} else {
						crearCasoMecanismoFirma({recordId: this.recordId, clienteExtranjero: false});
						this.handleModalToast(this.toastMecanismoFirmaArgosCorrecto);
						//this.toast('warning', 'Datos incompletos', this.toastMecanismoFirmaArgosCorrecto);
					}
					//this.cerrarModal();
				} else {
					this.handleMFNull();
				}
			}).catch(error => {
				console.error(error);
				this.cerrarModal();
			});
		});
		
	}

	handleMFDatosConfirmar(){
		const tieneNo = this.respuestasMecanismoFirmaDatos.some(item => item.value === 'No');
		if(!this.preguntasCompletasMecanismoFirma){
			//this.handleModalToast(this.toastMecanismoFirmaDatosIncompletos);
			this.toast('warning', 'Datos incompletos', this.toastMecanismoFirmaDatosIncompletos);
		}else{
			if(tieneNo){
				this.handleMFNull();
			}else{
				this.preguntaMecanismoFirmaDatos = false;
			}
		}
	}
	handleMFDatosCorrectos(){
		this.preguntaMecanismoFirmaDatos = false;
		//this.mostralDatosCorrectos = true;
	}
	handleMFDatosIncorrectos(){
		this.cerrarModal();
	}

	handleMFIdentificadorBloqueado(){
		//this.cerrarModal();
		this.handleModalToast(this.toastMecanismoFirmaIdentificadorBloqueado);
		//this.toast('warning', 'Identificador bloqueado', this.toastMecanismoFirmaIdentificadorBloqueado);

	}

	handleMFIdentificadorSinBloquear(){
		comprobarCasoCreadoMecanismoFirma({recordId: this.recordId})
		.then(resultado => {
			if(resultado){
				this.handleModalToast(this.toastMecanismoFirmaCasoCreado);
				//this.toast('warning', 'Atención', this.toastMecanismoFirmaCasoCreado);
			}else{
				this.handleModalToast(this.toastMecanismoFirmaIdentificadorSinBloquear);
				//this.toast('warning', 'Identificador sin bloquear', this.toastMecanismoFirmaIdentificadorSinBloquear);
				crearCasoMecanismoFirma({recordId: this.recordId, clienteExtranjero: true});
			}
			//this.cerrarModal();
		}).catch(error => {
			console.error(error);
			this.cerrarModal();
		});
	}

	handleChangeMF(event) {
		if (event.target) {

			let value = event.target.value;
			let name = event.target.name;

			// Verifica si la clave ya existe en respuestasMecanismoFirmaDatos
			if (!this.respuestasMecanismoFirmaDatos.some(item => item.key === name)) {
				this.respuestasMecanismoFirmaDatos.push({ key: name, value: value });
			} else {
				for (let item of this.respuestasMecanismoFirmaDatos) {
					if (item.key === name) {
						item.value = value;
						return;
					}
				}
			}
			// Verifica si todas las preguntas están completas
			if (this.respuestasMecanismoFirmaDatos.length === this.preguntaMecanismoFirmaDatosValores.length) {
				this.preguntasCompletasMecanismoFirma = true;
			}
		}
	}

	handleMFClienteIdentificado(){
/*		let denied;
		let restricted;

		recuperarArgosMecanismoFirmaDenied({recordId: this.recordId})
		.then(retorno => {
			denied = retorno.denied;
		})
		.catch(error => {
			console.error(error);
			this.cerrarModal();
		});

		recuperarArgosMecanismoFirmaRestricted({recordId: this.recordId})
		.then(retorno => {
			restricted = retorno.restricted;
		})
		.catch(error => {
			console.error(error);
			this.cerrarModal();
		});

		if(denied){
			let datosAdicionales = this.cybersocMF;
			let origen = 'operativaDerivar';
			let destino = 'realizartrasladocolaborador';
			this.cerrarModal();
			this.publicarMensajeDerivarInteraccion(origen, destino, datosAdicionales);
		}else if(restricted){
			this.handleModalToast(this.toastMecanismoFirmaAsuntoEnvioCodigo);
		}
*/	}

	handleMFNull(){
		this.preguntaMecanismoFirma = false;
		this.preguntaMecanismoFirmaDatos = false;
		this.preguntaMecanismoFirmaDatosValores = false;
		this.preguntaMecanismoFirmaIdentificador = false;
		this.preguntaMecanismoFirmaClienteAutenticado = false;
	}
		
	//MECANISMO FIRMA

	//Oficina sin tarea
	handleOficinaSinTarea(){
		
		getUrlNumeroOficinaApex({recordId: this.oficinaPrincipal})
		.then(resultado => {
			if (resultado.url) {
				this.urlOficina = resultado.url;
				this.numeroOficina = resultado.numeroOficina;
				this.mostrarModalToast = false;

				this.handleModalToastUrl(this.mensajeOficinaSinTarea);
			}
		});

		crearActividadOficinaSinTarea({recordId: this.recordId})
		.catch(error => {
			console.error(error);
			this.cerrarModal();
		});

	}

	//Oficina sin tarea

	/*

	//Colectivos vulnerables
	handleColectivoVulnerable(){

	}
	//Colectivos vulnerables*/
	
	//Derivar a SAC
	handleDerivarSAC(){
		this.activarSpinner();
		derivarSACApex({casoContactCenter: this.casoActual, motivo: 'Asignación de caso al SAC'})
		.then(() => {
			this.desactivarSpinner();
			this.handleModalToast(this.mensajeDerivarAlSACSuccess);
        
        })
		.catch(error => {
			console.error(error);
			this.desactivarSpinner();
			this.cerrarModal();
		});
	}
	//Fin Derivar a SAC

	//Devolver a SAC
	handleDevolverSAC(){
		if (this.motivoSAC === '' || this.motivoSAC === null || this.motivoSAC === undefined) {
            //Mostrar toast de advertencia si el motivo está vacío
            this.toast('warning', 'Advertencia', 'Por favor, rellene el motivo antes de continuar');
        } else {
			this.activarSpinner();
			devolverSACApex({motivo: this.motivoSAC, casoContactCenter: this.casoActual})
			.then(() => {
				this.desactivarSpinner();
				this.handleModalToast(this.mensajeDevolverAlSACSuccess);
				
			})
			.catch(error => {
				console.error(error);
				this.desactivarSpinner();
				this.cerrarModal();
			});
		}
	}

	handleMotivoSACChange(event) {
        this.motivoSAC = event.target.value;
    }
	//Fin Devolver a SAC

	//Onboarding/Desistir
	handleOnboarding() {
		this.activarSpinner();
		envioCorreoOnboarding({recordId: this.recordId})
			.then(() => {
				this.desactivarSpinner();
				this.handleModalToast(this.textoCorreoEnviado);
			})
			.catch(error => {
				this.desactivarSpinner();
			}).finally(() => {
				this.dispatchEvent(new CustomEvent('refrescartab', {detail: {}}));
			});
	}

	cerrarCasoOnboarding() {
		cerrarCasoOnboarding({recordId: this.recordId})
			.then(() => {
				this.cerrarModal(this.textoCasoCerrado);
			}).finally(() => {
				this.dispatchEvent(new CustomEvent('refrescartab', {detail: {}}));
			});
	}
	//Fin Onboarding/Desistir

	activarSpinner() {
		this.showSpinner = true;
	}

	desactivarSpinner() {
		this.showSpinner = false;
	}

	activarModalCita() {
		this.mostrarTareaModalCitaGestor = true;
	}

	activarModalCita() {
		this.mostrarTareaModalCitaGestor = false;
	}

	activarBotonCita() {
		this.ocultarBotonCita = false;
	}

	desactivarBotonCita() {
		this.ocultarBotonCita = true;
	}

	valorFechaCitaRapida(event) {
		this.fechaSeleccionada = event.detail;
	}
	
	valorFranjaCitaRapida(event) {
		this.franjaSeleccionada = event.detail;
	}

	valorTipoCita(event) {
		this.tipoCita =  event.target.value;
	}

	amenazasSuicidios(event){
		this.direccionAmenazasSuicidiosInputValue = event.detail.street + ' ' + event.detail.city + ' ' + event.detail.province + ' ' + event.detail.country;
	}

	get archivosLength() {
		return this.archivos ? this.archivos.length : 0;
	}
}