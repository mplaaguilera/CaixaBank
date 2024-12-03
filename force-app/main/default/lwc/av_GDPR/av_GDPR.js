import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } 		from 'lightning/platformShowToastEvent';

//Labels
import AV_CMP_NoDataFound 		from '@salesforce/label/c.AV_CMP_NoDataFound';
import AV_CMP_ErrorMessage 		from '@salesforce/label/c.AV_CMP_ErrorMessage';

import AV_CMP_No_Admit 			from '@salesforce/label/c.AV_GDPR_NoAdmit';
import AV_CMP_No_Admit_PME		from '@salesforce/label/c.AV_GDPR_NoAdmit_PME';
import AV_CMP_Yes_Admit 		from '@salesforce/label/c.AV_GDPR_YesAdmit';
import AV_CMP_Yes_Admit_PME 	from '@salesforce/label/c.AV_GDPR_YesAdmit_PME';

import AV_GDPR_Help 			from '@salesforce/label/c.AV_GDPR_Help';
//Methods
import getTreatments 			from '@salesforce/apex/AV_GDPR_Controller.getTreatments';
import getIdFilterObject       	from '@salesforce/apex/AV_SObjectRelatedInfoCController.getIdFilterObject';

export default class Av_GDPR extends LightningElement {


	@api recordId;
	@api objectApiName;
	@api filterField;
    @api filterObject;
	@api title;
	@api icon;
	@track listConsents;
	@track hasConsents = false;
	@track viewSpinner = true;
	@track noAdmit = false;
	@track noAdmitPME = false;
	@track yesAdmit = false;
	@track yesAdmitPME = false;
	@track noDataFound = AV_CMP_NoDataFound;
	@track currenObjectName;
    @track ObjectId;
	helpText = AV_GDPR_Help;


	label = {
        AV_CMP_No_Admit,
        AV_CMP_No_Admit_PME,
        AV_CMP_Yes_Admit,
        AV_CMP_Yes_Admit_PME
    };

	


	connectedCallback() {
		this.currenObjectName = this.objectApiName;
		this.getData();
	}

	refreshCmp(){
		this.hasConsents = !this.hasConsents;
		this.viewSpinner = !this.viewSpinner;
	}
		 
	getData() {
		this.getRecId(this.recordId,this.currenObjectName,this.filterObject,this.filterField);
	}

	getTreatments() {
		getTreatments({recordId: this.ObjectId})
			.then(result => {
				if(result.severity === 'ok'){
					this.listConsents = result.listTreatments;
					this.hasConsents = true;
					this.viewSpinner = false;
					for(let cns of this.listConsents){
						switch(cns.consentContent){
							case 'NO_ADMIT':
								this.noAdmit = true;
							break;

							case 'NO_ADMIT_PME':
								this.noAdmitPME = true;
							break;

							case 'YES_ADMIT':
								this.yesAdmit = true;
							break;

							case 'YES_ADMIT_PME':
								this.yesAdmitPME = true;
							break;
						}
					}

				}else if(result.severity === 'error'){
					console.log('Display ShowToastEvent error: ' + result.descError);
					const evt = new ShowToastEvent({
						title: AV_CMP_ErrorMessage,
						message: result.descError,
						variant: result.severity
					});
					this.noDataFound = result.descError;
					this.dispatchEvent(evt);
					this.viewSpinner = false;
				} 
				else {
					console.log('Option invalid: ' + JSON.stringify(result));
					this.viewSpinner = false;
				}
			})
			.catch(error => {
				console.log('Display ShowToastEvent error (catch): ' + JSON.stringify(error));
				const evt = new ShowToastEvent({
					title: AV_CMP_ErrorMessage,
					message: JSON.stringify(error),
					variant: 'error'
				});
				this.noDataFound = JSON.stringify(error);
				this.dispatchEvent(evt);
				this.viewSpinner = false;
			});
	}
	getRecId(recordId,objectApiName,filterObject,filterField){
        if(objectApiName == filterObject){
            this.ObjectId = recordId;
            this.getTreatments();
        }else{
            getIdFilterObject({ recordId: this.recordId, objectApiName: this.objectApiName, objectFilter: this.filterObject, filterField: this.filterField  })
                .then(resultIdObject => {
                    this.ObjectId = resultIdObject;
                    if(this.ObjectId != null && this.ObjectId != undefined)  this.getTreatments();
                })
                .catch(error => {
                    console.log(error);
                    const evt = new ShowToastEvent({
                        title: AV_CMP_ErrorMessage,
                        message: JSON.stringify(error),
                        variant: 'error'
                    });
                    this.dispatchEvent(evt);
                });
        }
    }

}