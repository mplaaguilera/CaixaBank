import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue, notifyRecordUpdateAvailable} from 'lightning/uiRecordApi';
import {errorApex, publicarEvento, toast, transitionThenCallback} from 'c/csbd_lwcUtils';
import desprogramarCitaApex from '@salesforce/apex/CSBD_Opportunity_Operativas_Controller.desprogramarCita';

import OPP_ACCOUNT_NAME from '@salesforce/schema/Opportunity.Account.Name';
import OPP_FECHA_CITA from '@salesforce/schema/Opportunity.CSBD_Fecha_Cita__c';

export default class csbdDesprogramarCita extends LightningElement {

	@api recordId;

	accountName;

	fechaCita;

	modalAbierto = false;

	spinner = false;

	@wire(getRecord, {recordId: '$recordId', fields: [OPP_ACCOUNT_NAME, OPP_FECHA_CITA]})
	wiredOpportunity({error, data: oportunidad}) {
		if (error) {
			errorApex(this, error, 'Problema recuperando la oportunidad');
		} else if (oportunidad) {
			this.accountName = getFieldValue(oportunidad, OPP_ACCOUNT_NAME);
			this.fechaCita = getFieldValue(oportunidad, OPP_FECHA_CITA);
		}
	}

	@api abrirModal() {
		this.refs.backdropModal.classList.add('slds-backdrop_open');
		this.refs.modalDesprogramarCita.classList.add('slds-fade-in-open');
		window.setTimeout(() => this.refs.botonCancelar.focus(), 90);
		publicarEvento(this, 'modalabierto', {nombreModal: 'modalDesprogramarCita'});
	}

	modalCerrar() {
		transitionThenCallback(
			this.refs.modalDesprogramarCita, 'slds-fade-in-open',
			() => publicarEvento(this, 'modalcerrado', {nombreModal: 'modalDesprogramarCita'}),
			'opacity'
		);
		this.refs.backdropModal.classList.remove('slds-backdrop_open');
	}

	modalTeclaPulsada({keyCode}) {
		if (keyCode === 27 && this.refs.modalDesprogramarCita.classList.contains('slds-fade-in-open')) {
			this.modalCerrar();
		}
	}

	desprogramarCita() {
		this.spinner = true;
		desprogramarCitaApex({recordId: this.recordId})
		.then(eventoDesprogramado => {
			if (eventoDesprogramado) {
				notifyRecordUpdateAvailable([{recordId: this.recordId}]);
				let fecha = new Date(eventoDesprogramado.StartDateTime);
				let fechaTexto = fecha.toLocaleDateString('es-ES', {weekday: 'long', month: 'long', day: 'numeric'});
				fechaTexto += ` a las ${fecha.getHours().toString().padStart(2, '0')}:${fecha.getMinutes().toString().padStart(2, '0')}`;
				toast('success', 'Se desprogramó cita', `Se ha cancelado la cita para el  ${fechaTexto.toUpperCase()}.`);
			} else {
				toast('info', 'Sin citas programadas', 'No existían citas pendientes con el cliente que cancelar.');
			}
			this.modalCerrar();
		}).catch(error => errorApex(this, error, 'Problema desprogramando la cita'))
		.finally(() => {
			this.spinner = false;
		});
	}
}