import { api, LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getExtensionId	from '@salesforce/apex/CIBE_TaskCallReportFields.getExtensionId';

import citaActualizada from '@salesforce/label/c.CIBE_EventoActualizado';
import citaActualizadaCorrectamente from '@salesforce/label/c.CIBE_EventoActualizadoCorrectamente';
import guardar from '@salesforce/label/c.CIBE_Guardar';
import callReport from '@salesforce/label/c.CIBE_CallReport';


export default class Cibe_EventCallReportFields extends LightningElement {
    labels = {
        citaActualizada,
        citaActualizadaCorrectamente,
        guardar,
        callReport
    }

    @api recordId;
    @track extensionId;
    comentario;
    conclusion;

    @wire(getExtensionId, { eventId : '$recordId' })
    getExtension({ error, data }) {
        if (data) {
			this.extensionId = data;
        } else if (error) {
            console.log(error)
        }
    }

    handleSuccess() {
        this.loading = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: this.labels.citaActualizada,
                message: this.labels.citaActualizadaCorrectamente,
                variant: 'success'
            })
        );
    }

    handleError(event) {
        this.loading = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: event.detail.message,
                message: event.detail.detail,
                variant: 'error'
            })
        );
    }

}