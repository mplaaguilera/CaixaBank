import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {NavigationMixin} from 'lightning/navigation';
import getCaracteristicasContactoApex from '@salesforce/apex/CC_Caracteristica.getCaracteristicasContacto';

import CONTACT_RT from '@salesforce/schema/Contact.RecordType.DeveloperName';
import CASE_CONTACT_ID from '@salesforce/schema/Case.ContactId';
import CASE_CONTACT_RT from '@salesforce/schema/Case.Contact.RecordType.DeveloperName';
import OPP_CONTACT_ID from '@salesforce/schema/Opportunity.CSBD_Contact__c';
import OPP_CONTACT_RT from '@salesforce/schema/Opportunity.CSBD_Contact__r.RecordType.DeveloperName';

//eslint-disable-next-line new-cap, camelcase
export default class caracteristicas_Asociadas extends NavigationMixin(LightningElement) {
	@api objectApiName;

	@api recordId;

	record;

	caracteristicas = [];

	get fieldsWire() {
		if (this.objectApiName === 'Contact') {
			return [CONTACT_RT];
		} else if (this.objectApiName === 'Case') {
			return [CASE_CONTACT_ID, CASE_CONTACT_RT];
		} else if (this.objectApiName === 'Opportunity') {
			return [OPP_CONTACT_ID, OPP_CONTACT_RT];
		} else {
			return [];
		}
	}

	get apexInput() {
		if (this.objectApiName === 'Contact') {
			return {idContacto: this.recordId, rtContacto: getFieldValue(this.record, CONTACT_RT)};
		} else if (this.objectApiName === 'Case') {
			return {idContacto: getFieldValue(this.record, CASE_CONTACT_ID), rtContacto: getFieldValue(this.record, CASE_CONTACT_RT)};
		} else if (this.objectApiName === 'Opportunity') {
			return {idContacto: getFieldValue(this.record, OPP_CONTACT_ID), rtContacto: getFieldValue(this.record, OPP_CONTACT_RT)};
		} else {
			return null;
		}
	}

	@wire(getRecord, {recordId: '$recordId', fields: '$fieldsWire'})
	async wiredRecord({data, error: errorGetRecord}) {
		try {
			if (data) {
				this.record = data;
				if (!this.apexInput.idContacto) {
					this.caracteristicas = [];
				} else {
					this.caracteristicas = await getCaracteristicasContactoApex(this.apexInput);
				}
			} else if (errorGetRecord) {
				throw errorGetRecord;
			}
		} catch (error) {
			console.error(error);
		}
	}

	/*
	@wire(conseguirCaracteristicaApex, {idCliente: '$recordId'})
	wiredCaracteristicas(retorno) {
		if (retorno.data) {
			this.caracteristicas = retorno.data;
		}
	}
	*/

	navigateToCaracteristica(event) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {recordId: event.currentTarget.dataset.id, actionName: 'view'}
		});
	}
}