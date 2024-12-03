import {LightningElement, api, wire, track} from 'lwc';
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';
import currentUserId from '@salesforce/user/Id';
import {RefreshEvent} from 'lightning/refresh';
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import generarDocumentoApex from '@salesforce/apex/CSBD_GenerarDocumento_Controller.generarDocumento';
import getOriginApex from '@salesforce/apex/CSBD_GenerarDocumento_Controller.getOrigin';

import OPPTY_OWNER_ID from '@salesforce/schema/Opportunity.OwnerId';
import OPPTY_HTML_DOC from '@salesforce/schema/Opportunity.CSBD_GenerarDocumentoHtml__c';

//import staticResourcHtml2Pdf from '@salesforce/resourceUrl/html2pdf';

//eslint-disable-next-line new-cap
export default class csbdGenerarDocumento extends NavigationMixin(LightningElement) {

	@api recordId;

	botonAbrirModalDisabled = true;

	formats = [
		'font', 'size', 'bold', 'italic', 'underline', 'strike', 'list', 'indent',
		'align', 'link', 'image', 'clean', 'table', 'header', 'color', 'background'
	];

	origin;

	@track rutasVisualforce = {};

	spinnerExportarPdf = false;

	spinnerGenerarVistaPrevia = false;

	cuerpo;

	querySelector = selector => this.template.querySelector(selector);

	async connectedCallback() {
		await this.getRutasVisualforce();
		window.addEventListener('message', event => {
			if (event.origin.endsWith(this.origin) && event.data.recordId === this.recordId) {
				if (event.data.name === 'finInit') {
					window.setTimeout(() => {
						if (this.cuerpo) {
							window.setTimeout(() => {
								this.enviarMensajeEditorHtml({name: 'setContent', content: this.cuerpo});
							}, 2000);
						} else {
							this.querySelector('div.divEdicion > span.spanCargandoEditor').classList.add('slds-hide');
							this.querySelector('div.divEdicion > iframe').classList.remove('slds-hide');
						}
						this.enviarMensajeEditorHtml({name: 'focusEditor'});
					}, 1000);

				} else if (event.data.name === 'setContentOk') {
					window.setTimeout(() => {
						this.querySelector('div.divEdicion > span.spanCargandoEditor').classList.add('slds-hide');
						this.querySelector('div.divEdicion > iframe').classList.remove('slds-hide');
						this.querySelector('.botonVistaPrevia').disabled = false;
						this.enviarMensajeEditorHtml({name: 'focusEditor'});
					}, 0);

				} else if (event.data.name === 'getContentOk') {
					this.cuerpo = event.data.content;
					if (event.data.vistaPrevia) {
						this.generarVistaPrevia();
					}

				} else if (event.data.name === 'contentChanged') {
					this.querySelector('.botonVistaPrevia').disabled = false;
					this.querySelector('.botonGenerarPdf').disabled = true;
					const spanPrevisualizacionDesactualizada = this.querySelector('.spanPrevisualizacionDesactualizada');
					if (spanPrevisualizacionDesactualizada) {
						spanPrevisualizacionDesactualizada.classList.add('visible');
					}

				} else if (event.data.name === 'cerrarModal') {
					this.cerrarModal();
				}
			}
		});
	}

	async getRutasVisualforce() {
		this.origin = await getOriginApex({tipo: 'lwc'});
		this.rutasVisualforce = {
			editor: `/apex/CSBD_EditorHtml?recordId=${this.recordId}`
			//vistaPrevia: `/apex/CSBD_DocumentoRedaccionPDF?id=${this.recordId}&n=${Date.now()}`
		};
	}

	@wire(getRecord, {recordId: '$recordId', fields: [OPPTY_OWNER_ID, OPPTY_HTML_DOC]})
	wiredOpportunity({data, error}) {
		if (data) {
			this.botonAbrirModalDisabled = getFieldValue(data, OPPTY_OWNER_ID) !== currentUserId;
			this.cuerpo = getFieldValue(data, OPPTY_HTML_DOC)?.trim(); //lightning-rich-text
		} else if (error) {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos de la oportunidad', error.body.message);
		}
	}

