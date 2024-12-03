import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';
import currentUserId from '@salesforce/user/Id';
import {RefreshEvent} from 'lightning/refresh';
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import generarDocumentoApex from '@salesforce/apex/CC_GenerarDocumento_Controller.generarDocumento';
import getVisualforceHostnameApex from '@salesforce/apex/CC_GenerarDocumento_Controller.getVisualforceHostname';

import CASE_OWNER_ID from '@salesforce/schema/Case.OwnerId';
import CASE_HTML_DOC from '@salesforce/schema/Case.CC_GenerarDocumentoHtml__c';
import CASE_HEADER from '@salesforce/schema/Case.CC_Header__c';
import CASE_FOOTER from '@salesforce/schema/Case.CC_Footer__c';


//eslint-disable-next-line new-cap
export default class ccGenerarDocumento extends NavigationMixin(LightningElement) {

	@api recordId;

	botonAbrirModalDisabled = true;

	formats = [
		'font', 'size', 'bold', 'italic', 'underline', 'strike', 'list', 'indent',
		'align', 'link', 'image', 'clean', 'table', 'header', 'color', 'background'
	];

	visualforceHostname;

	rutaVisualforce;

	spinnerExportarPdf = false;

	spinnerGenerarVistaPrevia = false;

	cuerpo;

	header;

	footer;

	plantillaId;

	@wire(getRecord, {recordId: '$recordId', fields: [CASE_OWNER_ID, CASE_HTML_DOC, CASE_HEADER, CASE_FOOTER]})
	wiredDatos({data, error}) {
		if (data) {
			this.botonAbrirModalDisabled = getFieldValue(data, CASE_OWNER_ID) !== currentUserId;
			this.cuerpo = getFieldValue(data, CASE_HTML_DOC)?.trim();
			this.header = getFieldValue(data, CASE_HEADER)?.trim();
			this.footer = getFieldValue(data, CASE_FOOTER)?.trim();
			this.abrirModalX();
		} else if (error) {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos del caso.', error.body.message);
		}
	}

	abrirModalX() {
		this.template.querySelector('.backdrop').classList.add('slds-backdrop_open');
		this.template.querySelector('.modalGenerarDocumento').classList.add('slds-fade-in-open');
	}


	@api abrirModal() {
		this.refs.backdropModal.classList.add('slds-backdrop_open');
		this.refs.modalGenerarDocumento.classList.add('slds-fade-in-open');
	}

	cerrarModal() {
		this.template.querySelector('.modalGenerarDocumento').classList.remove('slds-fade-in-open');
		this.template.querySelector('.backdrop').classList.remove('slds-backdrop_open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('modalcerrado', {detail: {data: null}})), 400);
	}

	inputCuerpoOnchange(event) {
		this.cuerpo = event.detail.value;
		this.template.querySelector('.botonGenerarPdf').disabled = true;
		const spanPrevisualizacionDesactualizada = this.template.querySelector('.spanPrevisualizacionDesactualizada');
		if (spanPrevisualizacionDesactualizada) {
			spanPrevisualizacionDesactualizada.classList.add('visible');
		}
	}
	

	async generarVistaPrevia(event) {
		const spanPrevisualizacionDesactualizada = this.template.querySelector('.spanPrevisualizacionDesactualizada');
		if (spanPrevisualizacionDesactualizada) {
			spanPrevisualizacionDesactualizada.classList.remove('visible');
		}
		this.spinnerGenerarVistaPrevia = true;
		const botonVistaPrevia = event.currentTarget;
		const botonGenerarPdf = this.template.querySelector('.botonGenerarPdf');
		botonVistaPrevia.disabled = true;
		botonGenerarPdf.disabled = true;
		const fieldsCase = {};
		fieldsCase.Id = this.recordId;
		fieldsCase[CASE_HTML_DOC.fieldApiName] = this.cuerpo;
		fieldsCase[CASE_HEADER.fieldApiName] = this.header;
		fieldsCase[CASE_FOOTER.fieldApiName] = this.footer;
		console.log('NMAAAA this.header: '+this.header);
		console.log('NMAAAA this.footer: '+this.footer);
		updateRecord({fields: fieldsCase})
		.then(async () => {
			this.rutaVisualforce = await this.getrutaVisualforce();
			botonGenerarPdf.disabled = false;
		}).finally(() => {
			botonVistaPrevia.disabled = false;
			this.spinnerGenerarVistaPrevia = false;
		});
	}

	exportarPdf(event) {
		this.spinnerExportarPdf = true;
		const botonVistaPrevia = this.template.querySelector('.botonVistaPrevia');
		botonVistaPrevia.disabled = true;
		event.currentTarget.disabled = true;
		generarDocumentoApex({recordId: this.recordId, plantillaId: this.plantillaId})
		.then(documento => {
			this.dispatchEvent(new RefreshEvent());
			this.verFile(documento.ContentDocumentId);
			this.toast('success', 'Se creó documento', 'Se creó correctamente el documento "' + documento.Title + '"');
			this.cerrarModal();
		}).catch(error => {
			console.error(error);
			this.toast('error', 'Error al generar el documento', error);
		}).finally(() => {
			botonVistaPrevia.disabled = false;
			this.spinnerExportarPdf = false;
		});
	}

	modalPlantillasAbierto() {
		this.template.querySelector('.modalGenerarDocumento').classList.add('slds-hidden');
	}

	modalPlantillasCerrado() {
		this.template.querySelector('.modalGenerarDocumento').classList.remove('slds-hidden');
	}

	modalPlantillasSeleccionada(event) {
		this.template.querySelector('.botonGenerarPdf').disabled = true;
		this.cuerpo = event.detail.cuerpo;
		console.log('event.detail.cuerpo;: '+event.detail.cuerpo);
		this.header = event.detail.header;
		console.log('event.detail.cabecera;: '+event.detail.header);
		this.footer = event.detail.footer;
		console.log('event.detail.pie;: '+event.detail.footer);
		this.plantillaId = event.detail.idPlantilla;
	}

	async getrutaVisualforce() {
		if (!this.visualforceHostname) {
			this.visualforceHostname = await getVisualforceHostnameApex({});
		}
		return (
			`https://${this.visualforceHostname}/apex/CC_DocumentoRedaccionPDF` +
			`?id=${this.recordId}&n=${Date.now()}`
		);
	}

	toast(variant, title, message) {
		this.dispatchEvent(new ShowToastEvent({variant, title, message}));
	}

	async verFile(recordId) {
		this[NavigationMixin.Navigate]({
			type: 'standard__namedPage',
			attributes: {pageName: 'filePreview'},
			state: {recordIds: recordId}
		});
	}
}