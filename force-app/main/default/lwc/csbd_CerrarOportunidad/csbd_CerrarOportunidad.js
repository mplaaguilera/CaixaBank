import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue, notifyRecordUpdateAvailable} from 'lightning/uiRecordApi';
import {errorApex, publicarEvento, toast, transitionThenCallback} from 'c/csbd_lwcUtils';

import OPP_RT_DEVNAME from '@salesforce/schema/Opportunity.RecordType.DeveloperName';
import OPP_RT_NAME from '@salesforce/schema/Opportunity.RecordType.Name';
import OPP_CREATED_DATE from '@salesforce/schema/Opportunity.CreatedDate';
import OPP_CONTACT from '@salesforce/schema/Opportunity.CSBD_Contact__c';
import OPP_NO_IDENTIFICADO from '@salesforce/schema/Opportunity.CSBD_No_Identificado__c';
import OPP_PRODUCTO from '@salesforce/schema/Opportunity.CSBD_Producto__c';
import OPP_AMOUNT from '@salesforce/schema/Opportunity.Amount';
import OPP_MOTIVO_DEVOLUCION from '@salesforce/schema/Opportunity.CSBD_Motivo_Devolucion__c';

import cerrarOportunidadApex from '@salesforce/apex/CSBD_Opportunity_Operativas_Controller.cerrarOportunidad';
import obtenerOportunidadesHijasApex from '@salesforce/apex/CSBD_Opportunity_Operativas_Controller.obtenerOportunidadesHijas';
import obtenerResolucionesApex from '@salesforce/apex/CSBD_CerrarOportunidad_Apex.obtenerResoluciones';
import obtenerEntidadesCompetenciaApex from '@salesforce/apex/CSBD_Opportunity_Operativas_Controller.obtenerEntidades';

const OPP_FIELDS = [
	OPP_PRODUCTO, OPP_CONTACT, OPP_NO_IDENTIFICADO, OPP_RT_NAME,
	OPP_RT_DEVNAME, OPP_AMOUNT, OPP_MOTIVO_DEVOLUCION, OPP_CREATED_DATE
];

export default class csbdCerrarOportunidad extends LightningElement {

	modalAbierto = false;

	@api recordId;

	spinner = false;

	oportunidad;

	botonesEtapaMensajeError;

	resoluciones;

	inputResolucionOptions = [];

	entidadesCompetencia = [];

	etapaFinal = 'Formalizada';

	mensajeSinResoluciones = {texto: '', recordTypeName: '', etapaName: ''};

	/*get diasAbierta() {
		if (!this.oportunidad) {
			return 0;
		}
		const fechaCreacion = new Date(getFieldValue(this.oportunidad, OPP_CREATED_DATE));
		const fechaActual = new Date();
		const diferencia = fechaActual - fechaCreacion;
		return Math.floor(diferencia / (1000 * 60 * 60 * 24)) + 1;
	} */

	@wire(getRecord, {recordId: '$recordId', fields: OPP_FIELDS})
	wiredRecord({error, data: oportunidad}) {
		if (oportunidad) {
			const clienteIdentificado = Boolean(getFieldValue(oportunidad, OPP_CONTACT) || getFieldValue(oportunidad, OPP_NO_IDENTIFICADO));
			this.oportunidad = {...oportunidad, _clienteIdentificado: clienteIdentificado};
			this.refs.modalCerrarOportunidad.classList.toggle('clienteNoIdentificado', !clienteIdentificado);
			this.refs.botonFormalizada.disabled = !clienteIdentificado;
			this.refs.botonPerdida.disabled = !clienteIdentificado;
			!clienteIdentificado && this.cambiarEtapa('Rechazada');

			if (this.modalAbierto) {
				this.abrirModal();
			}
		} else if (error) {
			errorApex(this, error, 'Error recuperando los datos de la oportunidad');
		}
	}

