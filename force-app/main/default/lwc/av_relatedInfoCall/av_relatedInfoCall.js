import { LightningElement, track, api, wire } from 'lwc';

import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecordUi } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import getFields from '@salesforce/apex/AV_RelatedInfoCall_Controller.getFields';
import getActivityUrl from '@salesforce/apex/AV_RelatedInfoCall_Controller.getActivityUrl';

export default class av_relatedInfoCall extends NavigationMixin(LightningElement) {

    @api recordId;
    //Parameters of Flexipage configuration
    @api filterObject;
    @api numberOfColumns;
    @api accordionTitle;
    _currentPage

// nuevo
    activities = [];
    error;
    href;

    name;
    id;


    @wire(CurrentPageReference)
        wirePageRef(data){
        if(data){
        this._currentPage = data;
        }
    }

    

    @wire(getFields, {recordId: '$recordId'})
    wiredActivities({ error, data }) {
        if (data && data.length > 0) {
            this.activities = data;
            // this.href = "/lightning/r/"+ data[0].name + '/' + data[0].id + '/view'; 
            this.id = data[0].id;
            this.name = data[0].name;

            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.activities = [];
        }
    }

    @wire(getActivityUrl, {activityId: '$id', name: '$name' })
    activityUrl({ error, data }) {
        let urlpath = window.location.href;
        let parsedUrl = new URL(urlpath);
        let baseUrl = parsedUrl.origin;

        if (data) {
            this.href = baseUrl + data;
        }
        else if (error) {
            this.error = error;
        }
    }


    // handleAccordionToggle(event) {
    //     const section = event.currentTarget.closest('.slds-accordion__section');
    //     if (section.classList.contains('slds-is-open')) {
    //         section.classList.remove('slds-is-open');
    //         section.querySelector('button').setAttribute('aria-expanded', 'false');
    //     } else {
    //         section.classList.add('slds-is-open');
    //         section.querySelector('button').setAttribute('aria-expanded', 'true');
    //     }
    // }

    handleSectionToggle(event) {
        event.detail.openSections;
    }

    get sizeColumn() {
		if(this.numberOfColumns===1){
            return 12;
        }
		else if(this.numberOfColumns===2){
            return 6;
        }
		else if(this.numberOfColumns===3){
            return 4;
        }
    }
    
}