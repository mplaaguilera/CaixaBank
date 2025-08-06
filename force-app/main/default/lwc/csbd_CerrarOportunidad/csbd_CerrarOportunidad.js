import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue, notifyRecordUpdateAvailable} from 'lightning/uiRecordApi';
import {errorApex, publicarEvento, toast, transitionThenCallback} from 'c/csbd_lwcUtils';

import OPP_PRODUCTO from '@salesforce/schema/Opportunity.CSBD_Producto__c';
import OPP_CONTACT from '@salesforce/schema/Opportunity.CSBD_Contact__c';
import OPP_NO_IDENTIFICADO from '@salesforce/schema/Opportunity.CSBD_No_Identificado__c';
import OPP_RT_NAME from '@salesforce/schema/Opportunity.RecordType.Name';
import OPP_RT_DEVNAME from '@salesforce/schema/Opportunity.RecordType.DeveloperName';
import OPP_MOTIVO_CSCC from '@salesforce/schema/Opportunity.CSBD_Motivo_MAC__c';
import OPP_MOTIVO_DEVOLUCION from '@salesforce/schema/Opportunity.CSBD_Motivo_Devolucion__c';
import OPP_AMOUNT from '@salesforce/schema/Opportunity.Amount';

import cerrarOportunidadApex from '@salesforce/apex/CSBD_Opportunity_Operativas_Controller.cerrarOportunidad';
import obtenerOportunidadesHijasApex from '@salesforce/apex/CSBD_Opportunity_Operativas_Controller.obtenerOportunidadesHijas';
import obtenerResolucionesApex from '@salesforce/apex/CSBD_Opportunity_Operativas_Controller.obtenerResoluciones';
import obtenerEntidadesCompetenciaApex from '@salesforce/apex/CSBD_Opportunity_Operativas_Controller.obtenerEntidades';

const OPP_FIELDS = [OPP_PRODUCTO, OPP_CONTACT, OPP_NO_IDENTIFICADO, OPP_RT_NAME, OPP_RT_DEVNAME, OPP_AMOUNT, OPP_MOTIVO_CSCC, OPP_MOTIVO_DEVOLUCION];

export default class csbdCerrarOportunidad extends LightningElement {

	modalAbierto = false;

	spinner = false;

	@api recordId;

	oportunidad;

	cerrarEtapas = [];

	cerrarResoluciones = [];

	entidadesCompetencia = [];

	mostrarNotificacion = false;

	mostrarMotivoRechazo = false;

	mostrarTipoBonificado = false;

	@wire(getRecord, {recordId: '$recordId', fields: OPP_FIELDS})
	wiredRecord({error, data: oportunidad}) {
		if (oportunidad) {
			this.oportunidad = oportunidad;
			this.mostrarNotificacion = !getFieldValue(oportunidad, OPP_CONTACT) && !getFieldValue(oportunidad, OPP_NO_IDENTIFICADO);

			if (this.modalAbierto) {
				this.abrirModal();
			}
		} else if (error) {
			errorApex(this, error, 'Error recuperando los datos de la oportunidad');
		}
	}

	modalCerrar() {
		this.modalAbierto = false;
		this.refs.backdropModal.classList.remove('slds-backdrop_open');
		transitionThenCallback(
			this.refs.modalCerrarOportunidad,
			'slds-fade-in-open',
			() => publicarEvento(this, 'modalcerrado', {nombreModal: 'modalCerrarOportunidad'}),
			'opacity'
		);
	}

	modalTeclaPulsada({keyCode}) {
		if (keyCode === 27) {
			this.modalCerrar();
		}
	}

