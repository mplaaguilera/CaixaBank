import {LightningElement, api, wire} from 'lwc';
import LightningConfirm from 'lightning/confirm';
import {getRecord, getFieldValue, notifyRecordUpdateAvailable} from 'lightning/uiRecordApi';
import {errorApex, publicarEvento, toast, transitionThenCallback} from 'c/csbd_lwcUtils';
import {cambiarSeccion} from './utils';

import programarCitaApex from '@salesforce/apex/CSBD_Opportunity_Operativas_Controller.programarCita';

import OPPTY_IDENTIFICADOR from '@salesforce/schema/Opportunity.CSBD_Identificador__c';
import OPPTY_OWNER_ID from '@salesforce/schema/Opportunity.OwnerId';
import OPPTY_OWNER_PROFILE_NAME from '@salesforce/schema/Opportunity.Owner.Profile.Name';
import USER_NAME from '@salesforce/schema/User.Name';

const OPPTY_FIELDS = [OPPTY_IDENTIFICADOR, OPPTY_OWNER_ID, OPPTY_OWNER_PROFILE_NAME];

export default class csbdProgramarCita extends LightningElement {

	componente = {spinner: false, numCalendarios: 0, lwcDisponibilidadWidth: null, funcionesBind: {}, admin: false};

	@api recordId;

	oportunidad;

	tiposAsignacion = [
		{label: 'A gestor específico', value: 'A gestor específico'},
		{label: 'Según disponibilidad', value: 'Según disponibilidad'},
		{label: 'Automática', value: 'Automática'}
	];

	idPropietarioSeleccionado;

	nombrePropietarioSeleccionado;

	@wire(getRecord, {recordId: '$idPropietarioSeleccionado', fields: [USER_NAME]})
	wiredUsuario({data: usuario, error: errorGetUsuario}) {
		if (usuario) {
			const nombre = getFieldValue(usuario, USER_NAME).toLowerCase().split(' ').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');
			this.nombrePropietarioSeleccionado = nombre;
		} else if (errorGetUsuario) {
			errorApex(this, errorGetUsuario, 'Problema recuperando los datos del usuario');
		}
	}

	tipoAsignacion = 'A gestor específico';

	inputFechaValueAnterior;

	@wire(getRecord, {recordId: '$recordId', fields: OPPTY_FIELDS})
	wiredOpportunity({data: oportunidad, error: errorGetRecord}) {
		if (oportunidad) {
			this.oportunidad = oportunidad;
			this.idPropietarioSeleccionado = getFieldValue(oportunidad, OPPTY_OWNER_ID);
			this.componente.admin = getFieldValue(oportunidad, OPPTY_OWNER_PROFILE_NAME) === 'System Administrator';
		} else if (errorGetRecord) {
			errorApex(this, errorGetRecord, 'Problema recuperando los datos de la oportunidad');
		}
	}

	@api abrirModal() {
		try {
			const fechaActual = new Date();
			let fechaInicial = new Date(fechaActual);

			let hours = fechaInicial.getHours();
			if (hours < 9) {
				//Si la hora actual es anterior a las 9:00, se cambia a las 9:00
				fechaInicial.setHours(9, 0, 0, 0);
			} else if (hours > 19) {
				//Si la hora actual es posterior a las 19:00, se cambia a las 9:00 del siguiente día laborable
				fechaInicial.setDate(fechaInicial.getDate() + (8 - fechaInicial.getDay()) % 7);
				fechaInicial.setHours(9, 0, 0, 0);
			}
			fechaInicial.setMinutes(fechaInicial.getMinutes() + 1);
			const inputFecha = this.refs.inputFecha;
			inputFecha.min = fechaActual.toISOString();
			inputFecha.value = fechaInicial.toISOString();
			this.inputFechaValueAnterior = inputFecha.value;

			this.refs.backdropModal.classList.add('slds-backdrop_open');
			this.refs.modalProgramarCita.classList.add('slds-fade-in-open');
			window.setTimeout(() => this.refs.botonCancelar.focus(), 90);
			publicarEvento(this, 'modalabierto', {nombreModal: 'modalProgramarCita'});

		} catch (error) {
			errorApex(this, error, 'Problema al iniciar la operariva');
			this.modalCerrar();
		}
	}

	modalCerrar() {
		transitionThenCallback(
			this.refs.modalProgramarCita, 'slds-fade-in-open',
			() => publicarEvento(this, 'modalcerrado', {nombreModal: 'modalProgramarCita'}),
			'opacity'
		);
		this.refs.backdropModal.classList.remove('slds-backdrop_open');
	}

