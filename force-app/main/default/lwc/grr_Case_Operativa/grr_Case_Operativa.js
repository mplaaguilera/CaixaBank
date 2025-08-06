import {LightningElement, api, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {getRecord, updateRecord, getFieldValue} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {loadStyle} from 'lightning/platformResourceLoader';
import currentUserId from '@salesforce/user/Id';

//CSS
import CUSTOM_CSS from '@salesforce/resourceUrl/GRR_Case_Gestion_Css';

//Campos
import CASE_ID from '@salesforce/schema/Case.Id';
import CASE_OWNER_ID from '@salesforce/schema/Case.OwnerId';
import CASE_STATUS from '@salesforce/schema/Case.Status';
import CASE_IDIOMA from '@salesforce/schema/Case.CC_Idioma__c';
import CASE_UR from '@salesforce/schema/Case.GRR_UR_Relacionada__c';
import CASE_UR_NAME from '@salesforce/schema/Case.GRR_UR_Relacionada__r.GRR_Id_UR__c';

//Métodos Apex
import validarCamposCaso from '@salesforce/apex/GRR_Case_Operativa.validarCamposCaso';
import buscarGruposColaboradores from '@salesforce/apex/GRR_Case_Operativa.buscarGruposColaboradores';
import getPlantillasGRR from '@salesforce/apex/GRR_Case_Operativa.getPlantillasGRR';
import prepararCaso from '@salesforce/apex/GRR_Case_Operativa.prepararCaso';
import destinatariosColaborador from '@salesforce/apex/GRR_Case_Operativa.destinatariosColaborador';
import mergeCase from '@salesforce/apex/GRR_Case_Operativa.mergeCase';
import getCarpetas from '@salesforce/apex/GRR_Case_Operativa.getCarpetas';
import getPlantillasResponder from '@salesforce/apex/GRR_Case_Operativa.getPlantillasResponder';
import buscarCorreoContacto from '@salesforce/apex/GRR_Case_Operativa.buscarCorreoContacto';
import getPlantillaGrupoList from '@salesforce/apex/GRR_Case_Operativa.getPlantillaGrupoList';
import getURCasoDestino from '@salesforce/apex/GRR_Case_Operativa.getURCasoDestino';
import crearTarea from '@salesforce/apex/GRR_Case_Operativa.crearTareaGestionadoMes'; 
import perteneceServiciosCentrales from '@salesforce/apex/GRR_Case_Operativa.perteneceServiciosCentrales';
import reabrirTareaTrasladoColaborador from '@salesforce/apex/GRR_Case_Operativa.reabrirTareaTrasladoColaborador';
import getUserRoleName from '@salesforce/apex/GRR_CaseTriggerHelper.getUserRoleName';




//eslint-disable-next-line camelcase, new-cap
export default class grr_Case_Operativa extends NavigationMixin(LightningElement) {

	userRole;
    isRoleGestiones = false;

	@wire(getUserRoleName)
	wiredUserRole({ data }) {
			if (data) {
				this.userRole = data;
				this.isRoleGestiones = data === 'GRR Agente COPS';
			} 
		}


	@api recordId;

	casoCargado = false;

	caso;

	showOperativas = false;

	resultadosGrupos = [];

	resultadosGruposMostrar = false;

	idGrupoSeleccionado;

	verTodasLasPlantillas = false;

	plantillas = [];

	plantillasColaborador = [];

	plantillasFiltro = [];

	resultadosPlantillasMostrar = false;

	idPlantillaSeleccionada;

	generandoBorrador = false;

	guardandoAlerta = false;

	fusionandoCaso = false;

	showErrorFusion = false;

	msgErrorFusion;
	
	idiomaPlantilla = '';

	tipoOperativa;

	idioma;

	opcionesIdiomaFolder = [];

	opcionesTratamientoFolder = [];

	carpetaIdiomaSeleccionada = false;

	tratamientoPlantilla;

	opcionesPlantillaResponder;

	cerrarCasoResponder = false;

	optionsUR = [];

	URCasoOrigen = '';

	URCasoDestino = '';

	perteneceServiciosCentrales = false;

	connectedCallback() {
        this.verificarUsuarioServiciosCentrales();
    }

	get resultadosGruposSinDatos() {
		return this.resultadosGrupos.length === 0;
	}

	get resultadosPlantillasSinDatos() {
		return this.plantillasFiltro.length === 0;
	}

	get operativaAlertaDisabled() {
		return !this.esPropietario || getFieldValue(this.caso, CASE_STATUS) === 'Cerrado' || getFieldValue(this.caso, CASE_STATUS) === 'Rechazado';
	}

	get operativasDisabled() {
		return !this.esPropietario || getFieldValue(this.caso, CASE_STATUS) !== 'Activo';
	}

	get botonGenerarBorradorDisabled() {
		return !this.idGrupoSeleccionado || !this.idPlantillaSeleccionada;
	}

	get botonGenerarBorradorResponderDisabled() {
		return !this.idPlantillaSeleccionada;
	}

	get botonFusionarDisabled() {
		let inputCasoRelacionado = this.template.querySelector('[data-id="casoRelacionado"]');
		return this.fusionandoCaso || inputCasoRelacionado && !inputCasoRelacionado.value;
	}

	get esPropietario() {
		return currentUserId === getFieldValue(this.caso, CASE_OWNER_ID);
	}

	@wire(getRecord, {recordId: '$recordId', fields: [CASE_OWNER_ID, CASE_STATUS, CASE_IDIOMA, CASE_UR, CASE_UR_NAME]})
	wiredRecord({error, data}) {
		if (error) {
			let mensajeError;
			if (Array.isArray(error.body)) {
				mensajeError = error.body.map(e => e.message).join(', ');
			} else if (typeof error.body.message === 'string') {
				mensajeError = error.body.message;
			}
			this.mostrarToast('error', 'Problema recuperando los datos del caso', mensajeError);
		} else if (data) {
			this.caso = data;
			this.casoCargado = true;
			let URId = getFieldValue(this.caso, CASE_UR);
			let URNombre = getFieldValue(this.caso, CASE_UR_NAME);
			if (URId && this.optionsUR.length === 0) {
				this.optionsUR = [...this.optionsUR];
				this.optionsUR.push({value: URId, label: URNombre});
			}
		}
	}

	verificarUsuarioServiciosCentrales(){
		perteneceServiciosCentrales()
		.then(result => {
			this.perteneceServiciosCentrales = result;
		})
		.catch(error => {
			console.error(JSON.stringify(error));
			let mensajeError;
			if (Array.isArray(error.body)) {
				mensajeError = error.body.map(e => e.message).join(', ');
			} else if (typeof error.body.message === 'string') {
				mensajeError = error.body.message;
			}
			this.mostrarToast('error', 'Problema recuperando el tipo de usuario', mensajeError);
		});
	}

	renderedCallback() {
		//Hoja de estilos para habilitar toasts con varias líneas de texto
		if (!this.cssCargado) {
			loadStyle(this, CUSTOM_CSS).then(() => this.cssCargado = true);
		}

		if (this.funcionAbrirModal) {
			this.funcionAbrirModal.call(this);
			this.funcionAbrirModal = null;
		}
	}

	mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({
			variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000
		}));
	}

	mostrarToastRecargar(tipo, titulo, mensaje) {
        const eventoToast = new ShowToastEvent({
            title: titulo,
            message: mensaje,
            variant: tipo
        });
        this.dispatchEvent(eventoToast);

        setTimeout(() => {
            location.reload();
        }, 2000);
    }

	modalTrasladarAbrir() {
		this.tipoOperativa = 'Trasladar';
		if (this.plantillas.length === 0) {
			getPlantillasGRR()
				.then(response => {
					let plantillas = [];
					response.forEach(plantilla => plantillas.push({value: plantilla.Id, label: plantilla.Name}));
					this.plantillas = plantillas;
				}).catch(error => {
					console.error(error);
					this.mostrarToast('error', 'problema recuperando plantillas', JSON.stringify(error));
				});
		}
		if (this.showOperativas) {
			this.modalTrasladarInicializar();
		} else {
			this.funcionAbrirModal = this.modalTrasladarInicializar;
			this.showOperativas = true;
		}
	}

	modalTrasladarInicializar() {
		this.validarCampos()
			.then(ok => {
				if (ok) {
					this.idGrupoSeleccionado = null;
					this.template.querySelector('.inputBuscarGruposTrasladar').value = null;
					this.verTodasLasPlantillas = false;
					this.template.querySelector('.toggleVerTodasLasPlantillasTrasladar').checked = false;
					this.idPlantillaSeleccionada = null;
					this.template.querySelector('.comboboxPlantillasTrasladar').value = null;
					this.template.querySelector('.modalTrasladar').classList.add('slds-fade-in-open');
					this.template.querySelector('.backdropModales').classList.add('slds-backdrop_open');
					this.template.querySelector('.modalTrasladarCancelar').focus();
				}
			});
	}

	modalRecuperarTrasladoAbrir() {
		if (this.showOperativas) {
			this.modalRecuperarTrasladoInicializar();
		} else {
			this.funcionAbrirModal = this.modalRecuperarTrasladoInicializar;
			this.showOperativas = true;
		}
	}

	modalRecuperarTrasladoInicializar() {
		this.validarCampos()
			.then(ok => {
				if (ok) {
					this.template.querySelector('.modalRecuperar').classList.add('slds-fade-in-open');
					this.template.querySelector('.backdropModales').classList.add('slds-backdrop_open');
					this.template.querySelector('.modalRecuperarCancelar').focus();
				}
			});
	}

	modalRemitirAbrir() {
		this.tipoOperativa = 'Remitir';
		if (this.plantillas.length === 0) {
			getPlantillasGRR()
				.then(response => {
					let plantillas = [];
					response.forEach(plantilla => plantillas.push({value: plantilla.Id, label: plantilla.Name}));
					this.plantillas = plantillas;
				}).catch(error => {
					console.error(error);
					this.mostrarToast('error', 'Problema recuperando plantillas', JSON.stringify(error));
				});
		}
		if (this.showOperativas) {
			this.modalRemitirInicializar();
		} else {
			this.funcionAbrirModal = this.modalRemitirInicializar;
			this.showOperativas = true;
		}
	}

	modalRemitirInicializar() {
		this.validarCampos()
			.then(ok => {
				if (ok) {
					this.idGrupoSeleccionado = null;
					this.template.querySelector('.inputBuscarGruposRemitir').value = null;
					this.verTodasLasPlantillas = false;
					this.template.querySelector('.toggleVerTodasLasPlantillasRemitir').checked = false;
					this.idPlantillaSeleccionada = null;
					this.template.querySelector('.comboboxPlantillasRemitir').value = null;
					this.template.querySelector('.modalRemitir').classList.add('slds-fade-in-open');
					this.template.querySelector('.backdropModales').classList.add('slds-backdrop_open');
					this.template.querySelector('.modalRemitirCancelar').focus();
				}
			});
	}

	modalResponderAbrir() {
		this.tipoOperativa = 'Responder';
		this.idioma = getFieldValue(this.caso, CASE_IDIOMA);
		
		if (this.plantillas.length === 0) {
			getPlantillasGRR()
				.then(response => {
					let plantillas = [];
					response.forEach(plantilla => plantillas.push({value: plantilla.Id, label: plantilla.Name}));
					this.plantillas = plantillas;
				}).catch(error => {
					console.error(error);
					this.mostrarToast('error', 'Problema recuperando plantillas', JSON.stringify(error));
				});
		}
		if (this.opcionesIdiomaFolder.length === 0) {
			this.loadCarpetasIdioma();
		}
		if (this.showOperativas) {
			this.modalResponderInicializar();
		} else {
			this.funcionAbrirModal = this.modalResponderInicializar;
			this.showOperativas = true;
		}
	}

	modalResponderInicializar() {
		this.validarCampos()
			.then(ok => {
				if (ok) {
					this.verTodasLasPlantillas = false;
					this.cerrarCasoResponder = false;
					this.template.querySelector('.toggleVerTodasLasPlantillasResponder').checked = false;
					this.idPlantillaSeleccionada = null;
					this.idiomaPlantilla = '';
					this.template.querySelector('.comboboxPlantillasResponder').value = null;
					this.template.querySelector('.modalResponder').classList.add('slds-fade-in-open');
					this.template.querySelector('.backdropModales').classList.add('slds-backdrop_open');
					this.template.querySelector('.modalResponderCancelar').focus();
				}
			});
	}

	modalSolicitarAbrir() {
		this.tipoOperativa = 'Solicitar';
		this.idioma = getFieldValue(this.caso, CASE_IDIOMA);
		if (this.plantillas.length === 0) {
			getPlantillasGRR()
				.then(response => {
					let plantillas = [];
					response.forEach(plantilla => plantillas.push({value: plantilla.Id, label: plantilla.Name}));
					this.plantillas = plantillas;
				}).catch(error => {
					console.error(error);
					this.mostrarToast('error', 'Problema recuperando plantillas', JSON.stringify(error));
				});
		}
		if (this.opcionesIdiomaFolder.length === 0) {
			this.loadCarpetasIdioma();
		}
		if (this.showOperativas) {
			this.modalSolicitarInicializar();
		} else {
			this.funcionAbrirModal = this.modalSolicitarInicializar;
			this.showOperativas = true;
		}
	}

	modalSolicitarInicializar() {
		this.validarCampos()
			.then(ok => {
				if (ok) {
					this.verTodasLasPlantillas = false;
					this.cerrarCasoResponder = false;
					this.template.querySelector('.toggleVerTodasLasPlantillasSolicitar').checked = false;
					this.idPlantillaSeleccionada = null;
					this.idiomaPlantilla = '';
					this.template.querySelector('.comboboxPlantillasSolicitar').value = null;
					this.template.querySelector('.modalSolicitar').classList.add('slds-fade-in-open');
					this.template.querySelector('.backdropModales').classList.add('slds-backdrop_open');
					this.template.querySelector('.modalSolicitarCancelar').focus();
				}
			});
	}

	validarCampos() {
		return new Promise(resolve => {
			validarCamposCaso({recordId: this.recordId})
				.then(response => {
					if (response.length > 0) {
						let mensajeError = 'Los siguientes campos son requeridos para iniciar la operativa:';
						response.forEach(mensaje => mensajeError += '\n · ' + mensaje);
						this.mostrarToast('info', 'Campos requeridos', mensajeError);
						resolve(false);
					} else {
						resolve(true);
					}
				})
				.catch(error => {
					console.error(JSON.stringify(error));
					this.mostrarToast('error', 'Problema iniciando la operativa', JSON.stringify(error));
				});
		});
	}

	toggleVerTodasLasPlantillasOnChange(event) {
		this.verTodasLasPlantillas = event.target.checked;
		this.idPlantillaSeleccionada = null;
	}

	toggleCerrarCasoResponderOnChange(event) {
		this.cerrarCasoResponder = event.target.checked;
	}

	inputBuscarGruposOnChange(event) {
		window.clearTimeout(this.idTimeoutBuscarGrupos);
		this.idGrupoSeleccionado = null;

		let cadenaBusqueda;
		if (event.currentTarget.dataset.operativa === 'Trasladar') {
			cadenaBusqueda = this.template.querySelector('.inputBuscarGruposTrasladar').value;
		} else {
			cadenaBusqueda = this.template.querySelector('.inputBuscarGruposRemitir').value;
		}
		if (cadenaBusqueda) {
			this.idTimeoutBuscarGrupos = window.setTimeout(() => {
				buscarGruposColaboradores({cadenaBusqueda: cadenaBusqueda})
					.then(response => {
						this.resultadosGrupos = response;
						this.resultadosGruposMostrar = true;
					}).catch(error => {
						console.error(JSON.stringify(error));
						this.mostrarToast('error', 'Problema recuperando resultados', JSON.stringify(error));
					});
			}, 400);
		} else {
			this.resultadosGruposMostrar = false;
			this.resultadosGrupos = [];
		}
	}

	seleccionarGrupoColaborador(event) {
		let operativa = this.tipoOperativa;
		if (event.currentTarget.dataset.operativa === 'Trasladar') {
			this.template.querySelector('.inputBuscarGruposTrasladar').value = event.currentTarget.dataset.name;
		} else {
			this.template.querySelector('.inputBuscarGruposRemitir').value = event.currentTarget.dataset.name;
		}
		this.idGrupoSeleccionado = {
			id: event.currentTarget.dataset.id,
			name: event.currentTarget.dataset.name
		};
		this.resultadosGruposMostrar = false;

		this.obtenerPlantillasGrupo(event);
	}

	handlePlantillaSeleccionada(event) {
		let comboboxPlantillas;
		if (event.currentTarget.dataset.operativa === 'Trasladar') {
			comboboxPlantillas = this.template.querySelector('.comboboxPlantillasTrasladar');
		} else if (event.currentTarget.dataset.operativa === 'Remitir') {
			comboboxPlantillas = this.template.querySelector('.comboboxPlantillasRemitir');
		} else if (event.currentTarget.dataset.operativa === 'Responder'){
			comboboxPlantillas = this.template.querySelector('.comboboxPlantillasResponder');
		} else {
			comboboxPlantillas = this.template.querySelector('.comboboxPlantillasSolicitar');
		}
		
		this.idPlantillaSeleccionada = comboboxPlantillas.value;
	}

	inputBuscarPlantillasOnChange(event) {
		this.idPlantillaSeleccionada = null;
		let cadenaBusqueda;
		if (event.currentTarget.dataset.operativa === 'Trasladar') {
			cadenaBusqueda = this.template.querySelector('.inputBuscarPlantillasTrasladar').value;
		} else if(event.currentTarget.dataset.operativa === 'Remitir') {
			cadenaBusqueda = this.template.querySelector('.inputBuscarPlantillasRemitir').value;
		} else if(event.currentTarget.dataset.operativa === 'Responder') {
			cadenaBusqueda = this.template.querySelector('.inputBuscarPlantillasResponder').value;
		} else {
			cadenaBusqueda = this.template.querySelector('.inputBuscarPlantillasSolicitar').value;
		}
		if (cadenaBusqueda) {
			this.resultadosPlantillasMostrar = true;
			this.plantillasFiltro = this.plantillas.filter(plantilla => plantilla.label.toLowerCase().includes(cadenaBusqueda.toLowerCase()));
		} else {
			this.resultadosPlantillasMostrar = false;
		}
	}

	inputOnKeyDown(event) {
		//Al pulsar la tecla ESC con foco en un input, solo se cierra el modal si no tiene valor
		if (event.currentTarget.value) {
			event.stopPropagation();
		}
	}

	seleccionarPlantilla(event) {
		if (event.currentTarget.dataset.operativa === 'Trasladar') {
			this.template.querySelector('.inputBuscarPlantillasTrasladar').value = event.currentTarget.dataset.name;
		} else if(event.currentTarget.dataset.operativa === 'Remitir') {
			this.template.querySelector('.inputBuscarPlantillasRemitir').value = event.currentTarget.dataset.name;
		} else if(event.currentTarget.dataset.operativa === 'Responder') {
			this.template.querySelector('.inputBuscarPlantillasResponder').value = event.currentTarget.dataset.name;
		} else {
			this.template.querySelector('.inputBuscarPlantillasSolicitar').value = event.currentTarget.dataset.name;
		}
		this.idPlantillaSeleccionada = event.currentTarget.dataset.id;
		this.resultadosPlantillasMostrar = false;
	}

	inputBuscarGruposTrasladarOnFocus() {
		this.resultadosGruposMostrar = this.template.querySelector('.inputBuscarGruposTrasladar').value;
	}

	inputBuscarGruposTrasladarOnBlur() {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => this.resultadosGruposMostrar = false, 200);
	}

	inputBuscarPlantillasTrasladarOnFocus() {
		this.resultadosPlantillasMostrar = this.template.querySelector('.inputBuscarPlantillasTrasladar').value;
	}

	inputBuscarPlantillasTrasladarOnBlur() {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => this.resultadosPlantillasMostrar = false, 200);
	}

	inputBuscarPlantillasRemitirOnFocus() {
		this.resultadosPlantillasMostrar = this.template.querySelector('.inputBuscarPlantillasRemitir').value;
	}

	inputBuscarPlantillasRemitirOnBlur() {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => this.resultadosPlantillasMostrar = false, 200);
	}

	inputBuscarPlantillasResponderOnFocus() {
		this.resultadosPlantillasMostrar = this.template.querySelector('.inputBuscarPlantillasResponder').value;
	}

	inputBuscarPlantillasResponderOnBlur() {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => this.resultadosPlantillasMostrar = false, 200);
	}

	inputBuscarPlantillasSolicitarOnFocus() {
		this.resultadosPlantillasMostrar = this.template.querySelector('.inputBuscarPlantillasSolicitar').value;
	}

	inputBuscarPlantillasSolicitarOnBlur() {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => this.resultadosPlantillasMostrar = false, 200);
	}

	trasladarColaborador() {
		this.template.querySelector('.modalTrasladarTrasladar').disabled = true;
		this.generarBorrador('Trasladar');
	}

	recuperarTrasladoColaborador() {
		this.template.querySelector('.modalRecuperarRecuperar').disabled = true;
		this.recuperarTareaTraslado();
	}

	remitirColaborador() {
		this.template.querySelector('.modalRemitirRemitir').disabled = true;
		this.generarBorrador('Remitir');
	}

	responderCliente() {
		this.template.querySelector('.modalResponderResponder').disabled = true;
		this.generarBorradorResponderSolicitar('Responder');
	}

	solicitarInfoCliente() {
		this.template.querySelector('.modalSolicitarSolicitar').disabled = true;
		this.generarBorradorResponderSolicitar('Solicitar');
	}

	generarBorrador(operativa) {
		prepararCaso({
			idCaso: this.recordId,
			idPlantilla: this.idPlantillaSeleccionada,
			informarReferenciaCorreo: true,
			operativa: operativa, 
			cierreOperativa: false
		})
			.then(() => {
				destinatariosColaborador({idGrupoColaborador: this.idGrupoSeleccionado.id})
					.then(datosDestinatarios => {
						let destinatariosPara = [];
						let destinatariosCc = [];
						if (datosDestinatarios) {
							for (let indice in datosDestinatarios) {
								if (datosDestinatarios[indice] === 'Para') {
									destinatariosPara.push(String(indice));
								} else if (datosDestinatarios[indice] === 'CC') {
									destinatariosCc.push(String(indice));
								}
							}
						}
						operativa = operativa === 'Trasladar' ? 'Traslado Colaborador' : 'Remitir Colaborador';
						this.sendEmail(operativa, destinatariosPara, destinatariosCc, this.idGrupoSeleccionado.name);
						this.closeModals();
					});
			})
			.catch(error => {
				console.error(error);
				this.mostrarToast('error', 'Problema generando el borrador de correo el caso', JSON.stringify(error));
			});
	}

	generarBorradorResponderSolicitar(operativa) {
		prepararCaso({
			idCaso: this.recordId,
			idPlantilla: this.idPlantillaSeleccionada,
			informarReferenciaCorreo: true,
			operativa: operativa, 
			cierreOperativa: this.cerrarCasoResponder
		})
			.then(() => {
				buscarCorreoContacto({idCaso: this.recordId})
					.then(result => {
						this.result = result;
						operativa = operativa === 'Responder' ? 'Responder a Cliente' : 'Solicitud Información';
						this.sendEmail(operativa, result,'','');
						this.closeModals();
					});
			})
			.catch(error => {
				console.error(error);
				this.mostrarToast('error', 'Problema generando el borrador de correo el caso', JSON.stringify(error));
			});
	}


	sendEmail(operativa, destinatariosPara, destinatariosCc, nombreGrupo) {
		this.dispatchEvent(new CustomEvent('rellenarmail', {
			detail: {
				operativa: operativa,
				para: destinatariosPara,
				cc: destinatariosCc,
				grupo: nombreGrupo
			}
		}));
	}

	recuperarTareaTraslado() {
		reabrirTareaTrasladoColaborador({
			idCaso: this.recordId
		})
			.then(() => {
				const fields = {};
				fields[CASE_ID.fieldApiName] = this.recordId;
				fields[CASE_STATUS.fieldApiName] = 'Pendiente Colaborador';
				updateRecord({fields})
					.then(() => {
						this.mostrarToast('success', 'Éxito', 'Se actualizó correctamente el estado del caso y se ha reabierto la última tarea de traslado a colaborador');
						this.closeModals();
					})
					.catch(error => {
						console.error(JSON.stringify(error));
						this.mostrarToast('error', 'Problema al actualizar el estado del caso', error.body.message);
						this.template.querySelector('.modalRecuperarRecuperar').disabled = false;
						this.closeModals();
					});
			})
			.catch(error => {
				console.error(JSON.stringify(error));
                this.mostrarToast('error', 'Error', error.body.message);
				this.template.querySelector('.modalRecuperarRecuperar').disabled = false;
				this.closeModals();
			});
	}

	closeModals() {
		this.generandoBorrador = false;
		this.verTodasLasPlantillas = false;
		this.cerrarCasoResponder = false;
 		this.idPlantillaSeleccionada = null;
		this.tipoOperativa = '';
		this.tratamientoPlantilla= null;
		this.opcionesPlantillaResponder = null;
		this.opcionesIdiomaFolder.splice(0, this.opcionesIdiomaFolder.length);
		this.carpetaIdiomaSeleccionada = false;
		
		this.template.querySelectorAll('.slds-modal').forEach(modal => modal.classList.remove('slds-fade-in-open'));
		this.template.querySelector('.backdropModales').classList.remove('slds-backdrop_open');
	}

	handleCarpetaIdiomaSeleccionada(event) {
		const idiomaPlantilla = event.detail.value;
		this.idiomaPlantilla = idiomaPlantilla;
		this.loadCarpetasTratamiento(event);
	}

	handleCarpetaTratamientoSeleccionada(event) {
		this.tratamientoPlantilla = event.target.value;
		this.getPlantillasResponder(event);
	}

	handleButtonPropiedad() {
		this.template.querySelector('[data-id="btnPropiedad"]').disabled = true;
		const fields = {};
		fields[CASE_ID.fieldApiName] = this.recordId;
		fields[CASE_OWNER_ID.fieldApiName] = currentUserId;
		updateRecord({fields})
			.then(() => {
				this.mostrarToast('success', 'Ahora es el propietario del caso', 'Se actualizó correctamente el propietario del caso')
			})
			.catch(error => {
				console.error(JSON.stringify(error));
				this.mostrarToast('error', 'Problema actualizando propietario del caso', error.body.message);
			})
			.finally(() => {
				let botonTomarPropiedad = this.template.querySelector('.botonTomarPropiedad');
				if (botonTomarPropiedad) {
					botonTomarPropiedad.disabled = false;
				}
			});
	}

	handleButtonFusionar() {
		if (this.showOperativas) {
			this.modalFusionarCaso();
		} else {
			this.funcionAbrirModal = this.modalFusionarCaso;
			this.showOperativas = true;
		}
	}

	modalTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.closeModals();
		}
	}

	modalFusionarCaso() {
		this.template.querySelector('.modalFusionar').classList.add('slds-fade-in-open');
		this.template.querySelector('.backdropModales').classList.add('slds-backdrop_open');
		this.template.querySelector('.modalFusionarCancelar').focus();
	}

	handleFusionarCaso() {
		this.idNuevoCaso = this.template.querySelector('[data-id="casoRelacionado"]').value;
		this.URCasoOrigen = getFieldValue(this.caso, CASE_UR);
		//this.URCasoDestino = this.template.querySelector('[data-id="casoRelacionado"]').CASE_UR;
		
		getURCasoDestino({idCasoDestino: this.idNuevoCaso})
			.then(result => {
				this.URCasoDestino = result;

				if (this.idNuevoCaso === this.recordId) {
					this.mostrarToast('error', 'Problema fusionando los casos', 'Los casos origen y destino de la fusión deben ser distintos');
				} else {
					if ((this.URCasoOrigen != null) && (this.URCasoDestino != null) && (this.URCasoOrigen != this.URCasoDestino)) {
						this.mostrarToast('error', 'Problema fusionando los casos', 'La UR de los casos origen y destino deben tener informada la misma UR');
					} else if ((this.URCasoOrigen != null) && (this.URCasoDestino == null)) {
						this.mostrarToast('error', 'Problema fusionando los casos', 'La UR debe estar informada en el caso destino, no en el caso origen');
					} else {
						this.fusionandoCaso = true;
						mergeCase({masterCaseId: this.recordId, idCasoSelected: this.idNuevoCaso})
						.then(result2 => {
							if (result2 != 'Ok'){
								this.mostrarToast('error', 'Problema fusionando los casos', result2);
							} else {
								this.mostrarToast('success', 'Se han fusionado los casos', 'Se han fusionado los casos correctamente');
								//Cerrar pestaña del caso origen y abrir nueva pestaña para el caso destino
								this.dispatchEvent(new CustomEvent('cerrarpestana', {detail: {
									idNuevoCaso: this.template.querySelector('[data-id="casoRelacionado"]').value
								}}));
							}
						}).catch(error => {
							console.error(error);
							this.mostrarToast('error', 'Problema fusionando los casos', error.body.message);
						}).finally(() => this.fusionandoCaso = false);
					}
				} 
			}).catch(error => {
				console.error(error);
				this.mostrarToast('error', 'Problema obteniendo UR', error.body.message);
			})

	}

	loadCarpetasIdioma() {
		let operativa = this.tipoOperativa;
		let idioma = this.idioma;
		let carpetaOperativa;
		let opcionesIdiomaFolder = [];

		if (operativa === 'Responder') {
			carpetaOperativa = 'GRR_Responder';
			idioma = 'GRR_Responder_' + idioma;
		} else if (operativa === 'Solicitar') {
			carpetaOperativa = 'GRR_Solicitar';
			idioma = 'GRR_Solicitar_' + idioma;
		}

		getCarpetas({carpetaDeveloperName: carpetaOperativa})
			.then(result5 => {
				result5.forEach(element => {
					opcionesIdiomaFolder.push({value: element.DeveloperName, label: element.Name});
				});
				this.opcionesIdiomaFolder = opcionesIdiomaFolder;	
				
				this.carpetaIdiomaSeleccionada = true;
				this.idiomaPlantilla = idioma;
				
				if (operativa === 'Responder') {
					this.template.querySelector('[data-id="comboboxIdiomaResponder"]').value = idioma;
				}  
				if (operativa === 'Solicitar') {
					this.template.querySelector('[data-id="comboboxIdiomaSolicitar"]').value = idioma;
				}

				this.loadCarpetasTratamiento();
			})
			.catch(error => {
				console.error(error);
				this.mostrarToast('error', 'Problema obteniendo las carpetas', error.body.message);
			});
	}

	loadCarpetasTratamiento() {
		let opcionesTratamientoFolder = [];
		let idioma = this.idiomaPlantilla;

		getCarpetas({carpetaDeveloperName: idioma})
			.then(result => {
				result.forEach(element => {
					opcionesTratamientoFolder.push({value: element.DeveloperName, label: element.Name});
				});
				this.opcionesTratamientoFolder = opcionesTratamientoFolder;
			})
			.catch(error => {
				console.error(error);
			});

		if (this.opcionesTratamientoFolder.length === 0) {
			this.idiomaPlantilla = idioma;
		} else {
			this.carpetaIdiomaSeleccionada = true;
		}
	}

	getPlantillasResponder() {
		getPlantillasResponder({recordId: this.recordId, carpeta: this.tratamientoPlantilla})
		.then(result => this.opcionesPlantillaResponder = result);
	}

	obtenerPlantillasGrupo() {
		//Aqui buscamos las plantillas de los grupos seleccionados
		getPlantillaGrupoList({grupoId: this.idGrupoSeleccionado.id, tipoOperativa: this.tipoOperativa})
			.then(result => {
				//this.optionsPlantilla = result;
				this.plantillasColaborador = result;
			}).catch(error => {
				console.error(JSON.stringify(error));
				this.mostrarToast('error', 'Problema recuperando resultados', JSON.stringify(error));
			});
	}

	handleCrearTarea() {
        crearTarea({ idCaso: this.recordId})
        .then(() => {
			this.mostrarToastRecargar('Success', 'Se ha creado la tarea', 'Se ha creado la tarea Gestionado en el mes correctamente');
		}).catch(error => {
			console.error(error);
			this.mostrarToast('error', 'Problema creando la tarea');
		})
    }

}