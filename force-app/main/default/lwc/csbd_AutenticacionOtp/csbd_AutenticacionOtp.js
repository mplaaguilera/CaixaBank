import {LightningElement, api, wire, track} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {NavigationMixin} from 'lightning/navigation';
import LightningConfirm from 'lightning/confirm';
import {errorApex} from 'c/csbd_lwcUtils';
import {DATATABLE_COLUMNS, NAME_COLUMN, confirmarInicioAutenticacion, toast} from './utils.js';
import {n2ValidarOtpMockOk, n2ValidarOtpMockKo} from './mocks.js';

import OPP_IDENTIFICADOR from '@salesforce/schema/Opportunity.CSBD_Identificador__c';
import OPP_RT_DEVELOPERNAME from '@salesforce/schema/Opportunity.RecordType.DeveloperName';
import OPP_OWNER_ID from '@salesforce/schema/Opportunity.OwnerId';
import OPP_ESTADO from '@salesforce/schema/Opportunity.CSBD_Estado__c';
import OPP_IDIOMA from '@salesforce/schema/Opportunity.CSBD_Idioma_Solicitud__c';
import OPP_FECHA_AUT from '@salesforce/schema/Opportunity.CSBD_UltimaAutenticacionFecha__c';
import OPP_NIVEL_AUT from '@salesforce/schema/Opportunity.CSBD_UltimaAutenticacionNivel__c';
import OPP_ESTADO_AUT from '@salesforce/schema/Opportunity.CSBD_EstadoAutenticacion__c';
//import OPP_CASO_ORIGEN_ID from '@salesforce/schema/Opportunity.CSBD_CasoOrigen__c';
//import OPP_CASO_ORIGEN_CANAL_ENTRADA from '@salesforce/schema/Opportunity.CSBD_CasoOrigen__r.Origin';
//import OPP_CASO_ORIGEN_REPRESENTANTE from '@salesforce/schema/Opportunity.CSBD_CasoOrigen__r.CC_Representante__c';
import OPP_ACCOUNT_ID from '@salesforce/schema/Opportunity.AccountId';
import OPP_ACCOUNT_NAME from '@salesforce/schema/Opportunity.Account.Name';
import OPP_ACCOUNT_EDAD from '@salesforce/schema/Opportunity.Account.AV_Age__c';
import OPP_ACCOUNT_MENOR_EMANCIPADO from '@salesforce/schema/Opportunity.Account.CC_MenorEmancipado__c';
import OPP_CONTACT_ID from '@salesforce/schema/Opportunity.CSBD_Contact__c';

import getDatosApex from '@salesforce/apex/CSBD_AutenticacionOtp_Apex.getDatos';
import getDatosAsyncApex from '@salesforce/apex/CSBD_AutenticacionOtp_Apex.getDatosAsync';
import getAutenticacionesApex from '@salesforce/apex/CSBD_AutenticacionOtp_Apex.getAutenticaciones';
import getPreguntasNivel2Apex from '@salesforce/apex/CSBD_AutenticacionOtp_Apex.getPreguntasNivel2';
import getPreguntasEmergenciaApex from '@salesforce/apex/CSBD_AutenticacionOtp_Apex.getPreguntasEmergencia';
import autenticacionEmergenciaApex from '@salesforce/apex/CSBD_AutenticacionOtp_Apex.autenticacionEmergencia';
import autenticacionClienteDigitalApex from '@salesforce/apex/CSBD_AutenticacionOtp_Apex.autenticacionClienteDigital';
import autenticacionClienteDigitalEnviarApex from '@salesforce/apex/CSBD_AutenticacionOtp_Apex.autenticacionClienteDigitalEnviar';
import autenticacionClienteDigitalValidarApex from '@salesforce/apex/CSBD_AutenticacionOtp_Apex.autenticacionClienteDigitalValidar';
import nivel2ValidacionInicialApex from '@salesforce/apex/CSBD_AutenticacionOtp_Apex.nivel2ValidacionInicial';
import nivel2EnviarSolicitudOtpApex from '@salesforce/apex/CSBD_AutenticacionOtp_Apex.nivel2EnviarSolicitudOtp';
import validacionRespuestasNivel2Apex from '@salesforce/apex/CSBD_AutenticacionOtp_Apex.validacionRespuestasNivel2';
import segundoNivelApex from '@salesforce/apex/CSBD_AutenticacionOtp_Apex.segundoNivel';
import n2ValidarOtpApex from '@salesforce/apex/CSBD_AutenticacionOtp_Apex.n2ValidarOtp';
import codigoAutenticacionNoRecibidoApex from '@salesforce/apex/CSBD_AutenticacionOtp_Apex.codigoAutenticacionNoRecibido';
import cancelarAutenticacionApex from '@salesforce/apex/CSBD_AutenticacionOtp_Apex.cancelarAutenticacion';
import eliminarAutenticacionesClienteApex from '@salesforce/apex/CSBD_AutenticacionOtp_Apex.eliminarAutenticacionesCliente';

const OPPTY_FIELDS = [
	OPP_IDENTIFICADOR, OPP_RT_DEVELOPERNAME, OPP_OWNER_ID, OPP_ESTADO, OPP_IDIOMA, OPP_ESTADO_AUT, OPP_FECHA_AUT, OPP_NIVEL_AUT, //OPP_INTENTOS_AUT,
	//OPP_CASO_ORIGEN_ID, OPP_CASO_ORIGEN_CANAL_ENTRADA, OPP_CASO_ORIGEN_REPRESENTANTE, //OPP_CASO_ORIGEN_OMITIR_PREGUNTAS,
	OPP_ACCOUNT_ID, OPP_ACCOUNT_NAME, OPP_ACCOUNT_EDAD, OPP_ACCOUNT_MENOR_EMANCIPADO, OPP_CONTACT_ID
];

//eslint-disable-next-line new-cap
export default class csbdAutenticacionOtp extends NavigationMixin(LightningElement) {
	@api recordId;

	@track componente = {
		usuarioDesarrollador: false,
		abierto: false,
		autEmergenciaHabilitada: false,
		spinner: false,
		funcionesBind: {},
		simularRespuestas: {enviarOtp: null, validarOtp: null, enviarPush: null}
	};

	oportunidad;

	//canalAutenticable = false;

	datatableColumns = DATATABLE_COLUMNS;

