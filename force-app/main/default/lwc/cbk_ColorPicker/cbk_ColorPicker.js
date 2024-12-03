import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';

import COLOR_FIELD from '@salesforce/schema/CC_MCC__c.CC_Color_En_Buscador__c';

export default class Cbk_ColorPicker extends LightningElement {

    @api recordId;

    color = '#6B92DC';

    @wire (getRecord, {recordId: '$recordId', fields: [COLOR_FIELD]})
	wiredRecord({error, data}) {
		if (data) {
			this.color = getFieldValue(data, COLOR_FIELD);
		} else if (error) {
			console.error(error);
		}
	}

    inputOnchange(event) {
        this.color = event.detail.value;
    }

    guardar() {
        const fields = {};
        fields['Id'] = this.recordId;
        fields[COLOR_FIELD.fieldApiName] = this.value;
        updateRecord({fields})
        .then(console.error('ok'))
        .catch(error => console.error(error));
    }

}