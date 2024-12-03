import { LightningElement, api} from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import getCliPremiumData from '@salesforce/apex/CIBE_UpdateCliPremium_Controller.getCliPremiumData';
import getSIRData from '@salesforce/apex/CIBE_SIR_Integration.sirIntegrationCallout';
//import getEEFFData from '@salesforce/apex/CIBE_EEFFIntegrationService.getCirbeEEFFdata';

export default class Av_Update_Cli_Premium extends LightningElement {


	@api recordId;   

	connectedCallback() {
		this.getClientData();
		this.getSIRData();
		//this.getEEFFData();
	}

	getClientData() {
		getCliPremiumData({recordId: this.recordId})
			.then(result => {
				if (result.responseFromUpdateAccount != null) {
				console.log('Display ShowToastEvent ok (then) Premium: ', result.responseFromUpdateAccount);

				this.dispatchEvent(new RefreshEvent());
				}
			})
			.catch(error => {
				console.log('Display ShowToastEvent error (catch): ', error);
			});
	}
	getSIRData() {
		getSIRData({accountId: this.recordId})
			.then(result => {
				console.log('Display SIR ShowToastEvent ok (then): ', result);
				this.dispatchEvent(new RefreshEvent());
			})
			.catch(error => {
				console.log('Display SIR ShowToastEvent error (catch): ', error);
			});	
	}
	/*
	getEEFFData() {
		getEEFFData({recordId: this.recordId})
			.then(result => {
				var data = JSON.stringify(result);
				if (data.length > 0) { 
					console.log('Display ShowToastEvent ok (then) EEFF: ', data.length);
					this.dispatchEvent(new RefreshEvent());
				}
				
			})
			.catch(error => {
				console.log('Display ShowToastEvent error (catch): ', error);
			});
		
	}*/
}