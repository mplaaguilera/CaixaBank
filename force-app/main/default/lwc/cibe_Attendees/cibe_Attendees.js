import { LightningElement, api, track } from 'lwc';
import {
    FlowAttributeChangeEvent
} from 'lightning/flowSupport';

import lookupSearchUser from '@salesforce/apex/CIBE_AttendeesController.searchUser';
// Labels

import asistentes from '@salesforce/label/c.CIBE_Asistentes';
import addPart from '@salesforce/label/c.CIBE_AnadeParticipantes';

export default class Cibe_Attendees extends LightningElement {

    @api
    get records() {
        return this._records;
    }

    set records(records = []) {
        this._records = [...records];
    }

    @track _records = [];
    @track initialSelection = [];
	@track errors = [];

    labels ={
        asistentes,
        addPart
    };
    
    handleSearch(event) {
		lookupSearchUser(event.detail)
			.then((results) => {
				this.template.querySelector('[data-id="clookup"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookup"]').scrollIntoView();
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

    handleSelectionChange(event) {
        this._records = event.detail;
        const attributeChangeEvent = new FlowAttributeChangeEvent(
            'records',
            this._records
        );
        this.dispatchEvent(attributeChangeEvent);
        console.log(this._records);
	}

    

}