	@track datatableData = {datatableEnCurso: [], datatableHistorico: [], datatableHistoricoFiltrada: []};

	historicoFiltrado = false;

	autenticacionPendValidar;

	preguntasNivel2 = {pregunta1: {}, pregunta2: {}};

	omitirOtpNivel2 = false;

	preguntasEmergencia = {basicas: [], aleatorias: []};

	modalMensaje = {iconName: null, iconClass: null, mensaje: null, spinner: false};

	get modalAutenticacionOtpClass() {
		const hayDatos = this.datatableData.datatableEnCurso.length || this.datatableData.datatableHistorico.length;
		return `modalAutenticar slds-modal ${hayDatos ? 'csbd-modal_ancho' : 'slds-modal_small'}`;
	}

	get nivelClienteDigital() {
		return this.nivel === 'Cliente Digital';
	}

	get botonEmergenciaAttribs() {
		if (this.componente.autEmergenciaHabilitada) {
			return {class: 'botonEmergencia', iconName: 'utility:notification'};
		}
		return {class: 'botonEmergencia noDisponible', iconName: 'utility:notification_off'};

	}

	@wire(getRecord, {recordId: '$recordId', fields: OPPTY_FIELDS})
	async wiredOpportunity({data, error}) {
		if (data) {
			this.oportunidad = {...data,
				_identificador: getFieldValue(data, OPP_IDENTIFICADOR),
				_accountName: getFieldValue(data, OPP_ACCOUNT_NAME)
			};
			this.componente.abierto && this.abrirModal(true);
		} else if (error) {
			console.error(error);
			toast('error', 'Problema recuperando los datos de la oportunidad', error);
		}
	}

	async iniciarAutenticacion({currentTarget: {dataset: {nivel}}}) {
		if (nivel === 'Emergencia' && !this.componente.autEmergenciaHabilitada) {
			toast('info', 'Autenticación de emergencia no disponible', 'La autenticación segura de emergencia se ha deshabilitado temporalmente');
			return;
		}

		this.nivel = nivel;
		if (await confirmarInicioAutenticacion(nivel)) {
			//this.cerrarModalNuevoIntento(); //PENDIENTE!
			this.componente.spinner = true;

			if (nivel === 'Nivel 2') {
				nivel2ValidacionInicialApex({recordId: this.recordId})
				.then(async ({resultado, omitirOtp}) => {
					this.componente.spinner = false;
					if (resultado === 'PENDIENTE VALIDAR') {
						toast('info', 'Autenticación de nivel 2 no disponible', 'Ya hay una autenticación previa pendiente de validar');
					} else if (resultado === 'SIN DATOS') {
						toast('info', 'Autenticación de nivel 2 no disponible', `No constan datos suficientes para poder validar la identidad del cliente ${getFieldValue(this.oportunidad, OPP_ACCOUNT_NAME)}`);
					} else if (resultado === 'CLIENTE BLOQUEADO') {
						toast('error', 'Autenticación de nivel 2 no disponible', 'No se permite autenticar al cliente ya que se encuentra bloqueado de manera preventiva');
					/*
					} else if (resultado === 'SIN LLAMADAS') {
						toast('info', 'Autenticación de nivel 2 no disponible', 'No hay ninguna llamada de teléfono en curso');
					*/
					} else if (resultado === 'OK') {
						this.componente.spinner = true;
						this.omitirOtpNivel2 = omitirOtp;
						await this.abrirModalPreguntasNivel2();
					}
				}).catch(error => {
					errorApex(this, error, 'Problema iniciando la autenticación de nivel 2');
					this.componente.spinner = false;
				});

			} else if (nivel === 'Emergencia') {
				/*
				if (this.canalAutenticable) {
					this.abrirModalPreguntasEmergencia();
				} else {
					this.componente.spinner = false;
					toast('info', 'Autenticación de emergencia no disponible', 'La autenticación segura de emergencia no está disponible para el canal ' + getFieldDisplayValue(this.oportunidad, OPP_CASO_ORIGEN_CANAL_ENTRADA));
				}
				xs*/
				this.abrirModalPreguntasEmergencia();

			} else if (nivel === 'Cliente Digital') {
				/*
				if (this.canalAutenticable) {
					this.crearAutenticacion('Cliente Digital');
				} else {
					this.componente.spinner = false;
					toast('info', 'Autenticación de cliente digital no disponible', 'La autenticación segura de cliente digital no está disponible para el canal ' + getFieldDisplayValue(this.oportunidad, OPP_CASO_ORIGEN_CANAL_ENTRADA));
				}
				*/
				this.crearAutenticacion('Cliente Digital');
			}
		}
	}

