import { LightningElement, api, track } from 'lwc';

import getContent from '@salesforce/apex/CIBE_PDFViewerController.getPDFContent';

import save from '@salesforce/label/c.CIBE_Guardar';
import cancel from '@salesforce/label/c.CIBE_Cancelar';

export default class cibe_PDFViewer extends LightningElement {

    labels = {
        save,
        cancel
    }
    
    @api recordId;
    @api label;
    @api visualforceName;
    @api hasRecordId;

    @track isOpenModal = false;

    handleOpenModal() {
        this.isOpenModal = true;
    }

    handleCancel() {
        this.isOpenModal = false;
    }

    handleSave() {
        this.isLoading = true;
        getContent({ recordId : this.recordId, visualforceName : this.visualforceName, hasRecordId : this.hasRecordId})
            .then(data => {
                const content = { 
                    detail : JSON.parse(JSON.stringify(data)) 
                };

                this.dispatchEvent(new CustomEvent("save", content));
                this.isOpenModal = false;
            }).catch(error => {
                console.log(error);
            }).finally(() => {
                this.isLoading = false;
            });
    }

    get url() {
        return '/apex/' + this.visualforceName + (this.hasRecordId ? '?recordId=' + this.recordId : '');
    }

    get isDisabled() {
        return  !((this.label !== null && this.label !== undefined) && (this.visualforceName !== null && this.visualforceName !== undefined));
    }
    
}