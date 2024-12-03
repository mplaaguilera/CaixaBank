import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";

// Fields
import NUMBER_EXPEDIENT_OPP from '@salesforce/schema/Opportunity.CIBE_NumberExpedient__c';
import NUMBER_EXPEDIENT_LO from '@salesforce/schema/AV_LeadOpportunity__c.AV_DossierNumber__c';


// Methods
import getUrl  from '@salesforce/apex/CIBE_OpportunitySiaButtonController.getUrl';


//Labels 
import accesoSIA from '@salesforce/label/c.CIBE_AccesoSIA';

export default class Cibe_OpportunitySiaButton extends NavigationMixin(LightningElement) {

    @api recordId;
    @api apiNameField; 

    @track numberExpedient;
    @track url;


    labels = {
        accesoSIA
    }

    @wire(getRecord, { recordId: '$recordId', fields: [NUMBER_EXPEDIENT_OPP] })
    getNumberExpedient({ error, data }){
        if(data){
            if(this.apiNameField==='CIBE_NumberExpedient__c'){
                this.numberExpedient = data.fields.CIBE_NumberExpedient__c.value;
            }else{
                this.numberExpedient = data.fields.AV_DossierNumber__c.value;
            }
        } else if(error){
            console.log(error);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [NUMBER_EXPEDIENT_LO] })
    getNumberExpedient2({ error, data }){
        if(data){
            if(this.apiNameField==='AV_DossierNumber__c'){
                this.numberExpedient = data.fields.AV_DossierNumber__c.value;
            }
        } else if(error){
            console.log(error);
        }
    }

    @wire(getUrl, { numberExpedient: '$numberExpedient' })
    getUrlSia({ error, data }){
        if(data){
            this.url = data;
        } else if(error){
            console.log(error);
        }
    }

}