	async crearAutenticacion(nivel, tipo) {
		this.componente.spinner = true;
		if (nivel === 'Nivel 2') {
			const inputsPreguntas = Array.from(this.template.querySelectorAll('lightning-input.inputPregunta'));
			inputsPreguntas.forEach(i => i.reportValidity());
			if (!inputsPreguntas.every(i => i.validity.valid)) {
				this.componente.spinner = false;
			} else {
				validacionRespuestasNivel2Apex({
					recordId: this.recordId,
					pregunta1: this.preguntasNivel2.pregunta1.inputLabel,
					respuesta1: this.refs.nivel2InputPregunta1.value.toString(),
					pregunta2: this.preguntasNivel2.pregunta2.inputLabel,
					respuesta2: this.refs.nivel2InputPregunta2.value.toString()
				}).then(async retornoValidacionRespuestas => {
					if (!retornoValidacionRespuestas.respuesta1 || !retornoValidacionRespuestas.respuesta2) {
						//Respuestas nivel 2 KO
						this.componente.spinner = false;
						/*
						this.notificarKo('Las respuestas son incorrectas.', () => {
							this.n2crearRegistroAutenticacion(retornoValidacionRespuestas)
							.catch(error => errorApex(this, error, 'Error en validacionesBasicas'))
							.finally(() => this.notificarKoCerrar());
						}, false);
						*/
						this.modalMensajeAbrir('Las respuestas son incorrectas.', 'utility:error', 'modalMensajeIconError', false, 1400);

						this.n2crearRegistroAutenticacion(retornoValidacionRespuestas)
						.catch(error => errorApex(this, error, 'Problema registrando el intento fallido de autenticación'));
					} else {
						//Respuestas nivel 2 OK
						/*
						if (!this.canalAutenticable) {
							this.cerrarModalPreguntasNivel2();
							this.componente.spinner = false;
							toast('info', 'Autenticación de nivel 2 no disponible', 'La autenticación segura de nivel 2 con envío de OTP no está disponible para el canal ' + getFieldDisplayValue(this.oportunidad, OPP_CASO_ORIGEN_CANAL_ENTRADA));
						} else {
						*/
						try {
							await this.n2crearRegistroAutenticacion(retornoValidacionRespuestas);
							//if (!getFieldValue(this.oportunidad, OPP_CASO_ORIGEN_OMITIR_PREGUNTAS)) {
							const callback = () => window.setTimeout(() => {
								this.n2EnviarOtp();
							}, 0);
							this.modalMensajeAbrir(
								'Las respuestas son correctas.', 'utility:success', 'modalMensajeIconSuccess',
								false, 1400, callback
							);
							//}
						} catch (error) {
							errorApex(this, error, 'Problema registrando la autenticación');
						}
						//}
					}
				}).catch(error => {
					errorApex(this, error, 'Problema comprobando las respuestas');
					this.componente.spinner = false;
				});
			}
		} else if (nivel === 'Emergencia') {
			//Se envía un email al cliente
			autenticacionEmergenciaApex({idOportunidad: this.recordId, nivel: this.nivel, valido: tipo === 'Válido'})
			.then(response => {
				if (response === 'Email' || response === 'OK') {
					toast('success', 'Correo enviado', 'Correo enviado');
					this.cerrarModalPreguntasEmergencia();
				} else if (response === 'Correo no informado') {
					toast('info', 'Autenticación de emergencia no disponible', 'El campo "Email solicitud" de la oportunidad no está informado');
				} else {
					//PENDIENTE
					//component.set('v.noValidado', true);
					//component.set('v.mensajeNoValidado', response);
					this.cerrarModalPreguntasEmergencia();
				}
			}).catch(error => {
				errorApex(this, error, 'Problema comprobando las respuestas');
				this.componente.spinner = false;
			}).finally(() => this.componente.spinner = false);
		} else if (nivel === 'Cliente Digital') {
			//PENDIENTE
			autenticacionClienteDigitalApex({
				idOportunidad: this.recordId,
				idCliente: getFieldValue(this.oportunidad, OPP_ACCOUNT_ID),
				ownerId: getFieldValue(this.oportunidad, OPP_OWNER_ID)
			}).then(({idAutenticacion, resultado}) => {
				if (resultado === 'NOK') {
					toast('info', 'Autenticación de cliente digital no disponible', 'No hay ninguna llamada de teléfono en curso');
					this.componente.spinner = false;
				} else if (resultado === 'Cliente bloqueado') {
					toast('error', 'Autenticación de cliente digital no disponible', 'No se permite autenticar al cliente ya que se encuentra bloqueado de manera preventiva');
					this.componente.spinner = false;
				} else if (resultado === 'OK') {
					this.componente.spinner = false;
					this.modalMensajeAbrir('Solicitando envío del código de un solo uso al cliente...', 'utility:push', null, true);
					autenticacionClienteDigitalEnviarApex({recordId: this.recordId, autenticacionId: idAutenticacion})
					.then(async resultadoEnvio => {
						if (resultadoEnvio === 'OK') {
							await this.actualizarTablasAutenticaciones();
							this.autenticacionPendValidar = this.datatableData.datatableEnCurso.find(a => a.Id === idAutenticacion);
							this.modalMensajeCerrar(async () => await this.abrirModalValidarPush());

						} else {
							console.error(resultadoEnvio);
							toast('error', 'Problema enviando la autenticación de cliente digital', resultadoEnvio);
							this.modalMensajeCerrar(() => this.abrirModal());
						}
					}).catch(error => errorApex(this, error, 'Problema enviando la autenticación de cliente digital'));
				}
			}).catch(error => {
				this.actualizarTablasAutenticaciones();
				errorApex(this, error, 'Problema iniciando la autenticación de cliente digital');
				this.componente.spinner = false;
			});
		}
	}

	async cancelarAutenticacion(autenticacion) {
		if (await LightningConfirm.open({
			variant: 'header', theme: 'error', label: 'Descartar autenticación',
			message: '¿Quieres descartar esta autenticacion segura de ' + autenticacion.CC_Nivel__c.toLowerCase() + ' en curso?'
		})) {
			this.componente.spinner = true;
			return cancelarAutenticacionApex({
				idOportunidad: autenticacion.CSBD_Opportunity__c,
				idAutenticacion: autenticacion.Id
			}).then(() => {
				toast('info', 'Se canceló autenticación', 'Se canceló correctamente la autenticación de ' + autenticacion.CC_Nivel__c.toLowerCase());
				this.actualizarTablasAutenticaciones();
				return true;
			}).catch(error => errorApex(this, error, 'Problema cancelando la autenticación de cliente digital'))
			.finally(() => this.componente.spinner = false);
		}
		return false;
	}

	@api async abrirModal(aperturaInicial = false) {
		//this.componente.abierto = true;

		const mostrarModal = () => {
			this.refs.backdropModal.classList.add('slds-backdrop_open');
			this.refs.modalAutenticacionOtp.classList.add('slds-fade-in-open');
			window.setTimeout(() => this.refs.modalBotonCerrar.focus(), 90);
		};

		this.componente.abierto = true;

		if (!aperturaInicial) {
			await this.actualizarTablasAutenticaciones();
			mostrarModal();
			return;
		}

		//Apertura inicial (necesita que el @wire haya acabado para que this.oportunidad tenga datos)
		if (this.oportunidad && !this.template.querySelectorAll('section.slds-modal.slds-fade-in-open').length) { //No hay ningún modal ya abierto
			this.modalMensajeAbrir('Cargando...', null, null, true);

			//Evaluar condiciones para abrir el modal
			if (!await this.abrirModalValidacionesOk()) {
				this.refs.backdropModal.classList.remove('slds-backdrop_open');
				this.componente.abierto = false;
				return;
			}

			//Condiciones para abrir el modal OK
			this.componente.abierto = true;
			await this.actualizarTablasAutenticaciones();
			this.modalMensajeCerrar();
			mostrarModal();

			window.setTimeout(() => {
				getDatosAsyncApex({})
				//.then(({autEmergenciaHabilitada, canalAutenticable}) => {
				.then(({autEmergenciaHabilitada}) => {
					this.componente.autEmergenciaHabilitada = autEmergenciaHabilitada || this.componente.usuarioDesarrollador;
					//this.canalAutenticable = getFieldValue(this.oportunidad, OPP_RT_DEVELOPERNAME) !== 'CSBD_MAC' || canalAutenticable;
				});
			}, 300);
		}
	}

