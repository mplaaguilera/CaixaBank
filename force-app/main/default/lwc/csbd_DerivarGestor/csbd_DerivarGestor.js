import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {errorApex, publicarEvento, toast} from 'c/csbd_lwcUtils';

import crearOportunidadGestor from '@salesforce/apex/CSBD_Opportunity_Operativas_Controller.crearTareaGestor';
import cerrarOportunidad from '@salesforce/apex/CSBD_Opportunity_Operativas_Controller.cerrarOportunidad';

import OPP_GESTOR_NAME from '@salesforce/schema/Opportunity.Account.AV_EAPGestor__r.Name';
import OPP_PRODUCTO_PF from '@salesforce/schema/Opportunity.AV_PF__c';
import OPP_DESCRIPTION from '@salesforce/schema/Opportunity.Description';
import OPP_NUM_GESTOR from '@salesforce/schema/Opportunity.Account.AV_EAPGestor__r.CC_Matricula__c';
import OPP_ID_GESTOR from '@salesforce/schema/Opportunity.Account.AV_EAPGestor__c';
import OPP_IDENTIFICADOR from '@salesforce/schema/Opportunity.CSBD_Identificador__c';

const OPP_FIELDS_GETRECORD = [OPP_GESTOR_NAME, OPP_PRODUCTO_PF, OPP_DESCRIPTION, OPP_NUM_GESTOR, OPP_ID_GESTOR];

export default class csbdDerivarGestor extends LightningElement {

	modalAbierto = false;

	@api recordId;

	oportunidad;

	cargandoGestor = false;

	nombreGestor;

	@wire(getRecord, {recordId: '$recordId', fields: OPP_FIELDS_GETRECORD})
	wiredRecord({error, data: oportunidad}) {
		if (oportunidad) {
			this.oportunidad = oportunidad;
			this.nombreGestor = getFieldValue(oportunidad, OPP_GESTOR_NAME);

			if (this.modalAbierto) {
				this.abrirModal();
			}
		} else if (error) {
			errorApex(this, error, 'Error recuperando los datos de la oportunidad');
		}
	}

	@api abrirModal() {
		const modalDerivarGestor = this.refs.modalDerivarGestor;
		if (modalDerivarGestor.classList.contains('slds-fade-in-open')) {
			return;
		}
		this.modalAbierto = true;
		if (!this.oportunidad) {
			return; //Si el getRecord no ha acabado, el modal se abrirá cuando acabe
		}

		this.template.querySelector('.comentariosTarea').value = getFieldValue(this.oportunidad, OPP_DESCRIPTION);
		if (getFieldValue(this.oportunidad, OPP_PRODUCTO_PF)) {
			this.refs.backdropModal.classList.add('slds-backdrop_open');
			modalDerivarGestor.classList.add('slds-fade-in-open');
			window.setTimeout(() => this.refs.botonCancelar.focus(), 50);
		} else {
			toast('info', 'Operativa no disponible', 'La oportunidad no se puede derivar a gestor porque no tiene producto PF');
		}
	}

	modalCerrar() {
		this.refs.modalDerivarGestor.addEventListener('transitionend', () => {
			publicarEvento(this, 'modalcerrado', {nombreModal: 'modalDerivarGestor'});
		}, {once: true});
		this.refs.modalDerivarGestor.classList.remove('slds-fade-in-open');
		this.refs.backdropModal.classList.remove('slds-backdrop_open');
	}

	modalTeclaPulsada({keyCode}) {
		keyCode === 27 && this.modalCerrar();
	}

	crearOportunidadGestor() {
		const comentariosTarea = this.template.querySelector('.comentariosTarea').value;
		if (!comentariosTarea) {
			this.template.querySelector('.comentariosTarea').reportValidity();
			return;
		}

		this.cargandoGestor = true;
		crearOportunidadGestor({
			recordId: this.recordId,
			numeroGestor: getFieldValue(this.oportunidad, OPP_NUM_GESTOR),
			idGestor: getFieldValue(this.oportunidad, OPP_ID_GESTOR),
			comentarios: comentariosTarea
		}).then(() => {
			toast('success', 'Oportunidad para el gestor creada con éxito', 'Podrá localizar la oportunidad en la ficha del cliente');

			cerrarOportunidad({
				recordId: this.recordId,
				nombreEtapaVentas: 'Perdida',
				resolucion: 'Traslado a oficina'
			}).then(() => {
				toast('info', `Oportunidad ${getFieldValue(this.oportunidad, OPP_IDENTIFICADOR)} cerrada con éxito`, 'La oportunidad se cerró como Perdida');
				this.modalCerrar();
				//Recargar el registro de la oportunidad
				this.template.querySelector('lightning-record-view-form').reloadRecord();
			}).catch(error => errorApex(this, error, 'Error cerrando la oportunidad'))
			.finally(() => this.cargandoGestor = false);

		}).catch(error => {
			errorApex(this, error, 'Error creando la oportunidad para el gestor');
			this.cargandoGestor = false;
		});
	}
}