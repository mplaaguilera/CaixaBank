import {LightningElement, wire, api} from 'lwc';
import getTaskAV from '@salesforce/apex/CC_MostrarTaskAV_Controller.getTaskAV';
import {NavigationMixin} from 'lightning/navigation';

//eslint-disable-next-line new-cap
export default class ccMostrarTaskAV extends NavigationMixin(LightningElement) {
	@api recordId;

	records = [];

	@wire(getTaskAV, {recordId: '$recordId'})
	wiredGetTaskAV({data, error}) {
		if (data) {
			this.records = data;
		} else if (error) {
			console.error(error);
		}
	}

	navigate({currentTarget}) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: currentTarget.dataset.recordId,
				actionName: 'view'
			}
		});
	}
}