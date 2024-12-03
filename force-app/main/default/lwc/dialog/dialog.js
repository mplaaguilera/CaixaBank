import { LightningElement, api } from 'lwc';
import { handleUpload } from 'c/fileList';
import deleteUploadedFile from "@salesforce/apex/SEG_FileController.deleteUploadedFile";
import TickerSymbol from '@salesforce/schema/Account.TickerSymbol';

export default class ConfirmationScreen extends LightningElement {
    @api visible;
    @api title;
    @api name;
    @api message;
    @api confirmLabel;
    @api cancelLabel;
    @api originalMessage;
    @api contentdata;
    @api mostrarcampos;
    @api adjuntosubido;

    get showMessage() {
        return this.message && this.message.length > 0 ? true : false;
    }
    //Button Click Handler
    handleConfirmClick(event) {
        //creates object which will be published to the parent component
        if (event.target) {
            let finalEvent = {
                originalMessage: this.originalMessage,
                status: event.target.name
            };

            //dispatch a 'click' event so the parent component can handle it
            //this.dispatchEvent(new CustomEvent('click', { detail: finalEvent }));
            handleUpload.call(this, event);
        }
    }

    @api handleCancel() {
        this.visible = false;
    }
    @api openmodal() {
        this.visible = true
    }
    @api closeModal() {
        this.mostrarcampos = false;
        this.adjuntosubido = false;
        this.contentdata;
        var valores = {campos: this.mostrarcampos, adjuntos: this.adjuntosubido};
        const valoresEvent = new CustomEvent('sendvaluesevent',{
            detail: valores
        });

        this.dispatchEvent(valoresEvent);

        this.visible = false
        this.deleteUnwanted();
    }
    deleteUnwanted(){
        if (this.contentdata.documentId != null){
            deleteUploadedFile({versionArchivo: this.contentdata.documentId})
        }
        this.contendata = null;
    }
}