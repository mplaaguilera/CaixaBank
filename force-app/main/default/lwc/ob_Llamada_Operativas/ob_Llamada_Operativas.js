import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';
import {refreshApex} from '@salesforce/apex';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import currentUserId from '@salesforce/user/Id';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import {loadScript} from 'lightning/platformResourceLoader';
import jsencrypt from '@salesforce/resourceUrl/jsencrypt';

//Apex
import envioGdd from '@salesforce/apex/OB_Llamada.envioGdd';
import datosUrlGrabacion from '@salesforce/apex/OB_Llamada.datosUrlGrabacion';
import erroresLlamada from '@salesforce/apex/OB_Llamada.erroresLlamada';

//Campos de la llamada
import ID_FIELD from '@salesforce/schema/CC_Llamada__c.Id';
import RECORDTYPE_ID_FIELD from '@salesforce/schema/CC_Llamada__c.RecordTypeId';
import OWNER_ID_FIELD from '@salesforce/schema/CC_Llamada__c.OwnerId';
import OB_ESTADO_FIELD from '@salesforce/schema/CC_Llamada__c.OB_Estado__c';
import OB_MARCA_ENVIO_GDD_FIELD from '@salesforce/schema/CC_Llamada__c.OB_Marca_Envio_Gdd__c';
import OB_RESULTADO_CIERRE_FIELD from '@salesforce/schema/CC_Llamada__c.OB_Resultado_Cierre__c';
import OB_MOTIVO_RECHAZO_FIELD from '@salesforce/schema/CC_Llamada__c.OB_Motivo_Rechazo__c';
import OB_FECHA_ULTIMA_VALIDACION_FIELD from '@salesforce/schema/CC_Llamada__c.OB_Fecha_Ultima_Validacion__c';
import CBK_TICKET_OCP_FIELD from '@salesforce/schema/CC_Llamada__c.CBK_Ticket_OCP__c';

//eslint-disable-next-line camelcase, new-cap
export default class Ob_Llamada_Operativas extends NavigationMixin(LightningElement) {

	@api recordId;

	wiredRecordResult;

	llamadaOutboundRtId;

	motivoRechazoPicklistValues;

	llamada;

	esPropietario = false;

	tareasError;

	popoverErroresIdTimeout;

	get botonReenviarGddVariant() {
		return this.marcaEnvioGddHoy() ? 'brand' : '';
	}

	get botonReenviarGddDisabled() {
		return this.campoLlamada(OB_ESTADO_FIELD) !== 'OB_Cerrada' || !this.esPropietario || this.marcaEnvioGddHoy();
	}

	get validarRechazarDisabled() {
		return !this.esPropietario || this.campoLlamada(OB_ESTADO_FIELD) !== 'OB_Pendiente_Validacion';
	}

	get mostrarReproductorAudio() {
		return this.campoLlamada(CBK_TICKET_OCP_FIELD) && this.campoLlamada(OB_ESTADO_FIELD) !== 'OB_Error';
	}

	get botonRechazarRechazarDisabled() {
		if (!this.buscarControl('.motivoRechazo')) {
			return true;
		}
		return !this.buscarControl('.motivoRechazo').value;
	}

	connectedCallback() {
		loadScript(this, jsencrypt);
	}

	disconnectedCallback() {
		let reproductorAudioSource = this.buscarControl('.reproductorAudioSource');
		if (reproductorAudioSource) {
			reproductorAudioSource.removeEventListener('error', this.reproductorAudioSourceError);
		}
	}