	async abrirModalValidacionesOk() {
		/*
		//Condiciones para iniciar la operativa que no requieren invocar método Apex
		if (getFieldValue(this.oportunidad, OPP_RT_DEVELOPERNAME) === 'CSBD_MAC' && !getFieldValue(this.oportunidad, OPP_CASO_ORIGEN_ID)) {
			this.modalMensajeCerrar();
			toast('error', 'Operativa de autenticación segura no disponible', 'La oportunidad no está vinculada a un caso origen de contact center');
			return false;

		} else if (this.clienteMenorSinRepresentante()) {
			this.modalMensajeCerrar();
			toast('error', 'Operativa de autenticación segura no disponible', 'El cliente es menor y el caso origen no tiene representante legal informado');
			return false;
		}
		*/
		//Condiciones para iniciar la operativa que requieren invocar método Apex
		try {
			//const {llamadaEnCurso, clienteBloqueado, usuarioDesarrollador} = await getDatosApex({
			const {clienteBloqueado, usuarioDesarrollador} = await getDatosApex({
				idOportunidad: this.recordId,
				idCliente: getFieldValue(this.oportunidad, OPP_ACCOUNT_ID)
			});
			this.componente.usuarioDesarrollador = usuarioDesarrollador;
			//this.componente.usuarioDesarrollador = false;

			/*
			if (!llamadaEnCurso) {
				this.modalMensajeCerrar();
				toast('info', 'Operativa de autenticación segura no disponible', 'No hay ninguna llamada de teléfono en curso');
				return false;
			}
			*/

			if (clienteBloqueado) {
				this.modalMensajeCerrar();
				toast('error', 'Operativa de autenticación segura no disponible', 'No se permite autenticar al cliente ya que se encuentra bloqueado de manera preventiva');
				return this.componente.usuarioDesarrollador;
			}

			if (usuarioDesarrollador) {
				this.mostrarOcultarColumnaNombreAutenticaciones();
			}
			return true;

		} catch (error) {
			this.modalMensajeCerrar();
			errorApex(this, error, 'Problema recuperando los datos de la oportunidad');
			return false;
		}
	}

	async datatablesOnrowaction({detail: {row: autenticacion}}) {
		if (autenticacion._accionName === 'enviar') {
			this.nivel = autenticacion.CC_Nivel__c;
			this.autenticacionPendValidar = autenticacion;
			this.n2EnviarOtp();

		} else if (autenticacion._accionName === 'validar') {
			this.nivel = autenticacion.CC_Nivel__c;
			this.autenticacionPendValidar = autenticacion;
			this.abrirModalValidarOtp();

		} else if (autenticacion._accionName === 'cancelar') {
			this.cancelarAutenticacion(autenticacion);

		} else if (autenticacion._accionName === 'verOportunidad') {
			this[NavigationMixin.Navigate]({type: 'standard__recordPage', attributes: {
				recordId: autenticacion.CSBD_Opportunity__c,
				actionName: 'view'
			}});
		}
	}

	async cerrarModal(ocultarBackdrop = true) {
		if (!this.componente.spinner) {
			this.componente.abierto = false;
			this.refs.modalAutenticacionOtp.classList.remove('slds-fade-in-open');
			ocultarBackdrop && this.refs.backdropModal.classList.remove('slds-backdrop_open');
		}
	}

	modalTeclaPulsada({keyCode}) {
		!this.componente.spinner && keyCode === 27 && this.cerrarModal(); //Tecla ESC
	}

	async actualizarTablasAutenticaciones() {
		try {
			const ESTADOS_RESULTADOS_CLASS = [
				{valor: 'Aprobado', class: 'slds-text-color_success'},
				{valor: 'Cerrado', class: 'slds-text-color_success'},
				{valor: 'Denegado', class: 'slds-text-color_error'},
				{valor: 'Error', class: 'slds-text-color_error'},
				{valor: 'Expirado', class: 'slds-text-color_error'},
				{valor: 'No autorizado', class: 'slds-text-color_error'},
				{valor: 'Rechazado', class: 'slds-text-color_error'},
				{valor: 'OTP errónea', class: 'slds-text-color_error'},
				{valor: 'Identificación NOK', class: 'slds-text-color_error'}
			];
			const NOMBRES_ACCIONES = {
				true: {
					'Nivel 2': {'Pdte. Envío': 'enviar', 'default': 'validar'},
					'default': {default: 'cancelar'}
				},
				false: {
					default: {true: 'verOportunidad', false: 'sinOportunidad'}
				}
			};
			const ACCIONES = {
				enviar: {title: 'Enviar', iconName: 'utility:send', iconClass: null},
				validar: {title: 'Validar', iconName: 'utility:thunder', iconClass: null},
				cancelar: {title: 'Descartar', iconName: 'utility:delete', iconClass: 'slds-icon-text-error'},
				verOportunidad: {title: 'Ver oportunidad', iconName: 'utility:opportunity', iconClass: null, iconVariant: 'border-filled'},
				sinOportunidad: {title: 'Sin oportunidad vinculada', iconName: 'utility:question_mark', iconVariant: 'container'}
			};

			const autenticaciones = await getAutenticacionesApex({recordId: this.recordId, idCliente: getFieldValue(this.oportunidad, OPP_ACCOUNT_ID)});
			let enCurso = [], historico = [];
			for (const aut of autenticaciones) {
				const autEnCurso = aut.CSBD_Opportunity__c === this.recordId && !aut.CSBD_EstadoFinal__c;
				let nombreAccion = NOMBRES_ACCIONES[autEnCurso];
				nombreAccion = nombreAccion[aut.CC_Nivel__c] ?? nombreAccion.default;
				nombreAccion = nombreAccion[autEnCurso ? aut.CC_Estado__c : !!aut.CSBD_Opportunity__c] ?? nombreAccion.default;
				const accion = ACCIONES[nombreAccion];
				const camposInternos = {
					_accionName: nombreAccion,
					_accionTitle: accion.title,
					_accionIconName: accion.iconName,
					_accionIconClass: accion.iconClass,
					_accionIconVariant: accion.iconVariant,
					_autenticacionUrl: `/${aut.Id}`,
					_oportunidadUrl: aut.CSBD_Opportunity__c ? `/${aut.CSBD_Opportunity__c}` : '',
					_oportunidadIdentificador: aut.CSBD_Opportunity__r?.CSBD_Identificador__c,
					_estadoClass: ESTADOS_RESULTADOS_CLASS.find(e => e.valor === aut.CC_Estado__c)?.class,
					_resultadoClass: ESTADOS_RESULTADOS_CLASS.find(r => r.valor === aut.CC_Resultado_Validacion__c)?.class
				};
				(autEnCurso ? enCurso : historico).push({...aut, ...camposInternos});
			}
			this.datatableData.datatableEnCurso = enCurso;
			this.datatableData.datatableHistorico = historico;
			this.filtrarHistorico();
			if (this.autenticacionPendValidar) {
				this.autenticacionPendValidar = enCurso.find(a => a.Id === this.autenticacionPendValidar.Id);
			}


		} catch (error) {
			errorApex(this, error, 'Problema recuperando la lista de autenticaciones');
			this.datatableData.datatableEnCurso = [];
			this.datatableData.datatableHistorico = [];
		}
	}