	@api abrirModal() {
		const modalCerrarOportunidad = this.refs.modalCerrarOportunidad;
		if (modalCerrarOportunidad.classList.contains('slds-fade-in-open')) {
			return;
		}
		this.modalAbierto = true;
		if (!this.oportunidad) {
			return; //Si el getRecord no ha acabado, el modal se abrirá cuando acabe
		} else if (!getFieldValue(this.oportunidad, OPP_PRODUCTO)) {
			notifyRecordUpdateAvailable([{recordId: this.recordId}]);
			this.modalAbierto = false;
			toast('info', 'Producto no informado', 'Es necesario informar el producto para poder cerrar la oportunidad');
			return;
		} else if (getFieldValue(this.oportunidad, OPP_RT_DEVNAME) === 'CSBD_MAC' && !getFieldValue(this.oportunidad, OPP_MOTIVO_CSCC)) {
			toast('info', 'Motivo CSCC no informado', 'Es necesario informar el motivo CSCC para poder cerrar la oportunidad');
			return;
		}

		//Preparar opciones del desplegable de etapas finales
		let etapasFinales = [{label: 'Rechazada', value: 'Rechazada'}];
		if (getFieldValue(this.oportunidad, 'Opportunity.CSBD_Contact__c') || getFieldValue(this.oportunidad, 'Opportunity.CSBD_No_Identificado__c')) {
			etapasFinales = [{label: 'Formalizada', value: 'Formalizada'}, {label: 'Perdida', value: 'Perdida'}, {label: 'Rechazada', value: 'Rechazada'}];
		}
		this.cerrarEtapas = etapasFinales;

		const inputEtapa = this.refs.inputEtapa;
		if (etapasFinales.length === 1) {
			inputEtapa.value = etapasFinales[0].value;
			this.inputEtapaOnchange();
		}

		this.refs.backdropModal.classList.add('slds-backdrop_open');
		modalCerrarOportunidad.classList.add('slds-fade-in-open');
		this.seleccionarControl(inputEtapa.value ? 'inputResolucion' : 'inputEtapa', 50);
	}

	inputEtapaOnchange() {
		const inputEtapa = this.template.querySelector('.inputEtapa');
		inputEtapa.setCustomValidity('');
		const etapa = inputEtapa.value;

		this.mostrarMotivoRechazo = false;

		if (etapa === 'Formalizada') {
			const recordType = getFieldValue(this.oportunidad, OPP_RT_DEVNAME);
			if (['CSBD_CMB', 'CSBD_CMN', 'CSBD_Hipoteca', 'CSBD_Prestamo', 'CSBD_Renting', 'CSBD_TPV'].includes(recordType)
			&& !getFieldValue(this.oportunidad, OPP_AMOUNT)) {
				inputEtapa.setCustomValidity('No se puede formalizar una oportunidad con importe 0€.');
				inputEtapa.reportValidity();
				//return;
			} else {
				obtenerOportunidadesHijasApex({idOportunidad: this.recordId})
				.then(abiertas => abiertas && inputEtapa.setCustomValidity('La oportunidad tiene acciones comerciales abiertas.'))
				.catch(error => errorApex(this, error, 'Error consultando acciones comerciales'));
			}
		}

		obtenerResolucionesApex({
			producto: getFieldValue(this.oportunidad, OPP_PRODUCTO),
			nombreRecordType: getFieldValue(this.oportunidad, OPP_RT_NAME),
			etapa
		}).then(resoluciones => {
			let inputResolucion =  this.template.querySelector('.inputResolucion');
			inputResolucion.value = null;
			this.cerrarResoluciones = resoluciones.map(resolucion => ({label: resolucion, value: resolucion}));

			const esDesistimiento = getFieldValue(this.oportunidad, OPP_RT_DEVNAME) === 'CSBD_Desistimiento';
			if (esDesistimiento && etapa === 'Formalizada') {
				inputResolucion.value = 'Desistimiento realizado';
			} else if (esDesistimiento && etapa === 'Rechazada') {
				inputResolucion.value = 'Duplicada';
			} else if (resoluciones.length === 1) {
				inputResolucion.value = resoluciones[0];
				if (resoluciones[0] === 'Devolución a contact' && getFieldValue(this.oportunidad, OPP_RT_DEVNAME) === 'CSBD_MAC') {
					this.mostrarMotivoRechazo = true;
					inputResolucion.reportValidity();
					this.seleccionarControl('inputMotivoRechazo', 40);
					//return;
				} else {
					this.mostrarMotivoRechazo = false;
					return;
				}
			}
			this.seleccionarControl('inputResolucion', 20);
		}).catch(error => errorApex(this, error, 'Error obteniendo la lista deresoluciones'));
	}

