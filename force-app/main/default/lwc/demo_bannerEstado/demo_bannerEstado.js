import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';

import CASE_ID from '@salesforce/schema/Case.Id';
import CASE_STATUS from '@salesforce/schema/Case.Status';
import CASE_LAST_MODIFIED_DATE from '@salesforce/schema/Case.LastModifiedDate';


export default class demoBannerEstado extends LightningElement {
	@api recordId;

	caso;

    @wire(getRecord, {recordId: '$recordId', fields: [CASE_STATUS, CASE_LAST_MODIFIED_DATE]})
	wiredRecord({error, data}) {
		if (error) {
			let mensajeError;
			if (Array.isArray(error.body)) {
				mensajeError = error.body.map(e => e.message).join(', ');
			} else if (typeof error.body.message === 'string') {
				mensajeError = error.body.message;
			}
			this.mostrarToast('error', 'Problema recuperando los datos del caso', mensajeError);
		} else if (data) {
			this.caso = {...data, _lastModifiedDate: getFieldValue(data, CASE_LAST_MODIFIED_DATE)};
		}
	}
}