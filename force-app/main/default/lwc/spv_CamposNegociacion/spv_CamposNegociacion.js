import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Llamadas Apex
import getPretensiones from '@salesforce/apex/SPV_LCMP_CamposNegociacion.getPretensiones';

export default class Spv_CamposNegociacion extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track spinnerLoading = false;
    @track pretensiones = [];

    @wire(getPretensiones, { casoId: '$recordId'})
    getPretensiones({ error, data }){
        if(data){
            this.pretensiones = data;
        }
    } 

    handleSubmit(event) {
        this.spinnerLoading = true;

        const fields = event.detail.fields;
        this.template.querySelectorAll('lightning-record-edit-form').forEach((form) => {form.submit()});
    }

    handleSuccess(event) {
        const updatedRecord = event.detail.id;
        const toast = new ShowToastEvent({
            title: 'Exito',
            message: 'Se han actualizado campos de la negociación.',
            variant: 'success'
        });
        this.dispatchEvent(toast);
        this.spinnerLoading = false;
    }
}