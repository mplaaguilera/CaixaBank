import { LightningElement, api, track, wire } from 'lwc';

//Labels
import AV_CMP_NoDataFound 		from '@salesforce/label/c.AV_CMP_NoDataFound';
import AV_CMP_ErrorMessage 		from '@salesforce/label/c.AV_CMP_ErrorMessage';
import AV_LabelLinkNotifyMe     from '@salesforce/label/c.AV_LabelLinkNotifyMe';
import {getRecord, getFieldDisplayValue}          from 'lightning/uiRecordApi';

//method
import getLink   from '@salesforce/apex/AV_LinkNotifyMeController.getLink';

import Origen_FIELD from '@salesforce/schema/AV_NotifyMe__c.AV_OrigenAct__c';
const fields = [Origen_FIELD];

export default class Av_LinkNotifyMe extends LightningElement {

    @api recordId; //para llamar al método.
    @track hasLink= false;
    @track url;

    noDataFound = AV_CMP_NoDataFound;  //variable para html.
    labelLinkNotifyMe = AV_LabelLinkNotifyMe;

    @wire(getRecord, { recordId: '$recordId', fields })
    AV_NotifyMe__c;

    get origen() {
        return getFieldDisplayValue(this.AV_NotifyMe__c.data, Origen_FIELD);
    }
    get titleURL(){
        return this.labelLinkNotifyMe + ': ' + this.origen;
    }

    connectedCallback() {
        this.getLinkId();
    } 

    getLinkId(){
        getLink({idNotificacion: this.recordId})
        .then(result => {
            if (result!='KO') {
                this.hasLink = true;  //hasLink y url del html.
                this.url = result;
            }else{
                console.log('Error: ', result);
            }
        })
        .catch(error => {
            console.log('Display ShowToastEvent error (catch): ',error);
            /*const evt = new ShowToastEvent({
                title: AV_CMP_ErrorMessage,
                message: JSON.stringify(error),
                variant: 'error'
            });
            this.dispatchEvent(evt);*/
        });

    }

}