	inputFechaOnchange({currentTarget: inputFecha, detail: {value: fechaNewIso}}) {
		if (fechaNewIso) {
			const fechaNew = new Date(fechaNewIso);
			this.inputFechaValueAnterior = fechaNewIso;

			if (this.tipoAsignacion === 'Según disponibilidad') {
				const lwcDisponibilidad = this.refs.lwcDisponibilidad;
				lwcDisponibilidad.fecha = fechaNew;
			}
		}
		inputFecha.checkValidity();
		inputFecha.reportValidity();
	}

	async radioGroupTiposAsignacionOnchange({detail: {value: tipoAsignacionDestino}}) {
		const tipoAsignacionActual = this.tipoAsignacion;
		this.tipoAsignacion = tipoAsignacionDestino;
		if (tipoAsignacionDestino === 'Según disponibilidad') {
			this.refs.lwcDisponibilidad.fecha = new Date(this.refs.inputFecha.value);
		}
		await cambiarSeccion(this, tipoAsignacionActual, tipoAsignacionDestino);
		this.refs.modalContainer.style.pointerEvents = 'auto';
	}

	async programarCita() {
		const asignacionAuto = this.tipoAsignacion === 'Automática';
		if (!asignacionAuto && typeof this.idPropietarioSeleccionado !== 'string') {
			this.refs.inputPropietario.reportValidity();
			return;
		}

		const inputFecha = this.refs.inputFecha;
		inputFecha.min = new Date().toISOString();
		inputFecha.reportValidity();
		if (!inputFecha.validity.valid) {
			return;
		}

		const fecha = new Date(inputFecha.value);
		let fechaTexto = fecha.toLocaleDateString('es-ES', {weekday: 'long', month: 'long', day: 'numeric'});
		fechaTexto += ` a las ${fecha.getHours().toString().padStart(2, '0')}:${fecha.getMinutes().toString().padStart(2, '0')}`;

		let mensaje = `Cita para el gestor ${this.nombrePropietarioSeleccionado.toUpperCase()}`;
		mensaje += ` el ${fechaTexto.toUpperCase()}. ¿Quieres continuar?`;

		if (this.tipoAsignacion === 'Según disponibilidad' && !await LightningConfirm.open({
			variant: 'header', theme: 'alt-inverse', label: 'Programar cita', message: mensaje})) {
			return;
		}

		this.componente = {...this.componente, spinner: true};
		programarCitaApex({
			recordId: this.recordId, asignacionAuto,
			comprobarContacto: this.refs.inputComprobarContacto.checked,
			idPropietario: asignacionAuto ? null : this.idPropietarioSeleccionado,
			startDateTime: inputFecha.value
		}).then(() => {
			toast('success', 'Se programó cita', `Se programó una cita con el cliente para el ${fechaTexto.toUpperCase()}.`);
			notifyRecordUpdateAvailable([{recordId: this.recordId}]);
			this.modalCerrar();

		}).catch(error => {
			errorApex(this, error, 'Problema programando la cita');
			this.componente = {...this.componente, spinner: false};
		});
	}

	modalTeclaPulsada({keyCode}) {
		if (keyCode === 27 && this.refs.modalProgramarCita.classList.contains('slds-fade-in-open')) {
			this.modalCerrar();
		}
	}

	lwcDisponibilidadOnupdatecalendarios(event) {
		this.componente = {
			...this.componente,
			numCalendarios: event.detail.numCalendarios,
			lwcDisponibilidadWidth: event.detail.width
		};
	}

	lwcDisponibilidadOnupdatefecha({detail: {fecha}}) {
		this.refs.inputFecha.value = fecha.toISOString();
		// this.inputFechaValidarEsFechaFutura(fecha);
	}

	async lwcDisponibilidadOngestorseleccionado({detail: {fecha, idGestor, disponible}}) {
		const inputFecha = this.refs.inputFecha;
		const cambioFecha = inputFecha.value !== fecha.toISOString();
		inputFecha.value = fecha.toISOString();
		// this.inputFechaValidarEsFechaFutura(fecha);
		this.idPropietarioSeleccionado = idGestor;
		if (!disponible) {
			const mensaje = `${this.nombrePropietarioSeleccionado} no está disponible a la hora seleccionada.`;
			window.setTimeout(() => {
				this.refs.lineaSeparacion.classList.add('slds-hidden');
				inputFecha.setCustomValidity(mensaje);
				inputFecha.reportValidity();
			}, 100);
		} else {
			this.refs.lineaSeparacion.classList.remove('slds-hidden');
			inputFecha.setCustomValidity('');
			inputFecha.reportValidity();
		}

		if (cambioFecha) {
			await new Promise(resolve => {
				this.refs.inputFecha.addEventListener('animationend', () => {
					resolve();
					this.refs.inputFecha.removeEventListener('animationend', resolve);
				});
				this.refs.inputFecha.classList.add('seleccionado');
			});
			this.refs.inputFecha.classList.remove('seleccionado');
		}
	}

	inputPropietarioOnchange({detail: {recordId}}) {
		this.idPropietarioSeleccionado = recordId;
	}
}