import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Recordform extends LightningElement {
 
    @api recordId;
    
    handleSubmit(event) {
        console.log('onsubmit: '+ event.detail.fields);
    }
    handleSuccess(event) {
        const updatedRecord = event.detail.id;
        console.log('onsuccess: ', updatedRecord);
        const toast = new ShowToastEvent({
            title: 'Gestión del caso',
            message: 'Se han actualizado campos del caso.',
            variant: 'success',
        });
        this.dispatchEvent(toast);
    }
}