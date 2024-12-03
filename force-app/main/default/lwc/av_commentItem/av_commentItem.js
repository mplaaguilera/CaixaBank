import { LightningElement, api, track } from 'lwc';

import productFieldLabel from '@salesforce/label/c.AV_ProductFieldOppTask';
import employeeLabel from '@salesforce/label/c.AV_Employee';
import commentLabel from '@salesforce/label/c.AV_HistoricalComment';

import { NavigationMixin } from 'lightning/navigation';
 
export default class Av_commentItem extends NavigationMixin(LightningElement) {
    @api item;

    @track divClass = 'slds-timeline__item_expandable';
    @track iconName = 'standard:';
    @track isType = false;
    @track isStatus = false;
    @track isEmployee = false;
    @track isDate = false;
    @track isProduct = false;
    @track isChannel = false;


    @track isDateNull = false;

    label = {
        productFieldLabel,
        employeeLabel,
        commentLabel
    }

    connectedCallback() {
        switch (this.item.type) {
            case 'task':
                this.divClass += ' slds-timeline__item_task';
                this.iconName += this.item.type;
                this.isType = true;
                this.isStatus = true;
                this.isEmployee = true;
                this.isDate = true;

                break;
            case 'event':
                this.divClass += ' slds-timeline__item_event';
                this.iconName += this.item.type;
                this.isType = true;
                this.isEmployee = true;
                this.isDate = true;
                break;
            case 'opportunity':
                this.divClass += ' slds-timeline__item_opportunity';
                this.iconName += this.item.type;
                this.isProduct = true;
                this.isStatus = true;
                this.isEmployee = true;
                this.isDate = true;
                break;
            case 'case':
                this.divClass += ' slds-timeline__item_red';
                this.iconName += this.item.type;
                this.isStatus = true;
                this.isChannel = true;
                this.isDate = true;
                break;            
        }
        if (this.item.modifiedDate == null) {
            this.isDateNull=true;
        }
    }

    viewRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": this.item.recordId,
                "objectApiName": this.item.type,
                "actionName": "view"
            },
        });
    }

}