import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

//Methods
import getRecInfo from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.getRecordInfo';
import retrieveListWithOutTask from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.retrieveListWithOutTask';

//Labels
import oppVinculadas from '@salesforce/label/c.CIBE_OportunidadesVinculadas';
import oppDisponibles from '@salesforce/label/c.CIBE_OportunidadesDisponiblesDelCliente';

export default class Cibe_ListOpportunitiesNewEvent extends LightningElement {

    labels = {
        oppVinculadas,
        oppDisponibles
    };
    
    @api
    get opportunities() {
        return this._opportunities;
    }

    @api recid;
    @api recordId;
    @api sobjname = 'Event';
    @track rId;
    @track recInfo;
    @track listOpp;
    @track showSpinner = false;

    @track _opportunities = [];
    @track mapOpportunities = {};

    connectedCallback() {
        this.enableSpinner();

        if(this.recid!=null){
            this.rId = this.recid;
            this.getRecordInfo(this.recid);
        }else{
            this.rId = this.recordId;
            this.getRecordInfo(this.recordId);
        }
    }

    getRecordInfo(rid){
        getRecInfo({recordId: rid, objectName: this.sobjname})
            .then(result => {
                if(result != null) {
                    this.recInfo = result;
                    this.getDataOpp(rid);
                }
            }).catch(error => {
                this.showToast('Error', error.body.message, 'error');
            }).finally(() => {
                this.disableSpinner();
            });
    }

    getDataOpp(rid) {
        retrieveListWithOutTask({listTareaOpp: this.recInfo,recordId: rid, objectName: this.sobjname})
            .then(result => {
                if(result != null) {
                    this.listOpp = result;
                }
            }).catch(error => {
                this.showToast('Error', error.body.message, 'error');
            }).finally(() => {
                this.disableSpinner();
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
        }));
    }

    refreshCmp(){
        this.enableSpinner();
        this.recInfo = [];
        this.listOpp = [];
        if(this.recid!=null){
            this.getRecordInfo(this.recid);
        }else{
            this.getRecordInfo(this.recordId);
        }
    }

    enableSpinner() {
        this.showSpinner = true;
    }

    disableSpinner() {
        this.showSpinner = false;
    }

    get isSingleOpp () {
        return (this.recInfo.length === 1);
    }

    handleDataPadre(event) {
        this.mapOpportunities[event.detail.Id] = event.detail;
        this._opportunities = Object.values(this.mapOpportunities);
        if(this._opportunities.length > 0) {
            this.dispatchEvent(
                new FlowAttributeChangeEvent(
                    'opportunities', 
                    this._opportunities
            ));
        }
    }
    
}