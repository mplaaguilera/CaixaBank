/*eslint-disable camelcase */
import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import consultaInicial from '@salesforce/apex/COL_ConsultaDocumentosFilenet_ctrl.consultaInicial';
import modifyBodyViewDocument from '@salesforce/apex/COL_ConsultaDocumentosFilenet_ctrl.modifyBodyViewDocument';
import calloutFilenetCont from '@salesforce/apexContinuation/COL_ConsultaDocumentosFilenet_ctrl.calloutFilenetCont';

import CASE_SNOW_NUMBER from '@salesforce/schema/Case.SNOW_Number__c';

export default class fileNetSnow extends LightningElement {
	@api recordId;

	caso;

	columns = [
		{label: 'Nombre', fieldName: 'Nombre_Documento', sortable: false, hideDefaultActions: true},
		{label: 'Tipo', fieldName: 'Serie_Documental', sortable: false, hideDefaultActions: true},
		//{ label: 'Añadido el', fieldName: 'Fecha_Alta_Documento', type: 'String', sortable: true },
		{label: 'Fecha envío SGAIM', fieldName: 'Fecha_Envio_SGAIM', sortable: false, initialWidth: 170, hideDefaultActions: true},
		{label: 'Envíar', id: 'Envio', type: 'button-icon', initialWidth: 90, typeAttributes: {
			iconName: 'utility:send', name: 'Envio', title: 'Envio SGAIM', variant: 'border-filled', disabled: {fieldName: 'isEnvioDisabled'}}},
		//{label: 'Envío', id: 'Envio', type: 'button', initialWidth: 83, typeAttributes: {
		//label: 'Envío', name: 'Envio', title: 'Envio SGAIM', variant: 'brand-outline', disabled: {fieldName: 'isEnvioDisabled'}}},
		{label: 'Descargar', id: 'Descargar', type: 'button-icon', initialWidth: 90, typeAttributes: {
			iconName: 'utility:download', name: 'Descargar', title: 'Descargar', variant: 'border-filled'}
		//{label: 'Descargar', id: 'Descargar', type: 'button', initialWidth: 127, typeAttributes: {
			//label: 'Descargar', name: 'Descargar', title: 'DescargarFileNet', variant: 'brand-outline'}
		}
	];

	documentos = [];

	isLoading = false;

	displayMessage = false;

	messageResponse = '';

	@wire(getRecord, {recordId: '$recordId', fields: [CASE_SNOW_NUMBER]})
	wiredCase({data, error}) {
		if (error) {
			console.error('Error fetching records:', error);
		} else if (data) {
			this.caso = data;
			consultaInicial({ticketId: this.recordId, SNOWNUMBER: getFieldValue(data, CASE_SNOW_NUMBER)})
			.then(documentosJson => {
				if (documentosJson !== '') {
					const documentos = JSON.parse(documentosJson);
					this.documentos = documentos.map(d => ({...d, isEnvioDisabled: Boolean(d.Fecha_Envio_SGAIM)}));
				} else {
					this.displayMessage = true;
					//this.messageResponse = documentosJson.messageResponse;
				}
			}).catch(errorConsultaInicial => console.error('Error fetching records:', errorConsultaInicial))
			.finally(() => this.isLoading = false);
		}
	}

	//async downloadFile(idFilenet, serie_Documental) {
	//console.log(idFilenet, serie_Documental);
	//let response = '';
	//let body = await createBodyViewDocument({ matricula: 'U1691512', fileNetId: idFilenet, serieDocumental: serie_Documental });
	//console.log(body);
	//calloutFilenet({ body }).then(result => {
	//response = result;
	//console.log(result + 'result');

	//});
	//console.log(response);
	//}

	handleRowAction({detail: {action: {name: actionName}, row}}) {
		if (actionName === 'Envio' && row.Fecha_Envio_SGAIM === '') {
			this.isLoading = true;
			modifyBodyViewDocument({fileNetId: row.Id_FileNet})
			//convertModifyResponse(calloutFilenet(modifyBodyViewDocument(idFileNet)))
			.then(result => {
				if (result !== '') {
					let data = JSON.parse(result);
					if (data.code === '000') {
						this.toast('success', data.description, '');
					} else if (data.code !== '000') {
						this.toast('error', data.description, 'Código de Error: ' + data.code);
					}
				} else {
					this.displayMessage = true;
					this.messageResponse = result.messageResponse;
				}
			}).catch(error => console.error('Error fetching records:', error))
			.finally(() => this.isLoading = false);

		} else if (actionName === 'Descargar') {
			calloutFilenetCont({filenetId: row.Id_FileNet, serieDocumental: row.Serie_Documental})
			.then(result => {
				console.log('tst ' + JSON.stringify(result));
				const doc = JSON.parse(result);
				const link = document.createElement('a');
				link.download = doc.Nombre + doc.Extension;
				link.href = 'data:' + doc.MimeType + ';base64,' + doc.Content;
				link.click();
			});

			/*
			verDocumento({ filenetId: event.detail.row.Id_FileNet, serieDocumental: event.detail.row.Serie_Documental })
			.then(result => {
				var doc = JSON.parse(result);
			var link = document.createElement('a');
			link.download = doc.Nombre + doc.Extension;
			link.href = 'data:' + doc.MimeType + ';base64,' + doc.Content;
			link.click()
			});
			break;
			*/
		}
	}

	toast(variant, title, message) {
		this.dispatchEvent(new ShowToastEvent({title, variant, message}));
	}
}