	@api abrirModal() {
		try {
			const modalCerrarOportunidad = this.refs.modalCerrarOportunidad;
			if (modalCerrarOportunidad.classList.contains('slds-fade-in-open')) {
				return;
			}

			this.modalAbierto = true;
			if (!this.oportunidad) {
				return; //Si el getRecord no ha acabado, el modal se abrirá cuando acabe
			} else if (!getFieldValue(this.oportunidad, OPP_PRODUCTO)) {
				this.modalAbierto = false;
				toast('info', 'Oportunidad sin producto', 'Es necesario indicar el producto de la oportunidad para poder cerrarla');
				return;
			}

			//Abrir modal
			this.obtenerResoluciones();

			let botonActivo, elementoFocus;
			if (this.oportunidad._clienteIdentificado) {
				this.refs.botonPerdida.disabled = false;
				this.refs.botonRechazada.disabled = false;

				this.etapaFinal = 'Formalizada';
				botonActivo = this.refs.botonFormalizada;
				elementoFocus = botonActivo;
			} else {
				this.etapaFinal = 'Rechazada';
				botonActivo = this.refs.botonRechazada;
				elementoFocus = this.refs.inputResolucion;
			}
			botonActivo.disabled = false;
			botonActivo.classList.add('selected');

			this.etapaFinalValida();

			this.refs.backdropModal.classList.add('slds-backdrop_open');
			modalCerrarOportunidad.classList.remove('camposCompetencia', 'rechazadaDevolucionContact');
			modalCerrarOportunidad.addEventListener('transitionend', () => {
				modalCerrarOportunidad.classList.add('slds-fade-in-open');
				elementoFocus.focus();
			}, {once: true});
			publicarEvento(this, 'modalabierto', {nombreModal: 'modalCerrarOportunidad'});

		} catch (error) {
			errorApex(this, error, 'Problema al iniciar la operariva');
			this.modalCerrar();
		}
	}

	inputResolucionValido(resolucionNew) {
		const inputResolucion = this.refs.inputResolucion;
		if (!resolucionNew) {
			inputResolucion.setCustomValidity('Éste campo es requerido.');
			inputResolucion.reportValidity();
			return false;
		} else {
			inputResolucion.setCustomValidity('');
			inputResolucion.reportValidity();
			return true;
		}
	}

	inputResolucionOnchange(event) {
		const resolucionNew = event.currentTarget.value;
		if (!this.inputResolucionValido(resolucionNew)) {
			return;
		}

		const perdidaCompetencia = resolucionNew === 'Competencia' && getFieldValue(this.oportunidad, OPP_RT_DEVNAME) === 'CSBD_Hipoteca';
		if (perdidaCompetencia) {
			if (!this.entidadesCompetencia.length) {
				obtenerEntidadesCompetenciaApex()
				.then(entidadesCompetencia => {
					this.template.querySelector('.inputEntidadCompetencia').value = null;
					this.entidadesCompetencia = entidadesCompetencia.map(entidad => ({label: entidad, value: entidad}));
				}).catch(error => errorApex(this, error, 'Error obteniendo entidades'));
			}
		}

		this.mostrarOcultarCamposAdicionales();
	}

	inputMotivoRechazoOnchange() {
		this.refs.botonAceptar.disabled = false;
	}

	cerrarOportunidad() {
		//Validaciones
		const inputsList = ['.inputMotivoRechazo', '.inputTipoOfertado', '.inputEntidadCompetencia'];
		const ok = inputsList.reduce((validity, input) => {
			//Para cada input
			const inputElement = this.template.querySelector(input);
			if (inputElement) { //Muestra el mensaje de error si aplica y se actualiza el resultado acumulado
				inputElement.reportValidity();
				return validity && inputElement.validity.valid;
			}
			return validity; //Si el input no se muestra no afecta al resultado
		}, true) && this.inputResolucionValido(this.refs.inputResolucion.value) && !this.botonesEtapaMensajeError;

		if (ok) {
			//Actualizar oportunidad
			this.spinner = true;
			const resolucion = this.refs.inputResolucion.value;
			const perdidaCompetencia = resolucion === 'Competencia' && getFieldValue(this.oportunidad, OPP_RT_DEVNAME) === 'CSBD_Hipoteca';
			const campos = {
				'CSBD_TipoOfertado__c': perdidaCompetencia ? parseFloat(this.refs.inputTipoOfertado.value) : null,
				'CSBD_EntidadCompetencia__c': perdidaCompetencia ? this.refs.inputEntidadCompetencia.value : null,
				'CSBD_Motivo_Devolucion__c': this.refs.inputMotivoRechazo.value
			};

			cerrarOportunidadApex({
				recordId: this.recordId,
				nombreEtapaVentas: this.etapaFinal,
				resolucion,
				campos
			}).then(oportunidad => {
				notifyRecordUpdateAvailable([{recordId: this.recordId}]);
				toast('success', 'Se cerró oportunidad ' + oportunidad.CSBD_Identificador__c, 'La oportunidad se cerró correctamente');
				this.modalCerrar();
			}).catch(error => {
				errorApex(this, error, 'Problema cerrando la oportunidad');
				this.spinner = false;
			});
		}
	}