	@wire(getRecord, {
		'recordId': '$recordId',
		'fields': [
			ID_FIELD,
			RECORDTYPE_ID_FIELD,
			OWNER_ID_FIELD,
			OB_ESTADO_FIELD,
			OB_RESULTADO_CIERRE_FIELD,
			CBK_TICKET_OCP_FIELD,
			OB_MARCA_ENVIO_GDD_FIELD
		]
	})
	wiredRecord(result) {
		this.wiredRecordResult = result;
		if (result.error) {
			console.error(result.error.body.message);
			this.mostrarToast(
				'error',
				'Error recuperando los datos de la llamada',
				result.error.body.message
			);
		} else if (result.data) {
			this.llamada = result.data;
			this.llamadaOutboundRtId = this.campoLlamada(RECORDTYPE_ID_FIELD);
			this.esPropietario = this.campoLlamada(OWNER_ID_FIELD) === currentUserId;
			this.estadoError = this.campoLlamada(OB_ESTADO_FIELD) === 'OB_Error';
			if (!this.estadoError && this.campoLlamada(CBK_TICKET_OCP_FIELD)) {
				//eslint-disable-next-line @lwc/lwc/no-async-operation
				window.setTimeout(() => {
					datosUrlGrabacion({'idLlamada': this.recordId})
						.then(response => {
							let reproductorAudio = this.buscarControl('.reproductorAudio');

							let validacion = 'idDoc:' + response.tiquet + ';appId:' + response.appid + ';username:' + response.username + ';timestamp:' + response.timestamp;
							//eslint-disable-next-line no-undef
							let crypt = new JSEncrypt();
							crypt.setPublicKey(response.publicKey);
							let crypted = crypt.encrypt(validacion);
							let auth = response.appid + ':' + response.username + ':' + response.canal;
							let url = response.baseUrl + '/?auth=' + encodeURIComponent(btoa(auth)) + '&validacion=' + encodeURIComponent(crypted);

							//url = 'https://file-examples.com/storage/febc474733629f43d9f078c/2017/11/file_example_MP3_700KB.mp3';

							let source = document.createElement('source');
							source.className = 'reproductorAudioSource';
							source.type = 'audio/mpeg';
							source.src = url;
							source.onerror = this.reproductorAudioSourceError.bind(this);
							reproductorAudio.appendChild(source);

							reproductorAudio.load();
						}).catch(error => {
							console.error(JSON.stringify(error));
							this.mostrarToast('error', 'Error al obtener enlace a la grabación', error.body.message);
						});
				}, 0);
			}
		}
	}

	reproductorAudioSourceError() {
		console.error('Problema recuperando el audio de la grabación\n' + this.buscarControl('.reproductorAudioSource').src);
		this.mostrarToast('info', 'Problema recuperando el audio de la grabación', 'Es posible que no sea posible reproducir la grabación de llamada');
	}

	@wire(getPicklistValues, {'recordTypeId': '$llamadaOutboundRtId', 'fieldApiName': OB_MOTIVO_RECHAZO_FIELD})
	//eslint-disable-next-line no-unused-vars
	getMotivoRechazoPicklistValues({error, data}) {
		if (data) {
			this.motivoRechazoPicklistValues = data.values;
		}
	}

	tomarPropiedad() {
		const fields = {};
		fields[ID_FIELD.fieldApiName] = this.recordId;
		fields[OWNER_ID_FIELD.fieldApiName] = currentUserId;
		updateRecord({fields})
			.then(() => {
				this.mostrarToast(
					'success',
					'Se actualizó correctamente propietario de la llamada',
					'Ahora es el propietario de la llamada.'
				);
			})
			.catch(error => {
				console.error(JSON.stringify(error));
				this.mostrarToast('error', 'Problema cambiando propietario de la llamada', error.body.message);
			});
	}

	reenvioGdd() {
		envioGdd({'idLlamadas': [this.recordId]})
			.then(() => {
				refreshApex(this.wiredRecordResult);
				this.mostrarToast('success', 'Se ha marcado la llamada para enviar a GDD', 'Se ha marcado correctamente la llamada para enviar a GDD');
				this.modalReenviarGddCerrar();
			})
			.catch(error => {
				console.error(JSON.stringify(error));
				this.mostrarToast('error', 'Error el marcar la llamada para enviar a GDD', error.body.message);
			});
	}

	abrirModalValidar() {
		if (this.campoLlamada(OB_RESULTADO_CIERRE_FIELD)) {
			this.buscarControl('.modalValidar').classList.add('slds-fade-in-open');
			this.buscarControl('.modalBackdrop').classList.add('slds-backdrop--open');
			this.buscarControl('.botonValidarCancelar').focus();
		} else {
			this.mostrarToast(
				'info',
				'Resultado de cierre obligatorio',
				'Para validar una grabación es necesario informar el resultado de cierre'
			);
		}
	}

	cerrarModalValidar() {
		this.buscarControl('.modalValidar').classList.remove('slds-fade-in-open');
		this.buscarControl('.modalBackdrop').classList.remove('slds-backdrop--open');
	}

	modalValidarTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.cerrarModalValidar();
		}
	}

	validar() {
		const fields = {};
		fields[ID_FIELD.fieldApiName] = this.recordId;
		fields[OB_ESTADO_FIELD.fieldApiName] = 'OB_Cerrada';
		fields[OB_FECHA_ULTIMA_VALIDACION_FIELD.fieldApiName] = new Date().toISOString();

		updateRecord({fields})
			.then(() => {
				this.mostrarToast(
					'success',
					'Grabación de llamada validada',
					'El estado de la llamada ahora es "Cerrada"'
				);
			})
			.catch(error => {
				console.error(JSON.stringify(error));
				this.mostrarToast('error', 'Problema registrando la validación positiva de la llamada', error.body.message);
			});
		this.cerrarModalValidar();
	}

	abrirModalRechazar() {
		this.buscarControl('.modalRechazar').classList.add('slds-fade-in-open');
		this.buscarControl('.modalBackdrop').classList.add('slds-backdrop--open');
		if (this.motivoRechazoPicklistValues.length === 1) {
			this.buscarControl('.motivoRechazo').value = this.motivoRechazoPicklistValues[0].value;
			this.buscarControl('.botonRechazarCancelar').focus();
		} else {
			this.buscarControl('.motivoRechazo').focus();
		}
	}

	cerrarModalRechazar() {
		this.buscarControl('.modalRechazar').classList.remove('slds-fade-in-open');
		this.buscarControl('.modalBackdrop').classList.remove('slds-backdrop--open');
	}

	modalRechazarTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.cerrarModalRechazar();
		}
	}

	rechazar() {
		const fields = {};
		fields[ID_FIELD.fieldApiName] = this.recordId;
		fields[OB_ESTADO_FIELD.fieldApiName] = 'OB_Rechazada';
		fields[OB_MOTIVO_RECHAZO_FIELD.fieldApiName] = this.buscarControl('.motivoRechazo').value;
		fields[OB_FECHA_ULTIMA_VALIDACION_FIELD.fieldApiName] = new Date().toISOString();
		updateRecord({fields})
			.then(() => {
				this.mostrarToast(
					'success',
					'Grabación de llamada rechazada',
					'El estado de la llamada ahora es "Rechazada"'
				);
			})
			.catch(error => {
				console.error(JSON.stringify(error));
				this.mostrarToast('error', 'Problema registrando la validación negativa de la llamada', error.body.message);
			});
		this.cerrarModalRechazar();
	}

	mostrarToast(tipo, titulo, mensaje) {
		const event = new ShowToastEvent({variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000});
		this.dispatchEvent(event);
	}

	campoLlamada(campo) {
		return getFieldValue(this.llamada, campo);
	}

	buscarControl(querySelector) {
		return this.template.querySelector(querySelector);
	}

	abrirPopoverErrores() {
		if (!this.tareasError) {
			erroresLlamada({'idLlamada': this.recordId})
				.then(tareasError => {
					if (tareasError) {
						this.tareasError = [];
						for (let key in tareasError) {
							if (Object.prototype.hasOwnProperty.call(tareasError, key)) {
								let tareaError = {...tareasError[key]};
								tareaError.errores = tareaError.errores.filter(msgError => msgError && msgError.trim().charAt(0) !== '<');
								this.tareasError.push({'key': key, 'value': tareaError});
							}
						}
					}
				})
				.catch(error => console.error(JSON.stringify(error)));
		}
		window.clearTimeout(this.popoverErroresIdTimeout);
		this.buscarControl('.popover').classList.remove('fadeOut');
		this.buscarControl('.popover').style.display = 'block';
		this.buscarControl('.popover').classList.add('fadeIn');
	}

	cerrarPopoverErrores() {
		this.buscarControl('.popover').classList.remove('fadeIn');
		this.buscarControl('.popover').classList.add('fadeOut');
		//eslint-disable-next-line no-return-assign, @lwc/lwc/no-async-operation
		this.popoverErroresIdTimeout = window.setTimeout(() => this.buscarControl('.popover').style.display = 'none', 500);
	}

	abrirTarea(event) {
		this[NavigationMixin.Navigate]({
			'type': 'standard__recordPage',
			'attributes': {
				'recordId': event.target.dataset.idtarea,
				'objectApiName': 'Task',
				'actionName': 'view'
			},
		});
	}

	marcaEnvioGddHoy() {
		let marcaEnvioGddHoy = false;
		if (this.campoLlamada(OB_MARCA_ENVIO_GDD_FIELD)) {
			let aux = this.campoLlamada(OB_MARCA_ENVIO_GDD_FIELD).split('-');
			let fechaEnvioGdd = new Date(aux[0], aux[1] - 1, aux[2]);
			const hoy = new Date();
			marcaEnvioGddHoy = fechaEnvioGdd.getDate() === hoy.getDate()
				&& fechaEnvioGdd.getMonth() === hoy.getMonth()
				&& fechaEnvioGdd.getFullYear() === hoy.getFullYear();
		}
		return marcaEnvioGddHoy;
	}

	modalReenviarGddAbrir() {
		this.buscarControl('.modalReenviarGdd').classList.add('slds-fade-in-open');
		this.buscarControl('.modalBackdrop').classList.add('slds-backdrop--open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => this.buscarControl('.modalReenviarGddBotonCancelar').focus(), 200);
	}

	modalReenviarGddCerrar() {
		this.buscarControl('.modalReenviarGdd').classList.remove('slds-fade-in-open');
		this.buscarControl('.modalBackdrop').classList.remove('slds-backdrop--open');
	}

	modalReenviarGddTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.modalReenviarGddCerrar();
		}
	}
}