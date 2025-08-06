import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Sac_Negociacion extends LightningElement {

    @api recordId;
    @api objectApiName;

    @track spinnerLoading = false;

    handleSubmit(event) {
        this.spinnerLoading = true;

        const fields = event.detail.fields;

        this.template
        .querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(event) {
        const updatedRecord = event.detail.id;
        const toast = new ShowToastEvent({
            title: 'Negociación de la pretensión',
            message: 'Se han actualizado campos de la pretensión.',
            variant: 'success'
        });
        this.dispatchEvent(toast);
        this.spinnerLoading = false;
    }

}