	etapaFinalValida() {
		this.botonesEtapaMensajeError = null;
		if (this.etapaFinal === 'Formalizada') {
			if (!getFieldValue(this.oportunidad, OPP_AMOUNT)) {
				this.botonesEtapaMensajeError = 'No se puede formalizar una oportunidad con importe 0€.';
			} else {
				obtenerOportunidadesHijasApex({idOportunidad: this.recordId})
				.then(abiertas => {
					if (abiertas) {
						this.botonesEtapaMensajeError = 'La oportunidad tiene acciones comerciales abiertas.';
					}
					this.refs.buttonGroupEtapas.classList.toggle('slds-has-error', this.botonesEtapaMensajeError);
				}).catch(error => errorApex(this, error, 'Error consultando acciones comerciales'));
			}
		}
		this.refs.buttonGroupEtapas.classList.toggle('slds-has-error', this.botonesEtapaMensajeError);
		return !this.botonesEtapaMensajeError;
	}

	botonEtapaOnclick({currentTarget}) {
		const etapaNew = currentTarget.dataset.etapa;
		if (etapaNew !== this.etapaFinal) {
			this.cambiarEtapa(etapaNew);
			currentTarget.classList.add('selected');
		}
	}

	cambiarEtapa(etapaNew) {
		const modalCerrarOportunidad = this.refs.modalCerrarOportunidad;
		modalCerrarOportunidad.classList.remove('perdidaCompetencia', 'rechazadaDevolucionContact');
		this.template.querySelectorAll('lightning-button-group lightning-button').forEach(b => b.classList.remove('selected'));

		const inputResolucion = this.refs.inputResolucion;
		inputResolucion.value = null;
		inputResolucion.setCustomValidity('');
		inputResolucion.reportValidity();
		this.etapaFinal = etapaNew;
		this.actualizarResoluciones(etapaNew);

		const esDesistimiento = getFieldValue(this.oportunidad, OPP_RT_DEVNAME) === 'CSBD_Desistimiento';
		if (esDesistimiento && etapaNew === 'Formalizada') {
			inputResolucion.value = 'Desistimiento realizado';
		} else if (esDesistimiento && etapaNew === 'Rechazada') {
			inputResolucion.value = 'Duplicada';
		} else if (this.inputResolucionOptions.length === 1) {
			inputResolucion.value = this.inputResolucionOptions[0].value;
		}
		this.etapaFinalValida() && this.mostrarOcultarCamposAdicionales();
	}

	actualizarResoluciones(etapaFinal) {
		const inputResolucion = this.refs.inputResolucion;
		inputResolucion.value = null;
		inputResolucion.setCustomValidity('');
		inputResolucion.reportValidity();
		const resoluciones = this.resoluciones ?? {};
		const inputResolucionOptions = resoluciones[etapaFinal]?.map(r => ({label: r, value: r})) || [];
		this.inputResolucionOptions = inputResolucionOptions;

		const sinResoluciones = !inputResolucionOptions.length;
		if (sinResoluciones) {
			this.mensajeSinResoluciones = {
				recordTypeName: getFieldValue(this.oportunidad, OPP_RT_NAME),
				producto: getFieldValue(this.oportunidad, OPP_PRODUCTO),
				etapaName: (etapaFinal + 's').toLowerCase()
			};
			const modalCerrarOportunidad = this.refs.modalCerrarOportunidad;
			if (!modalCerrarOportunidad.classList.contains('sinResoluciones')) {
				modalCerrarOportunidad.classList.remove('sinResoluciones');
				setTimeout(() => modalCerrarOportunidad.classList.add('sinResoluciones'), 0);
			}
		} else {
			this.refs.modalCerrarOportunidad.classList.remove('sinResoluciones');
			this.mensajeSinResoluciones = {texto: '', recordTypeName: '', etapaName: ''};
		}
	}

