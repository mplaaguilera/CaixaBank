import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import currentUserId from '@salesforce/user/Id';
import { publicarEvento, transitionThenCallback, toast, errorApex, usuarioDesarrollador } from 'c/csbd_lwcUtils';

import obtenerConfiguracionesApex from '@salesforce/apex/CSBD_CitaGestorController.obtenerConfiguraciones';
import obtenerDisponibilidadApex from '@salesforce/apex/CSBD_CitaGestorController.obtenerDisponibilidad';
import obtenerDisponibilidadLegoApex from '@salesforce/apex/CSBD_CitaGestorController.obtenerDisponibilidadLEGO';
import obtenerDisponibilidadAveApex from '@salesforce/apex/CSBD_CitaGestorController.obtenerDisponibilidadAVE';
import altaCitaGestorLegoApex from '@salesforce/apex/CSBD_CitaGestorController.altaCitaGestorLEGO';
import altaCitaGestorAveApex from '@salesforce/apex/CSBD_CitaGestorController.altaCitaGestorAVE';

import OPP_GESTOR_NAME from '@salesforce/schema/Opportunity.Account.AV_EAPGestor__r.Name';
import OPP_GESTOR_MATRICULA from '@salesforce/schema/Opportunity.Account.AV_EAPGestor__r.CC_Matricula__c';
import OPP_GESTOR_POOL from '@salesforce/schema/Opportunity.Account.AV_EAPGestor__r.AV_Pool__c';
import OPP_NUM_PERSO from '@salesforce/schema/Opportunity.Account.AV_NumPerso__c';
import OPP_NOMBRE_CUENTA from '@salesforce/schema/Opportunity.Account.Name';

const OPP_FIELDS = [OPP_GESTOR_NAME, OPP_GESTOR_MATRICULA, OPP_GESTOR_POOL, OPP_NUM_PERSO, OPP_NOMBRE_CUENTA];

export default class csbdProgramarCitaGestor extends LightningElement {

	@track componente = {
		usuarioDesarrollador: false,
		modalAbierto: false,
		spinner: false,
		spinnerDisponibilidad: false,
		tipoCitaOptions: [
			{ label: 'Presencial', value: '42' },
			{ label: 'Telefónica', value: '43' }
		],
		fechasOptions: {
			dias: [],
			horas: []
		}
	};

	@api recordId;

	oportunidad;

	disponibilidadPorFecha = {};

	tipoCitaSeleccionada;

	fechaSeleccionada;

	horaSeleccionada;

	@track gestorAve = {
		cargado: false, fullName: '', label: '', matricula: '', oficina: '', coincide: null
	};

	oficinasNoPresencialesAve;

	gestorLegoOficina;

	gestorPool = true;

	/*
	get mostrarBannerInfo() {
		return this.mostrarBannerGestor || this.mostrarBannerPool;
	}
	*/

	get mostrarBannerGestor() {
		return (!this.gestorPool && !this.gestorAve.coincide) && !this.componente.spinnerDisponibilidad;
	}

	get mostrarBannerPool() {
		return this.gestorPool && !this.componente.spinnerDisponibilidad;
	}

	get botonesDisabled() {
		return this.componente.spinner || this.componente.spinnerDisponibilidad;
	}

	@wire(getRecord, { recordId: '$recordId', fields: OPP_FIELDS })
	wiredRecord({ error, data: oportunidad }) {
		if (oportunidad) {
			this.gestorPool = getFieldValue(oportunidad, OPP_GESTOR_POOL); // ?? true;
			this.oportunidad = oportunidad;

			obtenerConfiguracionesApex({ esPool: this.gestorPool })
			.then(configuraciones => {
				const { tiposCita, tipoCitaDefault, oficinasNoPresenciales } = configuraciones;
				if (Object.keys(tiposCita).length) {
					this.componente.tipoCitaOptions = Object.entries(tiposCita).map(([value, label]) => ({ value, label }));
					this.tipoCitaSeleccionada = this.componente.tipoCitaOptions[0].value;
				} else {
					this.componente.tipoCitaOptions = [];
				}
				this.oficinasNoPresencialesAve = oficinasNoPresenciales;

				this.obtenerDisponibilidad(tipoCitaDefault);

				this.componente.modalAbierto && this.abrirModal();

			}).catch(error => {
				errorApex(this, error, 'Error al obtener los parámetros de la operativa');
				this.modalCerrar();
			});

		} else if (error) {
			errorApex(this, error, 'Error al obtener los datos de la oportunidad');
		}
	}

