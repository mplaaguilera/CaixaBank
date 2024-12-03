import {LightningElement, api, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {createRecord, getRecord, updateRecord, getFieldValue} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {loadStyle} from 'lightning/platformResourceLoader';
import currentUserId from '@salesforce/user/Id';

//CSS
import CUSTOM_CSS from '@salesforce/resourceUrl/sach_Case_Gestion_Css';

//Campos
import CASE_ID from '@salesforce/schema/Case.Id';
import CASE_OWNER_ID from '@salesforce/schema/Case.OwnerId';
import CASE_STATUS from '@salesforce/schema/Case.Status';
import CASE_ALERTA_FECHA from '@salesforce/schema/Case.SACH_Alerta_Fecha__c';
import CASE_DETALLE_CONSULTA from '@salesforce/schema/Case.CC_Detalles_Consulta__c';
import CASE_ALERTA_DESCRIPCION from '@salesforce/schema/Case.SACH_Alerta_Descripcion__c';
import PROCES_PROCESS_OBJECT from '@salesforce/schema/CBK_SCH_PendingProcess__c';
import PROCES_PROCESS_RECORDID from '@salesforce/schema/CBK_SCH_PendingProcess__c.RecordId__c';
import PROCES_PROCESS_TIME from '@salesforce/schema/CBK_SCH_PendingProcess__c.Schedule_Time__c';
import PROCES_PROCESS_CLASS from '@salesforce/schema/CBK_SCH_PendingProcess__c.ClassName__c';

//Métodos Apex
import validarCamposCaso from '@salesforce/apex/SACH_Case_Operativa.validarCamposCaso';
import buscarGruposColaboradores from '@salesforce/apex/SACH_Case_Operativa.buscarGruposColaboradores';
import getPlantillasSach from '@salesforce/apex/SACH_Case_Operativa.getPlantillasSach';
import prepararCaso from '@salesforce/apex/SACH_Case_Operativa.prepararCaso';
import destinatariosColaborador from '@salesforce/apex/SACH_Case_Operativa.destinatariosColaborador';
import createEvent from '@salesforce/apex/SACH_Case_Operativa.crearEvento';
import borrarEvento from '@salesforce/apex/SACH_Case_Operativa.borrarEvento';
import mergeCase from '@salesforce/apex/SACH_Case_Operativa.mergeCase';
import vincularLlamada from '@salesforce/apex/SACH_Case_Operativa.vincularLlamada';

//eslint-disable-next-line camelcase, new-cap
export default class sach_Case_Operativa extends NavigationMixin(LightningElement) {
	@api recordId;

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

	get operativaAlertaDisabled() {
		return !this.esPropietario || getFieldValue(this.caso, CASE_STATUS) === 'Cerrado' || getFieldValue(this.caso, CASE_STATUS) === 'Rechazado';
	}

	get operativasDisabled() {
		return !this.esPropietario || getFieldValue(this.caso, CASE_STATUS) !== 'Activo';
	}

	get botonGenerarBorradorDisabled() {
		return !this.idGrupoSeleccionado || !this.idPlantillaSeleccionada;
	}

	get botonFusionarDisabled() {
		let inputCasoRelacionado = this.template.querySelector('[data-id="casoRelacionado"]');
		return this.fusionandoCaso || inputCasoRelacionado && !inputCasoRelacionado.value;
	}

	get esPropietario() {
		return currentUserId === getFieldValue(this.caso, CASE_OWNER_ID);
	}

	get alertaProgramada() {
		return getFieldValue(this.caso, CASE_ALERTA_FECHA) != null;
	}

	@wire(getRecord, {recordId: '$recordId', fields: [CASE_OWNER_ID, CASE_STATUS, CASE_ALERTA_FECHA, CASE_DETALLE_CONSULTA]})
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
			let fecha = new Date(getFieldValue(this.caso, CASE_ALERTA_FECHA));
			if (fecha != null) {
				this.fechaAlertaVisual = fecha.getDate() + '/' + (fecha.getMonth() + 1) + '/' + fecha.getFullYear() + ' - ' + String(fecha.getHours()).padStart(2, '0') + ':' + String(fecha.getMinutes()).padStart(2, '0');
			}
			this.casoCargado = true;
		}
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

	modalTrasladarAbrir() {
		if (this.plantillas.length === 0) {
			getPlantillasSach()
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

	modalRemitirAbrir() {
		if (getFieldValue(this.caso, CASE_DETALLE_CONSULTA) === null) {
			this.mostrarToast('error', 'Error al Remitir a Colaborador', 'El campo "Detalles consulta" no puede estar vacío.');
		} else {
			if (this.plantillas.length === 0) {
				getPlantillasSach()
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
			//eslint-disable-next-line @lwc/lwc/no-async-operation
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
	}

	comboboxPlantillasOnChange(event) {
		let comboboxPlantillas;
		if (event.currentTarget.dataset.operativa === 'Trasladar') {
			comboboxPlantillas = this.template.querySelector('.comboboxPlantillasTrasladar');
		} else {
			comboboxPlantillas = this.template.querySelector('.comboboxPlantillasRemitir');
		}
		this.idPlantillaSeleccionada = comboboxPlantillas.value;
	}

	inputBuscarPlantillasOnChange(event) {
		this.idPlantillaSeleccionada = null;
		let cadenaBusqueda;
		if (event.currentTarget.dataset.operativa === 'Trasladar') {
			cadenaBusqueda = this.template.querySelector('.inputBuscarPlantillasTrasladar').value;
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
		if (event.currentTarget.dataset.operativa === 'Trasladar') {
			this.template.querySelector('.inputBuscarPlantillasTrasladar').value = event.currentTarget.dataset.name;
		} else {
			this.template.querySelector('.inputBuscarPlantillasRemitir').value = event.currentTarget.dataset.name;
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

	trasladarColaborador() {
		this.template.querySelector('.modalTrasladarTrasladar').disabled = true;
		this.generarBorrador('Trasladar');
	}

	remitirColaborador() {
		this.template.querySelector('.modalRemitirRemitir').disabled = true;
		this.generarBorrador('Remitir');
	}

	generarBorrador(operativa) {
		prepararCaso({
			idCaso: this.recordId,
			idPlantilla: this.idPlantillaSeleccionada,
			informarReferenciaCorreo: true,
			operativa: operativa
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

	closeModals() {
		this.generandoBorrador = false;
		this.verTodasLasPlantillas = false;
		this.template.querySelectorAll('.slds-modal').forEach(modal => modal.classList.remove('slds-fade-in-open'));
		this.template.querySelector('.backdropModales').classList.remove('slds-backdrop_open');
	}

	handleButtonPropiedad() {
		this.template.querySelector('[data-id="btnPropiedad"]').disabled = true;
		const fields = {};
		fields[CASE_ID.fieldApiName] = this.recordId;
		fields[CASE_OWNER_ID.fieldApiName] = currentUserId;
		updateRecord({fields})
			.then(() => {
				this.mostrarToast('success', 'Ahora es el propietario del caso', 'Se actualizó correctamente el propietario del caso');
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

	handleButtonPonerAlerta() {
		if (this.showOperativas) {
			this.modalProgramarAlertaInicializar();
		} else {
			this.funcionAbrirModal = this.modalProgramarAlertaInicializar;
			this.showOperativas = true;
		}
	}

	handleButtonQuitarAlerta() {
		if (this.showOperativas) {
			this.modalEliminarAlertaInicializar();
		} else {
			this.funcionAbrirModal = this.modalEliminarAlertaInicializar;
			this.showOperativas = true;
		}
	}

	handleButtonFusionar() {
		if (this.showOperativas) {
			this.modalFusionarCaso();
		} else {
			this.funcionAbrirModal = this.modalFusionarCaso;
			this.showOperativas = true;
		}
	}

	handleButtonVincular() {
		vincularLlamada({recordId: this.recordId})
		.then(reponse => {
			this.mostrarToast('success', 'Se vinculó caso con llamada en curso', 'Se vinculó correctamente la llamada ' + reponse + ' al caso.');
		})
		.catch(error => {
			console.error(error);
			this.mostrarToast('error', 'Problema vinculando la llamada', error.body.message);
		});
	}

	modalProgramarAlertaInicializar() {
		this.template.querySelector('.modalProgramarAlerta').classList.add('slds-fade-in-open');
		this.template.querySelector('.backdropModales').classList.add('slds-backdrop_open');
		this.template.querySelector('.modalProgramarAlertaCancelar').focus();
	}

	modalEliminarAlertaInicializar() {
		this.template.querySelector('.modalEliminarAlerta').classList.add('slds-fade-in-open');
		this.template.querySelector('.backdropModales').classList.add('slds-backdrop_open');
		this.template.querySelector('.modalEliminarAlertaCancelar').focus();
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
		let idNuevoCaso = this.template.querySelector('[data-id="casoRelacionado"]').value;
		if (idNuevoCaso === this.recordId) {
			this.mostrarToast('info', 'Caso no válido', 'Los casos origen y destino de la fusión deben ser distintos');
		} else {
			this.fusionandoCaso = true;
			mergeCase({masterCaseId: this.recordId, idCasoSelected: idNuevoCaso})
				.then(() => {
					this.mostrarToast('success', 'Se han fusionado los casos', 'Se han fusionado los casos correctamente');
					//Cerrar pestaña del caso origen y abrir nueva pestaña para el caso destino
					this.dispatchEvent(new CustomEvent('cerrarpestana', {detail: {
						idNuevoCaso: this.template.querySelector('[data-id="casoRelacionado"]').value
					}}));
				}).catch(error => {
					console.error(error);
					this.mostrarToast('error', 'Problema fusionando los casos', JSON.stringify(error));
				}).finally(() => this.fusionandoCaso = false);
		}
	}

	programarAlerta(event) {
		let operativa = event.currentTarget.dataset.id === 'botonProgramarAlerta' ? 'ponerAlerta' : 'quitarAlerta';
		let inputFecha = this.template.querySelector('[data-id="SACH_Alerta_Fecha__c"]');
		let inputDesc = this.template.querySelector('[data-id="SACH_Alerta_Descripcion__c"]');

		let ok = true;
		if (operativa === 'botonProgramarAlerta') {
			if (!inputFecha.value) {
				this.mostrarToast('info', 'Campo obligatorio', 'Indica una fecha para la alerta');
				ok = false;
			} else if (new Date(inputFecha.value) <= new Date()) {
				this.mostrarToast('info', 'Fecha no válida', 'La fecha de la alerta debe ser posterior a la actual');
				ok = false;
			}

			if (!inputDesc.value) {
				this.mostrarToast('info', 'Campo obligatorio', 'Indica una descripción para la alerta');
				ok = false;
			}
		}

		if (ok) {
			this.guardandoAlerta = true;
			const fields = {};
			fields[CASE_ID.fieldApiName] = this.recordId;
			fields[CASE_ALERTA_FECHA.fieldApiName] = operativa === 'ponerAlerta' ? inputFecha.value : null;
			fields[CASE_ALERTA_DESCRIPCION.fieldApiName] = operativa === 'ponerAlerta' ? inputDesc.value : null;
			updateRecord({fields})
				.then(() => {
					if (operativa === 'ponerAlerta') {
						this.crearAviso(inputFecha.value, inputDesc.value);
					} else {
						this.borrarEvento();
					}
				})
				.catch(error => {
					console.error(error);
					this.mostrarToast('error', operativa === 'ponerAlerta' ? 'Problema programando la alerta' : 'Problema desprogramando la alerta', error);
					this.guardandoAlerta = false;
				});
		}
	}

	crearAviso(fechaAlerta, descripcionAlerta) {
		const recordInput = {
			apiName: PROCES_PROCESS_OBJECT.objectApiName,
			fields: {
				[PROCES_PROCESS_RECORDID.fieldApiName]: this.recordId,
				[PROCES_PROCESS_TIME.fieldApiName]: fechaAlerta,
				[PROCES_PROCESS_CLASS.fieldApiName]: 'SACH_SCH_CSBD_ScheduleAlerta'
			}
		};
		createRecord(recordInput)
			.then(() => {
				createEvent({recordId: this.recordId, fecha: fechaAlerta, descripcion: descripcionAlerta})
					.then(() => {
						this.mostrarToast('success', 'Se programó la alerta', 'Se ha generado una alerta para el ' + this.fechaAlertaVisual);
						this.closeModals();
						this.guardandoAlerta = false;
					})
					.catch(error => {
						console.error(JSON.stringify(error));
						this.mostrarToast('error', 'Problema creando el evento', error.body.message);
						this.guardandoAlerta = false;
					});
			})
			.catch(error => {
				console.error(error);
				this.mostrarToast('error', 'Problema programando la alerta', JSON.stringify(error));
				this.guardandoAlerta = false;
			});
	}

	borrarEvento() {
		borrarEvento({recordId: this.recordId})
			.then(() => {
				this.closeModals();
				this.mostrarToast('info', 'Se desprogramó la alerta', 'Se ha desprogramado la alerta correctamente');
				this.guardandoAlerta = false;
			})
			.catch(error => {
				console.error(JSON.stringify(error));
				this.mostrarToast('error', 'Problema borrando el evento', error.body.message);
				this.guardandoAlerta = false;
			});
	}
}