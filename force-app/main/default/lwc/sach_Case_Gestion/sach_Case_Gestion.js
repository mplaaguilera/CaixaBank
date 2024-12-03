import {LightningElement, wire, api} from 'lwc';
import {updateRecord, getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {loadStyle} from 'lightning/platformResourceLoader';
import currentUserId from '@salesforce/user/Id';

//CSS
import CUSTOM_CSS from '@salesforce/resourceUrl/sach_Case_Gestion_Css';

//Campos Case
import CASE_ID from '@salesforce/schema/Case.Id';
import CASE_RECORDTYPE_NAME from '@salesforce/schema/Case.RecordType.Name';
import CASE_CASENUMBER from '@salesforce/schema/Case.CaseNumber';
import CASE_OWNERID from '@salesforce/schema/Case.OwnerId';
import CASE_STATUS from '@salesforce/schema/Case.Status';
import CASE_ORIGIN from '@salesforce/schema/Case.Origin';
import CASE_CONTACTID from '@salesforce/schema/Case.ContactId';
import CASE_CC_MCC_TEMATICA from '@salesforce/schema/Case.CC_MCC_Tematica__c';
import CASE_CC_MCC_TEMATICA_NAME from '@salesforce/schema/Case.CC_MCC_Tematica__r.Name';
import CASE_CC_MCC_PRODSERV from '@salesforce/schema/Case.CC_MCC_ProdServ__c';
import CASE_CC_MCC_PRODSERV_NAME from '@salesforce/schema/Case.CC_MCC_ProdServ__r.Name';
import CASE_CC_MCC_MOTIVO from '@salesforce/schema/Case.CC_MCC_Motivo__c';
import CASE_CC_MCC_MOTIVO_NAME from '@salesforce/schema/Case.CC_MCC_Motivo__r.Name';
import CASE_CC_MCC_CAUSA from '@salesforce/schema/Case.CC_MCC_Causa__c';
import CASE_CC_MCC_CAUSA_NAME from '@salesforce/schema/Case.CC_MCC_Causa__r.Name';
import CASE_CC_MCC_SOLUCION from '@salesforce/schema/Case.CC_MCC_Solucion__c';
import CASE_CC_MCC_SOLUCION_NAME from '@salesforce/schema/Case.CC_MCC_Solucion__r.Name';

//Métodos Apex
import getMCCValor from '@salesforce/apex/SACH_Case_Gestion_Controller.getValueMCC';
import crearActividad from '@salesforce/apex/SACH_Case_Gestion_Controller.crearActividad';
import reabrirTareaTrasladoColaborador from '@salesforce/apex/SACH_Case_Gestion_Controller.reabrirTareaTrasladoColaborador';

export default class sachCaseGestion extends LightningElement {

	@api recordId;

	caso;

	opcionesCargadas = {
		tematicas: false, productos: false, motivos: false,
		causas: false, soluciones: false
	}

	guardando = false;

	optionsTematica = [];

	optionsProducto = [];

	optionsMotivo = [];

	optionsCausa = [];

	optionsSolucion = [];

	cambiarEstadoPendienteColabChecked = false;

	get deshabilitar() {
		return getFieldValue(this.caso, CASE_STATUS) !== 'Activo' || getFieldValue(this.caso, CASE_OWNERID) !== currentUserId || this.guardando;
	}

	get casoAbierto() {
		return getFieldValue(this.caso, CASE_STATUS) !== 'Cerrado' && getFieldValue(this.caso, CASE_STATUS) !== 'Rechazado';
	}

	get deshabilitarCerrar() {
		return getFieldValue(this.caso, CASE_STATUS) !== 'Activo' || getFieldValue(this.caso, CASE_OWNERID) !== currentUserId || this.guardando || this.cambiarEstadoPendienteColabChecked;
	}

	get deshabilitarRechazar() {
		return getFieldValue(this.caso, CASE_STATUS) !== 'Activo' || this.guardando || this.cambiarEstadoPendienteColabChecked;
	}

	renderedCallback() {
		//Hoja de estilos para habilitar toasts con varias líneas de texto
		if (!this.cssCargado) {
			loadStyle(this, CUSTOM_CSS).then(() => this.cssCargado = true);
			document.body.style.setProperty('--lwc-colorBackgroundPathComplete', 'rgb(69, 198, 90');
			document.body.style.setProperty('--lwc-colorBackgroundPathActive', 'rgb(1, 68, 134)');
		}
	}

	@wire(getRecord, {
		recordId: '$recordId',
		fields: [
			CASE_OWNERID, CASE_STATUS, CASE_ORIGIN, CASE_RECORDTYPE_NAME, CASE_CASENUMBER, CASE_CONTACTID,
			CASE_CC_MCC_TEMATICA, CASE_CC_MCC_TEMATICA_NAME,
			CASE_CC_MCC_PRODSERV, CASE_CC_MCC_PRODSERV_NAME,
			CASE_CC_MCC_MOTIVO, CASE_CC_MCC_MOTIVO_NAME,
			CASE_CC_MCC_CAUSA, CASE_CC_MCC_CAUSA_NAME,
			CASE_CC_MCC_SOLUCION, CASE_CC_MCC_SOLUCION_NAME
		]})
	wiredRecord({error, data}) {
		if (error) {
			this.mostrarToast('error', 'Problema recuperando los datos del caso', JSON.stringify(error));
		} else if (data) {
			this.caso = data;

			//Temática
			let tematicaId = getFieldValue(this.caso, CASE_CC_MCC_TEMATICA);
			let tematicaNombre = getFieldValue(this.caso, CASE_CC_MCC_TEMATICA_NAME);
			if (tematicaId && this.optionsTematica.length === 0) {
				this.optionsTematica = [...this.optionsTematica];
				this.optionsTematica.push({value: tematicaId, label: tematicaNombre});
			}
			this.template.querySelector('[data-id="tematica"]').value = tematicaId;

			//Producto
			let productoId = getFieldValue(this.caso, CASE_CC_MCC_PRODSERV);
			let productoNombre = getFieldValue(this.caso, CASE_CC_MCC_PRODSERV_NAME);
			if (productoId && this.optionsProducto.length === 0) {
				this.optionsProducto = [...this.optionsProducto];
				this.optionsProducto.push({value: productoId, label: productoNombre});
			}
			this.template.querySelector('[data-id="producto"]').value = productoId;

			//Motivo
			let motivoId = getFieldValue(this.caso, CASE_CC_MCC_MOTIVO);
			let motivoNombre = getFieldValue(this.caso, CASE_CC_MCC_MOTIVO_NAME);
			if (motivoId && this.optionsMotivo.length === 0) {
				this.optionsMotivo = [...this.optionsMotivo];
				this.optionsMotivo.push({value: motivoId, label: motivoNombre});
			}
			this.template.querySelector('[data-id="motivo"]').value = motivoId;

			//Causa
			let causaId = getFieldValue(this.caso, CASE_CC_MCC_CAUSA);
			let causaNombre = getFieldValue(this.caso, CASE_CC_MCC_CAUSA_NAME);
			if (causaId && this.optionsCausa.length === 0) {
				this.optionsCausa = [...this.optionsCausa];
				this.optionsCausa.push({value: causaId, label: causaNombre});
			}
			this.template.querySelector('[data-id="causa"]').value = causaId;

			//Solución
			let solucionId = getFieldValue(this.caso, CASE_CC_MCC_SOLUCION);
			let solucionNombre = getFieldValue(this.caso, CASE_CC_MCC_SOLUCION_NAME);
			if (solucionId && this.optionsSolucion.length === 0) {
				this.optionsSolucion = [...this.optionsSolucion];
				this.optionsSolucion.push({value: solucionId, label: solucionNombre});
			}
			this.template.querySelector('[data-id="solucion"]').value = solucionId;

			this.calcularDisabledCamposClasificacion();
		}
	}

	tematicaFocus() {
		if (!this.opcionesCargadas.tematicas) {
			this.template.querySelector('[data-id="tematica"]').spinnerActive = true;
			this.getMccValores('CC_Tematica');
		}
	}

	tematicaSeleccionada() {
		this.template.querySelector('[data-id="producto"]').value = null;
		this.template.querySelector('[data-id="motivo"]').value = null;
		this.template.querySelector('[data-id="causa"]').value = null;
		this.template.querySelector('[data-id="solucion"]').value = null;
		this.calcularDisabledCamposClasificacion();
		this.opcionesCargadas.productos = false;
		this.template.querySelector('[data-id="producto"]').blur();
		this.productoFocus();
	}

	productoFocus() {
		if (!this.opcionesCargadas.productos) {
			this.template.querySelector('[data-id="producto"]').spinnerActive = true;
			this.getMccValores('CC_Producto_Servicio', this.template.querySelector('[data-id="tematica"]').value);
		}
	}

	productoSeleccionado() {
		this.template.querySelector('[data-id="motivo"]').value = null;
		this.template.querySelector('[data-id="causa"]').value = null;
		this.template.querySelector('[data-id="solucion"]').value = null;
		this.calcularDisabledCamposClasificacion();
		this.opcionesCargadas.motivos = false;
		this.template.querySelector('[data-id="motivo"]').blur();
		this.motivoFocus();
	}

	motivoFocus() {
		if (!this.opcionesCargadas.motivos) {
			this.template.querySelector('[data-id="motivo"]').spinnerActive = true;
			this.getMccValores('CC_Motivo', this.template.querySelector('[data-id="producto"]').value);
		}
	}

	motivoSeleccionado() {
		this.template.querySelector('[data-id="causa"]').value = null;
		this.template.querySelector('[data-id="solucion"]').value = null;
		this.calcularDisabledCamposClasificacion();
		this.opcionesCargadas.causas = false;
		this.template.querySelector('[data-id="causa"]').blur();
		this.causaFocus();
	}

	causaFocus() {
		if (!this.opcionesCargadas.causas) {
			this.template.querySelector('[data-id="causa"]').spinnerActive = true;
			this.getMccValores('CC_Causa', this.template.querySelector('[data-id="motivo"]').value);
		}
	}

	causaSeleccionada() {
		this.template.querySelector('[data-id="solucion"]').value = null;
		this.calcularDisabledCamposClasificacion();
		this.opcionesCargadas.soluciones = false;
		this.template.querySelector('[data-id="solucion"]').blur();
		this.solucionFocus();
	}

	solucionFocus() {
		if (!this.opcionesCargadas.soluciones) {
			this.template.querySelector('[data-id="solucion"]').spinnerActive = true;
			this.getMccValores('CC_Solucion', this.template.querySelector('[data-id="causa"]').value);
		}
	}

	getMccValores(tipoRegistroMCC, idClasificacionPadre = '') {
		getMCCValor({
			tipoCliente: getFieldValue(this.caso, CASE_RECORDTYPE_NAME),
			tipoRegistro: tipoRegistroMCC,
			mccRelacionado: idClasificacionPadre
		})
			.then(response =>{
				if (response) {
					switch (tipoRegistroMCC) {
						case 'CC_Tematica':
							this.optionsTematica = response;
							this.opcionesCargadas.tematicas = true;
							this.template.querySelector('[data-id="tematica"]').spinnerActive = false;
							if (response.length === 1) {
								this.template.querySelector('[data-id="tematica"]').value = response[0].value;
								this.tematicaSeleccionada();
							}
							break;
						case 'CC_Producto_Servicio':
							this.optionsProducto = response;
							this.opcionesCargadas.productos = true;
							this.template.querySelector('[data-id="producto"]').spinnerActive = false;
							if (response.length === 1) {
								this.template.querySelector('[data-id="producto"]').value = response[0].value;
								this.productoSeleccionado();
							}
							break;
						case 'CC_Motivo':
							this.optionsMotivo = response;
							this.opcionesCargadas.motivos = true;
							this.template.querySelector('[data-id="motivo"]').spinnerActive = false;
							if (response.length === 1) {
								this.template.querySelector('[data-id="motivo"]').value = response[0].value;
								this.motivoSeleccionado();
							}
							break;
						case 'CC_Causa':
							this.optionsCausa = response;
							this.opcionesCargadas.causas = true;
							this.template.querySelector('[data-id="causa"]').spinnerActive = false;
							if (response.length === 1) {
								this.template.querySelector('[data-id="causa"]').value = response[0].value;
								this.causaSeleccionada();
							}
							break;
						case 'CC_Solucion':
							this.optionsSolucion = response;
							this.opcionesCargadas.soluciones = true;
							this.template.querySelector('[data-id="solucion"]').spinnerActive = false;
							if (response.length === 1) {
								this.template.querySelector('[data-id="solucion"]').value = response[0].value;
							}
							break;
					}
				}
			})
			.catch(error => {
				console.error(JSON.stringify(error));
				this.mostrarToast('error', 'Problema obteniendo los MCCs', error.body.message);
			});
	}

	recordEditFormOnLoad() {
		this.template.querySelector('.formulario').classList.remove('slds-hide');
	}

	recordEditFormSubmit(event) {
		if (event.currentTarget.dataset.id === 'guardarCerrar') {
			//Validaciones cerrar
			let errores = '';
			if (!this.template.querySelector('[data-id="CC_Tipo_Contacto__c"]').value) {
				errores = '· Tipo de contacto\n';
			}
			if (!getFieldValue(this.caso, CASE_CONTACTID)) {
				errores += '· Contacto\n';
			}
			if (!this.template.querySelector('[data-id="causa"]').value) {
				errores += '· Causa\n';
			}
			if (!this.template.querySelector('[data-id="solucion"]').value) {
				errores += '· Solución\n';
			}
			if (!this.template.querySelector('[data-id="detallesConsulta"]').value) {
				errores += '· Detalles consulta\n';
			}

			if (errores) {
				this.guardando = false;
				this.calcularDisabledCamposClasificacion();
				this.mostrarToast('info', 'Campos requeridos', 'Los siguientes campos son necesarios para cerrar el caso:\n' + errores);
				return;
			}
		} else if (event.currentTarget.dataset.id === 'guardarRechazar') {
			//Validaciones rechazar
			let inputEnviarMotivoRechazar = this.template.querySelector('[data-id="inputEnviarMotivoRechazar"]');
			if (!inputEnviarMotivoRechazar.checkValidity()) {
				inputEnviarMotivoRechazar.reportValidity();
				return;
			}
		}

		this.guardando = true;
		this.calcularDisabledCamposClasificacion();

		//Guardar cambios
		this.template.querySelector('[data-id="inputTematica"]').value = this.template.querySelector('[data-id="tematica"]').value;
		this.template.querySelector('[data-id="inputProducto"]').value = this.template.querySelector('[data-id="producto"]').value;
		this.template.querySelector('[data-id="inputMotivo"]').value = this.template.querySelector('[data-id="motivo"]').value;
		this.template.querySelector('[data-id="inputCausa"]').value = this.template.querySelector('[data-id="causa"]').value;
		this.template.querySelector('[data-id="inputSolucion"]').value = this.template.querySelector('[data-id="solucion"]').value;
		if (event.currentTarget.dataset.id === 'guardarCerrar') {
			this.template.querySelector('[data-id="inputEstado"]').value = 'Cerrado';
		} else if (event.currentTarget.dataset.id === 'guardarRechazar') {
			this.template.querySelector('[data-id="inputOwnerId"]').value = currentUserId;
			this.template.querySelector('[data-id="inputEstado"]').value = 'Rechazado';
		}
		this.tipoSubmit = event.currentTarget.dataset.id;
		this.template.querySelector('[data-id="recordEditForm"]').submit();
	}

	recordEditFormOnSuccess() {
		if (this.tipoSubmit === 'guardar') {
			this.mostrarToast('success', 'Se actualizó Caso', 'Se actualizaron correctamente los datos del caso ' + getFieldValue(this.caso, CASE_CASENUMBER));
			if (this.cambiarEstadoPendienteColabChecked) {
				this.reabrirActividadTrasladoColaborador();
				this.cambiarEstadoPendienteColabChecked = false;
				this.template.querySelector('[data-id="inputCambiarPendienteColab"]').checked = false;
			}
		} else if (this.tipoSubmit === 'guardarCerrar') {
			this.mostrarToast('success', 'Se cerró Caso', 'Se cerró correctamente el caso ' + getFieldValue(this.caso, CASE_CASENUMBER));

		} else if (this.tipoSubmit === 'guardarRechazar') {
			this.mostrarToast('success', 'Se rechazó Caso', 'Se rechazó correctamente el caso ' + getFieldValue(this.caso, CASE_CASENUMBER));
			crearActividad({recordId: this.recordId, tipo: 'Rechazado', motivo: this.template.querySelector('[data-id="inputEnviarMotivoRechazar"]').value})
				.catch(error => {
					console.error(JSON.stringify(error));
					this.mostrarToast('error', 'Problema creando la tarea de rechazo', error.body.message);
				});
			this.modalRechazarCerrar();
		}

		this.guardando = false;
		this.calcularDisabledCamposClasificacion();
		this.tipoSubmit = null;
	}

	recordEditFormOnError(event) {
		console.error(JSON.stringify(event.detail));

		let titulo;
		if (this.tipoSubmit === 'guardar') {
			titulo = 'Problema actualizando el caso';
		} else if (this.tipoSubmit === 'guardarCerrar') {
			titulo = 'Problema cerrando el caso';
		} else if (this.tipoSubmit === 'guardarRechazar') {
			titulo = 'Problema rechazando el caso';
		}

		this.mostrarToast(
			event.detail.output.errors[0].errorCode === 'FIELD_CUSTOM_VALIDATION_EXCEPTION' ? 'info' : 'error',
			titulo,
			event.detail.output.errors[0].message
		);

		this.guardando = false;
		this.calcularDisabledCamposClasificacion();
		this.tipoSubmit = null;
	}

	reabrirActividadTrasladoColaborador() {
		reabrirTareaTrasladoColaborador({idCaso: this.recordId})
			.catch(error => {
				console.error(JSON.stringify(error));
				this.mostrarToast('error', 'Problema reabriendo la tarea de traslado a colaborador', error.body.message);
			});
	}

	modalRechazarAbrir() {
		this.template.querySelector('[data-id="inputEnviarMotivoRechazar"]').value = '';
		this.template.querySelector('.modalRechazar').classList.add('slds-fade-in-open');
		this.template.querySelector('.backdropModales').classList.add('slds-backdrop_open');
		this.template.querySelector('[data-id="inputEnviarMotivoRechazar"]').focus();
	}

	modalRechazarCerrar() {
		this.template.querySelector('.modalRechazar').classList.remove('slds-fade-in-open');
		this.template.querySelector('.backdropModales').classList.remove('slds-backdrop_open');
	}

	modalReactivarAbrir() {
		this.template.querySelector('[data-id="inputEnviarMotivoReactivar"]').value = '';
		this.template.querySelector('.modalReactivar').classList.add('slds-fade-in-open');
		this.template.querySelector('.backdropModales').classList.add('slds-backdrop_open');
		this.template.querySelector('[data-id="inputEnviarMotivoReactivar"]').focus();
	}

	modalReactivarCerrar() {
		this.template.querySelector('.modalReactivar').classList.remove('slds-fade-in-open');
		this.template.querySelector('.backdropModales').classList.remove('slds-backdrop_open');
	}

	reactivar() {
		let inputEnviarMotivoReactivar = this.template.querySelector('[data-id="inputEnviarMotivoReactivar"]');

		if (!inputEnviarMotivoReactivar.checkValidity()) {
			inputEnviarMotivoReactivar.reportValidity();
		} else {
			this.guardando = true;
			const fields = {};
			fields[CASE_ID.fieldApiName] = this.recordId;
			fields[CASE_STATUS.fieldApiName] = 'Activo';
			fields[CASE_OWNERID.fieldApiName] = currentUserId;
			updateRecord({fields})
				.then(() => {
					this.mostrarToast('success', 'Se reactivó Caso', 'Se reactivó correctamente el caso ' + getFieldValue(this.caso, CASE_CASENUMBER));
					crearActividad({recordId: this.recordId, tipo: 'Reactivación', motivo: inputEnviarMotivoReactivar.value})
						.catch(error => {
							console.error(JSON.stringify(error));
							this.mostrarToast('error', 'Problema creando la tarea de reactivación', error.body.message);
						});
					this.guardando = false;
					this.modalReactivarCerrar();
				}).catch(error => {
					this.guardando = false;
					console.error(JSON.stringify(error));
					this.mostrarToast('error', 'No se pudo reactivar el caso', JSON.stringify(error));
				});
		}
	}

	modalTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.closeModals();
		}
	}

	closeModals() {
		this.template.querySelectorAll('.slds-modal').forEach(modal => modal.classList.remove('slds-fade-in-open'));
		this.template.querySelector('.backdropModales').classList.remove('slds-backdrop_open');
	}

	calcularDisabledCamposClasificacion() {
		if (this.deshabilitar || this.guardando) {
			this.template.querySelectorAll('lightning-combobox').forEach(combobox => combobox.disabled = true);
		} else {
			let comboboxTematica = this.template.querySelector('[data-id="tematica"]');
			let comboboxProducto = this.template.querySelector('[data-id="producto"]');
			let comboboxMotivo = this.template.querySelector('[data-id="motivo"]');
			let comboboxCausa = this.template.querySelector('[data-id="causa"]');
			let comboboxSolucion = this.template.querySelector('[data-id="solucion"]');
			comboboxTematica.disabled = false;
			comboboxProducto.disabled = !comboboxTematica.value;
			comboboxMotivo.disabled = !comboboxProducto.value;
			comboboxCausa.disabled = !comboboxMotivo.value;
			comboboxSolucion.disabled = !comboboxCausa.value;
		}
	}

	cambiarEstadoPendienteColabOnChange(event) {
		this.cambiarEstadoPendienteColabChecked = event.target.checked;
	}

	mostrarToast(variant, title, message) {
		this.dispatchEvent(new ShowToastEvent({
			variant: variant, title: title, message: message, mode: 'dismissable', duration: 4000
		}));
	}
}