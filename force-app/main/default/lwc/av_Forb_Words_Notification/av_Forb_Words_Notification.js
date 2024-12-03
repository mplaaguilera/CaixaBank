import { LightningElement, api } from 'lwc';

//toast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//labels
import warningLabel from '@salesforce/label/c.AV_CMP_WarningEvent'

//apex methods
import retrieveMessage from '@salesforce/apex/AV_ForbWordsNotification_Controller.retrieveMessage';

export default class Av_Forb_Words_Notification extends LightningElement {

    @api recordId;
    @api objectApiName;

    connectedCallback() {
        this.retrieveMessage();
    }

    showToast(title, message, variant, mode){
        const event = new ShowToastEvent({
            title: title,
			message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }
    
    retrieveMessage() {
        retrieveMessage({recordId: this.recordId, objectName: this.objectApiName})
            .then(result => {
                if(result !== 'KO') {
                    this.showToast(warningLabel, result, 'warning', 'sticky');
                }
            })
            .catch(error => {
                console.log(error);
            });
    }
}