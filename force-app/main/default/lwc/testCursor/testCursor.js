import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';

import OPP_CREATED_DATE from '@salesforce/schema/Opportunity.CreatedDate';
import OPP_CLOSE_DATE from '@salesforce/schema/Opportunity.CloseDate';

export default class TestCursor extends LightningElement {

    @api recordId;

    progress = 0;

    @wire(getRecord, {recordId: '$recordId', fields: [OPP_CREATED_DATE, OPP_CLOSE_DATE]})
    wiredRecord({data, error}) {
    	if (data) {
    		this.progress = 50;
    	}
    }
}