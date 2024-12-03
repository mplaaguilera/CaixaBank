import { LightningElement, track, wire, api} from 'lwc';
import getAlerts from '@salesforce/apex/AV_ClientAlerts_Controller.retrieveAlerts';
import { updateRecord, getRecord } from 'lightning/uiRecordApi';
import NUMPERS_FIELD from '@salesforce/schema/Account.AV_NumPerso__c';
import DATEALERT_FIELD from '@salesforce/schema/Account.AV_FechaRefrescoAlertas__c';
import JSONALERT_FIELD from '@salesforce/schema/Account.AV_JSONAlertas__c';
import alertsSectionLabel from '@salesforce/label/c.AV_CMP_AlertsSection'
 
export default class Av_Client_Alerts extends LightningElement {

    numPers;
    dateAlert;
    jsonAlert;
    alerts;
    error;
    listSize = 0;
    currentDate;

    label = {
        alertsSectionLabel
    };

    @api recordId;

    @track showAlert = false;
    @track alertsReaded = true;

    @wire(getRecord, { recordId: '$recordId', fields: [NUMPERS_FIELD, DATEALERT_FIELD, JSONALERT_FIELD] })
	wiredAccount({data,error}) {
	  if(data) {
        this.numPers = data.fields.AV_NumPerso__c.value;
        this.dateAlert = data.fields.AV_FechaRefrescoAlertas__c.value;
        this.jsonAlert = data.fields.AV_JSONAlertas__c.value;
        var dateTimeNow = new Date().toISOString();
        this.currentDate = dateTimeNow;
	  }
	  if(error) {
		this.error = error;
	  }
	}

    @wire(getAlerts, { numPerson: '$numPers', fechaRefresco: '$dateAlert', jsonBody: '$jsonAlert' })
    wiredAlerts({ error, data }) {
      
        if (data) {      
            if(data !== 'ERROR' && data !== 'UPDATED'){
                if(data!== 'EMPTY'){
                    this.alerts = JSON.parse(data);                    
                }else{
                    this.alerts = undefined;
                    data= null;                 
                }
                updateRecord({ fields: {
                    Id: this.recordId, 
                    AV_FechaRefrescoAlertas__c: this.currentDate,       
                    AV_JSONAlertas__c: data
                } })
                .then(() => {    
                    this.error = undefined;
                })
                .catch(error => {
                    console.log(error);
                    this.error = error;
                });
            }else if(data === 'UPDATED'){
                this.alerts = JSON.parse(this.jsonAlert);
                this.listSize = (this.alerts != undefined) ?this.alerts.length:0;
            }else if(data === 'ERROR'){
                this.alerts = undefined;
            }

            if(this.alerts != undefined ){
                if(this.alerts.length > 0){
                    this.listSize = this.alerts.length;
                    this.showAlert = true;
                    this.alertsReaded = false;
                }
                this.error = undefined;
            }
        } else if (error) {
            this.error = error;
            this.alerts = undefined;
        }
    }

    toggleShowAlerts() {
        if(this.listSize > 0){
            this.alertsReaded = true;
            if(this.showAlert === false){
                this.showAlert = true;
            }else{
                this.showAlert = false;
            }
        }
    }
}