	toggleHistoricoFiltradoOnchange(event) {
		this.historicoFiltrado = event.currentTarget.checked;
		this.filtrarHistorico();
	}

	filtrarHistorico() {
		let datatableHistoricoFiltrada;
		if (this.historicoFiltrado) {
			datatableHistoricoFiltrada = this.datatableData.datatableHistorico.filter(a => a.CSBD_Opportunity__c === this.recordId);
		} else {
			datatableHistoricoFiltrada = this.datatableData.datatableHistorico;
		}
		this.datatableData.datatableHistoricoFiltrada = datatableHistoricoFiltrada;
	}

	async abrirModalPreguntasNivel2() {
		this.componente.spinner = true;
		getPreguntasNivel2Apex({recordId: this.recordId})
		.then(preguntas => {
			const getParamsInputPregunta = label => [
				{tipoPregunta: 'cuenta', inputType: 'number', inputMin: 4, inputMax: 9999, inputMaxLength: 4, inputPlaceholder: '1234'},
				{tipoPregunta: 'tarjeta', inputType: 'number', inputMin: 4, inputMax: 9999, inputMaxLength: 4, inputPlaceholder: '1234'},
				{tipoPregunta: 'año', inputType: 'number', inputMin: 1900, inputMax: 2040, inputMaxLength: 4, inputPlaceholder: '2024'},
				{tipoPregunta: 'edad', inputType: 'number', inputMin: 0, inputMax: 99, inputMaxLength: 2, inputPlaceholder: '18'}
			].find(pi => label && label.toLowerCase().includes(pi.tipoPregunta))
			|| {inputType: 'text', inputMin: 3, inputMax: null, inputMaxLength: 255, inputPlaceholder: '93000000'};

			this.preguntasNivel2 = {
				pregunta1: {...getParamsInputPregunta(preguntas.pregunta1), inputLabel: preguntas.pregunta1, textoAyuda: preguntas.textoAyuda1},
				pregunta2: {...getParamsInputPregunta(preguntas.pregunta2), inputLabel: preguntas.pregunta2, textoAyuda: preguntas.textoAyuda2}
			};
			this.componente.spinner = false;
			this.cerrarModal(false);

			const desarrollador = this.componente.usuarioDesarrollador;
			if (this.refs.nivel2InputPregunta1) {
				this.refs.nivel2InputPregunta1.value = desarrollador ? '650399855' : null;
			}
			if (this.refs.nivel2InputPregunta2) {
				this.refs.nivel2InputPregunta2.value = desarrollador ? 1984 : null;
			}

			this.refs.modalPreguntasNivel2.classList.add('slds-fade-in-open');
			window.setTimeout(() => this.refs.nivel2InputPregunta1.focus(), 90);
		}).catch(error => errorApex(this, error, 'Problema recuperando la lista de preguntas de validación para nivel 2'))
		.finally(() => this.componente.spinner = false);
	}

	cerrarModalPreguntasNivel2() {
		this.refs.modalPreguntasNivel2.classList.remove('slds-fade-in-open');
		this.abrirModal();
	}

	modalPreguntasNivel2TeclaPulsada({keyCode}) {
		!this.componente.spinner && keyCode === 27 && this.cerrarModalPreguntasNivel2(); //Tecla ESC
	}

	modalPreguntasNivel2Validar() {
		this.crearAutenticacion(this.nivel);
	}

	async n2crearRegistroAutenticacion({respuesta1, respuesta2}) {
		try {
			const retorno = await segundoNivelApex({
				recordId: this.recordId,
				valido: respuesta1 && respuesta2,
				nivel: 'Nivel 2',
				pregunta1: this.preguntasNivel2.pregunta1.inputLabel,
				respuesta1: this.refs.nivel2InputPregunta1.value,
				pregunta2: this.preguntasNivel2.pregunta2.inputLabel,
				respuesta2: this.refs.nivel2InputPregunta2.value,
				validacion1: respuesta1,
				validacion2: respuesta2,
				enviarSMS: this.omitirOtpNivel2
				//enviarPreguntas: getFieldValue(this.oportunidad, OPP_CASO_ORIGEN_OMITIR_PREGUNTAS)
			});

			await this.actualizarTablasAutenticaciones();

			console.log('this.datatableData.datatableEnCurso');
			console.log(this.autenticacionPendValidar);
			console.log('retorno');
			console.log(retorno);

			this.autenticacionPendValidar = this.datatableData.datatableEnCurso.find(a => a.Id === retorno.id);
			if (retorno.resultado !== 'OK') { //&& !getFieldValue(this.oportunidad, OPP_CASO_ORIGEN_OMITIR_PREGUNTAS)) {
				this.abrirModalNuevoIntento();
			}
		} catch (error) {
			errorApex(this, error, 'Problema creando el registro de autenticación');
		}
	}

