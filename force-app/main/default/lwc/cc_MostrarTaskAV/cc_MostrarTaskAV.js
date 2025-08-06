import {LightningElement, wire, api} from 'lwc';
import getTaskAV from '@salesforce/apex/CC_MostrarTaskAV_Controller.getTaskAV';
import {NavigationMixin} from 'lightning/navigation';

export default class Cc_MostrarTaskAV extends NavigationMixin(LightningElement) {    
    error;
    records = [];
    
    @api recordId;
    @wire(getTaskAV, {recordId: '$recordId'})
    wiredGetTaskAV({data, error}) {
        if (data) {
            this.records = data;
        } else if (error) {
            this.error = error;
        }
    }

    navigate(event) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: event.currentTarget.dataset.recordId,
				actionName: 'view'
			}
		});
	}
}