/*eslint no-console: ["error", { allow: ["warn", "error"] }] */
import {LightningElement, track, api, wire} from 'lwc';
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';

//campos
import RESUMEN_OPORTUNIDAD from '@salesforce/schema/Opportunity.CSBD_GptResumenInicialRich__c';
import INSTRUCCIONES_GPT from '@salesforce/schema/Opportunity.CSBD_InstruccionesGPT__c';
import ID_FIELD from '@salesforce/schema/Opportunity.Id';
import REFRESCOSOPORTUNIDAD from '@salesforce/schema/Opportunity.CSBD_GPTRefrescosOportunidad__c';

//apex
import resolverPrompt from '@salesforce/apex/CSBD_ChatGPT_Controller.resolverPrompt';

import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class csbdTestRopp extends LightningElement {
	@api recordId;

	@api planOpo;

	@api planAmpli;

	@track isLoadingOpp;

	@track muestraCopiaOpp = false;

	@track copiaResOpp = null;

	primerRender = true;

	@wire (getRecord, {recordId: '$recordId', fields: [RESUMEN_OPORTUNIDAD, INSTRUCCIONES_GPT, REFRESCOSOPORTUNIDAD]}) resumen;


	get resumenOportunidad() {
		return getFieldValue(this.resumen.data, RESUMEN_OPORTUNIDAD);
	}

	get intruccionesGPT() {
		return getFieldValue(this.resumen.data, INSTRUCCIONES_GPT);
	}

	get refrescosOportunidad() {
		return getFieldValue(this.resumen.data, REFRESCOSOPORTUNIDAD);
	}

	renderedCallback() {
		if (this.primerRender && typeof this.resumen.data !== 'undefined' && !this.resumenOportunidad) {
			this.primerRender = false;
			this.handleRefrescarOpp();
		}
		if (this.muestraCopiaOpp && this.resumenOportunidad) {
			this.muestraCopiaOpp = false;
		}
	}

	handleRefrescarOpp() {
		this.isLoadingOpp = true;
		resolverPrompt({oppId: this.recordId, apiPrompt: this.planOpo})
			.then(response => {
				response = this.limpiarRespuesta(response);
				const fields = {};
				fields[RESUMEN_OPORTUNIDAD.fieldApiName] = response;
				fields[ID_FIELD.fieldApiName] = this.recordId;
				fields[REFRESCOSOPORTUNIDAD.fieldApiName] = this.refrescosOportunidad === null ? 1 : this.refrescosOportunidad + 1;
				const recordInput = {fields};
				updateRecord(recordInput);
				//guardar el valor generado para mostrarlo mientras se hace el update
				this.copiaResOpp = response;
				this.muestraCopiaOpp = true;
				this.notifyUser('Éxito', 'Refresco del resumen realizado', 'success');
				this.isLoadingOpp = false;
			})
			.catch(error => {
				console.error('Error refrescando el resumen de la oportunidad', error);
				this.notifyUser('Error', 'Error refrescando el resumen de la oportunidad', 'error');
				this.isLoadingOpp = false;
			});
	}

	handleSubmitOpp(event) {
		event.preventDefault();       //stop the form from submitting
		this.isLoadingOpp = true;
		const fields = event.detail.fields;
		//si ha cambiado las instrucciones, hay que hacer un update
		if (fields.CSBD_InstruccionesGPT__c !== this.intruccionesGPT) {
			//console.log("actualizar instrucciones");
			this.template.querySelector('lightning-record-edit-form').submit(fields);
		}
		//si las instrucciones estan vacias hacer un refresh del resumen
		if (fields.CSBD_InstruccionesGPT__c === null || fields.CSBD_InstruccionesGPT__c === '') {
			//console.log("refresh");
			this.handleRefrescarOpp();
		} else {
			//console.log("ampliacion");
			//si no estan vacias hay que hacer la ampliacion del resumen
			resolverPrompt({oppId: this.recordId, apiPrompt: this.planAmpli})
			.then(response => {
				response = this.limpiarRespuesta(response);
				const fields = {};
				fields[RESUMEN_OPORTUNIDAD.fieldApiName] = response;
				fields[ID_FIELD.fieldApiName] = this.recordId;

				fields[REFRESCOSOPORTUNIDAD.fieldApiName] = this.refrescosOportunidad === null ? 1 : this.refrescosOportunidad + 1;
				const recordInput = {fields};
				updateRecord(recordInput);
				this.notifyUser('Éxito', 'Ampliacion resumen realizada', 'success');
				this.isLoadingOpp = false;
			})
			.catch(error => {
				console.error('Error ampliando el resumen', error);
				this.notifyUser('Error', 'Error ampliando el resumen', 'error');
				this.isLoadingOpp = false;
			});
		}
	}

	notifyUser(title, message, variant) {
		if (this.notifyViaAlerts) {
			//Notify via alert
			//eslint-disable-next-line no-alert
			alert(`${title}\n${message}`);
		} else {
			//Notify via toast
			const toastEvent = new ShowToastEvent({title, message, variant});
			this.dispatchEvent(toastEvent);
		}
	}

	//en ocasiones open IA encabeza los mensajes con tags html de esta manera
	limpiarRespuesta(response) {
		//quitar comas invertidas y html
		return response.replace(/```html|```/g, '').trim();
	}
}