	async connectedCallback() {
		this.componente.usuarioDesarrollador = await usuarioDesarrollador(currentUserId);
	}

	async obtenerDisponibilidad(tipoCitaDefault) {
		this.componente = { ...this.componente, spinnerDisponibilidad: true };

		obtenerDisponibilidadApex({
			recordId: this.recordId,
			esPool: this.gestorPool,
			tipoCitaDefault
		}).then(result => {
			if (result.result === 'OK') {
				this.disponibilidadPorFecha = result.disponibilidadPorFecha;

				this.actualizarOpcionesFechasHoras();

				if (!this.gestorPool) {
					const oppMatriculaGestor = getFieldValue(this.oportunidad, OPP_GESTOR_MATRICULA);
					this.gestorAve = {
						cargado: true,
						fullName: `${result.name ?? ''} ${result.lastname || ''}`.trim(),
						matricula: result.matricula || '',
						oficina: result.gestorAVEOficina || '',
						coincide: result.matricula?.toUpperCase() == oppMatriculaGestor?.toUpperCase()
					};

					this.gestorAve.label = this.gestorAve.fullName || this.gestorAve.matricula;

					//La Oficina 3223 no admite cita presencial.
					if (this.oficinasNoPresencialesAve && this.oficinasNoPresencialesAve.includes(this.gestorAve.oficina)) {
						const tipoCitaTelefonica = this.componente.tipoCitaOptions.find(option => option.value === '43');
						if (tipoCitaTelefonica) {
							this.componente.tipoCitaOptions = [tipoCitaTelefonica];
							this.tipoCitaSeleccionada = tipoCitaTelefonica.value;
						}
					}

				} else {
					this.gestorLegoOficina = result.oficina;
				}
				this.componente.modalAbierto && this.abrirModal();

			} else {
				throw new Error(result.errorMessage);
			}
		})
		.catch(error => {
			errorApex(this, error, 'Problema obteniendo las fechas disponibles');
			this.modalCerrar();
		})
		.finally(() => {
			this.componente = { ...this.componente, spinnerDisponibilidad: false };
			requestAnimationFrame(() => {
				this.refs.inputFecha && this.refs.inputFecha.classList.remove('fadeOut');
				const inputHora = this.refs.inputHora;
				inputHora && inputHora.classList.remove('fadeOut');
			});
		});
	}

	async actualizarOpcionesFechasHoras() {
		// Transformar las fechas
		const dias = Object.keys(this.disponibilidadPorFecha).map(fecha => {
			const fechaObj = new Date(fecha);
			const opciones = { weekday: 'long', day: 'numeric', month: 'long' };
			let label = fechaObj.toLocaleDateString('es-ES', opciones);
			// Capitalizar primera letra del día y del mes
			label = label.split(' ').map((palabra, index) => {
				if (index === 0 || index === 3) { // día de la semana o mes
					return palabra.charAt(0).toUpperCase() + palabra.slice(1);
				}
				return palabra;
			}).join(' ');

			return { label, value: fecha };
		});

		// Ordenar las fechas
		dias.sort((a, b) => new Date(a.value) - new Date(b.value));

		// Actualizar las opciones de fechas
		this.componente.fechasOptions = { ...this.componente.fechasOptions, dias };
		const inputFecha = this.refs.inputFecha;
		inputFecha && inputFecha.classList.remove('fadeOut');

		// Si hay fechas disponibles, actualizar las horas con la primera fecha
		if (dias.length) {
			// Establecer la primera fecha como valor por defecto
			this.fechaSeleccionada = dias[0].value;
			this.actualizarHorasDisponibles(dias[0].value);
		}
	}

