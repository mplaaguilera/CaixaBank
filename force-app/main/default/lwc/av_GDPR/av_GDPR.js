import { LightningElement, track, api,wire } from 'lwc';
import { ShowToastEvent } 		from 'lightning/platformShowToastEvent';

//Labels
import AV_CMP_NoDataFound 		from '@salesforce/label/c.AV_CMP_NoDataFound';
import AV_CMP_ErrorMessage 		from '@salesforce/label/c.AV_CMP_ErrorMessage';


import AV_GDPR_Help 			from '@salesforce/label/c.AV_GDPR_Help';
import AV_SupportContact        from '@salesforce/label/c.AV_SupportCallContact';  
import AV_OnlySupportOp        from '@salesforce/label/c.AV_OnlySupportOp';  

//Methods
import getJsonAlertas        from '@salesforce/apex/AV_ClientAlerts_Controller.getJsonAlertas';  
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

	alertas =[];  
	@track alertKy21 = false 
	@track admitCall = true;

	label = {
		AV_OnlySupportOp ,  
		AV_SupportContact  

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

	
	@wire(getJsonAlertas, { recordId: '$recordId', obj: '$objectApiName' })
    wiredAlertas({ error, data }) {
        if (data) {
            this.alertas = data;
			const keys = this.alertas.map(alt => alt.key); 
			if (keys.includes("21")) {
				this.hasConsents = true;
				this.alertKy21 = true;
				this.admitCall = false;
				this.viewSpinner = false;
			} else {
				this.hasConsents = true;
				this.viewSpinner = false;
				this.admitCall = true;
			}
			
			
        } 
		else if(data == null){
			this.hasConsents =true;
			this.admitCall = true;
			this.viewSpinner = false;
		}
		else if (error) {
            console.error('Error al obtener alertas:', error);
        }
		
    }

	getRecId(recordId,objectApiName,filterObject,filterField){
        if(objectApiName == filterObject){
            this.ObjectId = recordId;
            
        }else{
            getIdFilterObject({ recordId: this.recordId, objectApiName: this.objectApiName, objectFilter: this.filterObject, filterField: this.filterField  })
                .then(resultIdObject => {
                    this.ObjectId = resultIdObject;
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