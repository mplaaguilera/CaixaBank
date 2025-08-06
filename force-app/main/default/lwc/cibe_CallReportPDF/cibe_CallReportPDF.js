import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import saveFile from '@salesforce/apex/CIBE_CallReportPDFController.saveFileContent';

export default class cibe_CallReportPDF extends LightningElement {

    @api recordId;
    @api label;
    @api visualforceName;
    @api fileName;

    @track isLoading = false;

    handleSave(event) {
        const content = event.detail;
        if(content) {
            this.isLoading = true;
            saveFile({ recordId : this.recordId, content : content, fileName : this.fileName})
                .then(data => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title : 'Call Report',
                            message : 'PDF created successfully.',
                            variant : 'success'
                        }));
                    eval("$A.get('e.force:refreshView').fire();");
                }).catch(error => {
                    console.log(error);
                }).finally(() => {
                    this.isLoading = false;
                });
        }
    }
}