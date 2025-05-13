import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue, notifyRecordUpdateAvailable} from 'lightning/uiRecordApi';
import {errorApex, publicarEvento, toast, transitionThenCallback} from 'c/csbd_lwcUtils';

import reactivarOportunidadApex from '@salesforce/apex/CSBD_Opportunity_Operativas_Controller.reactivarOportunidad';

import OPP_IDENTIFICADOR from '@salesforce/schema/Opportunity.CSBD_Identificador__c';
import OPP_ULTIMA_ETAPA_VENTAS from '@salesforce/schema/Opportunity.CSBD_Ultima_Etapa_Ventas__c';

export default class csbdReactivarOportunidad extends LightningElement {
	@api recordId;

	oportunidad = {_ultimaEtapaVentas: null};

	spinner = false;

	reactivarEtapas = [
		{label: 'Solicitud', value: 'Solicitud'},
		{label: 'Gestión', value: 'Gestión'},
		{label: 'Documentación', value: 'Documentación'},
		{label: 'Estudio económico', value: 'Estudio económico'},
		{label: 'Firma', value: 'Firma'}
	];

	@wire(getRecord, {recordId: '$recordId', fields: [OPP_ULTIMA_ETAPA_VENTAS, OPP_IDENTIFICADOR]})
	wiredOpportunity({error, data: oportunidad}) {
		if (oportunidad) {
			const ultimaEtapaVentas = getFieldValue(oportunidad, OPP_ULTIMA_ETAPA_VENTAS);
			this.oportunidad = {...oportunidad, _ultimaEtapaVentas: ultimaEtapaVentas};
			this.refs.inputReactivarEtapa.value = ultimaEtapaVentas;
		} else if (error) {
			errorApex(this, error, 'Problema recuperando la oportunidad');
		}
	}

	@api abrirModal() {
		this.refs.backdropModal.classList.add('slds-backdrop_open');
		this.refs.modalReactivarOportunidad.classList.add('slds-fade-in-open');
		window.setTimeout(() => this.refs.botonCancelar.focus(), 90);
		publicarEvento(this, 'modalabierto', {nombreModal: 'modalReactivarOportunidad'});
	}

	modalCerrar() {
		transitionThenCallback(
			this.refs.modalReactivarOportunidad, 'slds-fade-in-open',
			() => publicarEvento(this, 'modalcerrado', {nombreModal: 'modalReactivarOportunidad'}),
			'opacity'
		);
		this.refs.backdropModal.classList.remove('slds-backdrop_open');
	}

	reactivarOportunidad() {
		let inputReactivarEtapa = this.refs.inputReactivarEtapa;
		inputReactivarEtapa.reportValidity();

		if (inputReactivarEtapa.validity.valid) {
			this.spinner = true;
			reactivarOportunidadApex({recordId: this.recordId, nombreEtapaVentas: inputReactivarEtapa.value})
			.then(() => {
				notifyRecordUpdateAvailable([{recordId: this.recordId}]);
				toast('success', 'Se reactivó oportunidad ' + getFieldValue(this.oportunidad, OPP_IDENTIFICADOR), 'La oportunidad se reactivó satisfactoriamente.');
				this.modalCerrar();
			}).catch(error => errorApex(this, error, 'Problema reactivando la oportunidad'))
			.finally(() => this.spinner = false);
		}
	}

	modalTeclaPulsada({keyCode}) {
		if (keyCode === 27 && !this.spinner && this.refs.modalReactivarOportunidad.classList.contains('slds-fade-in-open')) {
			this.modalCerrar();
		}
	}
}