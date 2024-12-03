import { LightningElement, track, api } from 'lwc';
import isEnabledNuevoProceso from '@salesforce/apex/SIR_LCMP_NewFormRefi.isEnabledNuevoProceso';

export default class Sir_lwc_NewFormRefiContainer extends LightningElement {

    @track showButton = false;
    @track showFormComponent = false;

    @api recordId;


    renderedCallback() {
        isEnabledNuevoProceso({idAccount: this.recordId}).then(result => {
            this.showButton = result; 
        });
    }
    showForm() {
        this.showFormComponent = true;
    }

}