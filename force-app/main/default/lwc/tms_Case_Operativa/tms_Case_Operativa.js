import {LightningElement, api, wire, track} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {createRecord, getRecord, updateRecord, getFieldValue} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {loadStyle} from 'lightning/platformResourceLoader';
import currentUserId from '@salesforce/user/Id';

//CSS Aquí: ¿es necesario?
//import CUSTOM_CSS from '@salesforce/resourceUrl/TMS_Aura_case_Operativa';

//Campos
import CASE_ID from '@salesforce/schema/Case.Id';
import CASE_OWNER_ID from '@salesforce/schema/Case.OwnerId';
import CASE_STATUS from '@salesforce/schema/Case.Status';
import CASE_SERVICIO_PREMIUM from '@salesforce/schema/Case.TMS_Servicio_Premium__c';

//Métodos Apex
import validarCamposCaso from '@salesforce/apex/TMS_Case_Operativa.validarCamposCaso';
import getPlantillasTMS from '@salesforce/apex/TMS_Case_Operativa.getPlantillasTMS';
import prepararCaso from '@salesforce/apex/TMS_Case_Operativa.prepararCaso';
import destinatarios from '@salesforce/apex/TMS_Case_Operativa.destinatarios';

//eslint-disable-next-line camelcase, new-cap
export default class Tms_Case_Operativa extends NavigationMixin(LightningElement) {
	@api recordId;

    @track sevicioPremium;

	casoCargado = false;

	caso;

	showOperativas = false;

	resultadosGrupos = [];

	resultadosGruposMostrar = false;

	idGrupoSeleccionado;

	verTodasLasPlantillas = false;

	plantillas = [];

	plantillasFiltro = [];

	resultadosPlantillasMostrar = false;

	idPlantillaSeleccionada;

	generandoBorrador = false;

	fechaAlertaVisual;

	guardandoAlerta = false;

	fusionandoCaso = false;

	showErrorFusion = false;

	msgErrorFusion;

	get resultadosGruposSinDatos() {
		return this.resultadosGrupos.length === 0;
	}

	get resultadosPlantillasSinDatos() {
		return this.plantillasFiltro.length === 0;
	}

	get operativaEnviarDisabled() {
		return !this.esPropietario || getFieldValue(this.caso, CASE_STATUS) === 'Rechazo Informe' || getFieldValue(this.caso, CASE_STATUS) === 'Aceptación Informe';
	}

    get operativaPremiumDisabled() {
		return !this.esPropietario || getFieldValue(this.caso, CASE_STATUS) === 'Rechazo Informe' || getFieldValue(this.caso, CASE_STATUS) === 'Aceptación Informe';
	}

	get botonGenerarBorradorDisabled() {
		return !this.idPlantillaSeleccionada;
	}

	get esPropietario() {
		return currentUserId === getFieldValue(this.caso, CASE_OWNER_ID);
	}

