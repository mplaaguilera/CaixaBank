import { LightningElement, api, wire} from 'lwc';
import argumentarioPrete from '@salesforce/apex/SAC_LCMP_RedaccionPretension.argumentarioPrete';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SAC_ArgumentarioPretensiones extends LightningElement {

    @api myVal;
    @api recordId;

    @wire(argumentarioPrete, { idCaso: '$recordId' }) 
    wiredResult({ data, error }) {
        if (data) {
            this.myVal = data;
        } else if (error) {
			this.mostrarToast('error', 'ERROR', JSON.stringify(error));
        }
    }

    mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({
			variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000
		}));
	}

}