	actualizarHorasDisponibles(fecha) {
		const slots = this.disponibilidadPorFecha[fecha] || [];
		const horas = slots.map(slot => ({
			label: `${slot.horaInicio} - ${slot.horaFin}`,
			value: slot.horaInicio
		}));

		this.componente.fechasOptions = { ...this.componente.fechasOptions, horas };
		const inputHora = this.refs.inputHora;
		inputHora && inputHora.classList.remove('fadeOut');

		// Establecer la primera hora como valor por defecto si hay horas disponibles
		if (horas.length) {
			this.horaSeleccionada = horas[0].value;
		}
	}

	handleFechaChange({ detail: { value: fechaSeleccionada } }) {
		this.fechaSeleccionada = fechaSeleccionada;

		const inputHora = this.refs.inputHora;
		inputHora && transitionThenCallback(inputHora, 'fadeOut', () => {
			this.actualizarHorasDisponibles(fechaSeleccionada);
		}, 'opacity');
	}

	handleHoraChange({ detail: { value: horaSeleccionada } }) {
		this.horaSeleccionada = horaSeleccionada;
	}

	handleTipoCitaChange({ detail: { value: tipoCitaSeleccionada } }) {
		this.tipoCitaSeleccionada = tipoCitaSeleccionada;
		if (!this.gestorPool) {
			this.obtenerDisponibilidadAve();
		}
	}

	obtenerDisponibilidadLego() {
		//sustituir por fecha seleccionada si se pone un datepicker
		this.componente = { ...this.componente, spinnerDisponibilidad: true };
		let dateToday = new Date();
		let dateString = dateToday.getFullYear() + '-' +
			String(dateToday.getMonth() + 1).padStart(2, '0') + '-' +
			String(dateToday.getDate()).padStart(2, '0');

		obtenerDisponibilidadLegoApex({
			oficina: this.gestorLegoOficina,
			fecha: dateString
		}).then(result => {
			if (result.result === 'OK') {
				this.disponibilidadPorFecha = result.disponibilidadPorFecha;
				this.actualizarOpcionesFechasHoras();
			} else {
				errorApex(this, result.errorMessage, 'Problema obteniendo las fechas disponibles');
			}
		}).catch(error => errorApex(this, error, 'Error al obtener la disponibilidad'))
			.finally(() => this.componente = { ...this.componente, spinnerDisponibilidad: false });
	}

	obtenerDisponibilidadAve() {
		this.componente = { ...this.componente, spinnerDisponibilidad: true };
		obtenerDisponibilidadAveApex({
			matriculaGestorAVE: this.gestorAve.matricula,
			numPerso: getFieldValue(this.oportunidad, OPP_NUM_PERSO),
			tipoCita: this.tipoCitaSeleccionada,
		}).then(result => {
			if (result.result === 'OK') {
				this.disponibilidadPorFecha = result.disponibilidadPorFecha;
				this.actualizarOpcionesFechasHoras();
			} else {
				errorApex(this, result.errorMessage, 'Problema obteniendo las fechas disponibles');
			}
		}).catch(error => errorApex(this, error, 'Error al obtener la disponibilidad'))
			.finally(() => this.componente = { ...this.componente, spinnerDisponibilidad: false });
	}

