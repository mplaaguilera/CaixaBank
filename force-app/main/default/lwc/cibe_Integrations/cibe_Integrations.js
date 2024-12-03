import { LightningElement, api} from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import getCliPremiumData from '@salesforce/apex/CIBE_UpdateCliPremium_Controller.getCliPremiumData';

export default class Av_Update_Cli_Premium extends LightningElement {


	@api recordId;   

	connectedCallback() {
		this.getClientData();
	}

	getClientData() {
		getCliPremiumData({recordId: this.recordId})
			.then(result => {
				if (result.responseFromUpdateAccount != null) {
				console.log('Display Premium ShowToastEvent OK: ', result.responseFromUpdateAccount);

				this.dispatchEvent(new RefreshEvent());
				}
			})
			.catch(error => {
				console.log('Display Premium ShowToastEvent error (catch): ', error);
			});
	}
}