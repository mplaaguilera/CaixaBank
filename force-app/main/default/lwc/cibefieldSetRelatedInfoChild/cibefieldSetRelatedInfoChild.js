import { LightningElement, api, track } from 'lwc';
//Labels
import c2cMakeCall from '@salesforce/apex/AV_SObjectRelatedInfoCController.c2cMakeCall';
import userWithoutPhone from '@salesforce/label/c.AV_CMP_C2C_CallingDevice_Empty'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class cibefieldSetRelatedInfoChild extends LightningElement {
    @api phoneValue;
    @api phoneLabel;
    @api calledDevice = '';
    @track isShowSpinner = true;
    @track phoneNumber;

    handleCallAction(event) {
        this.phoneNumber = String(this.phoneValue);        
        this.phoneNumber !== '' ? this.c2cMakeCall() : this.showDisplayToast('Error de Llamada', userWithoutPhone, 'warning');
    }
    c2cMakeCall(){
        c2cMakeCall({ calledDevice : this.phoneNumber })
            .then(result => {
                const [typeMessage, message] = result;
                this.showDisplayToast(typeMessage,message,typeMessage);
                this.isShowSpinner = false;
            })
            .catch(error => {
                console.log('Error:', error);
                this.showDisplayToast('Error',mess,'error');
                this.isShowSpinner = false;
            });
    }
    
    showDisplayToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    refresh(event) {
        this.isShowSpinner = true;
        refreshApex(this.wiredData)
            .finally(() => {
                this.isShowSpinner = false;
            });
    }
    
}