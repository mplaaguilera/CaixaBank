import { LightningElement, api,track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import registerCache from '@salesforce/apex/CBK_NotificationBar_Controller.registerCache';

import APP_FIELD from '@salesforce/schema/CBK_Notification__c.App__c';
import FIELD_ID from '@salesforce/schema/CBK_Notification__c.Id';
import APPSTR_FIELD from '@salesforce/schema/CBK_Notification__c.AppStr__c';
//import AUTOR_FIELD from '@salesforce/schema/CBK_Notification__c.Autor__c';



export default class Cbk_LWC_Notification_Create extends NavigationMixin(LightningElement) {
@api InputApp;
@track isNew = false;
@track objectName = 'CBK_Notification__c';
@track fieldName = 'App__c';
lstSelected = [];
@track options = [];
//@track defaultValue = [];
@track arrayOpt = [];
//@track check;
@track idNew;
@track str;

    handleSuccess(event){		
        const evt = new ShowToastEvent({
            title: "Notification created",
            message: "Record ID: " + event.detail.id,
            variant: "success"
        });

		this.updateFieldApp(event);
        this.dispatchEvent(evt);
		this.isNew = false;
		//location.reload(true);
		this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
					recordId : event.detail.id,
                    objectApiName: this.objectName,
                    actionName: 'view'
                }                    
            });
		//location.reload(true);
		//document.location.reload(false);
    }

	functionSplit(InputAppstr){
		let tt =  ( typeof InputAppstr !== 'undefined' ) ? InputAppstr : "" ;
		
		if (tt != ""){
		this.arrayOpt = tt.split(';');
		for (var i = 0; i < this.arrayOpt.length; i++){
			
			if (!this.options.includes(this.arrayOpt[i].value)){
				this.options.push({
						label: this.arrayOpt[i],
						value: this.arrayOpt[i]
					});
			}
		}}
    }

	buttonNew(){
	this.options = [];
      this.isNew = true;
	  this.functionSplit(this.InputApp);
    }

	closeModal() {
        this.isNew = false;
    }

	 handleChange(event) {
        this.lstSelected = event.detail.value;
    }

	updateFieldApp(event) {
		const fields = {};
		this.idNew = event.detail.id;
		this.lstSelected.sort();
		this.str = this.lstSelected.join(';');

		fields[FIELD_ID.fieldApiName] = event.detail.id;
		fields[APP_FIELD.fieldApiName] = this.str;
		fields[APPSTR_FIELD.fieldApiName] = this.str;
		
		const recordInput = { fields };
		updateRecord(recordInput)
            .then(() => {
			this.error = undefined;
			this.registerNotiCache();
            })
            .catch(error => {
				this.error = error;
				console.log('Error: '+  JSON.stringify(this.error));
           });	 
	}

	registerNotiCache(){
		registerCache({app: this.lstSelected.join(';'), idNew: this.idNew })
				.then(() => {        
						this.error = undefined;
					})
					.catch(error => {
						this.error = error;
						console.log('Error: '+  JSON.stringify(this.error));
					}
				);
	}
}