	inputResolucionOnchange() {
		this.mostrarMotivoRechazo = false;
		this.mostrarTipoBonificado = false;

		let resolucion = this.template.querySelector('.inputResolucion').value;
		if (resolucion === 'Competencia' && getFieldValue(this.oportunidad, OPP_RT_DEVNAME) === 'CSBD_Hipoteca') {
			obtenerEntidadesCompetenciaApex()
			.then(entidadesCompetencia => {
				this.template.querySelector('.inputEntidadCompetencia').value = null;
				this.entidadesCompetencia = entidadesCompetencia.map(entidad => ({label: entidad, value: entidad}));
			}).catch(error => errorApex(this, error, 'Error obteniendo entidades'));
			this.mostrarTipoBonificado = true;

		} else if (resolucion === 'Devolución a contact' && getFieldValue(this.oportunidad, OPP_RT_DEVNAME) === 'CSBD_MAC') {
			this.mostrarMotivoRechazo = true;
		}

		if (this.mostrarMotivoRechazo) {
			this.seleccionarControl('inputMotivoRechazo', 40);
		} else if (this.mostrarTipoBonificado) {
			this.seleccionarControl('inputTipoOfertado', 40);
		} else {
			this.seleccionarControl('botonAceptar', 40);
		}

	}

	cerrarOportunidad() {
		//Validaciones
		const inputsList = ['.inputEtapa', '.inputResolucion', '.inputMotivoRechazo', '.inputTipoOfertado', '.inputEntidadCompetencia'];
		const ok = inputsList.reduce((validity, input) => {
			//Para cada input
			const inputElement = this.template.querySelector(input);
			if (inputElement) { //Muestra el mensaje de error si aplica y se actualiza el resultado acumulado
				inputElement.reportValidity();
				return validity && inputElement.validity.valid;
			}
			return validity; //Si el input no se muestra no afecta al resultado
		}, true);

		if (ok) {
			this.spinner = true;
			//Actualizar oportunidad
			const inputTipoOfertado = this.refs.inputTipoOfertado;
			const inputEntidadCompetencia = this.refs.inputEntidadCompetencia;
			const campos = {
				'CSBD_TipoOfertado__c': inputTipoOfertado ? parseFloat(inputTipoOfertado.value) : null,
				'CSBD_EntidadCompetencia__c': inputEntidadCompetencia ? inputEntidadCompetencia.value : null
			};
			const inputMotivoRechazo = this.refs.inputMotivoRechazo;
			if (inputMotivoRechazo) {
				//eslint-disable-next-line camelcase
				campos.CSBD_Motivo_Devolucion__c = inputMotivoRechazo.value;
			}

			cerrarOportunidadApex({
				recordId: this.recordId,
				nombreEtapaVentas: this.refs.inputEtapa.value,
				resolucion: this.refs.inputResolucion.value,
				campos
			}).then(oportunidad => {
				toast('success', 'Se cerró oportunidad ' + oportunidad.CSBD_Identificador__c, 'La oportunidad se cerró correctamente');
				notifyRecordUpdateAvailable([{recordId: this.recordId}]);
				this.modalCerrar();
			}).catch(error => errorApex(this, error, 'Problema cerrando la oportunidad'))
			.finally(() => this.spinner = false);
		}
	}

	seleccionarControl(nombreControl, delay) {
		window.setTimeout(() => this.template.querySelector('.' + nombreControl).focus(), delay);
	}

}