	get servicioPremium() {
		return getFieldValue(this.caso, CASE_SERVICIO_PREMIUM);
	}

    
    @wire(getRecord, {recordId: '$recordId', fields: [CASE_OWNER_ID, CASE_STATUS, CASE_SERVICIO_PREMIUM]})
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
		}
	}


	renderedCallback() {
		//Hoja de estilos para habilitar toasts con varias líneas de texto
        /*
		if (!this.cssCargado) {
			loadStyle(this, CUSTOM_CSS).then(() => this.cssCargado = true);
		}*/

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

	modalEnviarAbrir() {
		if (this.plantillas.length === 0) {
			getPlantillasTMS()
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
			this.modalEnviarInicializar();
		} else {
			this.funcionAbrirModal = this.modalEnviarInicializar;
			this.showOperativas = true;
		}
	}

	modalEnviarInicializar() {
		this.validarCampos()
			.then(ok => {
				if (ok) {
					this.idGrupoSeleccionado = null;
					this.verTodasLasPlantillas = false;
					this.template.querySelector('.toggleVerTodasLasPlantillasEnviar').checked = false;
					this.idPlantillaSeleccionada = null;
					this.template.querySelector('.comboboxPlantillasEnviar').value = null;
					this.template.querySelector('.modalEnviar').classList.add('slds-fade-in-open');
					this.template.querySelector('.backdropModales').classList.add('slds-backdrop_open');
					this.template.querySelector('.modalEnviarCancelar').focus();
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

	comboboxPlantillasOnChange(event) {
		let comboboxPlantillas;
		if (event.currentTarget.dataset.operativa === 'Enviar') {
			comboboxPlantillas = this.template.querySelector('.comboboxPlantillasEnviar');
		} else {
			comboboxPlantillas = this.template.querySelector('.comboboxPlantillasRemitir');
		}
		this.idPlantillaSeleccionada = comboboxPlantillas.value;
	}

	inputBuscarPlantillasOnChange(event) {
		this.idPlantillaSeleccionada = null;
		let cadenaBusqueda;
		if (event.currentTarget.dataset.operativa === 'Enviar') {
			cadenaBusqueda = this.template.querySelector('.inputBuscarPlantillasEnviar').value;
		} else {
			cadenaBusqueda = this.template.querySelector('.inputBuscarPlantillasRemitir').value;
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
		if (event.currentTarget.dataset.operativa === 'Enviar') {
			this.template.querySelector('.inputBuscarPlantillasEnviar').value = event.currentTarget.dataset.name;
		} else {
			this.template.querySelector('.inputBuscarPlantillasRemitir').value = event.currentTarget.dataset.name;
		}
		this.idPlantillaSeleccionada = event.currentTarget.dataset.id;
		this.resultadosPlantillasMostrar = false;
	}


	inputBuscarPlantillasEnviarOnFocus() {
		this.resultadosPlantillasMostrar = this.template.querySelector('.inputBuscarPlantillasEnviar').value;
	}

	inputBuscarPlantillasEnviarOnBlur() {
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

	EnviarCorreo() {
		this.template.querySelector('.modalEnviarEnviar').disabled = true;
		this.generarBorrador('Enviar correo');
	}

	generarBorrador(operativa) {
		prepararCaso({
			idCaso: this.recordId,
			idPlantilla: this.idPlantillaSeleccionada,
			informarReferenciaCorreo: true,
			operativa: operativa
		})
			.then(() => {
				destinatarios({idCaso: this.recordId})
					.then(datosDestinatarios => {
                        let destinatariosPara = [];
                        let destinatariosCc = [];
                        if (datosDestinatarios) {
							for (let indice in datosDestinatarios) {
								if (indice === 'Para') {
									destinatariosPara = datosDestinatarios[indice];
								} else if (indice === 'CC') {
									destinatariosCc = datosDestinatarios[indice];
								}
							}
						}
                        
						this.sendEmail( destinatariosPara, destinatariosCc);
						this.closeModals();
					});
			})
			.catch(error => {
				console.error(error);
				this.mostrarToast('error', 'Problema generando el borrador de correo el caso', JSON.stringify(error));
			});
	}

	sendEmail( destinatariosPara, destinatariosCc) {
		this.dispatchEvent(new CustomEvent('rellenarmail', {
			detail: {
				para: destinatariosPara,
				cc: destinatariosCc
			}
		}));
	}

	closeModals() {
		this.generandoBorrador = false;
		this.verTodasLasPlantillas = false;
		this.template.querySelectorAll('.slds-modal').forEach(modal => modal.classList.remove('slds-fade-in-open'));
		this.template.querySelector('.backdropModales').classList.remove('slds-backdrop_open');
	}


    handleButtonServicioPremium() {
        const fields = {};
        fields[CASE_ID.fieldApiName] = this.recordId;
        fields[CASE_SERVICIO_PREMIUM.fieldApiName] = true;
        updateRecord({fields})
            .then(() => {
                this.mostrarToast('success', 'Servicio Premium', 'Se ha actualizado correctamente el caso');
            })
            .catch(error => {
                console.error(JSON.stringify(error));
                this.mostrarToast('error', 'Problema actualizando el caso', error.body.message);
            });
	}

    handleButtonNoServicioPremium() { 
        const fields = {};
        fields[CASE_ID.fieldApiName] = this.recordId;
        fields[CASE_SERVICIO_PREMIUM.fieldApiName] = false;
        updateRecord({fields})
            .then(() => {
                this.mostrarToast('info', 'No es Servicio Premium', 'Se ha actualizado correctamente el caso');
            })
            .catch(error => {
                console.error(JSON.stringify(error));
                this.mostrarToast('error', 'Problema actualizando el caso', error.body.message);
            });
	}

	modalTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.closeModals();
		}
	}
}