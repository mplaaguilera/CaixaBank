import { LightningElement, api, track } from 'lwc';
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent,
} from 'lightning/flowSupport';
import lookupSearchUser from '@salesforce/apex/AV_EventAttendesController.searchUser';

export default class Av_AttendesEvent extends LightningElement {


    @api
    get records() {
        return this._records;
    }

    set records(records = []) {
        this._records = [...records];
    }

    @track _records = [];

    initialSelection = [];
	errors = [];

    handleSearch(event) {
		lookupSearchUser(event.detail)
			.then((results) => {
				this.template.querySelector('[data-id="clookup"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookup"]').scrollIntoView();
			})
			.catch((error) => {
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