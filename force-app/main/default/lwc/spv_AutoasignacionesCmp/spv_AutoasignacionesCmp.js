import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
import autoasignarPropiedad from '@salesforce/apex/SPV_LCMP_Autoasignaciones.autoasignarPropiedad'
import { RefreshEvent } from 'lightning/refresh';


export default class Spv_AutoasignacionesCmp extends LightningElement {
    @api recordId;
    @api objectApiName;

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        this.init();
    }

    init() {
        autoasignarPropiedad({ objectType: this.objectApiName, recordId: this.recordId, usuarioActualId: USER_ID})
            .then(result => {
                if (result) {
                    this.refreshView();
                }
            })
            .catch(error => {
                this.showToast('Error al autoasignar la propiedad', error.body.message, 'error');
            });
    }

    refreshView() {
        this.dispatchEvent(new RefreshEvent());
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );
    }
}