import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue, notifyRecordUpdateAvailable} from 'lightning/uiRecordApi';
import {errorApex, publicarEvento, toast, transitionThenCallback} from 'c/csbd_lwcUtils';

import crearOportunidadGestor from '@salesforce/apex/CSBD_Opportunity_Operativas_Controller.crearTareaGestor';
import cerrarOportunidad from '@salesforce/apex/CSBD_Opportunity_Operativas_Controller.cerrarOportunidad';

import OPP_GESTOR_NAME from '@salesforce/schema/Opportunity.Account.AV_EAPGestor__r.Name';
import OPP_PRODUCTO_PF from '@salesforce/schema/Opportunity.AV_PF__c';
import OPP_DESCRIPTION from '@salesforce/schema/Opportunity.Description';
import OPP_NUM_GESTOR from '@salesforce/schema/Opportunity.Account.AV_EAPGestor__r.CC_Matricula__c';
import OPP_ID_GESTOR from '@salesforce/schema/Opportunity.Account.AV_EAPGestor__c';
import OPP_IDENTIFICADOR from '@salesforce/schema/Opportunity.CSBD_Identificador__c';

const OPP_FIELDS_GETRECORD = [OPP_GESTOR_NAME, OPP_PRODUCTO_PF, OPP_DESCRIPTION, OPP_NUM_GESTOR, OPP_ID_GESTOR, OPP_IDENTIFICADOR];

export default class csbdDerivarGestor extends LightningElement {

	modalAbierto = false;

	@api recordId;

	oportunidad;

	cargandoGestor = false;

	@wire(getRecord, {recordId: '$recordId', fields: OPP_FIELDS_GETRECORD})
	wiredRecord({error, data: oportunidad}) {
		if (oportunidad) {
			let _nombreGestor = getFieldValue(oportunidad, OPP_GESTOR_NAME);
			if (_nombreGestor === 'No asignado') {
				_nombreGestor = null;
			}
			this.oportunidad = {...oportunidad, _nombreGestor};
			this.modalAbierto && this.abrirModal();

		} else if (error) {
			errorApex(this, error, 'Problema recuperando los datos de la oportunidad');
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

		if (!getFieldValue(this.oportunidad, OPP_PRODUCTO_PF)) {
			toast('info', 'Operativa no disponible', 'La oportunidad no se puede derivar a un gestor porque no tiene producto PF');
		} else {
			this.refs.inputComentarios.value = getFieldValue(this.oportunidad, OPP_DESCRIPTION);

			this.refs.backdropModal.classList.add('slds-backdrop_open');
			transitionThenCallback(modalDerivarGestor, 'slds-fade-in-open', () => {
				this.refs.inputComentarios.focus();
				publicarEvento(this, 'modalabierto', {nombreModal: 'modalDerivarGestor'});
			}, 'opacity');
		}
	}

	modalCerrar() {
		transitionThenCallback(
			this.refs.modalDerivarGestor, 'slds-fade-in-open',
			() => publicarEvento(this, 'modalcerrado', {nombreModal: 'modalDerivarGestor'}),
			'opacity'
		);
		this.refs.backdropModal.classList.remove('slds-backdrop_open');
	}

	modalTeclaPulsada({keyCode}) {
		if (keyCode === 27 && this.refs.modalDerivarGestor.classList.contains('slds-fade-in-open')) {
			this.modalCerrar();
		}
	}

	crearOportunidadGestor() {
		const comentariosTarea = this.template.querySelector('.comentariosTarea').value;
		if (!comentariosTarea) {
			this.template.querySelector('.comentariosTarea').reportValidity();
			return;
		}

		this.cargandoGestor = true;

		const conGestorAsignado = (getFieldValue(this.oportunidad, OPP_GESTOR_NAME) ?? 'No asignado') !== 'No asignado';
		crearOportunidadGestor({
			recordId: this.recordId,
			numeroGestor: conGestorAsignado ? getFieldValue(this.oportunidad, OPP_NUM_GESTOR) : null,
			idGestor: conGestorAsignado ? getFieldValue(this.oportunidad, OPP_ID_GESTOR) : null,
			comentarios: comentariosTarea
		}).then(() => {
			toast('success', 'Oportunidad para el gestor creada con éxito', 'Puedes ver la nueva oportunidad en la ficha del cliente');
			cerrarOportunidad({recordId: this.recordId, nombreEtapaVentas: 'Perdida', resolucion: 'Traslado a oficina'}).then(() => {
				notifyRecordUpdateAvailable([{recordId: this.recordId}]);
				toast('info', `Oportunidad ${getFieldValue(this.oportunidad, OPP_IDENTIFICADOR)} cerrada con éxito`, 'La oportunidad se cerró como Perdida');
				this.modalCerrar();
			}).catch(error => errorApex(this, error, 'Error cerrando la oportunidad'))
			.finally(() => this.cargandoGestor = false);

		}).catch(error => {
			errorApex(this, error, 'Error creando la oportunidad para el gestor');
			this.cargandoGestor = false;
		});
	}
}