	mostrarOcultarCamposAdicionales() {
		const modalCerrarOportunidad = this.refs.modalCerrarOportunidad;
		const resolucion = this.refs.inputResolucion.value;

		const rechazadaDevolucionContact = resolucion === 'Devolución a contact' && getFieldValue(this.oportunidad, OPP_RT_DEVNAME) === 'CSBD_MAC';
		const perdidaCompetencia = resolucion === 'Competencia' && getFieldValue(this.oportunidad, OPP_RT_DEVNAME) === 'CSBD_Hipoteca';

		if (rechazadaDevolucionContact) {
			this.refs.camposDevolucionContact.classList.remove('slds-hide');
			modalCerrarOportunidad.classList.add('rechazadaDevolucionContact');
			setTimeout(() => this.refs.inputMotivoRechazo.focus(), 100);

		} else if (perdidaCompetencia) {
			this.refs.camposCompetencia.classList.remove('slds-hide');
			modalCerrarOportunidad.classList.add('perdidaCompetencia');
			this.refs.inputTipoOfertado.focus();

		} else {
			const modalCerrarOportunidadClases = modalCerrarOportunidad.classList;
			if (modalCerrarOportunidadClases.contains('perdidaCompetencia')
			|| modalCerrarOportunidadClases.contains('rechazadaDevolucionContact')) {
				modalCerrarOportunidad.addEventListener('transitionend', () => {
					this.refs.camposCompetencia.classList.add('slds-hide');
					this.refs.camposDevolucionContact.classList.add('slds-hide');
					setTimeout(() => this.refs.botonAceptar.focus(), 40);
				}, {once: true});
				modalCerrarOportunidad.classList.remove('perdidaCompetencia', 'rechazadaDevolucionContact');
			}
		}
	}

	async obtenerResoluciones() {
		if (this.resoluciones) {
			return;
		}

		obtenerResolucionesApex({
			producto: getFieldValue(this.oportunidad, OPP_PRODUCTO),
			nombreRecordType: getFieldValue(this.oportunidad, OPP_RT_NAME)
		}).then(resoluciones => {
			this.resoluciones = resoluciones;
			this.actualizarResoluciones(this.etapaFinal);
			const esDesistimiento = getFieldValue(this.oportunidad, OPP_RT_DEVNAME) === 'CSBD_Desistimiento';
			const inputResolucion = this.refs.inputResolucion;
			if (esDesistimiento && this.etapaFinal === 'Formalizada') {
				inputResolucion.value = 'Desistimiento realizado';
			} else if (esDesistimiento && this.etapaFinal === 'Rechazada') {
				inputResolucion.value = 'Duplicada';
			} else if (this.inputResolucionOptions.length === 1) {
				inputResolucion.value = this.inputResolucionOptions[0].value;
			}
			this.refs.modalCerrarOportunidad.classList.remove('cargando');
		}).catch(error => errorApex(this, error, 'Error obteniendo la lista deresoluciones'));
	}

	modalCerrar() {
		this.modalAbierto = false;
		transitionThenCallback(
			this.refs.modalCerrarOportunidad, 'slds-fade-in-open',
			() => publicarEvento(this, 'modalcerrado', {nombreModal: 'modalCerrarOportunidad'}),
			'opacity'
		);
		this.refs.backdropModal.classList.remove('slds-backdrop_open');
	}

	resetModal() {
		this.refs.modalCerrarOportunidad.classList.remove('camposCompetencia', 'rechazadaDevolucionContact');

		this.refs.inputResolucion.value = null;
		this.inputResolucionOptions = [];
		this.resoluciones = null;

		this.etapaFinal = 'Formalizada';

		const botonesEtapa = [this.refs.botonFormalizada, this.refs.botonPerdida, this.refs.botonRechazada];
		botonesEtapa.forEach(b => b.classList.remove('selected'));

		this.refs.botonFormalizada.diabled = true;
		this.refs.botonPerdida.disabled = true;
	}

	modalTeclaPulsada({keyCode}) {
		if (keyCode === 27 && !this.spinner
		&& this.refs.modalCerrarOportunidad.classList.contains('slds-fade-in-open')) {
			this.modalCerrar();
		}
	}
}