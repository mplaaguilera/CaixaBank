import { LightningElement, wire, api,track} from 'lwc';
//import { ShowToastEvent } 	    from 'lightning/platformShowToastEvent';
//labels
//import AV_CMP_ErrorMessage 		from '@salesforce/label/c.AV_CMP_ErrorMessage';

import getCustomerJourney from '@salesforce/apex/CIBE_UpdateCliPremium_Controller.getCustomerJourney';
import getCliPremiumData from '@salesforce/apex/CIBE_UpdateCliPremium_Controller.getCliPremiumData';
import { updateRecord, getRecord } from 'lightning/uiRecordApi';
import NUMPERS_FIELD from '@salesforce/schema/Account.AV_NumPerso__c';
import DATECLI_FIELD from '@salesforce/schema/Account.AV_FechaRefrescoClientePremium__c';
import JSONCLI_FIELD from '@salesforce/schema/Account.AV_JSONClientePremium__c';
import CJDATE_FIELD from '@salesforce/schema/Account.AV_FechaRefrescoCustomerJourney__c';
import ID_FIELD from '@salesforce/schema/Account.Id';

export default class Av_Update_Cli_Premium extends LightningElement {

	numPers;
	dateCli;
	jsonCli;
	@track error;
	@api recordId;   

	@wire(getRecord, { recordId: '$recordId', fields: [NUMPERS_FIELD, DATECLI_FIELD, JSONCLI_FIELD] })
	wiredAccount({data,error}) {
		if(data) {
			this.numPers = data.fields.AV_NumPerso__c.value;
			this.dateCli = data.fields.AV_FechaRefrescoClientePremium__c.value;
			this.jsonCli = data.fields.AV_JSONClientePremium__c.value;
		}
		if(error) {
			this.error = error;
		}
	}
	
	connectedCallback() {
		this.getClientData();
	}

	refreshViewEvent() {
		this.dispatchEvent(new CustomEvent('refresh'));
	}

	getClientData() {
		getCliPremiumData({recordId: this.recordId})
			.then(result => {
				console.log ('result: ', result);
				if (result.responseFromUpdateAccount != null) {
					console.log('Display ShowToastEvent error (then): ', result.responseFromUpdateAccount);

				}

				this.getCustomerJourneyData();
			})
			.catch(error => {
				console.log('Display ShowToastEvent error (catch): ', error);
			});
	}

	getCustomerJourneyData(){
		getCustomerJourney({recordId: this.recordId})
			.then(result => {
				const fields = {};
				fields[ID_FIELD.fieldApiName] = this.recordId;
				fields[CJDATE_FIELD.fieldApiName] = new Date().toISOString();
				const recordInput = {fields};
				if (result == 'OK') {
					updateRecord(recordInput)
					.then(() => {
						this.error = undefined;
					})
					.catch(error => {
						console.log(error);
						this.error = error;
					});
				}
			})
			.catch(error => {
				console.log('Display ShowToastEvent error (catch): ',error);
			});
	}

	getRecord() {
		getRecord({recordId: this.recordId, fields: [NUMPERS_FIELD, DATECLI_FIELD, JSONCLI_FIELD]})
			.then(data => {
				if(data) {
					this.numPers = data.fields.AV_NumPerso__c.value;
					this.dateCli = data.fields.AV_FechaRefrescoClientePremium__c.value;
					this.jsonCli = data.fields.AV_JSONClientePremium__c.value;
				}
			})
			.catch(error => {
				console.log('Display ShowToastEvent error (catch): ', error);
			});
	}

}