	async abrirModalPreguntasEmergencia() {
		if (!this.preguntasEmergencia.length) {
			const retorno = await getPreguntasEmergenciaApex({});
			this.preguntasEmergencia = {
				basicas: retorno.basicas.map(p => ({id: p.Id, nombre: p.Name, valor: p.CC_Valor__c})),
				aleatorias: retorno.aleatorias.map(p => ({id: p.Id, nombre: p.Name, valor: p.CC_Valor__c}))
			};
		}
		this.componente.spinner = false;
		this.cerrarModal(false);
		this.refs.modalPreguntasEmergencia.classList.add('slds-fade-in-open');
	}

	cerrarModalPreguntasEmergencia() {
		this.refs.modalPreguntasEmergencia.classList.remove('slds-fade-in-open');
		this.abrirModal();
	}

	modalPreguntasEmergenciaTeclaPulsada({keyCode}) {
		!this.componente.spinner && keyCode === 27 && this.cerrarModalPreguntasEmergencia(); //Tecla ESC
	}

	modalPreguntasEmergenciaFinalizar({currentTarget: {dataset: {respuesta}}}) {
		this.crearAutenticacion(this.nivel, respuesta);
	}

	async abrirModalValidarOtp() {
		await this.cerrarModal(false);
		const modalesAbiertos = this.template.querySelectorAll('section.slds-modal.slds-fade-in-open:not(.modalAutenticacionOtp)');
		modalesAbiertos.forEach(m => m.classList.remove('slds-fade-in-open'));

		this.template.querySelectorAll('input.inputOtp').forEach(inputOtp => {
			inputOtp.value = null;
			inputOtp.classList.remove('csbd-has-error');
		});
		await this.actualizarTablasAutenticaciones();
		this.refs.modalValidarOtp.classList.add('slds-fade-in-open');
		window.setTimeout(() => this.refs.inputOtp1?.focus(), 90);
	}

	async cerrarModalValidarOtp(event, confirmar = true) {
		if (confirmar && !await LightningConfirm.open({
			variant: 'header', theme: 'info', label: 'Pendiente de validar',
			message: '¿Quieres cerrar la validación del código OTP? Puedes reanudar la validación más tarde desde la lista de autenticaciones en curso.'
		})) {
			return;
		}
		this.refs.modalValidarOtp.classList.remove('slds-fade-in-open');
		this.abrirModal();
		this.autenticacionPendValidar = null;
	}

	async modalValidarOtpCancelar() {
		const autenticacion = this.datatableData.datatableEnCurso.find(a => a.Id === this.autenticacionPendValidar.Id);
		if (await this.cancelarAutenticacion(autenticacion)) {
			//Se ha aceotado el Lightging Confirm
			this.cerrarModalValidarOtp(null, false);
		}
	}

	modalValidarOtpTeclaPulsada({keyCode}) {
		!this.componente.spinner && keyCode === 27 && this.cerrarModalValidarOtp(); //Tecla ESC
	}

	async modalValidarOtpValidar() {
		//Obtener el código OTP a partir de los dígitos de cada input
		const inputsOtp = Array.from(this.template.querySelectorAll('input.inputOtp'));
		const {ok: inputsOtpInformados, valor: codigo} = inputsOtp.reduce(({ok, valor}, inputOtp) => ({
			ok: ok && Boolean(inputOtp.value),
			valor: valor + (inputOtp.value || ''),
			...inputOtp.classList.toggle('csbd-has-error', !inputOtp.value) && {}
		}), {ok: true, valor: ''});

		if (!inputsOtpInformados) {
			this.refs.inputOtp1.focus();
		} else {
			//this.componente.spinner = true;
			//await this.cerrarModalValidarOtp(null, false);
			this.modalMensajeAbrir('Consultando validez del código indicado...', 'utility:sms', null, true);


			this.n2ValidarOtp({recordId: this.recordId, idAutenticacion: this.autenticacionPendValidar.Id, codigo})
			.then(resultadoOk => {
				this.modalMensajeCerrar();
				window.setTimeout(() => {
					if (resultadoOk) {
						this.modalMensajeAbrir(
							'Código correcto.', 'utility:success', 'modalMensajeIconSuccess',
							false, 2300, () => this.cerrarModalValidarOtp(null, false)
						);
					} else {
						this.autenticacionPendValidar = null;
						this.modalMensajeAbrir(
							'Código incorrecto.', 'utility:error', 'modalMensajeIconError',
							false, 2300, () => this.abrirModalNuevoIntento()
						);
					}
				}, 180);
			}).catch(error => errorApex(this, error, 'Problema validando el código'));
		}
	}

	inputOtpOnfocus({currentTarget}) {
		currentTarget.select();
	}

	inputOtpOnkeydown(event) {
		const key = event.key;

		if (key === 'Backspace' && !event.currentTarget.value) {
			//Backspace mueve el foco al input anterior
			event.preventDefault();
			const anterior = +event.currentTarget.dataset.posicion - 1;
			if (anterior) {
				const inputAnterior = this.refs[`inputOtp${anterior}`];
				inputAnterior.value = '';
				inputAnterior.focus();
			}
		} else if (key === 'Escape') {
			//Escape borra todos el valor de todos los inputs si lo hay
			const inputsOtp = Array.from(this.template.querySelectorAll('input.inputOtp'));
			if (inputsOtp.some(i => i.value)) {
				event.stopPropagation();
				inputsOtp.forEach(i => {
					i.value = null;
					i.classList.remove('csbd-has-error');
				});
				this.refs.inputOtp1.focus();
			}
		} else if (!event.metaKey && !event.ctrlKey && !event.altKey && !event.shiftKey
		&& key !== 'Enter' && key !== 'Escape' && key !== 'Tab'
		&& !/^F[1-9]|F1[0-2]$/.test(key)
		&& (key.length === 1 && (key < '0' || key > '9') || key === ' ')) {
			//Solo dígitos
			event.preventDefault();
		}
	}

	inputOtpOninput({currentTarget}) {
		//Mover el foco al input siguiente
		if (currentTarget.value) {
			currentTarget.classList.remove('csbd-has-error');
			const siguiente = +currentTarget.dataset.posicion + 1;
			if (siguiente === 7) {
				this.refs.modalValidarOtpValidar.focus();
			} else {
				this.refs[`inputOtp${siguiente}`]?.focus();
			}
		}
	}

