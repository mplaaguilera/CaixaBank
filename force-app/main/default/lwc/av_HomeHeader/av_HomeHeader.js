import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import dataAsLabel from '@salesforce/label/c.AV_DataAs';
 
export default class Av_HomeHeader extends LightningElement {
    
    @api title;
    @api subtitle;
    @api headerIcon;
    @api hasHeader;

    @track now = Date.now();

    currentUserName;
    label = {
        dataAsLabel
    }

    @wire(getRecord, { recordId: USER_ID, fields: ['User.Name'] })
    userData({error, data}) {
        if(data) {
            this.currentUserName = data.fields.Name.value;
        } 
        else if(error) {
            console.log('error ====> ' + JSON.stringify(error))
        } 
    }

    @api
    refreshDate(currentDateTime) {
        this.now = currentDateTime;
    }
}