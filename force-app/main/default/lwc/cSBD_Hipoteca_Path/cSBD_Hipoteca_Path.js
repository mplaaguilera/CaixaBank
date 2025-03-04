import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {errorApex} from 'c/csbd_lwcUtils';

import {getSubetapas} from './cSBD_Hipoteca_Path_Constantes.js';

import OPP_ID from '@salesforce/schema/Opportunity.Id';
import OPP_IDENTIFICADOR from '@salesforce/schema/Opportunity.CSBD_Identificador__c';
import OPP_ISCLOSED from '@salesforce/schema/Opportunity.IsClosed';
import OPP_STAGENAME from '@salesforce/schema/Opportunity.StageName';
import OPP_MOTIVO_PENDIENTE_INTERNO from '@salesforce/schema/Opportunity.CSBD_Motivo_Pendiente_Interno__c';
import OPP_CLIENTE_INTERNACIONAL from '@salesforce/schema/Opportunity.CSBD_Cliente_Internacional__c';

const OPP_FIELDS = [OPP_IDENTIFICADOR, OPP_ISCLOSED, OPP_STAGENAME, OPP_MOTIVO_PENDIENTE_INTERNO, OPP_CLIENTE_INTERNACIONAL];

export default class csbdHipotecaPath extends LightningElement {

	@api recordId;

	oportunidad;

	internacionalSeleccionado = false;

	etapaSeleccionada = '';

	subetapas;

	subetapaSeleccionada = '';

	subetapaSeleccionadaOnLastClick = '';

	mostrarSubetapas = false;

	@wire(getRecord, {recordId: '$recordId', fields: OPP_FIELDS})
	wiredRecord({error, data}) {
		if (data) {
			const getRecordInicial = !this.oportunidad;
			this.oportunidad = data;
			this.internacionalSeleccionado = getFieldValue(data, OPP_CLIENTE_INTERNACIONAL);
			this.etapaSeleccionada = getFieldValue(data, OPP_STAGENAME);
			this.subetapaSeleccionada = getFieldValue(data, OPP_MOTIVO_PENDIENTE_INTERNO) ?? '';
			this.actualizarSubetapas();

			const oportunidadCerrada = getFieldValue(data, OPP_ISCLOSED);
			this.mostrarSubetapas = !oportunidadCerrada;

			//Oculta las etapas finales excepto aquella cuyo data-etapa-value coincida con StageName
			this.template.querySelectorAll('.etapaFinal').forEach(subetapaFinal => {
				if (subetapaFinal.dataset.etapaValue !== (oportunidadCerrada ? getFieldValue(data, OPP_STAGENAME) : 'Cerrada')) {
					subetapaFinal.classList.add('slds-hide');
				} else {
					subetapaFinal.classList.remove('slds-hide');
				}
			});
			this.template.querySelectorAll('.toggleInternacional, .botonActualizar').forEach(item => item.disabled = oportunidadCerrada);

			//Scroll automático a la subetapa seleccionada
			getRecordInicial && window.setTimeout(() => {
				const stepSubetapaSeleccionada = this.template.querySelector(`lightning-progress-step[data-value="${this.subetapaSeleccionada}"]`);
				stepSubetapaSeleccionada && stepSubetapaSeleccionada.scrollIntoView({block: 'nearest', behavior: 'smooth'});
			}, 300);

		} else if (error) {
			errorApex(this, error, 'Problema obteniendo los datos de la oportunidad');
		}
	}

	toggleInternacionalOnchange(event) {
		this.internacionalSeleccionado = event.target.checked;
		this.actualizarSubetapas();
	}

	etapaOnclick(event) {
		if (!getFieldValue(this.oportunidad, OPP_ISCLOSED)) {
			this.mostrarSubetapas = !event.currentTarget.classList.contains('etapaFinal');
			this.actualizarSubetapas(event.currentTarget.dataset.etapaValue);
			this.etapaSeleccionada = event.currentTarget.dataset.etapaValue;
			this.template.querySelectorAll('.toggleInternacional, .botonActualizar').forEach(item => item.disabled = this.etapaSeleccionada === 'Cerrada');
			this.subetapaSeleccionada = this.subetapas[0].value;
			this.subetapaSeleccionadaOnLastClick = '';
		}
	}

	actualizarSubetapas(etapa = this.etapaSeleccionada) {
		if (['Cerrada', 'Rechazada', 'Formalizada', 'Perdida'].includes(etapa)) {
			this.subetapas = [];
		} else {
			this.subetapas = getSubetapas(etapa, this.internacionalSeleccionado);
		}
	}

	subetapaOnclick(event) {
		this.subetapaSeleccionada = event.target.value;
		this.subetapaSeleccionadaOnLastClick = event.target.value;
	}

	botonActualizarOnclick() {
		const botonActualizar = this.template.querySelector('.botonActualizar');

		if (!this.subetapaSeleccionadaOnLastClick) {
			this.mostrarToast('info', 'Es necesario seleccionar una subetapa', '');
		} else {
			botonActualizar.disabled = true;
			const fields = {};
			fields[OPP_ID.fieldApiName] = this.recordId;
			fields[OPP_STAGENAME.fieldApiName] = this.etapaSeleccionada;
			fields[OPP_MOTIVO_PENDIENTE_INTERNO.fieldApiName] = this.subetapaSeleccionada;
			fields[OPP_CLIENTE_INTERNACIONAL.fieldApiName] = this.internacionalSeleccionado;
			const recordInput = {fields};
			updateRecord(recordInput)
			.then(() => this.mostrarToast('success', 'Se actualizó Oportunidad', 'Se actualizó correctamente la etapa de la oportunidad ' + getFieldValue(this.oportunidad, OPP_IDENTIFICADOR)))
			.catch(error => errorApex(this, error, 'Problema actualizando la oportunidad'))
			.finally(() => botonActualizar.disabled = false);
		}
	}

	mostrarToast(variant, title, message) {
		this.dispatchEvent(new ShowToastEvent({variant: variant, title: title, message: message, mode: 'dismissable', duration: 4000}));
	}
}