	abrirModal() {
		this.querySelector('div.backdrop').classList.add('slds-backdrop_open');
		this.querySelector('section.modalGenerarDocumento').classList.add('slds-fade-in-open');
		this.template.querySelector('section.modalGenerarDocumento .botonCerrarModal').focus();
	}

	cerrarModal() {
		this.querySelector('.modalGenerarDocumento').classList.remove('slds-fade-in-open');
		this.querySelector('.backdrop').classList.remove('slds-backdrop_open');
	}

	botonVistaPreviaOnclick() {
		this.enviarMensajeEditorHtml({name: 'getContent', vistaPrevia: true});
	}

	async generarVistaPrevia() {
		const spanPrevisualizacionDesactualizada = this.querySelector('.spanPrevisualizacionDesactualizada');
		if (spanPrevisualizacionDesactualizada) {
			spanPrevisualizacionDesactualizada.classList.remove('visible');
		}
		this.spinnerGenerarVistaPrevia = true;

		const botonVistaPrevia = this.querySelector('.botonVistaPrevia');
		const botonGenerarPdf = this.querySelector('.botonGenerarPdf');
		const csbdGenerarDocumentoPlantilla = this.refs.csbdGenerarDocumentoPlantilla;
		botonVistaPrevia.disabled = true;
		botonGenerarPdf.disabled = true;
		csbdGenerarDocumentoPlantilla.botonDisabled = true;

		const fieldsOportunidad = {};
		fieldsOportunidad.Id = this.recordId;
		fieldsOportunidad[OPPTY_HTML_DOC.fieldApiName] = this.cuerpo;
		updateRecord({fields: fieldsOportunidad})
		.then(async () => {
			this.rutasVisualforce.vistaPrevia = `/apex/CSBD_DocumentoRedaccionPDF?id=${this.recordId}&n=${Date.now()}`;
			botonGenerarPdf.disabled = false;
		}).catch(error => {
			console.error(error);
			this.toast('error', 'Problema generando la vista previa', error.body.message);
		}).finally(() => {
			this.spinnerGenerarVistaPrevia = false;
			csbdGenerarDocumentoPlantilla.botonDisabled = false;
		});
	}

	exportarPdf(event) {
		this.spinnerExportarPdf = true;

		const botonVistaPrevia = this.querySelector('.botonVistaPrevia');
		const csbdGenerarDocumentoPlantilla = this.refs.csbdGenerarDocumentoPlantilla;
		botonVistaPrevia.disabled = true;
		event.currentTarget.disabled = true;
		csbdGenerarDocumentoPlantilla.botonDisabled = true;

		generarDocumentoApex({recordId: this.recordId})
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
			csbdGenerarDocumentoPlantilla.botonDisabled = false;
			this.spinnerExportarPdf = false;
		});
	}

	modalPlantillasAbierto() {
		this.querySelector('.modalGenerarDocumento').classList.add('slds-hidden');
	}

	modalPlantillasCerrado() {
		this.querySelector('.modalGenerarDocumento').classList.remove('slds-hidden');
	}

	modalPlantillasSeleccionada(event) {
		this.querySelector('.botonGenerarPdf').disabled = true;
		this.querySelector('div.divEdicion > span.spanCargandoEditor').classList.remove('slds-hide');
		this.querySelector('div.divEdicion > iframe').classList.add('slds-hide');
		window.setTimeout(() =>	this.enviarMensajeEditorHtml({name: 'setContent', content: event.detail}), 0);
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

	enviarMensajeEditorHtml(mensaje) {
		let contentWindow = this.querySelector('div.divEdicion iframe').contentWindow;
		contentWindow.postMessage({...mensaje, recordId: this.recordId}, this.origin);
	}

	modalGenerarDocumentoOnkeydown(event) {
		event.keyCode === 27 && this.cerrarModal(); //Tecla ESC
	}
}