	modalValidarOtpNoRecibido() {
		this.componente.spinner = true;
		codigoAutenticacionNoRecibidoApex({
			idOportunidad: this.recordId,
			idAutenticacion: this.autenticacionPendValidar.Id,
			nivel: this.nivel
		}).then(() => this.cerrarModalValidarOtp(null, false))
		.catch(error => errorApex(this, error, 'Problema actualizando la oportunidad'))
		.finally(() => this.componente.spinner = false);
	}

	async abrirModalValidarPush() {
		await this.cerrarModal(false);
		const modalesAbiertos = this.template.querySelectorAll('section.slds-modal.slds-fade-in-open:not(.modalAutenticacionOtp)');
		modalesAbiertos.forEach(m => m.classList.remove('slds-fade-in-open'));

		this.refs.modalValidarPush.classList.add('slds-fade-in-open');
		window.setTimeout(() => this.refs.modalValidarPushValidar.focus(), 90);
	}

	async cerrarModalValidarPush() {
		this.refs.modalValidarPush.classList.remove('slds-fade-in-open');
		await this.abrirModal();
		this.autenticacionPendValidar = null;
	}

	modalValidarPushTeclaPulsada({keyCode}) {
		!this.componente.spinner && keyCode === 27 && this.modalValidarPushCancelar(); //Tecla ESC
	}

	async modalValidarPushCancelar() {
		const autenticacion = this.datatableData.datatableEnCurso.find(a => a.Id === this.autenticacionPendValidar.Id);
		if (await this.cancelarAutenticacion(autenticacion)) {
			//Se ha aceotado el Lightging Confirm
			this.cerrarModalValidarPush();
		}
	}

	async modalValidarPushValidar() {
		this.componente.spinner = true;
		try {
			let resultado = await autenticacionClienteDigitalValidarApex({
				recordId: this.recordId,
				autenticacionId: this.autenticacionPendValidar.Id
			});
			if (resultado === 'La autorización está pendiente (pendiente cliente)' || resultado === 'La autorización está en progreso (pendiente cliente)') {
				toast('warning', 'La autenticación está en progreso', 'La autenticación está en progreso');
			} else if (resultado === 'OK') {
				toast('success', 'Validado', 'Se ha validado correctamente');
				this.cerrarModalValidarPush();
			} else if (resultado === 'La autorización ha sido aprobada por el cliente' || resultado === 'La autorización ha finalizado correctamente') {
				toast('success', 'Autorización aprobada', resultado);
				this.cerrarModalValidarPush();
			} else {
				errorApex(this, resultado, 'Se he producido un error en la validación');
			}
		} catch (error) {
			errorApex(this, error, 'Se he producido un error en la validación');
		} finally {
			this.componente.spinner = false;
		}
	}

	modalValidarPushNoRecibido() {
		this.componente.spinner = true;
		codigoAutenticacionNoRecibidoApex({
			idOportunidad: this.recordId,
			idAutenticacion: this.autenticacionPendValidar.Id,
			nivel: this.nivel
		}).then(() => this.cerrarModalValidarPush())
		.catch(error => errorApex(this, error, 'Problema actualizando la oportunidad'))
		.finally(() => this.componente.spinner = false);
	}

	async abrirModalNuevoIntento() {
		await this.cerrarModal(false);
		const modalesAbiertos = this.template.querySelectorAll('section.slds-modal.slds-fade-in-open:not(.modalAutenticacionOtp)');
		modalesAbiertos.forEach(m => m.classList.remove('slds-fade-in-open'));
		this.refs.modalNuevoIntento.classList.add('slds-fade-in-open');
		//focus
	}

	cerrarModalNuevoIntento() {
		this.refs.modalNuevoIntento.classList.remove('slds-fade-in-open');
		this.abrirModal();
	}

	modalNuevoIntentoTeclaPulsada({keyCode}) {
		!this.componente.spinner && keyCode === 27 && this.cerrarModalNuevoIntento(); //Tecla ESC
	}

	botonRefrescarOnclick(event) {
		this.actualizarTablasAutenticaciones();
		const botonActualizar = event.currentTarget;
		this.componente.funcionesBind.botonActualizarOnanimationend = this.botonActualizarOnanimationend.bind(this, botonActualizar);
		botonActualizar.addEventListener('animationend', this.componente.funcionesBind.botonActualizarOnanimationend);
		botonActualizar.classList.add('rotar');
	}

	botonActualizarOnanimationend(botonActualizar) {
		botonActualizar.removeEventListener('animationend', this.componente.funcionesBind.botonActualizarOnanimationend);
		botonActualizar.classList.remove('rotar');
	}

	/*
	clienteMenorSinRepresentante() {
		return getFieldValue(this.oportunidad, OPP_ACCOUNT_EDAD)
		&& getFieldValue(this.oportunidad, OPP_ACCOUNT_EDAD) < 18
		&& !getFieldValue(this.oportunidad, OPP_ACCOUNT_MENOR_EMANCIPADO)
		&& !getFieldValue(this.oportunidad, OPP_CASO_ORIGEN_REPRESENTANTE);
	}
	*/

	async n2EnviarOtp() {
		this.componente.spinner = false;
		if (!this.autenticacionPendValidar) {
			console.error('No es posible determinar el registro de la autenticación en curso');
			toast('error', 'Problema solicitando el envío del código OTP', 'No es posible determinar el registro de la autenticación en curso');
			return false;
		}
		this.modalMensajeAbrir('Solicitando envío del código de un solo uso al cliente...', 'utility:sms', null, true);
		return nivel2EnviarSolicitudOtpApex({idAutenticacion: this.autenticacionPendValidar.Id})
		.then(({CC_Estado__c: estadoAutenticacion, CC_Codigo_Error__c: codigoError, CC_Mensaje_Error__c: mensajeError}) => {
			if (this.componente.simularRespuestas.enviarOtp === 'ok') {
				this.autenticacionPendValidar = {'Id': '00Q000000000000', 'CC_Estado__c': 'OK'};
				this.abrirModalValidarOtp();

			} else if (estadoAutenticacion !== 'Error') {
				this.abrirModalValidarOtp();

			} else {
				const retornoError = codigoError + ': ' + mensajeError;
				console.error(retornoError);
				toast('error', 'Se ha recibido un error al solicitar el envío del código OTP', retornoError);
				this.modalMensajeCerrar(() => this.abrirModal());
			}
		}).catch(error => {
			errorApex(this, error, 'Problema solicitando el envío del código OTP');
			this.modalMensajeCerrar(() => this.abrirModal());
		});
	}

