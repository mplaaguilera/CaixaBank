import { LightningElement, api, track } from 'lwc';

import getAvisosTasks            from '@salesforce/apex/AV_PendingTasks_Controller.getAvisosTasks';

import AV_CMP_ErrorMessage 		from '@salesforce/label/c.AV_CMP_ErrorMessage';
import noDataFoundLabel from '@salesforce/label/c.AV_CMP_NoDataFound';

export default class Av_PendingTasks extends LightningElement {
    @api recordId;
    @track listTasks;
    @track data=false;
    @track showSpinner = false;
    @track error=noDataFoundLabel;

    connectedCallback() {
        this.enableSpinner();
		this.getData();
	}

    getData() {
        getAvisosTasks({recordId: this.recordId})
            .then(result => {
                if (result != null) {
                    this.listTasks=result;
                    this.data=true;
                } else {
                    this.data=false;
                }
                this.disableSpinner();
            })
            .catch(error => {
                this.disableSpinner();
				console.log('Display ShowToastEvent error (catch): ', error);
                this.dispatchEvent(
					new ShowToastEvent({
						title: AV_CMP_ErrorMessage,
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
            });
    }

    sendData(event) {       
        const sendData = new CustomEvent('data', {
            detail: event.detail
        });
        this.dispatchEvent(sendData);
    }

    disableSpinner() {
        this.showSpinner = false;
    }

    enableSpinner() {
        this.showSpinner = true;
    }
}