import { LightningElement, track, api, wire } from 'lwc';

import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecordUi } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import getFields from '@salesforce/apex/CIBE_FieldSetRelatedInfo_Controller.getFields';
import getPhoneField from '@salesforce/apex/CIBE_FieldSetRelatedInfo_Controller.getPhoneField';
import getPhoneFieldValue from '@salesforce/apex/CIBE_FieldSetRelatedInfo_Controller.getFieldValue';
import c2cMakeCall from '@salesforce/apex/AV_SObjectRelatedInfoCController.c2cMakeCall';

export default class cibe_fieldSetRelatedInfo extends NavigationMixin(LightningElement) {

    @api recordId;
    fields;
    _currentPage;

    @wire(CurrentPageReference)
    wirePageRef(data){
        if(data){
            this._currentPage = data;
        }
    }

    //Parameters of Flexipage configuration
    @api filterObject;
    @api fieldSetName;
    @api phoneFieldInput;
    @api numberOfColumns;
    @api accordionTitle;
    @api calledDevice = '';
    @api phoneField;


    @track name;
    @track _wiredName;
    @track _wiredFields;
    @track _wiredData
    @track fields;
    @track phoneValue;
    @track phoneLabel;
    error;

    @wire(getPhoneFieldValue, { objectApiName: '$filterObject', fieldSetName: '$fieldSetName', fieldName: '$phoneFieldInput', recordId: '$recordId' })
    wiredField({error, data}) {
        if (data) {
            this.phoneValue = data;
        } else if (error) {
            this.error = error;
        }
    }
    @wire(getPhoneField, {recordId: '$recordId', fieldSetName: '$fieldSetName', phoneFieldInput: '$phoneFieldInput'})
    getPhoneFieldName({ error, data }) {
        if (data) {
            this.phoneFieldarray = data.filter(field => field.name  == this.phoneFieldInput);
            this.phoneField = this.phoneFieldarray[0].name;
            this.phoneLabel = this.phoneFieldarray[0].label;
        } else if (error) {
            console.log(error);
        }
    }
    @wire(getFields, {recordId: '$recordId', fieldSetName: '$fieldSetName'})
    getFieldsData({ error, data } ) {
        if (data) {
            const fieldList = data;
            this.fields = Object.values(fieldList).map(f => ({
                name: f.name,
                isPhoneField: f.name == this.phoneFieldInput
            }));
        } else if (error) {
            console.log(error);
        }
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