	@api abrirModal() {
		const modalProgramarCitaGestor = this.refs.modalProgramarCitaGestor;
		if (modalProgramarCitaGestor.classList.contains('slds-fade-in-open')) {
			return;
		}

		this.componente.modalAbierto = true;
		if (!this.oportunidad) {
			return; //Si el getRecord no ha acabado, el modal se abrirá cuando acabe
		}

		this.refs.backdropModal.classList.add('slds-backdrop_open');
		transitionThenCallback(modalProgramarCitaGestor, 'slds-fade-in-open', () => {
			publicarEvento(this, 'modalabierto', { nombreModal: 'modalProgramarCitaGestor' });
			this.refs.inputTipoCita.focus();
		}, 'opacity');
	}

	modalCerrar() {
		transitionThenCallback(
			this.refs.modalProgramarCitaGestor, 'slds-fade-in-open',
			() => publicarEvento(this, 'modalcerrado', { nombreModal: 'modalProgramarCitaGestor' }),
			'opacity'
		);
		this.refs.backdropModal.classList.remove('slds-backdrop_open');
	}

	modalTeclaPulsada({ keyCode }) {
		if (keyCode === 27
			&& !this.componente.spinner
			&& this.refs.modalProgramarCitaGestor.classList.contains('slds-fade-in-open')) {
			this.modalCerrar();
		}
	}

	programarCitaGestor() {
		const { inputAsunto, inputFecha, inputHora } = this.refs;
		const ok = [inputAsunto, inputFecha, inputHora].reduce((ok, input) => {
			input.reportValidity();
			return ok && input.validity.valid;
		}, true);

		if (ok) {
			const horaLabel = this.componente.fechasOptions.horas.find(hora => hora.value === this.horaSeleccionada)?.label;
			this.componente = { ...this.componente, spinner: true };

			if (this.gestorPool) {
				// Alta cita LEGO
				const params = {
					numOficina: this.gestorLegoOficina,
					numPer: getFieldValue(this.oportunidad, OPP_NUM_PERSO),
					fechaSeleccionada: this.fechaSeleccionada,
					franjaSeleccionada: this.horaSeleccionada,
					asunto: inputAsunto.value,
					tipoCita: this.tipoCitaSeleccionada,
					recordId: this.recordId
				};

				altaCitaGestorLegoApex({ params })
					.then(result => {
						if (result.result === 'OK') {
							this.modalCerrar();
							toast('success', 'Se programó cita con el gestor', 'Se programó correctamente la cita con el gestor para el día ' + this.fechaSeleccionada + ' a las ' + horaLabel);
						} else {
							errorApex(this, result.errorMessage, 'Problema programando la cita');
						}
					})
					.catch(error => {
						errorApex(this, error, 'Error al programar la cita');
					})
					.finally(() => {
						this.componente = { ...this.componente, spinner: false };
					});
			} else {
				// Alta cita AVE
				const params = {
					empleadoEx: this.gestorAve.matricula.replace('U01', ''),
					centroEx: this.gestorAve.oficina,
					asunto: inputAsunto.value,
					fecContacto: this.fechaSeleccionada,
					horaIni: this.horaSeleccionada,
					medio: this.tipoCitaSeleccionada,
					numperso: getFieldValue(this.oportunidad, OPP_NUM_PERSO),
					accName: getFieldValue(this.oportunidad, OPP_NOMBRE_CUENTA),
					recordId: this.recordId,
					gestorMatricula: this.gestorAve.matricula,
				};

				altaCitaGestorAveApex({ params })
					.then(result => {
						if (result.result !== 'OK') {
							throw new Error(result.errorMessage);
						}
						this.modalCerrar();
						toast('success', 'Se programó cita con el gestor', 'Se programó correctamente la cita con el gestor para el día ' + this.fechaSeleccionada + ' a las ' + horaLabel);
					})
					.catch(error => errorApex(this, error, 'Error al programar la cita'))
					.finally(() => this.componente = { ...this.componente, spinner: false });
			}
		}
	}

// 	botonDebugOnclick() {
// 		console.log(JSON.stringify(this.gestorAve, null, 3));
// 	}
}