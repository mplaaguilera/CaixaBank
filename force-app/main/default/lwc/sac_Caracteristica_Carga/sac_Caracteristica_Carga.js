import { LightningElement, api, track } from 'lwc';
import loadFile from '@salesforce/apex/SAC_CaracteristicaCarga.loadFile';
import deleteFile from '@salesforce/apex/SAC_CaracteristicaCarga.deleteFile';


export default class Sac_Caracteristica_Carga extends LightningElement {
    @track acceptButtonDisabled = true;
    @track cancelButtonDisabled = false;
    @track contentDocumentId;
    @api recordId;
    @track logUrl;

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        this.contentDocumentId = uploadedFiles[0].documentId;
        this.acceptButtonDisabled = false;
        this.cancelButtonDisabled = false;
    }

    handleClickAceptar() {
        this.acceptButtonDisabled = true;
        this.cancelButtonDisabled = true;
        const caracteristicaId = this.recordId;
        const contentDocumentId = this.contentDocumentId;
        loadFile( {caracteristicaId, contentDocumentId} )
            .then(result => {
                this.logUrl = result;
                this.error = undefined;
                let myData = [];
                myData[0] = this.logUrl;
                this.dispatchEvent(new CustomEvent('showlogtoast', {
                    detail: { myData }
                }));
                this.dispatchEvent(new CustomEvent('clickaceptar'));
            })
            .catch(error => {
                this.error = error;
                this.logUrl = undefined;
                this.dispatchEvent(new CustomEvent('clickaceptar'));
            }); 
    }

    handleClickCancelar() {
        this.cancelButtonDisabled = true;
        this.acceptButtonDisabled = true;
        const contentDocumentId = this.contentDocumentId;
        deleteFile( {contentDocumentId} );
        this.dispatchEvent(new CustomEvent('clickcancelar'));
    }
}