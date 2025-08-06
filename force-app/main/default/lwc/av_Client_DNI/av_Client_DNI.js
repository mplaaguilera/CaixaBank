import { LightningElement,api,track } from 'lwc';
import dniCallout           from '@salesforce/apex/AV_DNI_Integration.callDNIApi';
import {ShowToastEvent}				   						   from 'lightning/platformShowToastEvent';

import cmpMainLabel         from '@salesforce/label/c.AV_PersonalDocumentSection';
export default class Av_Client_DNI extends LightningElement {
    @api recordId;
    @track showSpinner = true;
    @track folded = false;
    label = {
        cmpMainLabel
    };
    @track anvers;
    @track nodni = false;
    visibleByCss = 'hiddenDiv';
    firstRender = false;
 
    fillImgUrls(){
        let anvImg = this.template.querySelector('[data-id="anversImg"]');
        if (!this.firstRender && anvImg != null ){
            anvImg.src = this.anvers;
            this.firstRender = true;
            this.showSpinner = false;

        }
    }
    getDNI(){
        dniCallout({accountId:this.recordId})
        .then(res => {
            if(res.response == 'OK'){
                this.anvers = this.getUrlFromByteArray(res.anvers);
                this.fillImgUrls();
            }else{
                console.log('Error => ',res.errorMessage);
                this.nodni = true;
                this.showSpinner = false;
            }
        }).catch(error => {
            console.log(error);
            this.nodni = true;
            this.showSpinner = false;
        })
    }
    getUrlFromByteArray(byteArrayString){
        let byteArray = JSON.parse(byteArrayString);
        const uint8Array = new Uint8Array(byteArray.map(byte => byte < 0 ? byte +256 : byte ));
        const blob = new Blob([uint8Array],{type: 'image/jpeg'});
        return URL.createObjectURL(blob);

    }

    showToast(title, message, variant) {
		var event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: 'pester'
		});
		this.dispatchEvent(event);
	} 

    unFoldCmp(){
        this.folded = !this.folded;
        this.visibleByCss = (this.folded) ? 'visibleDiv' :'hiddenDiv';
        if(!this.firstRender){
            this.getDNI();
        }
    }
}