import { LightningElement, api} from 'lwc';

import getRepresentativeData from '@salesforce/apex/AV_UpdateGcfRepresentative_Controller.getRepresentativeData';

export default class av_GcfRepresentative extends LightningElement {

	error;
	@api recordId;   
	
	connectedCallback() {
		this.getClientData();
	}

	getClientData() {
		getRepresentativeData({recordId: this.recordId})
			.then(result => {
				if (result != null){
					console.log('Se ha realizado correctamente la Api de Apoderado ');
				}
			})
			.catch(error => {
				console.log('Display ShowToastEvent error (catch): ', error);
			});
	}

}