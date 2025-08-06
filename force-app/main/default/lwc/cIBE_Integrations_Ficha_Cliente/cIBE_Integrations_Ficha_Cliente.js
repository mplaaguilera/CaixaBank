import { LightningElement, api} from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import getSIRData from '@salesforce/apex/CIBE_SIR_Integration.sirIntegrationCallout';
import getEEFFData from '@salesforce/apex/CIBE_EEFFIntegrationService.getCirbeEEFFdata';

export default class Av_Update_Cli_Premium extends LightningElement {


	@api recordId;   

	connectedCallback() {
		this.getSIRData();
		this.getEEFFData();
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
	getEEFFData() {
		getEEFFData({recordId: this.recordId})
			.then(result => {
				var data = JSON.stringify(result);
				if (data.length > 0) { 
					console.log('Display EEFF ShowToastEvent OK: ', data.length);
					this.dispatchEvent(new RefreshEvent());
				}
				
			})
			.catch(error => {
				console.log('Display EEFF ShowToastEvent error (catch): ', error);
			});
		
	}
}