	inputPreguntaOnkeypress(event) {
		event.key === 'Enter' && this.modalPreguntasNivel2Validar();
	}

	modalMensajeAbrir(mensaje, iconName, iconClass, spinner, tiempoCierre, callback) {
		//Cerrar modales abiertos
		const modalesAbiertos = this.template.querySelectorAll('section.slds-modal.slds-fade-in-open:not(.modalAMensaje)');
		modalesAbiertos.forEach(m => m.classList.remove('slds-fade-in-open'));

		//Abrir modal de mensaje informativo
		this.modalMensaje = {mensaje, iconName, iconClass: iconClass || 'iconoAzul', spinner};
		const modalMensaje = this.refs.modalMensaje;
		this.refs.backdropModal.classList.add('slds-backdrop_open');
		modalMensaje.classList.add('slds-fade-in-open');

		if (tiempoCierre) {
			window.setTimeout(() => {
				this.modalMensajeCerrar();
				typeof callback === 'function' && window.setTimeout(callback, 100);
			}, tiempoCierre);
		} else {
			typeof callback === 'function' && callback();
		}
	}

	modalMensajeCerrar(callback) {
		this.refs.modalMensaje.classList.remove('slds-fade-in-open');
		typeof callback === 'function' && window.setTimeout(callback, 200);
	}

	/*
	async notificarOk(mensaje, callback) {
		this.modalMensaje = {mensaje, iconName: 'utility:sms', spinner: true};
		const modalesAbiertos = this.template.querySelectorAll('section.slds-modal.slds-fade-in-open:not(.modalAutenticacionOtp)');
		modalesAbiertos.forEach(m => m.classList.remove('slds-fade-in-open'));
		const modalMensaje = this.refs.modalMensaje;
		modalMensaje.classList.add('slds-fade-in-open');
		window.setTimeout(() => {
			modalMensaje.classList.remove('slds-fade-in-open');
			typeof callback === 'function' && callback();
		}, 1300);
	}

	async notificarKo(mensaje, callback, cerrarAuto = true) {
		this.modalMensaje.mensaje = mensaje;
		const modalesAbiertos = this.template.querySelectorAll('section.slds-modal.slds-fade-in-open:not(.modalAutenticacionOtp)');
		modalesAbiertos.forEach(m => m.classList.remove('slds-fade-in-open'));
		const modalMensaje = this.refs.modalMensaje;
		modalMensaje.classList.add('slds-fade-in-open');
		window.setTimeout(() => {
			cerrarAuto && this.notificarKoCerrar();
			typeof callback === 'function' && callback();
		}, 1300);
	}
	*/

	navegarDetalleCliente() {
		this[NavigationMixin.Navigate]({type: 'standard__recordPage', attributes: {
			recordId: getFieldValue(this.oportunidad, OPP_ACCOUNT_ID), actionName: 'view'
		}});
	}

	async menuDevOnselect({detail: {value: accion}}) { //Menú de desarrollo

		if (accion.startsWith('simular.')) {
			let [, tipo, valorNuevo] = accion.split('.');
			valorNuevo = this.componente.simularRespuestas[tipo] === valorNuevo ? null : valorNuevo;
			this.componente.simularRespuestas[tipo] = valorNuevo;
			this.refs[`simular.${tipo}.ok`].iconName = valorNuevo === 'ok' ? 'utility:check' : '';
			this.refs[`simular.${tipo}.ko`].iconName = valorNuevo === 'ko' ? 'utility:check' : '';

		} else if (accion === 'debugger') {
			//debugger;

		} else if (accion === 'eliminarAutenticacionesCliente' && await LightningConfirm.open({
			variant: 'header', theme: 'warning', label: 'Eliminar autenticaciones del cliente',
			message: `¿Quieres eliminar todas las autenticaciones del cliente ${getFieldValue(this.oportunidad, OPP_ACCOUNT_NAME).toUpperCase()}?`
		})) {
			this.eliminarAutenticacionesCliente();

		} else if (accion === 'mostrarNombreAutenticaciones') {
			this.mostrarOcultarColumnaNombreAutenticaciones();

		} else if (accion === 'aux') {
			//eslint-disable-next-line no-console
			console.log('aux');
			const aux = () => this.abrirModal();
			this.modalMensajeAbrir('Consultando validez del código indicado...', 'utility:sms', null, true, 2000, aux);
		}
	}

	mostrarOcultarColumnaNombreAutenticaciones() {
		const mostrarOcultarColumnaNombreAut = columnas => {
			const indexColumnaNombreAut = columnas.findIndex(c => c.fieldName === '_autenticacionUrl');
			if (indexColumnaNombreAut === -1) {
				//Añadir columna de nombre de la autenticación después de la fecha de creación
				columnas.splice(2, 0, NAME_COLUMN);
			} else {
				//Quitar columna de nombre de la autenticación
				columnas.splice(indexColumnaNombreAut, 1);
			}
		};

		mostrarOcultarColumnaNombreAut(this.datatableColumns.datatableEnCurso);
		mostrarOcultarColumnaNombreAut(this.datatableColumns.datatableHistorico);
		this.datatableColumns.datatableEnCurso = [...this.datatableColumns.datatableEnCurso];
		this.datatableColumns.datatableHistorico = [...this.datatableColumns.datatableHistorico];
		this.datatableColumns = {...this.datatableColumns};
	}

	async n2ValidarOtp(inputs) {
		if (this.componente.simularRespuestas.validarOtp === 'ok') {
			return n2ValidarOtpMockOk(inputs);
		} else if (this.componente.simularRespuestas.validarOtp === 'ko') {
			return n2ValidarOtpMockKo(inputs);
		}
		return n2ValidarOtpApex(inputs);

	}

	eliminarAutenticacionesCliente() {
		this.componente.spinner = true;
		eliminarAutenticacionesClienteApex({idAccount: getFieldValue(this.oportunidad, OPP_ACCOUNT_ID)})
		.then(async () => {
			toast('success', 'Autenticaciones del cliente eliminadas');
			await this.actualizarTablasAutenticaciones();
		}).finally(() => this.componente.spinner = false);
	}
}